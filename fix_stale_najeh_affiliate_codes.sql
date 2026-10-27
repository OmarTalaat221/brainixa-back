-- `students.affiliate_code` is generated once, on first view, by generateStudentAffiliateCode()
-- in app/user/student/affiliate/manage.php - and only when the column is still empty. The
-- generator itself was fixed a while back to produce "BRX-STU-..." codes, but that fix was
-- deliberately left non-retroactive, same as every other prefix fix in this project: any student
-- who had already seen their code before that fix keeps whatever was stored, "NAJEH-STU-...".
--
-- This clears just that stale value so it regenerates in the current "BRX-STU-..." form the next
-- time that student opens the "التسويق والدعوة" page. Scoped to the prefix itself, so it only
-- touches rows that actually still carry the old branding - running it twice is a no-op.

UPDATE students
SET affiliate_code = NULL
WHERE affiliate_code LIKE 'NAJEH-%';

SELECT id, name, affiliate_code
FROM students
WHERE affiliate_code IS NULL
LIMIT 50;
