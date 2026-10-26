-- Which of the pending migrations are already applied on this database.
-- Read-only: it changes nothing, it only reports. Run it before running anything else.

SELECT '100 — gateway discounts & points' AS migration,
       IF(COUNT(*) = 4, 'APPLIED', CONCAT('MISSING (', 4 - COUNT(*), ' of 4 columns)')) AS state
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payment_transactions'
  AND COLUMN_NAME IN ('original_amount','discount_code_id','discount_amount','points_spent')

UNION ALL
SELECT '107 — consultation meeting link',
       IF(COUNT(*) = 1, 'APPLIED', 'MISSING')
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consultation_slots'
  AND COLUMN_NAME = 'meeting_link'

UNION ALL
SELECT '108 — consultation live state',
       IF(COUNT(*) = 2, 'APPLIED', CONCAT('MISSING (', 2 - COUNT(*), ' of 2 columns)'))
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'consultation_slots'
  AND COLUMN_NAME IN ('started_at','ended_at')

UNION ALL
SELECT '109 — package session live state',
       IF(COUNT(*) = 2, 'APPLIED', CONCAT('MISSING (', 2 - COUNT(*), ' of 2 columns)'))
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'teacher_availability_slots'
  AND COLUMN_NAME IN ('started_at','ended_at')

UNION ALL
-- The banners work needed no migration at all; this line only proves why.
SELECT 'banners table (needed by the new slider)',
       IF(COUNT(*) = 1, 'ALREADY THERE — no migration needed', 'MISSING')
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'banners' AND COLUMN_NAME = 'type';
