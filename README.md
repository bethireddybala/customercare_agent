# Customer Care Agent

An **Agentic AI customer support system** that understands customer complaints in natural language, looks up the customer-care database for known issues, classifies and prioritizes the problem, and automatically creates a support ticket — escalating to a human reviewer for serious cases.

It combines **LangGraph** (workflow orchestration), **LangChain** (SQL agent tooling), **Google Gemini** (via Vertex AI), and a **PostgreSQL** customer-support database with 50+ products, multi-tier support agents, tickets, and resolutions.

## How it works

The core of the project is a LangGraph state machine (`agent_graph.py`) that routes a complaint through the following stages:

```mermaid
flowchart TD
    A[understand_complaint] --> B[sql_knowledge]
    B --> C[classify_complaint]
    C --> D[decide_next_action]
    D -->|known_resolution| E[known_resolution_response]
    D -->|create_ticket| F[create_ticket]
    D -->|human_review| G[human_review]
    G --> F
    F --> H[ticket_created_response]
    E --> I[END]
    H --> I[END]
```

1. **understand_complaint** – summarizes the complaint and notes any product hint.
2. **sql_knowledge** – a read-only LangChain SQL agent (`sql_agent_service.py`) queries the database for matching products, similar resolved tickets, and known resolutions.
3. **classify_complaint** – rule-based classification into a category (e.g. `product_defect`, `billing`, `shipping_damage`) and a priority (`low` → `critical`), flagging escalation for serious language (legal threats, repeated complaints, fraud, etc.).
4. **decide_next_action** – routes to one of three branches:
   - **known_resolution** – a matching resolved issue exists, so the customer is answered immediately.
   - **create_ticket** – no known fix, so a new ticket is opened.
   - **human_review** – critical/escalation cases pause the graph (via LangGraph `interrupt`) for a human decision before a ticket is created.
5. **create_ticket** – a deterministic, parameterized repository (`ticket_repository.py`) resolves the customer, product, and an appropriate support agent (Tier 1, Tier 2, or Escalations) and inserts the ticket — the LLM never writes to the database directly.
6. A final customer-facing response is generated and returned.

## Features

- Natural-language customer complaint intake with automatic understanding and summarization
- Read-only natural-language-to-SQL querying against the support database
- Rule-based issue classification and priority/SLA assignment
- Automatic matching against known issues and previously resolved tickets
- Safe, parameterized ticket creation (LLM is never given write access)
- Multi-tier agent routing (Tier 1, Tier 2, Escalations) based on category and priority
- Human-in-the-loop review for critical/escalated complaints using LangGraph interrupts
- Electronics product catalog with 50+ products across 12 categories
- Dashboard-ready SQL views for agent performance, ticket overview, and resolution summaries
- Docker-based Postgres + pgAdmin setup for local development

## Tech stack

| Layer | Technology |
|---|---|
| Agent orchestration | [LangGraph](https://github.com/langchain-ai/langgraph) |
| LLM tooling / SQL agent | [LangChain](https://github.com/langchain-ai/langchain) |
| LLM | Google Gemini (`gemini-2.5-flash-lite`) via Vertex AI |
| Database | PostgreSQL 16 |
| DB access | SQLAlchemy |
| DB admin UI | pgAdmin 4 |
| Package management | [uv](https://github.com/astral-sh/uv) |
| Language | Python 3.14 |

## Project structure

```
customercare_agent/
├── agent_graph.py          # Builds and compiles the LangGraph customer-care workflow
├── nodes.py                # Workflow node implementations (understand, classify, route, etc.)
├── state.py                # CustomerCareState TypedDict shared across graph nodes
├── sql_agent_service.py     # Read-only LangChain SQL agent used for knowledge lookups
├── ticket_repository.py    # Safe, parameterized ticket creation and agent/customer lookups
├── database.py             # SQLAlchemy engine and query helpers
├── utils.py                 # LLM, database, and SQL-toolkit factory helpers
├── agent.py                 # Standalone example: a generic LangGraph + SQL-toolkit agent
├── main.py                  # Placeholder entry point
├── testing.py               # Small script for verifying .env / API key loading
├── langgraph.json           # LangGraph CLI config (exposes "agent-graph")
├── docker-compose.yml       # Postgres + pgAdmin services
├── servers.json / pgpass    # pgAdmin server registration for the Postgres container
├── customercaredb/
│   └── init.sql              # Full schema, sample data, and SQL views
├── pyproject.toml / uv.lock # Project dependencies (managed with uv)
└── .python-version           # Python version pin (3.14)
```

## Database schema

`customercaredb/init.sql` provisions the following on container start:

**Tables**
- `products` – 50+ product catalog (TVs, laptops, phones, audio, wearables, cameras, etc.)
- `customers`
- `agents` – support agents grouped by department (Tier 1, Tier 2, Escalations, QA, Management)
- `ticket_categories` – categories with SLA hours
- `ticket_statuses`
- `tickets`
- `resolutions`
- `ticket_comments`

**Views**
- `v_product_catalog`
- `v_ticket_overview`
- `v_resolution_summary`
- `v_agent_performance`

## Getting started

### Prerequisites

- Python 3.14+
- [uv](https://docs.astral.sh/uv/) for dependency management
- Docker and Docker Compose (for PostgreSQL + pgAdmin)
- A Google Cloud project with the Vertex AI API enabled, and credentials available locally (e.g. `gcloud auth application-default login`)

### 1. Clone the repository

```bash
git clone https://github.com/bethireddybala/customercare_agent.git
cd customercare_agent
```

### 2. Install dependencies

```bash
uv sync
```

### 3. Configure environment variables

Create a `.env` file in the project root:

```env
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
DATABASE_URL=postgresql://myuser:mypassword@localhost:5432/customer_care
MODEL_NAME=gemini-2.5-flash-lite
# Optional, for LangSmith tracing used by testing.py
LANGCHAIN_API_KEY=your-langsmith-key
```

### 4. Start the database

```bash
docker compose up -d
```

This starts:
- **PostgreSQL** on `localhost:5432`, auto-initialized from `customercaredb/init.sql`
- **pgAdmin** on `localhost:5050` (login: `admin@admin.com` / `admin`), pre-configured to connect to the `customer_care` database

### 5. Run the workflow

The compiled LangGraph graph is exposed as `agent-graph` in `langgraph.json`. Start the LangGraph dev server and Studio UI with:

```bash
uv run langgraph dev
```

Alternatively, exercise the read-only SQL agent directly:

```bash
uv run python sql_agent_service.py
```

or the standalone example SQL-toolkit agent:

```bash
uv run python agent.py
```

## Example questions the SQL agent can answer

- "Show all tickets with critical status and assigned support agent."
- "Which product brands have the highest number of support tickets?"
- "Show customer complaints along with product name, category, and ticket priority."
- "Which support agents are handling the highest number of active tickets?"
- "Show all customer support tickets that have not been resolved yet."

## Notes

- The SQL agent is restricted by its system prompt to `SELECT`-only queries; all ticket writes go through the deterministic functions in `ticket_repository.py`.
- `human_review_node` uses LangGraph's `interrupt()`, so the graph pauses and persists state until resumed with a human `decision` and `comments` — this requires running the graph with a checkpointer (the default when using `langgraph dev`).
- `main.py` is currently a placeholder and is not wired into the workflow.

## License

No license has been specified for this repository.
