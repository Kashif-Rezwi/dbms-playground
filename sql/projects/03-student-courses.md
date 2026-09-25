# 🏗️ Project 3 — Student Course Management System

**Milestone:** SQL Stage 3 (after Day 14) · **Time:** ~90 min · **Dataset:** your own

## Objective

Design and build a many-to-many relationship — students ↔ courses ↔ enrollments — and query it with joins and subqueries.

## Scenario

A coaching institute: students enroll in courses. A student takes many courses; a course has many students. Each enrollment gets a grade eventually.

## Requirements — Design First

Design these tables yourself (choose types, keys, constraints):

- `students`: id, name, email, city, enrolled_on
- `courses`: id, title, instructor, capacity, fee
- `enrollments`: the **junction table** — student + course + enrolled_at + grade (nullable until graded)

**Design questions to answer before typing:**

1. Why can't you put a `student_id` column directly in `courses`?
2. What's the natural primary key of `enrollments`?
3. What constraint stops a student enrolling twice in the same course?

Insert 8 students, 5 courses, and ~15 enrollments (some ungraded), including: one student with 4 courses, one course at capacity, one student with only ungraded enrollments.

## Required Queries

4. Every enrollment: student name + course title (+ grade) — the base three-table join
5. Courses and their enrollment counts, **including zero-enrollment courses**
6. Students who are *not* enrolled in anything
7. The average grade per course (NULLs excluded — why?)
8. Students enrolled in the course 'SQL Fundamentals' (two ways: JOIN, and a subquery with IN)
9. Pairs of students who share a course (self-join on enrollments — the `<` id trick from Day 13)
10. Courses where enrollment has hit capacity (compare count against `capacity` — HAVING or subquery)
11. The top student by average grade (only counting graded enrollments)

## Constraints

- Predict counts before running (5, 6, 10 especially)
- Two ways for query 8, both verified identical

## Performance Requirement

None (tiny data) — but name the column you'd index first for query 4 and say why.

## Challenge Tasks ⭐

12. Add a grade constraint (CHECK between 0 and 100 — or A–F letter, your design) and prove a bad insert fails
13. A "transcript" query: one row per student — name, courses taken, average grade (GROUP BY + join)

## Bonus Challenge 🔴

14. Students enrolled in **more than one course with the same instructor** (self-join with two different aliases of courses)
15. Revenue per instructor (SUM of fee across their enrollments) — watch for double counting students... there is none (each enrollment pays once) — but *say why* before running.

## Expected Outcome

Your first real many-to-many system, built and queried — the design pattern behind tags, likes, follows, and enrollments everywhere.

## Self-Review Questions

- Explain the junction table to a non-programmer in two sentences.
- What did you make nullable and why?
- Query 9's `<` trick — what breaks without it?
- Compare your design with `shared/datasets/jobs.sql` (applications/candidate_skills) — same pattern?

> ✅ Done? [solutions/03-student-courses.md](solutions/03-student-courses.md)
