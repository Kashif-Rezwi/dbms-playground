# 💼 Job Platform — ER Diagram

```mermaid
erDiagram
    companies ||--o{ jobs : "posts"
    candidates ||--o{ applications : "submits"
    jobs ||--o{ applications : "receives"
    candidates ||--o{ candidate_skills : "has"
    skills ||--o{ candidate_skills : "is known via"
    jobs ||--o{ job_skills : "requires"
    skills ||--o{ job_skills : "is required via"

    candidates {
        int id PK
        string name
        string email UK
        int experience_years
        string city
    }
    companies {
        int id PK
        string name
        string industry
        string city
        int founded_year
    }
    jobs {
        int id PK
        int company_id FK
        string title
        int salary_min
        int salary_max
        bool is_remote
        date posted_at
    }
    applications {
        int id PK
        int candidate_id FK
        int job_id FK
        string status
        date applied_at
    }
    skills {
        int id PK
        string name UK
    }
    candidate_skills {
        int candidate_id PK_FK
        int skill_id PK_FK
        string level
    }
    job_skills {
        int job_id PK_FK
        int skill_id PK_FK
        bool is_required
    }
```

**Relationships:**
- `candidates *—* jobs` — a **many-to-many** resolved by the `applications` junction table (which carries extra data: status and date).
- `candidates *—* skills` and `jobs *—* skills` — two *more* many-to-many relationships, resolved by `candidate_skills` and `job_skills`. Note these junctions carry their own data (`level`, `is_required`).
- A classic interview exercise: "find candidates whose skills match a job's required skills" — solved by joining *both* junction tables.
