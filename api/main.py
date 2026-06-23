"""FastAPI service exposing the customer-care LangGraph workflow.

Each complaint runs as a LangGraph "thread", identified by a thread_id.
A thread can pause mid-workflow when a human review is required (see
``nodes.human_review_node``); the same thread_id is then used to resume
it with a reviewer's decision via ``/complaints/{thread_id}/review``.

Run locally with:

    uv run uvicorn api.main:app --reload --port 8000
"""

import uuid
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, HTTPException
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import Command
from langgraph_cli import schemas

from agent_graph import build_customer_care_graph
from api.schemas import ComplaintRequest, ComplaintResponse, ReviewDecisionRequest

# A single in-memory checkpointer shared by the app's lifetime.
# Swap this for a persistent checkpointer (e.g. PostgresSaver) in production
# so pending human-review threads survive a server restart.
checkpointer = MemorySaver()
compiled_graph = build_customer_care_graph(checkpointer=checkpointer)


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(
    title="Customer Care Agent API",
    description="HTTP interface for the LangGraph-based customer care workflow.",
    version="1.0.0",
    lifespan=lifespan,
)


def _config_for(thread_id: str) -> dict[str, Any]:
    return {"configurable": {"thread_id": thread_id}}


def _to_response(thread_id: str, result: dict[str, Any]) -> ComplaintResponse:
    """Convert a raw graph state dict into the API response shape."""
    interrupts = result.get("__interrupt__")
    if interrupts:
        payload = getattr(interrupts[0], "value", interrupts[0])
        return ComplaintResponse(
            thread_id=thread_id,
            status="pending_human_review",
            review_payload=payload,
        )

    return ComplaintResponse(
        thread_id=thread_id,
        status="completed",
        response=result.get("response"),
        category=result.get("category"),
        priority=result.get("priority"),
        ticket_ref=result.get("ticket_ref"),
        assigned_agent_email=result.get("assigned_agent_email"),
    )


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/complaints", response_model=ComplaintResponse)
def create_complaint(payload: ComplaintRequest) -> ComplaintResponse:
    """Submit a new customer complaint and run the workflow.

    Returns immediately with either the final response (``completed``)
    or, for serious/escalated complaints, a ``pending_human_review``
    status containing the context a reviewer needs.
    """
    thread_id = str(uuid.uuid4())

    initial_state = {
        "complaint_text": payload.complaint_text,
        "customer_name": payload.customer_name,
        "customer_email": payload.customer_email,
        "product_name": payload.product_name,
        "channel": payload.channel,
    }

    result = compiled_graph.invoke(initial_state, config=_config_for(thread_id))
    return _to_response(thread_id, result)


@app.get("/complaints/{thread_id}", response_model=ComplaintResponse)
def get_complaint(thread_id: str) -> ComplaintResponse:
    """Fetch the current state of a complaint thread."""
    snapshot = compiled_graph.get_state(_config_for(thread_id))
    if not snapshot.values:
        raise HTTPException(status_code=404, detail="Unknown thread_id")

    if snapshot.next:
        # Workflow is paused (e.g. awaiting human review).
        payload = None
        if snapshot.interrupts:
            payload = snapshot.interrupts[0].value
        return ComplaintResponse(
            thread_id=thread_id, status="pending_human_review", review_payload=payload
        )

    return _to_response(thread_id, snapshot.values)


@app.post("/complaints/{thread_id}/review", response_model=ComplaintResponse)
def review_complaint(thread_id: str, payload: ReviewDecisionRequest) -> ComplaintResponse:
    """Resume a paused workflow with a human reviewer's decision."""
    snapshot = compiled_graph.get_state(_config_for(thread_id))
    if not snapshot.values:
        raise HTTPException(status_code=404, detail="Unknown thread_id")
    if not snapshot.next:
        raise HTTPException(status_code=409, detail="This thread is not awaiting review")

    result = compiled_graph.invoke(
        Command(resume={"decision": payload.decision, "comments": payload.comments}),
        config=_config_for(thread_id),
    )
    return _to_response(thread_id, result)