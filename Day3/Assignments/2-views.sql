-- 01, Simpelt View
CREATE OR REPLACE VIEW student_overview AS
SELECT s."name" AS "Studerende",
       p."name" AS "Program",
       p."level" AS "Niveau"
FROM "Students" s
JOIN "Programs" p ON s."programid" = p."id";

SELECT * FROM student_overview;

-- 02, View med Filter
CREATE OR REPLACE VIEW failed_exams AS
SELECT s."name" AS "Studerende",
       e."grade" AS "Karakter"
FROM "Students" s
JOIN "Exams" e ON s."id" = e."studentid"
WHERE e."grade" < 2;

SELECT * FROM failed_exams;

-- 03, Aggregeret View
CREATE OR REPLACE VIEW program_avg_grades AS
SELECT p."name" AS "Program",
       ROUND(AVG(e."grade"), 2) AS "Karaktergennemsnit"
FROM "Programs" p
JOIN "Exams" e ON p."id" = e."programid"
GROUP BY p."name";

SELECT * FROM program_avg_grades;

-- 04, View med join over flere tabeller
CREATE OR REPLACE VIEW course_enrollments AS
SELECT c."name" AS "Kursus",
       p."name" AS "Programnavn",
       COUNT(e."studentid") AS "Tilmeldte"
FROM "Courses" c
JOIN "Programs" p ON c."programid" = p."id"
JOIN "Enrollments" e ON c."id" = e."courseid"
GROUP BY c."name", p."name";

SELECT * FROM course_enrollments;

-- 05, Opdatering via View
CREATE OR REPLACE VIEW active_students AS
SELECT s."name" AS "Studerende med mindst en bestået eksamen"
FROM "Students" s
WHERE s."id" IN (SELECT DISTINCT "studentid"
                 FROM "Exams"
                 WHERE "grade" >= 2);

SELECT * FROM active_students;

UPDATE active_students
SET "Studerende med mindst en bestået eksamen" = 'Peter'
WHERE "Studerende med mindst en bestået eksamen" = 'Jane Doe';

SELECT * FROM active_students;
SELECT * FROM "Students";

-- https://www.postgresql.org/docs/current/sql-createview.html#SQL-CREATEVIEW-UPDATABLE-VIEWS