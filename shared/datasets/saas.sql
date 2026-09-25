-- ============================================================
-- SAAS dataset (small) — dbms-playground
-- Load:  ./scripts/seed/seed-postgres.sh saas
-- Tables: organizations, users, projects, tasks,
--         subscriptions, invoices
-- ============================================================

BEGIN;

DROP TABLE IF EXISTS invoices, subscriptions, tasks, projects, users, organizations CASCADE;

CREATE TABLE organizations (
    id          INT PRIMARY KEY,
    name        TEXT NOT NULL,
    plan        TEXT NOT NULL DEFAULT 'free',   -- free|pro|enterprise
    created_at  DATE
);

CREATE TABLE users (
    id       INT PRIMARY KEY,
    org_id   INT NOT NULL REFERENCES organizations(id),
    name     TEXT NOT NULL,
    email    TEXT NOT NULL UNIQUE,
    role     TEXT NOT NULL DEFAULT 'member'     -- admin|member|viewer
);

CREATE TABLE projects (
    id         INT PRIMARY KEY,
    org_id     INT NOT NULL REFERENCES organizations(id),
    name       TEXT NOT NULL,
    status     TEXT NOT NULL DEFAULT 'active', -- active|paused|done
    deadline   DATE
);

CREATE TABLE tasks (
    id            INT PRIMARY KEY,
    project_id    INT NOT NULL REFERENCES projects(id),
    assignee_id   INT REFERENCES users(id),     -- NULL = unassigned
    title         TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'todo', -- todo|doing|done
    priority      TEXT NOT NULL DEFAULT 'medium',
    created_at    DATE,
    completed_at  DATE
);

CREATE TABLE subscriptions (
    id          INT PRIMARY KEY,
    org_id      INT NOT NULL UNIQUE REFERENCES organizations(id),
    plan        TEXT NOT NULL,
    seats       INT NOT NULL DEFAULT 1,
    started_at  DATE,
    renews_at   DATE
);

CREATE TABLE invoices (
    id              INT PRIMARY KEY,
    org_id          INT NOT NULL REFERENCES organizations(id),
    subscription_id INT NOT NULL REFERENCES subscriptions(id),
    amount          NUMERIC(10,2) NOT NULL,
    status          TEXT NOT NULL DEFAULT 'open',  -- paid|open|overdue
    issued_at       DATE
);

INSERT INTO organizations (id, name, plan, created_at) VALUES
    (1, 'Acme Studio',      'pro',        '2024-01-05'),
    (2, 'BrightLabs',       'free',       '2024-02-18'),
    (3, 'Cobalt Systems',   'enterprise', '2023-11-02'),
    (4, 'Dune Digital',     'pro',        '2024-03-25'),
    (5, 'Everlytics',       'free',       '2024-05-12'),
    (6, 'Frostbyte',        'pro',        '2024-06-08');

INSERT INTO users (id, org_id, name, email, role) VALUES
    (1,  1, 'Ayesha Khan',   'ayesha@acme.dev',     'admin'),
    (2,  1, 'Bilal Ahmed',   'bilal@acme.dev',      'member'),
    (3,  1, 'Chen Wei',      'chen@acme.dev',       'member'),
    (4,  2, 'Dua Malik',     'dua@brightlabs.dev',  'admin'),
    (5,  3, 'Emre Yilmaz',   'emre@cobalt.dev',     'admin'),
    (6,  3, 'Farah Ali',     'farah@cobalt.dev',    'member'),
    (7,  4, 'Grace Okafor',  'grace@dune.dev',      'admin'),
    (8,  4, 'Hassan Raza',   'hassan@dune.dev',     'viewer'),
    (9,  5, 'Ivy Santos',    'ivy@everlytics.dev',  'admin'),
    (10, 6, 'Junaid Sheikh', 'junaid@frostbyte.dev','admin');

INSERT INTO projects (id, org_id, name, status, deadline) VALUES
    (1, 1, 'Website Redesign',      'done',    '2025-01-31'),
    (2, 1, 'Mobile App v2',         'active',  '2025-12-15'),
    (3, 2, 'Landing Page',           'active',  '2025-10-01'),
    (4, 3, 'Data Warehouse',         'active',  '2026-03-01'),
    (5, 3, 'Billing Migration',      'paused',  NULL),
    (6, 4, 'Marketing Site',        'done',    '2025-06-30'),
    (7, 4, 'Customer Portal',        'active',  '2026-01-20'),
    (8, 6, 'Analytics Dashboard',    'active',  '2025-11-05');

