// ============================================================
// SAAS dataset (small) — MongoDB seed
// Load:  ./scripts/seed/seed-mongo.sh saas
// Collections: organizations, users, projects, tasks,
//               subscriptions, invoices
// ============================================================

db = db.getSiblingDB('saas');
db.dropDatabase();

db.organizations.insertMany([
  { _id: 1, name: 'Acme Studio',    plan: 'pro',        created_at: ISODate('2024-01-05') },
  { _id: 2, name: 'BrightLabs',    plan: 'free',       created_at: ISODate('2024-02-18') },
  { _id: 3, name: 'Cobalt Systems', plan: 'enterprise', created_at: ISODate('2023-11-02') },
  { _id: 4, name: 'Dune Digital',  plan: 'pro',        created_at: ISODate('2024-03-25') },
  { _id: 5, name: 'Everlytics',    plan: 'free',       created_at: ISODate('2024-05-12') },
  { _id: 6, name: 'Frostbyte',     plan: 'pro',        created_at: ISODate('2024-06-08') }
]);

db.users.insertMany([
  { _id: 1, org_id: 1, name: 'Ayesha Khan', email: 'ayesha@acme.dev', role: 'admin' },
  { _id: 2, org_id: 1, name: 'Bilal Ahmed', email: 'bilal@acme.dev', role: 'member' },
  { _id: 3, org_id: 1, name: 'Chen Wei', email: 'chen@acme.dev', role: 'member' },
  { _id: 4, org_id: 2, name: 'Dua Malik', email: 'dua@brightlabs.dev', role: 'admin' },
  { _id: 5, org_id: 3, name: 'Emre Yilmaz', email: 'emre@cobalt.dev', role: 'admin' },
  { _id: 6, org_id: 3, name: 'Farah Ali', email: 'farah@cobalt.dev', role: 'member' },
  { _id: 7, org_id: 4, name: 'Grace Okafor', email: 'grace@dune.dev', role: 'admin' },
  { _id: 8, org_id: 4, name: 'Hassan Raza', email: 'hassan@dune.dev', role: 'viewer' },
  { _id: 9, org_id: 5, name: 'Ivy Santos', email: 'ivy@everlytics.dev', role: 'admin' },
  { _id: 10, org_id: 6, name: 'Junaid Sheikh', email: 'junaid@frostbyte.dev', role: 'admin' }
]);

db.projects.insertMany([
  { _id: 1, org_id: 1, name: 'Website Redesign', status: 'done', deadline: ISODate('2025-01-31') },
  { _id: 2, org_id: 1, name: 'Mobile App v2', status: 'active', deadline: ISODate('2025-12-15') },
  { _id: 3, org_id: 2, name: 'Landing Page', status: 'active', deadline: ISODate('2025-10-01') },
  { _id: 4, org_id: 3, name: 'Data Warehouse', status: 'active', deadline: ISODate('2026-03-01') },
  { _id: 5, org_id: 3, name: 'Billing Migration', status: 'paused', deadline: null },
  { _id: 6, org_id: 4, name: 'Marketing Site', status: 'done', deadline: ISODate('2025-06-30') },
  { _id: 7, org_id: 4, name: 'Customer Portal', status: 'active', deadline: ISODate('2026-01-20') },
  { _id: 8, org_id: 6, name: 'Analytics Dashboard', status: 'active', deadline: ISODate('2025-11-05') }
]);

db.tasks.insertMany([
  { _id: 1, project_id: 1, assignee_id: 2, title: 'Design homepage mockups', status: 'done', priority: 'medium', created_at: ISODate('2024-11-01'), completed_at: ISODate('2024-11-20') },
  { _id: 2, project_id: 1, assignee_id: 3, title: 'Implement navigation component', status: 'done', priority: 'high', created_at: ISODate('2024-11-05'), completed_at: ISODate('2024-12-02') },
  { _id: 3, project_id: 1, assignee_id: 1, title: 'QA review', status: 'done', priority: 'high', created_at: ISODate('2024-12-10'), completed_at: ISODate('2025-01-28') },
  { _id: 4, project_id: 2, assignee_id: 2, title: 'Set up CI pipeline', status: 'done', priority: 'high', created_at: ISODate('2025-02-01'), completed_at: ISODate('2025-02-15') },
  { _id: 5, project_id: 2, assignee_id: 3, title: 'Offline mode prototype', status: 'doing', priority: 'medium', created_at: ISODate('2025-03-01'), completed_at: null },
  { _id: 6, project_id: 2, assignee_id: null, title: 'Push notification research', status: 'todo', priority: 'low', created_at: ISODate('2025-04-10'), completed_at: null },
  { _id: 7, project_id: 2, assignee_id: 1, title: 'Beta release checklist', status: 'todo', priority: 'high', created_at: ISODate('2025-05-01'), completed_at: null },
  { _id: 8, project_id: 3, assignee_id: 4, title: 'Copy writing', status: 'doing', priority: 'medium', created_at: ISODate('2025-06-01'), completed_at: null },
  { _id: 9, project_id: 3, assignee_id: null, title: 'SEO audit', status: 'todo', priority: 'low', created_at: ISODate('2025-06-15'), completed_at: null },
  { _id: 10, project_id: 4, assignee_id: 5, title: 'Model star schema', status: 'done', priority: 'high', created_at: ISODate('2025-01-10'), completed_at: ISODate('2025-02-28') }
]);

