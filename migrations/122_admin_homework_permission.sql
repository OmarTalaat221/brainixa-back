-- Homework, settable from the admin dashboard as well as by a teacher.
--
-- `homework` rows have only ever been created through /teacher/homework, so an academy running a
-- subject without a teacher account - or simply wanting to post the assignment itself - had no
-- way to set one at all. The new /admin/homework routes write the same table, with the same
-- shape; the only difference is that the teacher is a field the admin picks rather than their
-- own id taken from a token.
--
-- Additive only: no table is created or altered and no existing permission is touched. A super
-- admin already passes every permission check (helpers/rbac.php), so the new routes work before
-- this file is applied - running it is what lets the permission be granted to anyone else.

INSERT INTO `permissions` (`code`, `name`, `module`, `description`) VALUES
('manage_homework', 'Manage Homework', 'homework', 'Create homework, and review what students submit')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `module` = VALUES(`module`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 1, 'إدارة الواجبات', 'إنشاء الواجبات ومراجعة تسليمات الطلاب'
FROM `permissions` p WHERE p.code = 'manage_homework'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `permissions_translations` (`permission_id`, `language_id`, `name`, `description`)
SELECT p.id, 2, 'Manage Homework', 'Create homework, and review what students submit'
FROM `permissions` p WHERE p.code = 'manage_homework'
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Super Admin (role 1) gets it, the same way every other module permission is granted.
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 1, p.id FROM `permissions` p WHERE p.code = 'manage_homework'
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);
