# psql Survival Guide — the 20 commands that carry the track

`psql` is PostgreSQL's command-line client. All lessons assume it. Learn these and you'll never feel lost.

## Getting in and out

```text
psql -d ecommerce        # connect to a local database
psql -h host -U me -d db  # connect over the network
\q                       # quit
```

## Finding things (meta-commands start with \ — they're NOT SQL)

```text
\l               -- list databases
\c social        -- connect to another database
\dt              -- list tables in the current schema
\dt public.*     -- be explicit about schema
\d orders        -- describe a table: columns, types, constraints, indexes
\d+ orders       -- ...plus storage info
\di              -- list indexes
\dv              -- list views
\df              -- list functions
\dn              -- list schemas
```

## Running things

```text
\i file.sql              -- run a file of SQL
\e                       -- edit the last query in $EDITOR (Vim/VS Code!)
\p                       -- show current query buffer
\r                       -- reset the buffer
\timing on               -- show query execution times (leave ON)
\x on                    -- rotated output for wide rows (auto: \x auto)
\watch 5                 -- re-run the last query every 5s
```

## Formatting

```text
\pset null '∅'           -- make NULLs visible in output!
\pset pager off          -- stop the pager stealing your scrollback
\x auto                 -- wide rows automatically rotate
```

## Getting help

```text
\?                       -- all meta-commands
\h UPDATE                -- SQL syntax help for a statement
```

## Your daily driver patterns

```sql
-- multi-line queries just work; end with ;
SELECT u.name, COUNT(o.id)
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.name;

-- run one-off scripts:
-- psql -d ecommerce -f my_queries.sql
```

## Suggested `.psqlrc` (optional)

Create `~/.psqlrc` with:

```text
\timing on
\pset null '∅'
\x auto
\pset pager off
```

Every session starts ready to learn. (If queries start behaving oddly, suspect this file.)

**That's it. Everything else in the track is SQL.**