INSERT INTO tasks (id, project_id, assignee_id, title, status, priority, created_at, completed_at) VALUES
    (1,  1, 2, 'Design homepage mockups',        'done',  'medium', '2024-11-01', '2024-11-20'),
    (2,  1, 3, 'Implement navigation component', 'done',  'high',   '2024-11-05', '2024-12-02'),
    (3,  1, 1, 'QA review',                      'done',  'high',   '2024-12-10', '2025-01-28'),
    (4,  2, 2, 'Set up CI pipeline',              'done',  'high',   '2025-02-01', '2025-02-15'),
    (5,  2, 3, 'Offline mode prototype',          'doing', 'medium', '2025-03-01', NULL),
    (6,  2, NULL, 'Push notification research',   'todo',  'low',    '2025-04-10', NULL),
    (7,  2, 1, 'Beta release checklist',          'todo',  'high',   '2025-05-01', NULL),
    (8,  3, 4, 'Copy writing',                    'doing', 'medium', '2025-06-01', NULL),
    (9,  3, NULL, 'SEO audit',                    'todo',  'low',    '2025-06-15', NULL),
    (10, 4, 5, 'Model star schema',               'done',  'high',   '2025-01-10', '2025-02-28'),
    (11, 4, 6, 'Build ETL for orders',            'doing', 'high',   '2025-03-01', NULL),
    (12, 4, 5, 'Historical backfill',             'todo',  'medium', '2025-04-01', NULL),
    (13, 5, 6, 'Map legacy fields',               'todo',  'medium', '2025-01-15', NULL),
    (14, 6, 7, 'Wire up forms',                   'done',  'medium', '2025-03-01', '2025-05-20'),
    (15, 6, 8, 'Accessibility pass',              'done',  'low',    '2025-05-01', '2025-06-25'),
    (16, 7, 7, 'Auth screens',                   'doing', 'high',   '2025-06-20', NULL),
    (17, 7, NULL, 'Usage report page',            'todo',  'medium', '2025-07-01', NULL),
    (18, 8, 10, 'Chart library spike',            'done',  'low',    '2025-07-01', '2025-07-15'),
    (19, 8, 10, 'SQL for KPI tiles',              'doing', 'high',   '2025-07-16', NULL),
    (20, 8, NULL, 'Export to CSV button',         'todo',  'low',    '2025-08-01', NULL);

INSERT INTO subscriptions (id, org_id, plan, seats, started_at, renews_at) VALUES
    (1, 1, 'pro',        5,  '2024-01-05', '2026-01-05'),
    (2, 2, 'free',       3,  '2024-02-18', NULL),
    (3, 3, 'enterprise', 50, '2023-11-02', '2025-11-02'),
    (4, 4, 'pro',        8,  '2024-03-25', '2026-03-25'),
    (5, 5, 'free',       2,  '2024-05-12', NULL),
    (6, 6, 'pro',        6,  '2024-06-08', '2026-06-08');

INSERT INTO invoices (id, org_id, subscription_id, amount, status, issued_at) VALUES
    (1,  1, 1, 49.00,   'paid',    '2025-01-05'),
    (2,  1, 1, 49.00,   'paid',    '2025-02-05'),
    (3,  1, 1, 49.00,   'open',    '2025-09-05'),
    (4,  3, 3, 1200.00, 'paid',    '2024-11-02'),
    (5,  3, 3, 1200.00, 'paid',    '2025-05-02'),
    (6,  3, 3, 1200.00, 'overdue', '2025-08-02'),
    (7,  4, 4, 79.00,   'paid',    '2025-03-25'),
    (8,  4, 4, 79.00,   'open',    '2025-09-25'),
    (9,  6, 6, 59.00,   'paid',    '2025-06-08'),
    (10, 6, 6, 59.00,   'overdue', '2025-09-08');

COMMIT;

-- Sanity check: organizations 6 | users 10 | projects 8 | tasks 20 | subscriptions 6 | invoices 10

