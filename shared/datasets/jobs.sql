-- ============================================================
-- JOB PLATFORM dataset (small) — dbms-playground
-- Load:  ./scripts/seed/seed-postgres.sh jobs
-- Tables: candidates, companies, jobs, applications,
--         skills, candidate_skills, job_skills
-- ============================================================

BEGIN;

DROP TABLE IF EXISTS job_skills, candidate_skills, applications, jobs, companies, candidates, skills CASCADE;

CREATE TABLE candidates (
    id                INT PRIMARY KEY,
    name              TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    experience_years  INT NOT NULL DEFAULT 0,
    city              TEXT
);

CREATE TABLE companies (
    id            INT PRIMARY KEY,
    name          TEXT NOT NULL,
    industry      TEXT,
    city          TEXT,
    founded_year  INT
);

CREATE TABLE jobs (
    id           INT PRIMARY KEY,
    company_id   INT NOT NULL REFERENCES companies(id),
    title        TEXT NOT NULL,
    salary_min   INT,
    salary_max   INT,
    is_remote    BOOLEAN NOT NULL DEFAULT FALSE,
    posted_at    DATE
);

CREATE TABLE applications (
    id            INT PRIMARY KEY,
    candidate_id  INT NOT NULL REFERENCES candidates(id),
    job_id        INT NOT NULL REFERENCES jobs(id),
    status        TEXT NOT NULL DEFAULT 'applied',  -- applied|interview|offer|rejected
    applied_at    DATE
);

CREATE TABLE skills (
    id    INT PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE candidate_skills (
    candidate_id  INT NOT NULL REFERENCES candidates(id),
    skill_id      INT NOT NULL REFERENCES skills(id),
    level         TEXT NOT NULL DEFAULT 'intermediate',  -- beginner|intermediate|advanced
    PRIMARY KEY (candidate_id, skill_id)
);

CREATE TABLE job_skills (
    job_id       INT NOT NULL REFERENCES jobs(id),
    skill_id     INT NOT NULL REFERENCES skills(id),
    is_required  BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (job_id, skill_id)
);

INSERT INTO candidates (id, name, email, experience_years, city) VALUES
    (1, 'Ayesha Khan',   'ayesha@mail.dev',  2, 'Karachi'),
    (2, 'Bilal Ahmed',   'bilal@mail.dev',   4, 'Lahore'),
    (3, 'Chen Wei',      'chen@mail.dev',    6, 'Toronto'),
    (4, 'Dua Malik',     'dua@mail.dev',     1, 'Islamabad'),
    (5, 'Emre Yilmaz',   'emre@mail.dev',    8, 'Istanbul'),
    (6, 'Farah Ali',     'farah@mail.dev',   3, 'Karachi'),
    (7, 'Grace Okafor',  'grace@mail.dev',   5, 'Lagos'),
    (8, 'Hassan Raza',   'hassan@mail.dev',  0, 'Multan');

INSERT INTO companies (id, name, industry, city, founded_year) VALUES
    (1, 'Nova Tech',     'Software',    'Karachi', 2015),
    (2, 'Orbit Labs',    'Software',    'Remote',  2019),
    (3, 'PeakData',      'Analytics',   'Toronto', 2012),
    (4, 'QuickCart',     'E-commerce',  'Lahore',  2017),
    (5, 'Riverline',     'Fintech',     'London',  2010),
    (6, 'Skyward Media', 'Media',       'Dubai',   2020);

INSERT INTO skills (id, name) VALUES
    (1, 'SQL'), (2, 'Python'), (3, 'JavaScript'),
    (4, 'PostgreSQL'), (5, 'MongoDB'), (6, 'Data Modeling'),
    (7, 'System Design'), (8, 'Docker'), (9, 'Communication'), (10, 'Testing');

INSERT INTO jobs (id, company_id, title, salary_min, salary_max, is_remote, posted_at) VALUES
    (1,  1, 'Backend Engineer',          90000,  130000, FALSE, '2025-06-01'),
    (2,  1, 'Database Administrator',     100000, 140000, FALSE, '2025-07-15'),
    (3,  2, 'Full-Stack Developer',       80000,  120000, TRUE,  '2025-05-20'),
    (4,  2, 'Data Engineer',              95000,  135000, TRUE,  '2025-08-01'),
    (5,  3, 'Analytics Engineer',          85000,  115000, TRUE,  '2025-06-10'),
    (6,  4, 'Frontend Engineer',          70000,  100000, FALSE, '2025-07-01'),
    (7,  4, 'Data Analyst',               60000,  85000,  FALSE, '2025-08-10'),
    (8,  5, 'Platform Engineer',           110000, 160000, TRUE,  '2025-04-15'),
    (9,  5, 'Database Internals Engineer',120000, 170000, TRUE,  '2025-03-01'),
    (10, 6, 'Web Developer',              55000,  75000,  TRUE,   '2025-09-01');

INSERT INTO applications (id, candidate_id, job_id, status, applied_at) VALUES
    (1,  1, 3,  'interview', '2025-05-25'),
    (2,  1, 5,  'applied',   '2025-06-12'),
    (3,  2, 1,  'offer',     '2025-06-05'),
    (4,  2, 4,  'interview', '2025-08-03'),
    (5,  3, 2,  'rejected',  '2025-07-20'),
    (6,  3, 9,  'interview', '2025-03-10'),
    (7,  4, 6,  'applied',   '2025-07-05'),
    (8,  4, 10, 'rejected',  '2025-09-05'),
    (9,  5, 8,  'offer',     '2025-04-20'),
    (10, 6, 7,  'applied',   '2025-08-15'),
    (11, 7, 4,  'interview', '2025-08-05'),
    (12, 8, 10, 'applied',   '2025-09-02');

INSERT INTO candidate_skills (candidate_id, skill_id, level) VALUES
    (1, 1, 'intermediate'), (1, 3, 'beginner'),     (1, 4, 'beginner'),
    (2, 1, 'advanced'),     (2, 2, 'intermediate'),(2, 4, 'advanced'),
    (3, 4, 'advanced'),     (3, 1, 'advanced'),     (3, 7, 'intermediate'),
    (4, 3, 'intermediate'), (4, 10,'beginner'),
    (5, 4, 'advanced'),     (5, 5, 'advanced'),     (5, 7, 'advanced'),
    (6, 1, 'intermediate'), (6, 2, 'intermediate'), (6, 9, 'beginner'),
    (7, 2, 'advanced'),    (7, 8, 'intermediate'),  (7, 9, 'advanced'),
    (8, 1, 'beginner');

INSERT INTO job_skills (job_id, skill_id, is_required) VALUES
    (1, 1, TRUE),  (1, 4, TRUE),   (1, 3, FALSE),
    (2, 4, TRUE),  (2, 7, FALSE),
    (3, 3, TRUE),  (3, 2, TRUE),   (3, 10, FALSE),
    (4, 2, TRUE),  (4, 4, TRUE),   (4, 6, FALSE),
    (5, 1, TRUE),  (5, 6, TRUE),
    (6, 3, TRUE), (6, 10, FALSE),
    (7, 1, TRUE), (7, 2, FALSE),
    (8, 4, TRUE), (8, 7, TRUE),   (8, 8, FALSE),
    (9, 4, TRUE), (9, 7, TRUE),
    (10, 3, TRUE),(10, 9, FALSE);

COMMIT;

-- Sanity check: candidates 8 | companies 6 | jobs 10 | applications 12 | skills 10
--               candidate_skills 20 | job_skills 23

