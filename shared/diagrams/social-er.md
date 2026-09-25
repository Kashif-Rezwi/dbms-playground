# 💬 Social Platform — ER Diagram

```mermaid
erDiagram
    users ||--o{ posts : "writes"
    users ||--o{ comments : "writes"
    users ||--o{ likes : "likes"
    users ||--o{ followers : "follows (as follower)"
    users ||--o{ followers : "is followed (as followed)"
    users ||--o{ messages : "sends"
    posts ||--o{ comments : "receives"
    posts ||--o{ likes : "receives"

    users {
        int id PK
        string username UK
        string email UK
        string bio
        date joined_at
    }
    posts {
        int id PK
        int user_id FK
        string content
        date created_at
    }
    comments {
        int id PK
        int post_id FK
        int user_id FK
        string content
        date created_at
    }
    likes {
        int user_id PK_FK
        int post_id PK_FK
        date liked_at
    }
    followers {
        int follower_id PK_FK
        int followed_id PK_FK
        date followed_at
    }
    messages {
        int id PK
        int sender_id FK
        int receiver_id FK
        string body
        date sent_at
        bool is_read
    }
```

**Relationships:**
- `likes` and `followers` use **composite primary keys** — a like is identified by (user, post) together; no single column would be unique on its own.
- `followers` is a **self-referencing many-to-many**: both sides of the relationship are users. (The `follower_id <> followed_id` CHECK prevents following yourself.)
- `messages` references `users` **twice** (sender and receiver) — you'll need table aliases to join it.
