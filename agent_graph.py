"""LangGraph workflow definition for the customer care agent.

This module defines the customer care workflow as a LangGraph state
machine. The workflow coordinates complaint understanding, knowledge
retrieval, classification, ticket creation, human review, and response
generation.

The compiled graph is exposed as a module-level variable and can be
invoked by application services to process customer support requests.
"""

from langgraph.graph import StateGraph, START, END

from state import CustomerCareState
from nodes import (
    classify_complaint,
    create_ticket_node,
    decide_next_action,
    human_review_node,
    known_resolution_response_node,
    route_after_decision,
    sql_knowledge_node,
    ticket_created_response_node,
    understand_complaint,
)


def build_customer_care_graph(checkpointer=None):
    """Build and compile the customer care workflow graph.

    The workflow performs the following high-level steps:

    1. Understand the customer complaint.
    2. Retrieve relevant information from the database.
    3. Classify the issue and determine priority.
    4. Decide the next workflow action.
    5. Route to resolution, ticket creation, or human review.
    6. Generate a final customer-facing response.

    Args:
        checkpointer: Optional LangGraph checkpointer used to persist
            state between invocations. Required for the human-review
            interrupt to be resumable across separate calls (e.g. from
            an API server). Defaults to ``None``, which keeps the
            previous behaviour for ``langgraph dev`` / LangGraph
            Platform, which provide their own persistence layer.

    Returns:
        CompiledStateGraph: Compiled LangGraph workflow ready for
            execution.
    """
    builder = StateGraph(CustomerCareState)

    builder.add_node("understand_complaint", understand_complaint)
    builder.add_node("sql_knowledge", sql_knowledge_node)
    builder.add_node("classify_complaint", classify_complaint)
    builder.add_node("decide_next_action", decide_next_action)

    builder.add_node("known_resolution_response",known_resolution_response_node)
    builder.add_node("create_ticket", create_ticket_node)
    builder.add_node("human_review", human_review_node)
    builder.add_node("ticket_created_response",ticket_created_response_node)

    builder.add_edge(START, "understand_complaint")
    builder.add_edge("understand_complaint", "sql_knowledge")
    builder.add_edge("sql_knowledge", "classify_complaint")

    builder.add_conditional_edges(
        "decide_next_action",
        route_after_decision,
        {
            "known_resolution": "known_resolution_response",
            "create_ticket": "create_ticket",
            "human_review": "human_review",
        },
    )

    builder.add_edge("known_resolution_response", END)
    builder.add_edge("create_ticket", "ticket_created_response")
    builder.add_edge("ticket_created_response", END)
    builder.add_edge("human_review", "create_ticket")
    return builder.compile(checkpointer=checkpointer)


graph = build_customer_care_graph()