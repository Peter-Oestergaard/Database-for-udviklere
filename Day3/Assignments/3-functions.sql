-- 01, Antal studerende
CREATE OR REPLACE FUNCTION get_student_count()
RETURNS INTEGER
LANGUAGE SQL
AS $$
SELECT COUNT("id") FROM "Students";
$$;

SELECT get_student_count() AS "Studerende ialt";

-- 02, Gennemsnitlig karakter for programs
CREATE OR REPLACE FUNCTION get_avg_grade(programId INT)
RETURNS FLOAT
LANGUAGE SQL
AS $$
SELECT AVG("grade") FROM "Exams" WHERE "programid" = $1;
$$;

SELECT get_avg_grade(1) AS "Karaktergennemsnit for program 1";
SELECT get_avg_grade(2) AS "Karaktergennemsnit for program 2";
SELECT get_avg_grade(3) AS "Karaktergennemsnit for program 3";
SELECT get_avg_grade(4) AS "Karaktergennemsnit for program 4";
SELECT get_avg_grade(5) AS "Karaktergennemsnit for program 5";

-- 03, Studerende på bestemt kursus
CREATE OR REPLACE FUNCTION get_students_on_course(course_id INT)
RETURNS TABLE("students" VARCHAR)
LANGUAGE SQL
AS $$
SELECT s."name"
FROM "Students" s
JOIN "Enrollments" e ON s."id" = e."studentid"
WHERE e."courseid" = $1;
$$;

SELECT get_students_on_course(1) AS "Studerende på kursus 1";
SELECT get_students_on_course(2) AS "Studerende på kursus 2";
SELECT get_students_on_course(3) AS "Studerende på kursus 3";
SELECT get_students_on_course(4) AS "Studerende på kursus 4";
SELECT get_students_on_course(5) AS "Studerende på kursus 5";

SELECT E'Selve udtrækket er så simpelt at jeg nok bare ville lave den JOIN hver gang.
Men ellers kan jeg ikke se hvad der kan optimeres på.'
AS "Er dette den mest optimale måde at udføre denne handling på?";