db.tasks.insertMany([
  { _id: 11, project_id: 4, assignee_id: 6, title: 'Build ETL for orders', status: 'doing', priority: 'high', created_at: ISODate('2025-03-01'), completed_at: null },
  { _id: 12, project_id: 4, assignee_id: 5, title: 'Historical backfill', status: 'todo', priority: 'medium', created_at: ISODate('2025-04-01'), completed_at: null },
  { _id: 13, project_id: 5, assignee_id: 6, title: 'Map legacy fields', status: 'todo', priority: 'medium', created_at: ISODate('2025-01-15'), completed_at: null },
  { _id: 14, project_id: 6, assignee_id: 7, title: 'Wire up forms', status: 'done', priority: 'medium', created_at: ISODate('2025-03-01'), completed_at: ISODate('2025-05-20') },
  { _id: 15, project_id: 6, assignee_id: 8, title: 'Accessibility pass', status: 'done', priority: 'low', created_at: ISODate('2025-05-01'), completed_at: ISODate('2025-06-25') },
  { _id: 16, project_id: 7, assignee_id: 7, title: 'Auth screens', status: 'doing', priority: 'high', created_at: ISODate('2025-06-20'), completed_at: null },
  { _id: 17, project_id: 7, assignee_id: null, title: 'Usage report page', status: 'todo', priority: 'medium', created_at: ISODate('2025-07-01'), completed_at: null },
  { _id: 18, project_id: 8, assignee_id: 10, title: 'Chart library spike', status: 'done', priority: 'low', created_at: ISODate('2025-07-01'), completed_at: ISODate('2025-07-15') },
  { _id: 19, project_id: 8, assignee_id: 10, title: 'SQL for KPI tiles', status: 'doing', priority: 'high', created_at: ISODate('2025-07-16'), completed_at: null },
  { _id: 20, project_id: 8, assignee_id: null, title: 'Export to CSV button', status: 'todo', priority: 'low', created_at: ISODate('2025-08-01'), completed_at: null }
]);

db.subscriptions.insertMany([
  { _id: 1, org_id: 1, plan: 'pro', seats: 5, started_at: ISODate('2024-01-05'), renews_at: ISODate('2026-01-05') },
  { _id: 2, org_id: 2, plan: 'free', seats: 3, started_at: ISODate('2024-02-18'), renews_at: null },
  { _id: 3, org_id: 3, plan: 'enterprise', seats: 50, started_at: ISODate('2023-11-02'), renews_at: ISODate('2025-11-02') },
  { _id: 4, org_id: 4, plan: 'pro', seats: 8, started_at: ISODate('2024-03-25'), renews_at: ISODate('2026-03-25') },
  { _id: 5, org_id: 5, plan: 'free', seats: 2, started_at: ISODate('2024-05-12'), renews_at: null },
  { _id: 6, org_id: 6, plan: 'pro', seats: 6, started_at: ISODate('2024-06-08'), renews_at: ISODate('2026-06-08') }
]);

db.invoices.insertMany([
  { _id: 1, org_id: 1, subscription_id: 1, amount: 49.00, status: 'paid', issued_at: ISODate('2025-01-05') },
  { _id: 2, org_id: 1, subscription_id: 1, amount: 49.00, status: 'paid', issued_at: ISODate('2025-02-05') },
  { _id: 3, org_id: 1, subscription_id: 1, amount: 49.00, status: 'open', issued_at: ISODate('2025-09-05') },
  { _id: 4, org_id: 3, subscription_id: 3, amount: 1200.00, status: 'paid', issued_at: ISODate('2024-11-02') },
  { _id: 5, org_id: 3, subscription_id: 3, amount: 1200.00, status: 'paid', issued_at: ISODate('2025-05-02') },
  { _id: 6, org_id: 3, subscription_id: 3, amount: 1200.00, status: 'overdue', issued_at: ISODate('2025-08-02') },
  { _id: 7, org_id: 4, subscription_id: 4, amount: 79.00, status: 'paid', issued_at: ISODate('2025-03-25') },
  { _id: 8, org_id: 4, subscription_id: 4, amount: 79.00, status: 'open', issued_at: ISODate('2025-09-25') },
  { _id: 9, org_id: 6, subscription_id: 6, amount: 59.00, status: 'paid', issued_at: ISODate('2025-06-08') },
  { _id: 10, org_id: 6, subscription_id: 6, amount: 59.00, status: 'overdue', issued_at: ISODate('2025-09-08') }
]);

print('✅ saas dataset seeded: orgs 6, users 10, projects 8, tasks 20, subscriptions 6, invoices 10');

