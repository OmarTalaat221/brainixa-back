<?php
require_once __DIR__ . '/language.php';

if (!function_exists('format_image_url')) {
    function format_image_url(?string $image): ?string {
        if (empty($image)) {
            return null;
        }
        $image = trim($image);
        if ($image === '') {
            return null;
        }

        if (str_starts_with(strtolower($image), 'http') || preg_match('/^(data:|blob:|\/\/)/i', $image)) {
            return $image;
        }

        $cleanPath = ltrim($image, '/');

        return 'https://camp-coding.online/brain-ixa/' . $cleanPath;
    }
}

if (!function_exists('format_response_images')) {
    function format_response_images($data) {
        if (!is_array($data)) {
            if (is_string($data) && (
                str_starts_with(strtolower($data), 'http') ||
                preg_match('/^(data:|blob:|\/\/)/i', $data) ||
                str_starts_with(strtolower($data), 'uploads/') ||
                preg_match('/\.(jpg|jpeg|png|gif|webp|svg|mp4|webm|pdf|doc|docx|zip|mp3|wav)$/i', $data)
            )) {
                return format_image_url($data);
            }
            return $data;
        }

        $isAssoc = false;
        foreach (array_keys($data) as $key) {
            if (is_string($key)) {
                $isAssoc = true;
                break;
            }
        }

        if (!$isAssoc) {
            foreach ($data as $idx => $item) {
                $data[$idx] = format_response_images($item);
            }
            return $data;
        }

        $imageKeys = [
            'image', 'image_path', 'image_ar', 'image_en', 'avatar', 'photo', 'icon', 'thumbnail',
            'cover_image', 'cover', 'banner', 'banner_url'
        ];

        foreach ($imageKeys as $imgKey) {
            if (array_key_exists($imgKey, $data) && !empty($data[$imgKey]) && is_string($data[$imgKey])) {
                if (empty($data['image']) || !is_string($data['image'])) {
                    $data['image'] = $data[$imgKey];
                }
            }
        }

        if (array_key_exists('file_path', $data)) {
            if (!empty($data['file_path']) && (empty($data['file']) || !is_string($data['file']))) {
                $data['file'] = $data['file_path'];
            }
        }

        $mediaKeys = [
            'image', 'image_path', 'image_ar', 'image_en', 'avatar', 'photo', 'icon', 'thumbnail',
            'video', 'video_url', 'video_preview_url', 'video_path',
            'pdf', 'pdf_url', 'file', 'file_path', 'file_url',
            'cover_image', 'cover', 'attachment', 'attachment_url',
            'audio', 'audio_url', 'media', 'media_url',
            'certificate_file', 'certificate_path', 'certificate_url',
            'banner', 'banner_url', 'doc', 'doc_url', 'document',
            'transfer_receipt', 'receipt', 'receipt_image'
        ];

        foreach ($data as $k => $v) {
            if (is_array($v)) {
                $data[$k] = format_response_images($v);
            } elseif (is_string($v) && in_array(strtolower($k), $mediaKeys)) {
                $data[$k] = format_image_url($v);
            }
        }

        if (array_key_exists('image_path', $data) && array_key_exists('image', $data)) {
            $data['image_path'] = $data['image'];
        }
        if (array_key_exists('file_path', $data) && array_key_exists('file', $data)) {
            $data['file_path'] = $data['file'];
        }

        return $data;
    }
}

if (!function_exists('save_moved_file')) {
    function save_moved_file(array $file, string $targetFilePath): bool {
        if (isset($file['tmp_name']) && file_exists($file['tmp_name'])) {
            if (is_uploaded_file($file['tmp_name'])) {
                return move_uploaded_file($file['tmp_name'], $targetFilePath);
            } else {
                return copy($file['tmp_name'], $targetFilePath) || rename($file['tmp_name'], $targetFilePath);
            }
        }
        return false;
    }
}

