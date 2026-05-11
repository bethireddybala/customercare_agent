import os
from typing import Annotated
from langchain_community.utilities import SQLDatabase
from langchain_community.agent_toolkits import SQLDatabaseToolkit
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from typing_extensions import TypedDict
from dotenv import load_dotenv


# Connecting to Postgres container
DB_URL = "postgresql://myuser:mypassword@localhost:5432/customer_care"
db = SQLDatabase.from_uri(DB_URL)

# LLM
load_dotenv()
project = os.getenv('GOOGLE_CLOUD_PROJECT')


# model
llm = ChatGoogleGenerativeAI(
    model = "gemini-2.5-flash-lite",
    vertexai = True,
    project = project
)

# Build the SQL toolkit and bind tools to the LLM
toolkit = SQLDatabaseToolkit(db=db, llm=llm)
tools   = toolkit.get_tools()           # list_tables, get_schema, query_sql, query_checker
llm_with_tools = llm.bind_tools(tools)


# LangGraph state
class AgentState(TypedDict):
    messages: Annotated[list, add_messages]


# Agent node: calls the LLM (with tools bound)
SYSTEM_PROMPT = """You are an expert SQL agent for a customer-care database.
Always look at the available tables first, inspect the relevant schema,
then write and execute a correct SQL query.
Return a clear, concise answer in plain English."""

def call_agent(state: AgentState) -> AgentState:
    from langchain_core.messages import SystemMessage
    messages = [SystemMessage(content=SYSTEM_PROMPT)] + state["messages"]
    response = llm_with_tools.invoke(messages)
    return {"messages": [response]}


# Graph
graph_builder = StateGraph(AgentState)

graph_builder.add_node("agent",  call_agent)
graph_builder.add_node("tools",  ToolNode(tools))   # executes any tool calls

graph_builder.add_edge(START, "agent")

# If the LLM returned tool calls → run them, then loop back to agent.
# If not → we're done.
graph_builder.add_conditional_edges(
    "agent",
    tools_condition,            
)
graph_builder.add_edge("tools", "agent")

agent = graph_builder.compile()


# Helper to run a natural-language query
def ask(question: str) -> str:
    from langchain_core.messages import HumanMessage
    result = agent.invoke({"messages": [HumanMessage(content=question)]})
    return result["messages"][-1].content


# Example queries
if __name__ == "__main__":
    questions = [
        "Show all tickets with critical status and assigned support agent.",
        "Which product brands have the highest number of support tickets?",
        "Show customer complaints along with product name, category, and ticket priority.",
        "Which support agents are handling the highest number of active tickets?",
        "Show all customer support tickets that have not been resolved yet.",
    ]

    for q in questions:
        print(f"\nQ: {q}")
        print(f"A: {ask(q)}")