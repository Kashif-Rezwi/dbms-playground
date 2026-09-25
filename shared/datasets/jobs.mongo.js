// ============================================================
// JOB PLATFORM dataset (small) — MongoDB seed
// Load:  ./scripts/seed/seed-mongo.sh jobs
// Note: skills are EMBEDDED here (array of {skill, level}) —
// a deliberate document-modeling choice vs the SQL version.
// Collections: companies, candidates, jobs, applications
// ============================================================

db = db.getSiblingDB('jobs');
db.dropDatabase();

db.companies.insertMany([
  { _id: 1, name: 'Nova Tech', industry: 'Software', city: 'Karachi', founded_year: 2015 },
  { _id: 2, name: 'Orbit Labs', industry: 'Software', city: 'Remote', founded_year: 2019 },
  { _id: 3, name: 'PeakData', industry: 'Analytics', city: 'Toronto', founded_year: 2012 },
  { _id: 4, name: 'QuickCart', industry: 'E-commerce', city: 'Lahore', founded_year: 2017 },
  { _id: 5, name: 'Riverline', industry: 'Fintech', city: 'London', founded_year: 2010 },
  { _id: 6, name: 'Skyward Media', industry: 'Media', city: 'Dubai', founded_year: 2020 }
]);

db.candidates.insertMany([
  { _id: 1, name: 'Ayesha Khan', email: 'ayesha@mail.dev', experience_years: 2, city: 'Karachi',
    skills: [ { skill: 'SQL', level: 'intermediate' }, { skill: 'JavaScript', level: 'beginner' }, { skill: 'PostgreSQL', level: 'beginner' } ] },
  { _id: 2, name: 'Bilal Ahmed', email: 'bilal@mail.dev', experience_years: 4, city: 'Lahore',
    skills: [ { skill: 'SQL', level: 'advanced' }, { skill: 'Python', level: 'intermediate' }, { skill: 'PostgreSQL', level: 'advanced' } ] },
  { _id: 3, name: 'Chen Wei', email: 'chen@mail.dev', experience_years: 6, city: 'Toronto',
    skills: [ { skill: 'PostgreSQL', level: 'advanced' }, { skill: 'SQL', level: 'advanced' }, { skill: 'System Design', level: 'intermediate' } ] },
  { _id: 4, name: 'Dua Malik', email: 'dua@mail.dev', experience_years: 1, city: 'Islamabad',
    skills: [ { skill: 'JavaScript', level: 'intermediate' }, { skill: 'Testing', level: 'beginner' } ] },
  { _id: 5, name: 'Emre Yilmaz', email: 'emre@mail.dev', experience_years: 8, city: 'Istanbul',
    skills: [ { skill: 'PostgreSQL', level: 'advanced' }, { skill: 'MongoDB', level: 'advanced' }, { skill: 'System Design', level: 'advanced' } ] },
  { _id: 6, name: 'Farah Ali', email: 'farah@mail.dev', experience_years: 3, city: 'Karachi',
    skills: [ { skill: 'SQL', level: 'intermediate' }, { skill: 'Python', level: 'intermediate' }, { skill: 'Communication', level: 'beginner' } ] },
  { _id: 7, name: 'Grace Okafor', email: 'grace@mail.dev', experience_years: 5, city: 'Lagos',
    skills: [ { skill: 'Python', level: 'advanced' }, { skill: 'Docker', level: 'intermediate' }, { skill: 'Communication', level: 'advanced' } ] },
  { _id: 8, name: 'Hassan Raza', email: 'hassan@mail.dev', experience_years: 0, city: 'Multan',
    skills: [ { skill: 'SQL', level: 'beginner' } ] }
]);

