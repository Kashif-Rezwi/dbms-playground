# Solutions — Project 3: Student Course System

> Same caveat as always: compare methods, not bytes.

## Design answers

1. A `student_id` column in courses would store **one** student per course — but a course has *many* students. One column can't hold many values without the CSV disease (Day 20/27). A many-to-many needs a junction table.
2. Natural PK of enrollments: `(student_id, course_id)` composite — a student can enroll in a course only once.
3. That composite PK *is* the constraint (or a UNIQUE if you use a surrogate id).

## Reference schema

```sql
CREATE TABLE students (
    id INT PRIMARY KEY, name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE, city TEXT,
    enrolled_on DATE NOT NULL
);

CREATE TABLE courses (
    id INT PRIMARY KEY, title TEXT NOT NULL,
    instructor TEXT NOT NULL, capacity INT NOT NULL CHECK (capacity > 0),
    fee NUMERIC(8,2) NOT NULL CHECK (fee >= 0)
);

CREATE TABLE enrollments (
    student_id INT NOT NULL REFERENCES students(id),
    course_id  INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    grade INT CHECK (grade BETWEEN 0 AND 100),   -- NULL = not graded yet
    PRIMARY KEY (student_id, course_id)
);
```

## Queries 4–11

```sql
-- 4. the base three-table join
SELECT s.name AS student, c.title AS course, e.grade
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses  c ON c.id = e.course_id;

-- 5. counts including zero
SELECT c.title, COUNT(e.student_id) AS enrolled
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.title;

-- 6. students not enrolled in anything
SELECT s.name
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id
WHERE e.course_id IS NULL;

-- 7. avg grade per course (NULL grades excluded automatically by AVG)
SELECT c.title, ROUND(AVG(e.grade), 1) AS avg_grade
FROM courses c JOIN enrollments e ON e.course_id = c.id
GROUP BY c.title;

-- 8a. JOIN way
SELECT s.name
FROM students s
JOIN enrollments e ON e.student_id = s.id
JOIN courses  c ON c.id = e.course_id AND c.title = 'SQL Fundamentals';
-- 8b. subquery way
SELECT name FROM students
WHERE id IN (SELECT e.student_id FROM enrollments e
             JOIN courses c ON c.id = e.course_id
             WHERE c.title = 'SQL Fundamentals');

-- 9. pairs sharing a course (the < trick prevents duplicate reversed pairs)
SELECT s1.name AS student_a, s2.name AS student_b, c.title
FROM enrollments e1
JOIN enrollments e2 ON e1.course_id = e2.course_id AND e1.student_id < e2.student_id
JOIN students s1 ON s1.id = e1.student_id
JOIN students s2 ON s2.id = e2.student_id
JOIN courses  c ON c.id = e1.course_id;

-- 10. full courses (capacity reached)
SELECT c.title, c.capacity, COUNT(e.student_id) AS enrolled
FROM courses c JOIN enrollments e ON e.course_id = c.id
GROUP BY c.title, c.capacity
HAVING COUNT(e.student_id) >= c.capacity;

-- 11. top student by average grade
SELECT s.name, ROUND(AVG(e.grade), 1) AS avg_grade
FROM students s JOIN enrollments e ON e.student_id = s.id
WHERE e.grade IS NOT NULL
GROUP BY s.name
ORDER BY avg_grade DESC
LIMIT 1;
```

## Challenges 12–13, Bonuses 14–15

```sql
-- 12. prove the CHECK: this must FAIL
INSERT INTO enrollments (student_id, course_id, enrolled_at, grade)
VALUES (1, 1, '2025-09-01', 150);

-- 13. transcript
SELECT s.name,
       COUNT(*) AS courses,
       ROUND(AVG(e.grade), 1) AS avg_grade
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id
GROUP BY s.name;

-- 14. two courses with the same instructor
SELECT s.name, c1.title, c2.title, c1.instructor
FROM enrollments e1
JOIN enrollments e2 ON e1.student_id = e2.student_id AND e1.course_id <> e2.course_id
JOIN courses c1 ON c1.id = e1.course_id
JOIN courses c2 ON c2.id = e2.course_id AND c1.instructor = c2.instructor
JOIN students s ON s.id = e1.student_id
WHERE e1.course_id < e2.course_id;   -- avoid mirror duplicates

-- 15. revenue per instructor
SELECT c.instructor, SUM(c.fee) AS revenue
FROM enrollments e JOIN courses c ON c.id = e.course_id
GROUP BY c.instructor ORDER BY revenue DESC;
-- No double counting: each enrollment row = one student paying once for one course.
```

## Self-review answers (short)

- Junction table to a non-programmer: "a sign-up sheet connecting students to courses — one line per student per course, with extra info like the grade."
- The `<` trick: without it, (Ali, Sara) and (Sara, Ali) both appear — duplicates by reversal.
- Compare with `jobs.sql`: `applications` = enrollments with a status; `candidate_skills` = enrollments with a level. Same pattern, different domain.
