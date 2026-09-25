# 🛒 E-Commerce — ER Diagram

```mermaid
erDiagram
    users ||--o{ orders : "places"
    categories ||--o{ products : "contains"
    orders ||--o{ order_items : "contains"
    products ||--o{ order_items : "appears in"
    orders ||--o| payments : "is paid by"
    products ||--o{ reviews : "receives"
    users ||--o{ reviews : "writes"

    users {
        int id PK
        string name
        string email UK
        string city
        bool is_active
        date joined_at
    }
    categories {
        int id PK
        string name
    }
    products {
        int id PK
        string name
        int category_id FK
        numeric price
        int stock
        date created_at
    }
    orders {
        int id PK
        int user_id FK
        string status
        numeric total_amount
        date ordered_at
    }
    order_items {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        numeric unit_price
    }
    payments {
        int id PK
        int order_id FK "UNIQUE - one payment per order"
        string method
        numeric amount
        date paid_at
    }
    reviews {
        int id PK
        int product_id FK
        int user_id FK
        int rating
        string comment
        date created_at
    }
```

**Relationships:**
- `users 1—* orders` (one-to-many: a user places many orders)
- `orders 1—* order_items` (an order contains many items — the classic "line item" pattern)
- `products 1—* order_items` (a product appears in many orders — many-to-many between orders & products, resolved by order_items)
- `orders 1—0..1 payments` (one-to-optional-one: pending/cancelled orders may have no payment)