db.jobs.insertMany([
  { _id: 1, company_id: 1, title: 'Backend Engineer', salary_min: 90000, salary_max: 130000, is_remote: false, posted_at: ISODate('2025-06-01'),
    skills: [ { skill: 'SQL', required: true }, { skill: 'PostgreSQL', required: true }, { skill: 'JavaScript', required: false } ] },
  { _id: 2, company_id: 1, title: 'Database Administrator', salary_min: 100000, salary_max: 140000, is_remote: false, posted_at: ISODate('2025-07-15'),
    skills: [ { skill: 'PostgreSQL', required: true }, { skill: 'System Design', required: false } ] },
  { _id: 3, company_id: 2, title: 'Full-Stack Developer', salary_min: 80000, salary_max: 120000, is_remote: true, posted_at: ISODate('2025-05-20'),
    skills: [ { skill: 'JavaScript', required: true }, { skill: 'Python', required: true }, { skill: 'Testing', required: false } ] },
  { _id: 4, company_id: 2, title: 'Data Engineer', salary_min: 95000, salary_max: 135000, is_remote: true, posted_at: ISODate('2025-08-01'),
    skills: [ { skill: 'Python', required: true }, { skill: 'PostgreSQL', required: true }, { skill: 'Data Modeling', required: false } ] },
  { _id: 5, company_id: 3, title: 'Analytics Engineer', salary_min: 85000, salary_max: 115000, is_remote: true, posted_at: ISODate('2025-06-10'),
    skills: [ { skill: 'SQL', required: true }, { skill: 'Data Modeling', required: true } ] },
  { _id: 6, company_id: 4, title: 'Frontend Engineer', salary_min: 70000, salary_max: 100000, is_remote: false, posted_at: ISODate('2025-07-01'),
    skills: [ { skill: 'JavaScript', required: true }, { skill: 'Testing', required: false } ] },
  { _id: 7, company_id: 4, title: 'Data Analyst', salary_min: 60000, salary_max: 85000, is_remote: false, posted_at: ISODate('2025-08-10'),
    skills: [ { skill: 'SQL', required: true }, { skill: 'Python', required: false } ] },
  { _id: 8, company_id: 5, title: 'Platform Engineer', salary_min: 110000, salary_max: 160000, is_remote: true, posted_at: ISODate('2025-04-15'),
    skills: [ { skill: 'PostgreSQL', required: true }, { skill: 'System Design', required: true }, { skill: 'Docker', required: false } ] },
  { _id: 9, company_id: 5, title: 'Database Internals Engineer', salary_min: 120000, salary_max: 170000, is_remote: true, posted_at: ISODate('2025-03-01'),
    skills: [ { skill: 'PostgreSQL', required: true }, { skill: 'System Design', required: true } ] },
  { _id: 10, company_id: 6, title: 'Web Developer', salary_min: 55000, salary_max: 75000, is_remote: true, posted_at: ISODate('2025-09-01'),
    skills: [ { skill: 'JavaScript', required: true }, { skill: 'Communication', required: false } ] }
]);

db.applications.insertMany([
  { _id: 1, candidate_id: 1, job_id: 3, status: 'interview', applied_at: ISODate('2025-05-25') },
  { _id: 2, candidate_id: 1, job_id: 5, status: 'applied', applied_at: ISODate('2025-06-12') },
  { _id: 3, candidate_id: 2, job_id: 1, status: 'offer', applied_at: ISODate('2025-06-05') },
  { _id: 4, candidate_id: 2, job_id: 4, status: 'interview', applied_at: ISODate('2025-08-03') },
  { _id: 5, candidate_id: 3, job_id: 2, status: 'rejected', applied_at: ISODate('2025-07-20') },
  { _id: 6, candidate_id: 3, job_id: 9, status: 'interview', applied_at: ISODate('2025-03-10') },
  { _id: 7, candidate_id: 4, job_id: 6, status: 'applied', applied_at: ISODate('2025-07-05') },
  { _id: 8, candidate_id: 4, job_id: 10, status: 'rejected', applied_at: ISODate('2025-09-05') },
  { _id: 9, candidate_id: 5, job_id: 8, status: 'offer', applied_at: ISODate('2025-04-20') },
  { _id: 10, candidate_id: 6, job_id: 7, status: 'applied', applied_at: ISODate('2025-08-15') },
  { _id: 11, candidate_id: 7, job_id: 4, status: 'interview', applied_at: ISODate('2025-08-05') },
  { _id: 12, candidate_id: 8, job_id: 10, status: 'applied', applied_at: ISODate('2025-09-02') }
]);

print('✅ jobs dataset seeded: companies 6, candidates 8, jobs 10, applications 12');