if (!function_exists('upload_image_file')) {
    function upload_image_file(array $file, string $subfolder = 'avatars'): ?string {
        if (empty($file['tmp_name']) || !file_exists($file['tmp_name'])) {
            return null;
        }
        if (isset($file['error']) && (int)$file['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];
        $allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
        $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));
        if (empty($ext)) {
            $mimeToExt = [
                'image/jpeg' => 'jpg',
                'image/png' => 'png',
                'image/gif' => 'gif',
                'image/webp' => 'webp',
                'image/svg+xml' => 'svg'
            ];
            $ext = $mimeToExt[$file['type'] ?? ''] ?? '';
        }
        if ($ext === 'jpeg') $ext = 'jpg';

        // $allowedTypes above went unused and this accepted literally any file (a PDF included) as
        // long as save_moved_file() succeeded - a non-image upload must fall through to
        // upload_video_file()/upload_document_file() instead of being silently renamed img_*.<ext>.
        if (!in_array($ext, $allowedExts, true) && !in_array(strtolower($file['type'] ?? ''), $allowedTypes, true)) {
            return null;
        }

        $fileName = uniqid('img_', true) . '.' . $ext;

        $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
        if (!file_exists($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $targetFilePath = $targetDir . $fileName;
        if (save_moved_file($file, $targetFilePath)) {
            return 'uploads/' . $subfolder . '/' . $fileName;
        }

        return null;
    }
}

if (!function_exists('upload_video_file')) {
    function upload_video_file(array $file, string $subfolder = 'videos'): ?string {
        if (empty($file['tmp_name']) || !file_exists($file['tmp_name'])) {
            return null;
        }
        if (isset($file['error']) && (int)$file['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        $allowedExts = ['mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv'];
        $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));
        if (empty($ext)) {
            $mimeToExt = [
                'video/mp4' => 'mp4',
                'video/webm' => 'webm',
                'video/ogg' => 'ogg',
                'video/quicktime' => 'mov',
                'video/x-msvideo' => 'avi'
            ];
            $ext = $mimeToExt[$file['type'] ?? ''] ?? '';
        }

        // Same mistake as upload_image_file() used to make: accepting any extension here meant a
        // non-video upload never reached upload_document_file()/upload_audio_file() in the fallback
        // chain, since this function would already have "succeeded" and renamed it vid_*.<ext>.
        if (!in_array($ext, $allowedExts, true)) {
            return null;
        }

        $fileName = uniqid('vid_', true) . '.' . $ext;

        $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
        if (!file_exists($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $targetFilePath = $targetDir . $fileName;
        if (save_moved_file($file, $targetFilePath)) {
            return 'uploads/' . $subfolder . '/' . $fileName;
        }

        return null;
    }
}

if (!function_exists('upload_document_file')) {
    function upload_document_file(array $file, string $subfolder = 'documents'): ?string {
        if (empty($file['tmp_name']) || !file_exists($file['tmp_name'])) {
            return null;
        }
        if (isset($file['error']) && (int)$file['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));
        $allowedExts = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'zip'];
        if (empty($ext) || !in_array($ext, $allowedExts)) {
            $ext = 'pdf';
        }

        $fileName = uniqid('doc_', true) . '.' . $ext;

        $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
        if (!file_exists($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $targetFilePath = $targetDir . $fileName;
        if (save_moved_file($file, $targetFilePath)) {
            return 'uploads/' . $subfolder . '/' . $fileName;
        }

        return null;
    }
}

if (!function_exists('upload_audio_file')) {
    function upload_audio_file(array $file, string $subfolder = 'audio'): ?string {
        if (empty($file['tmp_name']) || !file_exists($file['tmp_name'])) {
            return null;
        }
        if (isset($file['error']) && (int)$file['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));
        $allowedExts = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'opus', 'amr', 'wma', 'flac', 'caf', '3gp', 'webm'];
        if (empty($ext) || !in_array($ext, $allowedExts)) {
            $mimeToExt = [
                'audio/mpeg' => 'mp3',
                'audio/mp3' => 'mp3',
                'audio/wav' => 'wav',
                'audio/x-wav' => 'wav',
                'audio/aac' => 'aac',
                'audio/mp4' => 'm4a',
                'audio/m4a' => 'm4a',
                'audio/ogg' => 'ogg',
                'audio/amr' => 'amr',
                'audio/3gpp' => '3gp',
                'audio/webm' => 'webm'
            ];
            $ext = $mimeToExt[$file['type'] ?? ''] ?? 'mp3';
        }

        $fileName = uniqid('aud_', true) . '.' . $ext;

        $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
        if (!file_exists($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $targetFilePath = $targetDir . $fileName;
        if (save_moved_file($file, $targetFilePath)) {
            return 'uploads/' . $subfolder . '/' . $fileName;
        }

        return null;
    }
}

if (!function_exists('process_receipt_input')) {
    /**
     * A file offered as proof of payment: an image or a PDF, as base64 or as an upload.
     *
     * process_image_input() covers the image half and refuses the other: a PDF arrives as
     * `data:application/pdf;base64,` and its allow-list only names image, video and audio. A
     * receipt is a photo of a screen as often as it is a bank's PDF, so both have to be taken -
     * and nothing else, because the one thing this must never do is write an executable
     * extension into a directory that is served back.
     */
    function process_receipt_input($input, string $subfolder = 'receipts', ?array $fileInput = null): ?string {
        if (is_array($fileInput) && !empty($fileInput['tmp_name'])) {
            $ext = strtolower(pathinfo($fileInput['name'] ?? '', PATHINFO_EXTENSION));
            if ($ext === 'pdf') {
                return upload_document_file($fileInput, $subfolder);
            }
            return upload_image_file($fileInput, $subfolder) ?? upload_document_file($fileInput, $subfolder);
        }

        if (is_string($input) && preg_match('/^data:application\/pdf;base64,/i', trim($input))) {
            $input = trim($input);
            $payload = base64_decode(substr($input, strpos($input, ',') + 1));
            if ($payload === false) {
                return null;
            }

            // The same ceiling process_image_input() applies, for the same reason: a data URI is
            // ~4/3 the size of its payload, and without a limit one request can fill the disk.
            if (strlen($payload) > 12 * 1024 * 1024) {
                return null;
            }

            $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
            if (!file_exists($targetDir)) {
                mkdir($targetDir, 0777, true);
            }

            $fileName = uniqid('doc_', true) . '.pdf';
            if (file_put_contents($targetDir . $fileName, $payload)) {
                return 'uploads/' . $subfolder . '/' . $fileName;
            }
            return null;
        }

        return process_image_input($input, $subfolder, $fileInput);
    }
}

if (!function_exists('process_image_input')) {
    function process_image_input($imageInput, string $subfolder = 'avatars', ?array $fileInput = null): ?string {
        if (is_array($fileInput) && isset($fileInput['tmp_name']) && !empty($fileInput['tmp_name'])) {
            $uploaded = upload_image_file($fileInput, $subfolder) ?? upload_audio_file($fileInput, $subfolder) ?? upload_video_file($fileInput, $subfolder) ?? upload_document_file($fileInput, $subfolder);
            if ($uploaded) return $uploaded;
        }

        if (empty($imageInput) || !is_string($imageInput)) {
            return null;
        }

        $imageInput = trim($imageInput);

        if (preg_match('/^data:(image|video|audio)\/(\w+);base64,/i', $imageInput, $matches)) {
            $mediaType = strtolower($matches[1]);
            $type = strtolower($matches[2]);
            $mediaData = substr($imageInput, strpos($imageInput, ',') + 1);
            $decodedData = base64_decode($mediaData);

            if ($decodedData === false) {
                return null;
            }

            $prefix = ($mediaType === 'video') ? 'vid_' : (($mediaType === 'audio') ? 'aud_' : 'img_');
            $ext = ($type === 'jpeg') ? 'jpg' : (($type === 'mpeg') ? 'mp3' : $type);

            // REMOTE CODE EXECUTION GUARD. The extension used to be whatever subtype the caller
            // put after "data:image/", and `\w+` happily matches "php" - so a student filing an
            // offline-payment receipt as "data:image/php;base64,<webshell>" had a .php file
            // written into uploads/ and served straight back by the rewrite rule, which passes
            // any file that exists on disk. An allow-list is the fix: anything not named here is
            // refused rather than coerced, because guessing an extension for unknown input is how
            // this happened in the first place.
            $allowed = [
                'image' => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
                'video' => ['mp4', 'webm', 'ogg', 'mov'],
                'audio' => ['mp3', 'wav', 'ogg', 'webm', 'm4a', 'aac'],
            ];
            if (!in_array($ext, $allowed[$mediaType] ?? [], true)) {
                return null;
            }

            // A data URI is ~4/3 the size of its payload; 12MB of base64 is about 9MB of file.
            // Without a ceiling a single request can fill the disk.
            if (strlen($mediaData) > 12 * 1024 * 1024) {
                return null;
            }

            $fileName = uniqid($prefix, true) . '.' . $ext;

            $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
            if (!file_exists($targetDir)) {
                mkdir($targetDir, 0777, true);
            }

            $targetFilePath = $targetDir . $fileName;
            if (file_put_contents($targetFilePath, $decodedData)) {
                return 'uploads/' . $subfolder . '/' . $fileName;
            }
            return null;
        }

        return $imageInput;
    }
}

if (!function_exists('upload_blocked_extensions')) {
    /**
     * The extensions that are refused no matter what, because the rest of this file is now an
     * allow-list of one: anything.
     *
     * Every other uploader here names the extensions it accepts. A product file cannot - the
     * whole point is that an owner may attach a CAD drawing, a font, an .apk or something nobody
     * thought of. So the rule is inverted, and what is named is what must never land in
     * `uploads/`: anything a web server might decide to RUN.
     *
     * This is the FIRST lock, not the only one. `uploads/.htaccess` already turns the PHP engine
     * off, strips the handlers and refuses to serve these outright, which is what makes accepting
     * arbitrary files defensible at all. A deny-list on its own would not be - deny-lists are
     * beaten by the extension nobody listed - but a deny-list in front of a directory that cannot
     * execute anything is a second lock on a closed door.
     */
    function upload_blocked_extensions(): array {
        return [
            // Server-side executables and anything a misconfigured handler may run.
            'php', 'php2', 'php3', 'php4', 'php5', 'php6', 'php7', 'php8', 'phps', 'phtml', 'pht',
            'phar', 'inc', 'shtml', 'shtm', 'cgi', 'pl', 'py', 'rb', 'jsp', 'jspx', 'asp', 'aspx',
            'asa', 'asax', 'cfm', 'cfc',
            // Windows and shell executables, in case a file is downloaded and opened.
            'exe', 'com', 'bat', 'cmd', 'msi', 'scr', 'vbs', 'vbe', 'js', 'jse', 'wsf', 'wsh',
            'ps1', 'psm1', 'sh', 'bash', 'jar', 'dll', 'so',
            // Server configuration. An .htaccess in uploads/ could undo the protection above.
            'htaccess', 'htpasswd', 'ini', 'conf',
        ];
    }
}

if (!function_exists('upload_extension_is_allowed')) {
    /**
     * A double extension is the classic way past a deny-list: `invoice.php.pdf` on one server,
     * `invoice.pdf.php` on another, depending on how the handler is configured. So EVERY segment
     * of the name is checked, not only the last one.
     */
    function upload_extension_is_allowed(string $fileName): bool {
        $blocked = upload_blocked_extensions();
        $segments = explode('.', strtolower($fileName));
        array_shift($segments); // the base name itself is not an extension

        foreach ($segments as $segment) {
            if (in_array(trim($segment), $blocked, true)) {
                return false;
            }
        }

        return true;
    }
}

if (!function_exists('upload_safe_basename')) {
    /**
     * The original name, kept for display only - never used as a path.
     *
     * The file on disk is always given a generated name; this is what the download is called when
     * somebody saves it, so an owner who uploaded "دليل المقاس.pdf" sees that rather than
     * "file_6930ab.pdf". Stripped of anything that could traverse a directory, because it is
     * stored and later echoed back.
     */
    function upload_safe_basename(string $fileName): string {
        $name = basename(str_replace('\\', '/', $fileName));
        $name = preg_replace('/[\x00-\x1F\x7F]/u', '', $name);
        $name = str_replace(['..', '/', '\\'], '', (string)$name);
        $name = trim((string)$name);

        if ($name === '') {
            return 'file';
        }

        return function_exists('mb_substr') ? mb_substr($name, 0, 180, 'UTF-8') : substr($name, 0, 180);
    }
}

if (!function_exists('upload_any_file')) {
    /**
     * A file of any kind, for a product attachment.
     *
     * Returns null on refusal, or on success an array rather than a bare path - because what a
     * product needs to show is not only where the file is but what it is called, how big it is
     * and what kind it appears to be, and recomputing that from the path later means stat()ing a
     * file on every list.
     *
     *   ['path' => 'uploads/products/file_x.ai', 'name' => 'المخطط.ai', 'extension' => 'ai',
     *    'size' => 184320, 'mime' => 'application/postscript']
     */
    function upload_any_file(array $file, string $subfolder = 'products'): ?array {
        if (empty($file['tmp_name']) || !file_exists($file['tmp_name'])) {
            return null;
        }
        if (isset($file['error']) && (int)$file['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        $originalName = upload_safe_basename((string)($file['name'] ?? 'file'));
        if (!upload_extension_is_allowed($originalName)) {
            return null;
        }

        $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        // A file with no extension is kept as-is rather than guessed at: inventing ".pdf" for an
        // unknown file is how upload_document_file() ends up writing a mislabelled download.
        $ext = preg_replace('/[^a-z0-9]/', '', $ext) ?: '';

        $storedName = uniqid('file_', true) . ($ext !== '' ? '.' . $ext : '');

        $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
        if (!file_exists($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $targetFilePath = $targetDir . $storedName;
        $size = (int)($file['size'] ?? 0);
        $mime = (string)($file['type'] ?? '');

        if (!save_moved_file($file, $targetFilePath)) {
            return null;
        }

        if ($size <= 0 && file_exists($targetFilePath)) {
            $size = (int)filesize($targetFilePath);
        }

        return [
            'path' => 'uploads/' . $subfolder . '/' . $storedName,
            'name' => $originalName,
            'extension' => $ext,
            'size' => $size,
            'mime' => $mime,
        ];
    }
}

if (!function_exists('process_any_file_input')) {
    /**
     * The same three ways every other field here accepts a file - a multipart upload, a base64
     * data URI, or a path/URL already on the server - resolved to the array upload_any_file()
     * returns.
     *
     * The data URI branch exists because the dashboards post JSON, not multipart, for everything
     * else; unlike process_image_input() it accepts ANY media type, and gets its extension from
     * `name` when one is supplied rather than from the mime subtype. Taking the extension from
     * the subtype is exactly the hole that let "data:image/php;base64,..." write a webshell, so
     * the subtype is used only as a last resort and is run through the same deny-list.
     */
    function process_any_file_input($input, string $subfolder = 'products', ?array $fileInput = null, ?string $originalName = null): ?array {
        if (is_array($fileInput) && !empty($fileInput['tmp_name'])) {
            return upload_any_file($fileInput, $subfolder);
        }

        if (empty($input) || !is_string($input)) {
            return null;
        }

        $input = trim($input);

        if (preg_match('/^data:([^;,]*);base64,/i', $input, $matches)) {
            $mime = strtolower(trim($matches[1]));
            $data = base64_decode(substr($input, strpos($input, ',') + 1), true);
            if ($data === false) {
                return null;
            }

            // 25 MiB of decoded bytes. A data URI is ~4/3 the size of what it carries, and
            // without a ceiling one request can fill the disk.
            if (strlen($data) > 25 * 1024 * 1024) {
                return null;
            }

            $name = upload_safe_basename((string)($originalName ?: 'file'));
            $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));

            if ($ext === '' && $mime !== '' && strpos($mime, '/') !== false) {
                $ext = strtolower(preg_replace('/[^a-z0-9]/i', '', substr($mime, strpos($mime, '/') + 1)));
                $name = $ext !== '' ? $name . '.' . $ext : $name;
            }

            if (!upload_extension_is_allowed($name)) {
                return null;
            }

            $storedName = uniqid('file_', true) . ($ext !== '' ? '.' . $ext : '');
            $targetDir = __DIR__ . '/../uploads/' . $subfolder . '/';
            if (!file_exists($targetDir)) {
                mkdir($targetDir, 0777, true);
            }

            if (file_put_contents($targetDir . $storedName, $data) === false) {
                return null;
            }

            return [
                'path' => 'uploads/' . $subfolder . '/' . $storedName,
                'name' => $name,
                'extension' => $ext,
                'size' => strlen($data),
                'mime' => $mime,
            ];
        }

        // Already a stored path or an external URL - kept as given, which is how an admin
        // re-saves a product without re-uploading its file.
        $name = upload_safe_basename($originalName ?: basename(parse_url($input, PHP_URL_PATH) ?: $input));

        return [
            'path' => $input,
            'name' => $name,
            'extension' => strtolower(pathinfo($name, PATHINFO_EXTENSION)),
            'size' => 0,
            'mime' => '',
        ];
    }
}
