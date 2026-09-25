# SaaS Platform — ER Diagram

```mermaid
erDiagram
    organizations ||--o{ users : "employs"
    organizations ||--o{ projects : "runs"
    organizations ||--o| subscriptions : "subscribes"
    organizations ||--o{ invoices : "is billed"
    projects ||--o{ tasks : "contains"
    users ||--o{ tasks : "is assigned"
    subscriptions ||--o{ invoices : "generates"

    organizations {
        int id PK
        string name
        string plan
        date created_at
    }
    users {
        int id PK
        int org_id FK
        string name
        string email UK
        string role
    }
    projects {
        int id PK
        int org_id FK
        string name
        string status
        date deadline
    }
    tasks {
        int id PK
        int project_id FK
        int assignee_id FK "nullable - unassigned tasks"
        string title
        string status
        string priority
        date created_at
        date completed_at
    }
    subscriptions {
        int id PK
        int org_id FK "UNIQUE - one subscription per org"
        string plan
        int seats
        date started_at
        date renews_at
    }
    invoices {
        int id PK
        int org_id FK
        int subscription_id FK
        numeric amount
        string status
        date issued_at
    }
```

**Relationships:**
- `organizations 1—0..1 subscriptions` — one-to-one (each org has at most one active subscription; free plans have `renews_at = NULL`).
- `tasks.assignee_id` is **nullable** — the NULL here means "unassigned", a real-world design decision you'll explore in Day 7.
- `invoices` links to *both* the org and the subscription — redundant-looking, but each link answers a different common query.
