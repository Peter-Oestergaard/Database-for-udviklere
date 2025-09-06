-- 01, Scalar Subquery
SELECT
    "name" AS "Studerende",
    (SELECT AVG("grade") FROM "Exams") AS "Karaktergennemsnit for alle"
FROM "Students";

-- 02, Row Subquery
SELECT
    "name" AS "Mønsterelev"
FROM "Students"
WHERE ("id", "programid") = (SELECT
                                    "studentid",
                                    "programid"
                                FROM "Exams"
                                ORDER BY "grade"
                                DESC
                                LIMIT 1);

-- 03, Table Subquery
SELECT "name" AS "Studerende på Multimediedesigner"
FROM "Students"
WHERE "programid"
IN (SELECT DISTINCT "studentid"
    FROM "Enrollments"
    WHERE "courseid" IN (SELECT "id"
                         FROM "Courses"
                         WHERE "programid" = (SELECT "id"
                                              FROM "Programs"
                                              WHERE "name"='Multimediedesigner')));

-- 04, Correlated Subquery
SELECT "name" AS "Studerende",
       (SELECT MAX("grade")
        FROM "Exams"
        WHERE "studentid" = s."id") AS "Bedste karakter"
FROM "Students" s