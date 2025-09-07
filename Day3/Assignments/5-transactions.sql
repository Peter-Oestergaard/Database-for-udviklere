-- 01, Wallet Transfer
CREATE TABLE "Wallets" (
    "studentId" INTEGER NOT NULL PRIMARY KEY,
    "balance" NUMERIC,
    CONSTRAINT "fk_studentId_Students_id" FOREIGN KEY("studentId") REFERENCES "Students"("id")
);

CREATE TABLE "TransferLogs" (
    "id" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "message" VARCHAR
);

INSERT INTO "Wallets" ("studentId", "balance") VALUES
(1, 100),
(2, 1200),
(3, 15),
(4, 2050),
(5, 310),
(6, 124),
(7, 55776234883);

-- CREATE OR REPLACE PROCEDURE transfer_funds_between_wallets(fromStudent INTEGER, toStudent INTEGER, amount NUMERIC)
-- LANGUAGE SQL
-- AS $$
-- UPDATE "Wallets" SET "balance" = "balance" + $3 WHERE "studentId" = $2;
-- UPDATE "Wallets" SET "balance" = "balance" - $3 WHERE "studentId" = $1;
-- IF (SELECT "balance" FROM "Wallets" WHERE "studentId" = $1) < 0 THEN
-- COMMIT;
-- ELSE
-- ROLLBACK;
-- $$;

-- Show the "before" balance for the two students we will transfer between
SELECT * FROM "Wallets" WHERE "studentId" IN (1, 2);

-- Do the transfer
--CALL transfer_funds_between_wallets(1, 2, 75);
DO $$
BEGIN
UPDATE "Wallets" SET "balance" = "balance" + 75 WHERE "studentId" = 2;
UPDATE "Wallets" SET "balance" = "balance" - 75 WHERE "studentId" = 1;

IF EXISTS(SELECT "balance" FROM "Wallets" WHERE "studentId" = 1 AND "balance" >= 0) THEN
    INSERT INTO "TransferLogs" ("message") VALUES
        ('OK');
    COMMIT;
ELSE
    ROLLBACK;
    INSERT INTO "TransferLogs" ("message") VALUES
        ('INSUFFICIENT_FUNDS');
END IF;
END
$$;

-- Show the "after" balance
SELECT * FROM "Wallets" WHERE "studentId" IN (1, 2);

-- Do the same transfer again
DO $$
BEGIN
UPDATE "Wallets" SET "balance" = "balance" + 75 WHERE "studentId" = 2;
UPDATE "Wallets" SET "balance" = "balance" - 75 WHERE "studentId" = 1;

IF EXISTS(SELECT "balance" FROM "Wallets" WHERE "studentId" = 1 AND "balance" >= 0) THEN
    INSERT INTO "TransferLogs" ("message") VALUES
    ('OK');
    COMMIT;
ELSE
    ROLLBACK;
    INSERT INTO "TransferLogs" ("message") VALUES
        ('INSUFFICIENT_FUNDS');
END IF;
END
$$;

-- Show the "after after" balance
SELECT * FROM "Wallets" WHERE "studentId" IN (1, 2);

SELECT * FROM "TransferLogs";

-- 02, Batch-tilmeldinger som stored procedure
CREATE OR REPLACE PROCEDURE enroll_many_on_course(courseId INTEGER, studentIds INTEGER[], OUT inserted INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    studentId INTEGER;
BEGIN
    inserted := 0;
    FOREACH studentId IN ARRAY studentIds
    LOOP
        INSERT INTO "Enrollments" ("studentid", "courseid") VALUES
        (studentId, courseId);
    END LOOP;
    inserted := array_length(studentIds, 1);
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'A student can''t be enrolled in the same course more than once. Offending studentId: %', studentId;
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'A student must be known in order to be enrolled in a course. Offending studentId: %', studentId;
    WHEN OTHERS THEN
        RAISE NOTICE 'Something really bad just happened. I''m really sorry. %', SQLERRM;  
END;
$$;

SELECT * FROM "Enrollments";

-- No problems
CALL enroll_many_on_course(4, ARRAY[1, 2], NULL);

SELECT * FROM "Enrollments";

-- Duplicate entry
CALL enroll_many_on_course(3, ARRAY[1, 2, 3, 4], NULL);

SELECT * FROM "Enrollments";

-- Unknown student
CALL enroll_many_on_course(3, ARRAY[1, 2, 3, 8], NULL);

SELECT * FROM "Enrollments";