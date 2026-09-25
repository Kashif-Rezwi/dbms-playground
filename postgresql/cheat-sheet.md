# PostgreSQL Cheat Sheet

*PG-specific* quick reference — SQL syntax lives in [`../sql/cheat-sheet.md`](../sql/cheat-sheet.md).

## psql

```text
\l  \dt  \d table  \di  \dv  \df  \dn      -- explore
\c db  \i file.sql  \e  \timing on  \x auto -- work
\?  \h UPDATE                                -- help
```

## Data types (the ones that matter)

```sql
SERIAL / GENERATED ALWAYS AS IDENTITY       -- auto ids (prefer identity)
INT, BIGINT, NUMERIC(10,2)                   -- NUMERIC for money
TEXT, VARCHAR(n)                             -- TEXT for anything
BOOLEAN, DATE, TIMESTAMP/TIMESTAMPTZ          -- TIMESTAMPTZ in real apps
JSONB, INT[], TEXT[]                          -- documents & arrays
UUID, INET, INTERVAL                          -- special-purpose
```

## Identity & sequences

```sql
CREATE TABLE t (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ...
);
CREATE SEQUENCE invoice_numbers START 1000;
NEXTVAL('invoice_numbers'), CURRVAL(''), LASTVAL();
```

## PostgreSQL indexes

```sql
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);  -- composite; order matters
CREATE UNIQUE INDEX idx_users_email ON users(lower(email));              -- expression index
CREATE INDEX idx_active_users ON users(email) WHERE is_active;           -- partial
CREATE INDEX idx_items_gin ON products(tags) USING GIN;                 -- arrays/jsonb
REINDEX TABLE orders;  DROP INDEX idx_name;
```

## EXPLAIN

```sql
EXPLAIN SELECT ...;
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;
ANALYZE orders;                    -- refresh planner statistics
```

## Transactions & isolation

```sql
BEGIN;  ...  COMMIT; / ROLLBACK;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED | REPEATABLE READ | SERIALIZABLE;
SHOW transaction_isolation;
SELECT * FROM pg_locks WHERE NOT granted;   -- who's waiting?
```

## Roles & grants

```sql
CREATE ROLE app_read LOGIN PASSWORD '...';
GRANT CONNECT ON DATABASE ecommerce TO app_read;
GRANT USAGE ON SCHEMA public TO app_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_read;
REVOKE SELECT ON users FROM app_read;
```

## Row-level security

```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY org_isolation ON projects
    USING (org_id = current_setting('app.current_org')::int);
SET app.current_org = '3';        -- per-request context
```

## Functions / triggers

```sql
CREATE FUNCTION bump_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER touch_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION bump_updated_at();
```

## Backup / restore

```bash
pg_dump -d ecommerce -Fc -f ecommerce.dump        # custom format
pg_dump -d ecommerce -f ecommerce.sql             # plain SQL
pg_restore -d ecommerce --clean ecommerce.dump
psql -d ecommerce -f ecommerce.sql
pg_dumpall > all_servers.sql                       # entire instance
```

## Maintenance

```sql
VACUUM (VERBOSE, ANALYZE) orders;   -- reclaim dead rows, refresh stats
pg_stat_user_tables;                -- bloat/seq-vs-index insights
pg_stat_statements;                 -- your slow-query finder (needs extension)
SELECT pg_size_pretty(pg_total_relation_size('big_orders'));
```

## JSONB quick hits

```sql
SELECT data->>'name', data->'tags' FROM events;
SELECT * FROM events WHERE data @> '{"type": "signup"}';
CREATE INDEX ON events USING GIN (data);
```
