"""Request/response models for the Customer Care Agent API."""

from typing import Any, Literal, Optional
from pydantic import BaseModel, Field


class ComplaintRequest(BaseModel):
    """Payload submitted when a customer raises a new complaint."""

    complaint_text: str = Field(..., min_length=1, description="The customer's complaint, in their own words.")
    customer_name: Optional[str] = None
    customer_email: Optional[str] = None
    product_name: Optional[str] = Field(
        default=None, description="Product name or hint, if the customer provided one."
    )
    channel: Literal["email", "phone", "chat", "in_store", "social_media"] = "chat"


class ReviewDecisionRequest(BaseModel):
    """Payload submitted by a human reviewer to resume a paused workflow."""

    decision: Literal["approve", "reject"] = Field(
        ..., description="Reviewer's decision on the escalated complaint."
    )
    comments: Optional[str] = None


class ComplaintResponse(BaseModel):
    """Response returned after running (or resuming) the workflow."""

    thread_id: str
    status: Literal["completed", "pending_human_review"]
    response: Optional[str] = None
    category: Optional[str] = None
    priority: Optional[str] = None
    ticket_ref: Optional[str] = None
    assigned_agent_email: Optional[str] = None
    review_payload: Optional[dict[str, Any]] = Field(
        default=None,
        description="Present only when status is 'pending_human_review'. "
        "Contains the context a reviewer needs to approve or reject the case.",
    )