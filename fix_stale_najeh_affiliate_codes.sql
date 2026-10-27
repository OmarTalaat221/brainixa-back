-- `students.affiliate_code` is generated once, on first view, by generateStudentAffiliateCode()
-- in app/user/student/affiliate/manage.php - and only when the column is still empty. The
-- generator itself was fixed a while back to produce "BRX-STU-..." codes, but that fix was
-- deliberately left non-retroactive, same as every other prefix fix in this project: any student
-- who had already seen their code before that fix keeps whatever was stored, "NAJEH-STU-...".
--
-- This rewrites that stale prefix in place, directly, rather than clearing the column and waiting
-- for the student to reopen "التسويق والدعوة" to regenerate it - the owner asked for the old
-- codes to be changed now. Only the "NAJEH-" text is swapped for "BRX-"; the rest of each code
-- (the student id, and the "-NNN" disambiguation suffix a collision would have added) is kept
-- exactly as it was, so uniqueness is untouched. Safe to run twice: a code with no "NAJEH-" left
-- in it does not match the WHERE clause a second time.

UPDATE students
SET affiliate_code = REPLACE(affiliate_code, 'NAJEH-', 'BRX-')
WHERE affiliate_code LIKE 'NAJEH-%';

SELECT id, name, affiliate_code
FROM students
WHERE affiliate_code LIKE 'BRX-%'
LIMIT 50;
