-- 01, Simpel procedure uden parametre
-- Er det her et trick spørgsmål? En stored procedure kan ikke returnere data.
-- Jeg laver det som et view istedet.
CREATE OR REPLACE VIEW list_all_students AS
SELECT s."name" AS "Studerende",
       p."name" AS "Program"
FROM "Students" s
JOIN "Programs" p ON s."programid" = p."id";

SELECT * FROM list_all_students;

-- 02, Procedure med 1 parameter
-- Endnu et trick spørgsmål? En stored procedure kan stadig ikke returnere data.
-- Jeg laver det som en funktion istedet - pga. parameteren.
CREATE OR REPLACE FUNCTION list_students_by_program(program_id INT)
RETURNS TABLE("students" VARCHAR)
LANGUAGE SQL
AS $$
SELECT "name" AS "Studerende"
FROM "Students"
WHERE "programid" = $1;
$$;

SELECT list_students_by_program(1) AS "Studerende på program 1";
SELECT list_students_by_program(2) AS "Studerende på program 2";
SELECT list_students_by_program(3) AS "Studerende på program 3";
SELECT list_students_by_program(4) AS "Studerende på program 4";
SELECT list_students_by_program(5) AS "Studerende på program 5";

-- 03, Procedure med insert
-- Because the student's ids have been manually inserted in the initialization script,
-- we need to syncronize the Students.id counter - otherwise we need to calculate the
-- next available id each time. We don't want to do that. Most correct solution is,
-- of course, to correct the original input.
DO $$
BEGIN
PERFORM setval(pg_get_serial_sequence('"Students"', 'id'), MAX("id")) FROM "Students"; -- Thank you ChatGPT!
END
$$;

CREATE OR REPLACE PROCEDURE add_new_student(name VARCHAR, program_id INT)
LANGUAGE SQL
AS $$
INSERT INTO "Students" ("name", "programid") VALUES
($1, $2);
$$;

CALL add_new_student('Bruce Wayne', 5);
SELECT list_students_by_program(5) AS "Studerende på program 5";

-- 04, Procedure med update
CREATE OR REPLACE PROCEDURE update_student_program(student_id INT, new_program_id INT)
LANGUAGE SQL
AS $$
UPDATE "Students"
SET "programid" = $2
WHERE "id" = $1;
$$;

CALL update_student_program(6, 5);
SELECT list_students_by_program(5) AS "Studerende på program 5";