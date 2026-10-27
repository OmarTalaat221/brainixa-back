<?php
require_once __DIR__ . '/../../helpers/upload.php';

/**
 * Chat itself talks to Firebase directly (see app/admin/chat/access.php) - but who shows up in
 * "start a new conversation" was, until now, also read from Firebase's own `users/{uid}` node.
 * That node is only ever written the moment a given account opens its own chat page for the
 * first time (see upsertChatUser calls across the three frontends), so it drifted from the real
 * database two ways at once: an account that had never opened chat was simply invisible, and an
 * account renamed/re-emailed on the real database kept showing its old name/email forever,
 * because nothing ever told Firebase about the change. "Najeh Super Admin" / info@najeh.com
 * sitting in the picker long after the real rebrand was exactly that: stale Firebase data, not a
 * real account.
 *
 * This endpoint is the fix: the picker's contact list now comes from here, a plain read of the
 * real students/teachers/parents tables, so it can never show an account twice or under a name
 * that no longer exists. Firebase remains the live messaging transport once a conversation is
 * open - it was never the right place to also be the directory of who exists.
 *
 * Admin accounts are deliberately left out of this list: a teacher or student does not pick a
 * specific admin to write to any more, they reach a single shared "support" contact that every
 * admin's own inbox shows (see brainixa-dash-admin's LayoutShell/chat page) - that is a frontend-
 * only, synthetic entry and has nothing to look up here.
 */
if (!function_exists('chat_directory_rows')) {
    function chat_directory_rows($con, string $selfRole, int $selfId): array {
        $rows = [];

        $tables = [
            'student' => 'students',
            'teacher' => 'teachers',
            'parent'  => 'parents',
        ];

        foreach ($tables as $role => $table) {
            $res = mysqli_query($con, "SELECT id, name, email, image FROM `{$table}` WHERE is_active = 1 ORDER BY name ASC");
            if (!$res) {
                continue;
            }

            while ($row = mysqli_fetch_assoc($res)) {
                $id = (int)$row['id'];
                if ($role === $selfRole && $id === $selfId) {
                    continue;
                }

                $rows[] = format_response_images([
                    'uid'       => "{$role}_{$id}",
                    'id'        => $id,
                    'role'      => $role,
                    'name'      => $row['name'],
                    'email'     => $row['email'],
                    'image'     => $row['image'],
                    'is_active' => true,
                ]);
            }
        }

        return $rows;
    }
}

if (!function_exists('chatListDirectory')) {
    function chatListDirectory($con, $authData, string $selfRole) {
        $selfId = 0;
        if (is_array($authData)) {
            $selfId = (int)($authData['id'] ?? 0);
        } elseif (is_object($authData)) {
            $selfId = (int)($authData->id ?? 0);
        }

        return [
            'status' => 'success',
            'message' => 'Chat directory fetched successfully',
            'data' => chat_directory_rows($con, $selfRole, $selfId),
        ];
    }
}
