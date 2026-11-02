-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 07, 2026 at 05:39 AM
-- Server version: 10.11.19-MariaDB-cll-lve-log
-- PHP Version: 8.4.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `campcod1_najeh`
--

-- --------------------------------------------------------

--
-- Table structure for table `academic_years`
--

CREATE TABLE `academic_years` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `number` smallint(5) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `academic_years`
--

INSERT INTO `academic_years` (`id`, `code`, `number`, `is_active`, `created_at`, `updated_at`) VALUES
(9, 'grade-9', 9, 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 'seconde', 10, 1, '2026-08-10 16:00:00', '2026-09-25 08:53:00'),
(11, 'bac1-scientific', 11, 1, '2026-08-10 16:00:00', '2026-09-25 08:53:01'),
(12, 'terminale-ls', 12, 1, '2026-08-10 16:00:00', '2026-09-25 08:53:01'),
(14, 'bac1-humanities', 11, 1, '2026-09-24 18:15:00', '2026-09-25 08:52:47'),
(15, 'terminale-gs', 13, 1, '2026-09-25 08:53:01', '2026-09-25 08:53:01'),
(16, 'terminale-se', 14, 1, '2026-09-25 08:53:01', '2026-09-25 08:53:01'),
(17, 'terminale-lh', 15, 1, '2026-09-25 08:53:01', '2026-09-25 08:53:01'),
(18, 'seconde-all', 10, 1, '2026-09-25 23:43:32', '2026-09-25 23:43:32'),
(19, 'terminale-all', 12, 1, '2026-09-25 23:43:32', '2026-09-25 23:43:32');

-- --------------------------------------------------------

--
-- Table structure for table `academic_years_translations`
--

CREATE TABLE `academic_years_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `academic_year_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `academic_years_translations`
--

INSERT INTO `academic_years_translations` (`id`, `academic_year_id`, `language_id`, `name`, `is_active`, `created_at`, `updated_at`) VALUES
(17, 9, 1, 'السنة التاسعة الأساسية', 1, '2026-08-10 16:00:00', '2026-09-25 08:53:00'),
(18, 9, 2, 'Grade Nine', 1, '2026-08-10 16:00:00', '2026-09-25 09:33:15'),
(19, 10, 1, 'التعليم الثانوي - السنة الأولى', 1, '2026-08-10 16:00:00', '2026-09-25 08:53:00'),
(20, 10, 2, 'First Secondary', 1, '2026-08-10 16:00:00', '2026-09-25 09:33:16'),
(21, 11, 1, 'التعليم الثانوي - السنة الثانية - فرع العلوم', 1, '2026-08-10 16:00:00', '2026-09-25 08:53:01'),
(22, 11, 2, 'Second Secondary - Sciences Section', 1, '2026-08-10 16:00:00', '2026-09-25 09:33:16'),
(23, 12, 1, 'التعليم الثانوي - السنة الثالثة - فرع علوم الحياة', 1, '2026-08-10 16:00:00', '2026-09-25 08:53:01'),
(24, 12, 2, 'Third Secondary - Life Sciences', 1, '2026-08-10 16:00:00', '2026-09-25 09:33:16'),
(27, 14, 1, 'التعليم الثانوي - السنة الثانية - فرع الإنسانيات', 1, '2026-09-24 18:15:00', '2026-09-25 08:52:47'),
(28, 14, 2, 'Second Secondary - Humanities Section', 1, '2026-09-24 18:15:00', '2026-09-25 09:33:16'),
(51, 15, 1, 'التعليم الثانوي - السنة الثالثة - فرع العلوم العامة', 1, '2026-09-25 08:53:01', '2026-09-25 08:53:01'),
(52, 15, 2, 'Third Secondary - General Sciences', 1, '2026-09-25 08:53:01', '2026-09-25 09:33:16'),
(53, 16, 1, 'التعليم الثانوي - السنة الثالثة - فرع الاجتماع والاقتصاد', 1, '2026-09-25 08:53:01', '2026-09-25 08:53:01'),
(54, 16, 2, 'Third Secondary - Sociology & Economics', 1, '2026-09-25 08:53:01', '2026-09-25 09:33:16'),
(55, 17, 1, 'التعليم الثانوي - السنة الثالثة - فرع الآداب والإنسانيات', 1, '2026-09-25 08:53:01', '2026-09-25 08:53:01'),
(56, 17, 2, 'Third Secondary - Literature & Humanities', 1, '2026-09-25 08:53:01', '2026-09-25 09:33:16'),
(81, 18, 1, 'التعليم الثانوي - السنة الثانية (جميع الفروع)', 1, '2026-09-25 23:43:32', '2026-09-25 23:43:32'),
(82, 18, 2, 'Second Secondary - All Branches', 1, '2026-09-25 23:43:32', '2026-09-25 23:43:32'),
(83, 19, 1, 'التعليم الثانوي - السنة الثالثة (جميع الفروع)', 1, '2026-09-25 23:43:32', '2026-09-25 23:43:32'),
(84, 19, 2, 'Third Secondary - All Branches', 1, '2026-09-25 23:43:32', '2026-09-25 23:43:32');

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password` varchar(255) NOT NULL,
  `image` varchar(500) DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `role` enum('super_admin','admin','moderator') NOT NULL DEFAULT 'admin',
  `role_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `admin_permissions`
--

CREATE TABLE `admin_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_permissions`
--

INSERT INTO `admin_permissions` (`id`, `admin_id`, `permission_id`, `created_at`) VALUES
(1, 2, 1, '2026-08-30 12:45:09'),
(2, 2, 3, '2026-08-30 12:45:09'),
(3, 2, 4, '2026-08-30 12:45:09'),
(4, 2, 5, '2026-08-30 12:45:09'),
(5, 2, 8, '2026-08-30 12:45:09'),
(6, 2, 9, '2026-08-30 12:45:09'),
(19, 3, 14, '2026-08-30 13:09:38'),
(20, 3, 21, '2026-08-30 13:09:38'),
(21, 3, 27, '2026-08-30 13:09:38');

-- --------------------------------------------------------

--
-- Table structure for table `advertisements`
--

CREATE TABLE `advertisements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `link` varchar(1000) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `type` enum('banner','media','text') NOT NULL DEFAULT 'banner',
  `status` enum('draft','published') NOT NULL DEFAULT 'draft',
  `user_type` enum('student','teacher','parent') DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `advertisements_translations`
--

CREATE TABLE `advertisements_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `advertisement_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `image` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `affiliates`
--

CREATE TABLE `affiliates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `affiliate_code` varchar(100) NOT NULL,
  `commission_type` enum('percentage','fixed') NOT NULL,
  `commission_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `affiliate_commissions`
--

CREATE TABLE `affiliate_commissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `affiliate_id` bigint(20) UNSIGNED NOT NULL,
  `referred_student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `item_type` enum('course','book','subscription_code','other') DEFAULT 'subscription_code',
  `item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `purchase_amount` decimal(10,2) DEFAULT 0.00,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `commission_date` datetime NOT NULL,
  `status` enum('pending','approved','paid','rejected') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `approved_by_admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_exception_requests`
--

CREATE TABLE `attendance_exception_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `occurrence_date` date NOT NULL,
  `requested_by_type` enum('teacher','student') NOT NULL,
  `requested_by_id` bigint(20) UNSIGNED NOT NULL,
  `request_type` enum('absence_permission','late_notice') NOT NULL,
  `reason` text NOT NULL,
  `expected_minutes_late` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by_admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `admin_note` text DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `availability_slot_bookings`
--

CREATE TABLE `availability_slot_bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `slot_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('booked','cancelled','attended','missed') NOT NULL DEFAULT 'booked',
  `booked_by_type` enum('student','admin','teacher') NOT NULL DEFAULT 'student',
  `booked_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `banners`
--

CREATE TABLE `banners` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title_ar` varchar(255) DEFAULT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `image_ar` varchar(500) NOT NULL,
  `image_en` varchar(500) DEFAULT NULL,
  `link` varchar(500) DEFAULT NULL,
  `type` enum('image','video') NOT NULL DEFAULT 'image',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `banner_views`
--

CREATE TABLE `banner_views` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `banner_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_type` varchar(50) DEFAULT 'guest',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `book_teachers`
--

CREATE TABLE `book_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `certificates`
--

CREATE TABLE `certificates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `academic_year_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(100) NOT NULL,
  `score` decimal(8,2) NOT NULL DEFAULT 0.00,
  `certificate_type` varchar(50) NOT NULL DEFAULT 'general',
  `image` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `certificates_translations`
--

CREATE TABLE `certificates_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `certificate_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `certificate_teachers`
--

CREATE TABLE `certificate_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `certificate_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cities_translations`
--

CREATE TABLE `cities_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `city_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `class_sessions`
--

CREATE TABLE `class_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(50) DEFAULT NULL,
  `day_of_week` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room` varchar(100) DEFAULT NULL,
  `is_online` tinyint(1) NOT NULL DEFAULT 0,
  `meeting_link` varchar(500) DEFAULT NULL,
  `grade` varchar(100) DEFAULT NULL,
  `academic_year_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `class_session_notification_log`
--

CREATE TABLE `class_session_notification_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `notify_type` varchar(50) NOT NULL,
  `session_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `code_redemptions_log`
--

CREATE TABLE `code_redemptions_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subscription_code_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `redeemed_at` timestamp NULL DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `consultation_slots`
--

CREATE TABLE `consultation_slots` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'educational',
  `meeting_type` enum('offline','video_call','chat','online') NOT NULL DEFAULT 'video_call',
  `slot_date` date NOT NULL,
  `slot_time` time NOT NULL,
  `notes` text DEFAULT NULL,
  `is_booked` tinyint(1) NOT NULL DEFAULT 0,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `booked_at` timestamp NULL DEFAULT NULL,
  `status` enum('available','pending','approved','rejected') NOT NULL DEFAULT 'available',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `iso2` char(2) NOT NULL COMMENT 'ISO 3166-1 alpha-2, uppercase',
  `name_ar` varchar(150) NOT NULL,
  `name_en` varchar(150) NOT NULL,
  `dial_code` varchar(10) NOT NULL DEFAULT '',
  `currency_code` char(3) NOT NULL COMMENT 'The currency a price for this country is entered in',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 100,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `countries`
--

INSERT INTO `countries` (`id`, `iso2`, `name_ar`, `name_en`, `dial_code`, `currency_code`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'EG', 'مصر', 'Egypt', '20', 'EGP', 1, 1, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(2, 'SA', 'المملكة العربية السعودية', 'Saudi Arabia', '966', 'SAR', 1, 2, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(3, 'AE', 'الإمارات العربية المتحدة', 'United Arab Emirates', '971', 'AED', 1, 3, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(4, 'KW', 'الكويت', 'Kuwait', '965', 'KWD', 1, 4, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(5, 'QA', 'قطر', 'Qatar', '974', 'QAR', 1, 5, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(6, 'BH', 'البحرين', 'Bahrain', '973', 'BHD', 1, 6, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(7, 'OM', 'عُمان', 'Oman', '968', 'OMR', 1, 7, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(8, 'JO', 'الأردن', 'Jordan', '962', 'JOD', 1, 8, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(9, 'LB', 'لبنان', 'Lebanon', '961', 'LBP', 1, 9, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(10, 'IQ', 'العراق', 'Iraq', '964', 'IQD', 1, 10, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(11, 'PS', 'الأراضي الفلسطينية', 'Palestinian Territories', '970', 'ILS', 1, 11, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(12, 'SY', 'سوريا', 'Syria', '963', 'SYP', 1, 12, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(13, 'YE', 'اليمن', 'Yemen', '967', 'YER', 1, 13, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(14, 'LY', 'ليبيا', 'Libya', '218', 'LYD', 1, 14, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(15, 'SD', 'السودان', 'Sudan', '249', 'SDG', 1, 15, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(16, 'MA', 'المغرب', 'Morocco', '212', 'MAD', 1, 16, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(17, 'DZ', 'الجزائر', 'Algeria', '213', 'DZD', 1, 17, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(18, 'TN', 'تونس', 'Tunisia', '216', 'TND', 1, 18, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(19, 'MR', 'موريتانيا', 'Mauritania', '222', 'MRU', 1, 19, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(20, 'SO', 'الصومال', 'Somalia', '252', 'SOS', 1, 20, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(21, 'DJ', 'جيبوتي', 'Djibouti', '253', 'DJF', 1, 21, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(22, 'KM', 'جزر القمر', 'Comoros', '269', 'KMF', 1, 22, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(23, 'AD', 'أندورا', 'Andorra', '376', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(24, 'AF', 'أفغانستان', 'Afghanistan', '93', 'AFN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(25, 'AG', 'أنتيغوا وبربودا', 'Antigua & Barbuda', '1268', 'XCD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(26, 'AL', 'ألبانيا', 'Albania', '355', 'ALL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(27, 'AM', 'أرمينيا', 'Armenia', '374', 'AMD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(28, 'AO', 'أنغولا', 'Angola', '244', 'AOA', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(29, 'AR', 'الأرجنتين', 'Argentina', '54', 'ARS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(30, 'AT', 'النمسا', 'Austria', '43', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(31, 'AU', 'أستراليا', 'Australia', '61', 'AUD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(32, 'AW', 'أروبا', 'Aruba', '297', 'AWG', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(33, 'AZ', 'أذربيجان', 'Azerbaijan', '994', 'AZN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(34, 'BA', 'البوسنة والهرسك', 'Bosnia & Herzegovina', '387', 'BAM', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(35, 'BB', 'بربادوس', 'Barbados', '1246', 'BBD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(36, 'BD', 'بنغلاديش', 'Bangladesh', '880', 'BDT', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(37, 'BE', 'بلجيكا', 'Belgium', '32', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(38, 'BF', 'بوركينا فاسو', 'Burkina Faso', '226', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(39, 'BG', 'بلغاريا', 'Bulgaria', '359', 'BGN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(40, 'BI', 'بوروندي', 'Burundi', '257', 'BIF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(41, 'BJ', 'بنين', 'Benin', '229', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(42, 'BN', 'بروناي', 'Brunei', '673', 'BND', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(43, 'BO', 'بوليفيا', 'Bolivia', '591', 'BOB', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(44, 'BQ', 'هولندا الكاريبية', 'Caribbean Netherlands', '599', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(45, 'BR', 'البرازيل', 'Brazil', '55', 'BRL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(46, 'BS', 'جزر البهاما', 'Bahamas', '1242', 'BSD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(47, 'BT', 'بوتان', 'Bhutan', '975', 'BTN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(48, 'BW', 'بوتسوانا', 'Botswana', '267', 'BWP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(49, 'BY', 'بيلاروس', 'Belarus', '375', 'BYN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(50, 'BZ', 'بليز', 'Belize', '501', 'BZD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(51, 'CA', 'كندا', 'Canada', '1', 'CAD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(52, 'CD', 'الكونغو - كينشاسا', 'Congo - Kinshasa', '243', 'CDF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(53, 'CF', 'جمهورية أفريقيا الوسطى', 'Central African Republic', '236', 'XAF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(54, 'CG', 'الكونغو - برازافيل', 'Congo - Brazzaville', '242', 'XAF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(55, 'CH', 'سويسرا', 'Switzerland', '41', 'CHF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(56, 'CI', 'ساحل العاج', 'Côte d’Ivoire', '225', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(57, 'CL', 'تشيلي', 'Chile', '56', 'CLP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(58, 'CM', 'الكاميرون', 'Cameroon', '237', 'XAF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(59, 'CN', 'الصين', 'China', '86', 'CNY', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(60, 'CO', 'كولومبيا', 'Colombia', '57', 'COP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(61, 'CR', 'كوستاريكا', 'Costa Rica', '506', 'CRC', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(62, 'CU', 'كوبا', 'Cuba', '53', 'CUP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(63, 'CV', 'الرأس الأخضر', 'Cape Verde', '238', 'CVE', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(64, 'CW', 'كوراساو', 'Curaçao', '599', 'ANG', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(65, 'CY', 'قبرص', 'Cyprus', '357', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(66, 'CZ', 'التشيك', 'Czechia', '420', 'CZK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(67, 'DE', 'ألمانيا', 'Germany', '49', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(68, 'DK', 'الدانمرك', 'Denmark', '45', 'DKK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(69, 'DM', 'دومينيكا', 'Dominica', '1767', 'XCD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(70, 'DO', 'جمهورية الدومينيكان', 'Dominican Republic', '1', 'DOP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(71, 'EC', 'الإكوادور', 'Ecuador', '593', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(72, 'EE', 'إستونيا', 'Estonia', '372', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(73, 'ER', 'إريتريا', 'Eritrea', '291', 'ERN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(74, 'ES', 'إسبانيا', 'Spain', '34', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(75, 'ET', 'إثيوبيا', 'Ethiopia', '251', 'ETB', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(76, 'FI', 'فنلندا', 'Finland', '358', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(77, 'FJ', 'فيجي', 'Fiji', '679', 'FJD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(78, 'FM', 'ميكرونيزيا', 'Micronesia', '691', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(79, 'FR', 'فرنسا', 'France', '33', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(80, 'GA', 'الغابون', 'Gabon', '241', 'XAF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(81, 'GB', 'المملكة المتحدة', 'United Kingdom', '44', 'GBP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(82, 'GD', 'غرينادا', 'Grenada', '1473', 'XCD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(83, 'GE', 'جورجيا', 'Georgia', '995', 'GEL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(84, 'GF', 'غويانا الفرنسية', 'French Guiana', '594', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(85, 'GH', 'غانا', 'Ghana', '233', 'GHS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(86, 'GM', 'غامبيا', 'Gambia', '220', 'GMD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(87, 'GN', 'غينيا', 'Guinea', '224', 'GNF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(88, 'GP', 'غوادلوب', 'Guadeloupe', '590', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(89, 'GQ', 'غينيا الاستوائية', 'Equatorial Guinea', '240', 'XAF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(90, 'GR', 'اليونان', 'Greece', '30', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(91, 'GT', 'غواتيمالا', 'Guatemala', '502', 'GTQ', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(92, 'GU', 'غوام', 'Guam', '1671', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(93, 'GW', 'غينيا بيساو', 'Guinea-Bissau', '245', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(94, 'GY', 'غيانا', 'Guyana', '592', 'GYD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(95, 'HK', 'هونغ كونغ الصينية (منطقة إدارية خاصة)', 'Hong Kong SAR China', '852', 'HKD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(96, 'HN', 'هندوراس', 'Honduras', '504', 'HNL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(97, 'HR', 'كرواتيا', 'Croatia', '385', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(98, 'HT', 'هايتي', 'Haiti', '509', 'HTG', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(99, 'HU', 'هنغاريا', 'Hungary', '36', 'HUF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(100, 'ID', 'إندونيسيا', 'Indonesia', '62', 'IDR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(101, 'IE', 'أيرلندا', 'Ireland', '353', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(102, 'IL', 'إسرائيل', 'Israel', '972', 'ILS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(103, 'IN', 'الهند', 'India', '91', 'INR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(104, 'IO', 'الإقليم البريطاني في المحيط الهندي', 'British Indian Ocean Territory', '246', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(105, 'IR', 'إيران', 'Iran', '98', 'IRR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(106, 'IS', 'آيسلندا', 'Iceland', '354', 'ISK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(107, 'IT', 'إيطاليا', 'Italy', '39', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(108, 'JM', 'جامايكا', 'Jamaica', '1876', 'JMD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(109, 'JP', 'اليابان', 'Japan', '81', 'JPY', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(110, 'KE', 'كينيا', 'Kenya', '254', 'KES', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(111, 'KG', 'قيرغيزستان', 'Kyrgyzstan', '996', 'KGS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(112, 'KH', 'كمبوديا', 'Cambodia', '855', 'KHR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(113, 'KI', 'كيريباتي', 'Kiribati', '686', 'AUD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(114, 'KN', 'سانت كيتس ونيفيس', 'St. Kitts & Nevis', '1869', 'XCD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(115, 'KP', 'كوريا الشمالية', 'North Korea', '850', 'KPW', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(116, 'KR', 'كوريا الجنوبية', 'South Korea', '82', 'KRW', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(117, 'KZ', 'كازاخستان', 'Kazakhstan', '7', 'KZT', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(118, 'LA', 'لاوس', 'Laos', '856', 'LAK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(119, 'LC', 'سانت لوسيا', 'St. Lucia', '1758', 'XCD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(120, 'LI', 'ليختنشتاين', 'Liechtenstein', '423', 'CHF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(121, 'LK', 'سريلانكا', 'Sri Lanka', '94', 'LKR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(122, 'LR', 'ليبيريا', 'Liberia', '231', 'LRD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(123, 'LS', 'ليسوتو', 'Lesotho', '266', 'LSL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(124, 'LT', 'ليتوانيا', 'Lithuania', '370', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(125, 'LU', 'لوكسمبورغ', 'Luxembourg', '352', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(126, 'LV', 'لاتفيا', 'Latvia', '371', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(127, 'MC', 'موناكو', 'Monaco', '377', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(128, 'MD', 'مولدوفا', 'Moldova', '373', 'MDL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(129, 'ME', 'الجبل الأسود', 'Montenegro', '382', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(130, 'MG', 'مدغشقر', 'Madagascar', '261', 'MGA', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(131, 'MH', 'جزر مارشال', 'Marshall Islands', '692', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(132, 'MK', 'مقدونيا الشمالية', 'North Macedonia', '389', 'MKD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(133, 'ML', 'مالي', 'Mali', '223', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(134, 'MM', 'ميانمار (بورما)', 'Myanmar (Burma)', '95', 'MMK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(135, 'MN', 'منغوليا', 'Mongolia', '976', 'MNT', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(136, 'MO', 'منطقة ماكاو الإدارية الخاصة', 'Macao SAR China', '853', 'MOP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(137, 'MQ', 'جزر المارتينيك', 'Martinique', '596', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(138, 'MT', 'مالطا', 'Malta', '356', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(139, 'MU', 'موريشيوس', 'Mauritius', '230', 'MUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(140, 'MV', 'جزر المالديف', 'Maldives', '960', 'MVR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(141, 'MW', 'ملاوي', 'Malawi', '265', 'MWK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(142, 'MX', 'المكسيك', 'Mexico', '52', 'MXN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(143, 'MY', 'ماليزيا', 'Malaysia', '60', 'MYR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(144, 'MZ', 'موزمبيق', 'Mozambique', '258', 'MZN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(145, 'NA', 'ناميبيا', 'Namibia', '264', 'NAD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(146, 'NC', 'كاليدونيا الجديدة', 'New Caledonia', '687', 'XPF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(147, 'NE', 'النيجر', 'Niger', '227', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(148, 'NG', 'نيجيريا', 'Nigeria', '234', 'NGN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(149, 'NI', 'نيكاراغوا', 'Nicaragua', '505', 'NIO', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(150, 'NL', 'هولندا', 'Netherlands', '31', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(151, 'NO', 'النرويج', 'Norway', '47', 'NOK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(152, 'NP', 'نيبال', 'Nepal', '977', 'NPR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(153, 'NR', 'ناورو', 'Nauru', '674', 'AUD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(154, 'NZ', 'نيوزيلندا', 'New Zealand', '64', 'NZD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(155, 'PA', 'بنما', 'Panama', '507', 'PAB', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(156, 'PE', 'بيرو', 'Peru', '51', 'PEN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(157, 'PF', 'بولينيزيا الفرنسية', 'French Polynesia', '689', 'XPF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(158, 'PG', 'بابوا غينيا الجديدة', 'Papua New Guinea', '675', 'PGK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(159, 'PH', 'الفلبين', 'Philippines', '63', 'PHP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(160, 'PK', 'باكستان', 'Pakistan', '92', 'PKR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(161, 'PL', 'بولندا', 'Poland', '48', 'PLN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(162, 'PR', 'بورتوريكو', 'Puerto Rico', '1', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(163, 'PT', 'البرتغال', 'Portugal', '351', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(164, 'PW', 'بالاو', 'Palau', '680', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(165, 'PY', 'باراغواي', 'Paraguay', '595', 'PYG', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(166, 'RE', 'روينيون', 'Réunion', '262', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(167, 'RO', 'رومانيا', 'Romania', '40', 'RON', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(168, 'RS', 'صربيا', 'Serbia', '381', 'RSD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(169, 'RU', 'روسيا', 'Russia', '7', 'RUB', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(170, 'RW', 'رواندا', 'Rwanda', '250', 'RWF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(171, 'SB', 'جزر سليمان', 'Solomon Islands', '677', 'SBD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(172, 'SC', 'سيشل', 'Seychelles', '248', 'SCR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(173, 'SE', 'السويد', 'Sweden', '46', 'SEK', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(174, 'SG', 'سنغافورة', 'Singapore', '65', 'SGD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(175, 'SI', 'سلوفينيا', 'Slovenia', '386', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(176, 'SK', 'سلوفاكيا', 'Slovakia', '421', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(177, 'SL', 'سيراليون', 'Sierra Leone', '232', 'SLE', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(178, 'SM', 'سان مارينو', 'San Marino', '378', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(179, 'SN', 'السنغال', 'Senegal', '221', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(180, 'SR', 'سورينام', 'Suriname', '597', 'SRD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(181, 'SS', 'جنوب السودان', 'South Sudan', '211', 'SSP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(182, 'ST', 'ساو تومي وبرينسيبي', 'São Tomé & Príncipe', '239', 'STN', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(183, 'SV', 'السلفادور', 'El Salvador', '503', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(184, 'SZ', 'إسواتيني', 'Eswatini', '268', 'SZL', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(185, 'TD', 'تشاد', 'Chad', '235', 'XAF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(186, 'TG', 'توغو', 'Togo', '228', 'XOF', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(187, 'TH', 'تايلاند', 'Thailand', '66', 'THB', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(188, 'TJ', 'طاجيكستان', 'Tajikistan', '992', 'TJS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(189, 'TL', 'تيمور - ليشتي', 'Timor-Leste', '670', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(190, 'TM', 'تركمانستان', 'Turkmenistan', '993', 'TMT', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(191, 'TO', 'تونغا', 'Tonga', '676', 'TOP', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(192, 'TR', 'تركيا', 'Türkiye', '90', 'TRY', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(193, 'TT', 'ترينيداد وتوباغو', 'Trinidad & Tobago', '1868', 'TTD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(194, 'TV', 'توفالو', 'Tuvalu', '688', 'AUD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(195, 'TW', 'تايوان', 'Taiwan', '886', 'TWD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(196, 'TZ', 'تنزانيا', 'Tanzania', '255', 'TZS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(197, 'UA', 'أوكرانيا', 'Ukraine', '380', 'UAH', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(198, 'UG', 'أوغندا', 'Uganda', '256', 'UGX', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(199, 'US', 'الولايات المتحدة', 'United States', '1', 'USD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(200, 'UY', 'أورغواي', 'Uruguay', '598', 'UYU', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(201, 'UZ', 'أوزبكستان', 'Uzbekistan', '998', 'UZS', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(202, 'VA', 'الفاتيكان', 'Vatican City', '39', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(203, 'VC', 'سانت فنسنت وجزر غرينادين', 'St. Vincent & Grenadines', '1784', 'XCD', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(204, 'VE', 'فنزويلا', 'Venezuela', '58', 'VES', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(205, 'VN', 'فيتنام', 'Vietnam', '84', 'VND', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(206, 'VU', 'فانواتو', 'Vanuatu', '678', 'VUV', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(207, 'WS', 'ساموا', 'Samoa', '685', 'WST', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(208, 'XK', 'كوسوفو', 'Kosovo', '383', 'EUR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(209, 'ZA', 'جنوب أفريقيا', 'South Africa', '27', 'ZAR', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(210, 'ZM', 'زامبيا', 'Zambia', '260', 'ZMW', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(211, 'ZW', 'زيمبابوي', 'Zimbabwe', '263', 'ZWG', 1, 100, '2026-09-28 09:59:25', '2026-09-28 09:59:25');

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `academic_year_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `slug` varchar(190) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'recorded',
  `kind` enum('normal','package') NOT NULL DEFAULT 'normal',
  `duration_months` tinyint(3) UNSIGNED DEFAULT NULL,
  `allow_video_download` tinyint(1) NOT NULL DEFAULT 0,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `image` varchar(500) DEFAULT NULL,
  `lessons_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `order_num` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `show_on_website` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `what_you_will_learn` text DEFAULT NULL,
  `video_preview_url` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `courses_translations`
--

CREATE TABLE `courses_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `what_you_will_learn` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_books`
--

CREATE TABLE `course_books` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `unit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `file_type` varchar(50) DEFAULT 'pdf',
  `category` enum('summary','exam') NOT NULL DEFAULT 'summary',
  `extension` varchar(20) DEFAULT 'pdf',
  `link` text DEFAULT NULL,
  `file_path` text DEFAULT NULL,
  `order_num` int(11) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `show_on_website` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `price` double DEFAULT 0,
  `allow_download` tinyint(1) NOT NULL DEFAULT 1,
  `cover_image` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_books_translations`
--

CREATE TABLE `course_books_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_categories`
--

CREATE TABLE `course_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `image` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_categories`
--

INSERT INTO `course_categories` (`id`, `code`, `image`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'natural-sciences', 'https://loremflickr.com/1000/700/science,laboratory,education?lock=101', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 'mathematics', 'https://loremflickr.com/1000/700/mathematics,geometry,education?lock=102', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 'languages-literature', 'https://loremflickr.com/1000/700/language,books,education?lock=103', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 'humanities-philosophy', 'https://loremflickr.com/1000/700/history,philosophy,books?lock=104', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 'technology', 'https://loremflickr.com/1000/700/computer,technology,coding?lock=105', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 'exam-revision', 'https://loremflickr.com/1000/700/exam,study,education?lock=106', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 'ground-science', 'uploads/avatars/img_6a7ad6868d5bd2.16878557.webp', 1, '2026-08-11 08:00:06', '2026-08-11 08:00:06');

-- --------------------------------------------------------

--
-- Table structure for table `course_categories_translations`
--

CREATE TABLE `course_categories_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_category_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_categories_translations`
--

INSERT INTO `course_categories_translations` (`id`, `course_category_id`, `language_id`, `name`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'العلوم الطبيعية', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'Natural Sciences', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'الرياضيات', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'Mathematics', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 3, 1, 'اللغات والآداب', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, 2, 'Languages & Literature', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 4, 1, 'العلوم الإنسانية والفلسفة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 4, 2, 'Humanities & Philosophy', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 5, 1, 'التكنولوجيا وعلوم الحاسب', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 5, 2, 'Technology & Computer Science', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(11, 6, 1, 'المراجعات والامتحانات', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(12, 6, 2, 'Exam Revision', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(13, 7, 1, 'علوم الأرض', 1, '2026-08-11 08:00:06', '2026-08-11 08:00:06'),
(14, 7, 2, 'Ground Science', 1, '2026-08-11 08:00:06', '2026-08-11 08:00:06');

-- --------------------------------------------------------

--
-- Table structure for table `course_exams`
--

CREATE TABLE `course_exams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `unit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_num` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `duration_minutes` int(11) NOT NULL DEFAULT 30,
  `total_marks` int(11) NOT NULL DEFAULT 100,
  `pass_marks` int(11) NOT NULL DEFAULT 50,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_exams_translations`
--

CREATE TABLE `course_exams_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_ratings`
--

CREATE TABLE `course_ratings` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_teachers`
--

CREATE TABLE `course_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `course_videos`
--

CREATE TABLE `course_videos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `unit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `duration` varchar(50) DEFAULT NULL,
  `video_url` text DEFAULT NULL,
  `order_num` int(11) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `course_videos_translations`
--

CREATE TABLE `course_videos_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `video_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `currencies`
--

CREATE TABLE `currencies` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` char(3) NOT NULL COMMENT 'ISO 4217',
  `name_ar` varchar(120) NOT NULL,
  `name_en` varchar(120) NOT NULL,
  `symbol_ar` varchar(20) NOT NULL,
  `symbol_en` varchar(20) NOT NULL,
  `decimal_digits` tinyint(3) UNSIGNED NOT NULL DEFAULT 2,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `currencies`
--

INSERT INTO `currencies` (`id`, `code`, `name_ar`, `name_en`, `symbol_ar`, `symbol_en`, `decimal_digits`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'AED', 'درهم إماراتي', 'United Arab Emirates Dirham', 'دإ', 'AED', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(2, 'AFN', 'أفغاني', 'Afghan Afghani', '؋', '؋', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(3, 'ALL', 'ليك ألباني', 'Albanian Lek', 'ALL', 'ALL', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(4, 'AMD', 'درام أرميني', 'Armenian Dram', '֏', '֏', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(5, 'ANG', 'غيلدر أنتيلي هولندي', 'Netherlands Antillean Guilder', 'ANG', 'ANG', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(6, 'AOA', 'كوانزا أنغولي', 'Angolan Kwanza', 'Kz', 'Kz', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(7, 'ARS', 'بيزو أرجنتيني', 'Argentine Peso', 'AR$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(8, 'AUD', 'دولار أسترالي', 'Australian Dollar', 'AU$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(9, 'AWG', 'فلورن أروبي', 'Aruban Florin', 'AWG', 'AWG', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(10, 'AZN', 'مانات أذربيجان', 'Azerbaijani Manat', '₼', '₼', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(11, 'BAM', 'مارك البوسنة والهرسك قابل للتحويل', 'Bosnia-Herzegovina Convertible Mark', 'KM', 'KM', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(12, 'BBD', 'دولار بربادوسي', 'Barbadian Dollar', 'BB$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(13, 'BDT', 'تاكا بنغلاديشي', 'Bangladeshi Taka', '৳', '৳', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(14, 'BGN', 'ليف بلغاري', 'Bulgarian Lev', 'BGN', 'BGN', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(15, 'BHD', 'دينار بحريني', 'Bahraini Dinar', 'دب', 'BHD', 3, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(16, 'BIF', 'فرنك بروندي', 'Burundian Franc', 'BIF', 'BIF', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(17, 'BND', 'دولار بروناي', 'Brunei Dollar', 'BN$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(18, 'BOB', 'بوليفيانو بوليفي', 'Bolivian Boliviano', 'Bs', 'Bs', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(19, 'BRL', 'ريال برازيلي', 'Brazilian Real', 'R$', 'R$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(20, 'BSD', 'دولار باهامي', 'Bahamian Dollar', 'BS$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(21, 'BTN', 'نولتوم بوتاني', 'Bhutanese Ngultrum', 'BTN', 'BTN', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(22, 'BWP', 'بولا بتسواني', 'Botswanan Pula', 'P', 'P', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(23, 'BYN', 'روبل بيلاروسي', 'Belarusian Ruble', 'р', 'BYN', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(24, 'BZD', 'دولار بليزي', 'Belize Dollar', 'BZ$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(25, 'CAD', 'دولار كندي', 'Canadian Dollar', 'CA$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(26, 'CDF', 'فرنك كونغولي', 'Congolese Franc', 'CDF', 'CDF', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(27, 'CHF', 'فرنك سويسري', 'Swiss Franc', 'CHF', 'CHF', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(28, 'CLP', 'بيزو تشيلي', 'Chilean Peso', 'CL$', '$', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(29, 'CNY', 'يوان صيني', 'Chinese Yuan', 'CN¥', '¥', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(30, 'COP', 'بيزو كولومبي', 'Colombian Peso', 'CO$', '$', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(31, 'CRC', 'كولن كوستاريكي', 'Costa Rican Colón', '₡', '₡', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(32, 'CUP', 'بيزو كوبي', 'Cuban Peso', 'CU$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(33, 'CVE', 'اسكودو الرأس الأخضر', 'Cape Verdean Escudo', 'CVE', 'CVE', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(34, 'CZK', 'كرونة تشيكية', 'Czech Koruna', 'Kč', 'Kč', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(35, 'DJF', 'فرنك جيبوتي', 'Djiboutian Franc', 'DJF', 'DJF', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(36, 'DKK', 'كرونة دنماركية', 'Danish Krone', 'kr', 'kr', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(37, 'DOP', 'بيزو الدومنيكان', 'Dominican Peso', 'DO$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(38, 'DZD', 'دينار جزائري', 'Algerian Dinar', 'دج', 'DZD', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(39, 'EGP', 'جنيه مصري', 'Egyptian Pound', 'E£', 'E£', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(40, 'ERN', 'ناكفا أريتري', 'Eritrean Nakfa', 'ERN', 'ERN', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(41, 'ETB', 'بير أثيوبي', 'Ethiopian Birr', 'ETB', 'ETB', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(42, 'EUR', 'يورو', 'Euro', '€', '€', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(43, 'FJD', 'دولار فيجي', 'Fijian Dollar', 'FJ$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(44, 'GBP', 'جنيه إسترليني', 'British Pound', 'UK£', '£', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(45, 'GEL', 'لارى جورجي', 'Georgian Lari', '₾', '₾', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(46, 'GHS', 'سيدي غانا', 'Ghanaian Cedi', 'GH₵', 'GH₵', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(47, 'GMD', 'دلاسي غامبي', 'Gambian Dalasi', 'GMD', 'GMD', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(48, 'GNF', 'فرنك غينيا', 'Guinean Franc', 'FG', 'FG', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(49, 'GTQ', 'كوتزال غواتيمالا', 'Guatemalan Quetzal', 'Q', 'Q', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(50, 'GYD', 'دولار غيانا', 'Guyanaese Dollar', 'GY$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(51, 'HKD', 'دولار هونغ كونغ', 'Hong Kong Dollar', 'HK$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(52, 'HNL', 'ليمبيرا هنداروس', 'Honduran Lempira', 'L', 'L', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(53, 'HTG', 'جوردى هايتي', 'Haitian Gourde', 'HTG', 'HTG', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(54, 'HUF', 'فورينت هنغاري', 'Hungarian Forint', 'Ft', 'Ft', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(55, 'IDR', 'روبية إندونيسية', 'Indonesian Rupiah', 'Rp', 'Rp', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(56, 'ILS', 'شيكل إسرائيلي جديد', 'Israeli New Shekel', '₪', '₪', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(57, 'INR', 'روبية هندي', 'Indian Rupee', '₹', '₹', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(58, 'IQD', 'دينار عراقي', 'Iraqi Dinar', 'دع', 'IQD', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(59, 'IRR', 'ريال إيراني', 'Iranian Rial', 'رإ', 'IRR', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(60, 'ISK', 'كرونة أيسلندية', 'Icelandic Króna', 'kr', 'kr', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(61, 'JMD', 'دولار جامايكي', 'Jamaican Dollar', 'JM$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(62, 'JOD', 'دينار أردني', 'Jordanian Dinar', 'دأ', 'JOD', 3, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(63, 'JPY', 'ين ياباني', 'Japanese Yen', 'JP¥', '¥', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(64, 'KES', 'شلن كينيي', 'Kenyan Shilling', 'KES', 'KES', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(65, 'KGS', 'سوم قيرغستاني', 'Kyrgyz Som', '⃀', '⃀', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(66, 'KHR', 'رييال كمبودي', 'Cambodian Riel', '៛', '៛', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(67, 'KMF', 'فرنك جزر القمر', 'Comorian Franc', 'CF', 'CF', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(68, 'KPW', 'وون كوريا الشمالية', 'North Korean Won', '₩', '₩', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(69, 'KRW', 'وون كوريا الجنوبية', 'South Korean Won', '₩', '₩', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(70, 'KWD', 'دينار كويتي', 'Kuwaiti Dinar', 'دك', 'KWD', 3, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(71, 'KZT', 'تينغ كازاخستاني', 'Kazakhstani Tenge', '₸', '₸', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(72, 'LAK', 'كيب لاوسي', 'Laotian Kip', '₭', '₭', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(73, 'LBP', 'جنيه لبناني', 'Lebanese Pound', 'L£', 'L£', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(74, 'LKR', 'روبية سريلانكية', 'Sri Lankan Rupee', 'Rs', 'Rs', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(75, 'LRD', 'دولار ليبيري', 'Liberian Dollar', '$LR', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(76, 'LSL', 'لوتي ليسوتو', 'Lesotho Loti', 'LSL', 'LSL', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(77, 'LYD', 'دينار ليبي', 'Libyan Dinar', 'دل', 'LYD', 3, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(78, 'MAD', 'درهم مغربي', 'Moroccan Dirham', 'دم', 'MAD', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(79, 'MDL', 'ليو مولدوفي', 'Moldovan Leu', 'MDL', 'MDL', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(80, 'MGA', 'أرياري مدغشقر', 'Malagasy Ariary', 'Ar', 'Ar', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(81, 'MKD', 'دينار مقدوني', 'Macedonian Denar', 'MKD', 'MKD', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(82, 'MMK', 'كيات ميانمار', 'Myanmar Kyat', 'K', 'K', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(83, 'MNT', 'توغروغ منغولي', 'Mongolian Tugrik', '₮', '₮', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(84, 'MOP', 'باتاكا ماكاوي', 'Macanese Pataca', 'MOP', 'MOP', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(85, 'MRU', 'أوقية موريتانية', 'Mauritanian Ouguiya', 'أم', 'MRU', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(86, 'MUR', 'روبية موريشيوسية', 'Mauritian Rupee', 'Rs', 'Rs', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(87, 'MVR', 'روفيه جزر المالديف', 'Maldivian Rufiyaa', 'MVR', 'MVR', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(88, 'MWK', 'كواشا مالاوي', 'Malawian Kwacha', 'MWK', 'MWK', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(89, 'MXN', 'بيزو مكسيكي', 'Mexican Peso', 'MX$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(90, 'MYR', 'رينغيت ماليزي', 'Malaysian Ringgit', 'RM', 'RM', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(91, 'MZN', 'متكال موزمبيقي', 'Mozambican Metical', 'MZN', 'MZN', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(92, 'NAD', 'دولار ناميبي', 'Namibian Dollar', '$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(93, 'NGN', 'نايرا نيجيري', 'Nigerian Naira', '₦', '₦', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(94, 'NIO', 'قرطبة نيكاراغوا', 'Nicaraguan Córdoba', 'C$', 'C$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(95, 'NOK', 'كرونة نرويجية', 'Norwegian Krone', 'kr', 'kr', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(96, 'NPR', 'روبية نيبالي', 'Nepalese Rupee', 'Rs', 'Rs', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(97, 'NZD', 'دولار نيوزيلندي', 'New Zealand Dollar', 'NZ$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(98, 'OMR', 'ريال عماني', 'Omani Rial', 'رع', 'OMR', 3, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(99, 'PAB', 'بالبوا بنمي', 'Panamanian Balboa', 'PAB', 'PAB', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(100, 'PEN', 'سول بيروفي', 'Peruvian Sol', 'PEN', 'PEN', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(101, 'PGK', 'كينا بابوا غينيا الجديدة', 'Papua New Guinean Kina', 'PGK', 'PGK', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(102, 'PHP', 'بيزو فلبيني', 'Philippine Peso', '₱', '₱', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(103, 'PKR', 'روبية باكستاني', 'Pakistani Rupee', 'Rs', 'Rs', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(104, 'PLN', 'زلوتي بولندي', 'Polish Zloty', 'zł', 'zł', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(105, 'PYG', 'غواراني باراغواي', 'Paraguayan Guarani', '₲', '₲', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(106, 'QAR', 'ريال قطري', 'Qatari Riyal', 'رق', 'QAR', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(107, 'RON', 'ليو روماني', 'Romanian Leu', 'lei', 'lei', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(108, 'RSD', 'دينار صربي', 'Serbian Dinar', 'RSD', 'RSD', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(109, 'RUB', 'روبل روسي', 'Russian Ruble', '₽', '₽', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(110, 'RWF', 'فرنك رواندي', 'Rwandan Franc', 'RF', 'RF', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(111, 'SAR', 'ريال سعودي', 'Saudi Riyal', 'رس', 'SAR', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(112, 'SBD', 'دولار جزر سليمان', 'Solomon Islands Dollar', 'SB$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(113, 'SCR', 'روبية سيشيلية', 'Seychellois Rupee', 'SCR', 'SCR', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(114, 'SDG', 'جنيه سوداني', 'Sudanese Pound', 'جس', 'SDG', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(115, 'SEK', 'كرونة سويدية', 'Swedish Krona', 'kr', 'kr', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(116, 'SGD', 'دولار سنغافوري', 'Singapore Dollar', '$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(117, 'SLE', 'ليون سيراليوني', 'Sierra Leonean Leone', 'SLE', 'SLE', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(118, 'SOS', 'شلن صومالي', 'Somali Shilling', 'SOS', 'SOS', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(119, 'SRD', 'دولار سورينامي', 'Surinamese Dollar', 'SR$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(120, 'SSP', 'جنيه جنوب السودان', 'South Sudanese Pound', '£', '£', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(121, 'STN', 'دوبرا ساو تومي وبرينسيبي', 'São Tomé & Príncipe Dobra', 'Db', 'Db', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(122, 'SYP', 'ليرة سورية', 'Syrian Pound', '£', '£', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(123, 'SZL', 'ليلانجيني سوازيلندي', 'Swazi Lilangeni', 'SZL', 'SZL', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(124, 'THB', 'باخت تايلاندي', 'Thai Baht', '฿', '฿', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(125, 'TJS', 'سوموني طاجيكستاني', 'Tajikistani Somoni', 'TJS', 'TJS', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(126, 'TMT', 'مانات تركمانستان', 'Turkmenistani Manat', 'TMT', 'TMT', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(127, 'TND', 'دينار تونسي', 'Tunisian Dinar', 'دت', 'TND', 3, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(128, 'TOP', 'بانغا تونغا', 'Tongan Paʻanga', 'T$', 'T$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(129, 'TRY', 'ليرة تركية', 'Turkish Lira', '₺', '₺', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(130, 'TTD', 'دولار ترينداد وتوباغو', 'Trinidad & Tobago Dollar', 'TT$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(131, 'TWD', 'دولار تايواني', 'New Taiwan Dollar', 'NT$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(132, 'TZS', 'شلن تنزاني', 'Tanzanian Shilling', 'TZS', 'TZS', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(133, 'UAH', 'هريفنيا أوكراني', 'Ukrainian Hryvnia', '₴', '₴', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(134, 'UGX', 'شلن أوغندي', 'Ugandan Shilling', 'UGX', 'UGX', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(135, 'USD', 'دولار أمريكي', 'US Dollar', 'US$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(136, 'UYU', 'بيزو اوروغواي', 'Uruguayan Peso', 'UY$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(137, 'UZS', 'سوم أوزبكستاني', 'Uzbekistani Som', 'UZS', 'UZS', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(138, 'VES', 'بوليفار فنزويلي', 'Venezuelan Bolívar', 'VES', 'VES', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(139, 'VND', 'دونج فيتنامي', 'Vietnamese Dong', '₫', '₫', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(140, 'VUV', 'فاتو فانواتو', 'Vanuatu Vatu', 'VUV', 'VUV', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(141, 'WST', 'تالا ساموا', 'Samoan Tala', 'WST', 'WST', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(142, 'XAF', 'فرنك وسط أفريقي', 'Central African CFA Franc', 'FCFA', 'FCFA', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(143, 'XCD', 'دولار شرق الكاريبي', 'East Caribbean Dollar', '$', '$', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(144, 'XOF', 'فرنك غرب أفريقي', 'West African CFA Franc', 'FCFA', 'FCFA', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(145, 'XPF', 'فرنك سي إف بي', 'CFP Franc', 'CFPF', 'CFPF', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(146, 'YER', 'ريال يمني', 'Yemeni Rial', 'ري', 'YER', 0, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(147, 'ZAR', 'راند جنوب أفريقيا', 'South African Rand', 'R', 'R', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(148, 'ZMW', 'كواشا زامبي', 'Zambian Kwacha', 'ZK', 'ZK', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25'),
(149, 'ZWG', 'ذهب زيمبابوي', 'Zimbabwean Gold', 'ZWG', 'ZWG', 2, 1, 0, '2026-09-28 09:59:25', '2026-09-28 09:59:25');

-- --------------------------------------------------------

--
-- Table structure for table `discount_codes`
--

CREATE TABLE `discount_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `discount_type` enum('percentage','fixed') NOT NULL DEFAULT 'percentage',
  `discount_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency_code` char(3) DEFAULT NULL COMMENT 'Which currency a fixed amount is in. NULL = the base currency. Ignored for percentage codes.',
  `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT 'Caps a percentage discount; ignored for fixed',
  `applies_to` enum('all','selected') NOT NULL DEFAULT 'all',
  `max_uses` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL = unlimited',
  `used_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `once_per_student` tinyint(1) NOT NULL DEFAULT 1,
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `discount_code_courses`
--

CREATE TABLE `discount_code_courses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `discount_code_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `discount_code_redemptions`
--

CREATE TABLE `discount_code_redemptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `discount_code_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `student_subscription_id` bigint(20) UNSIGNED DEFAULT NULL,
  `original_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('pending','applied') NOT NULL DEFAULT 'applied' COMMENT 'pending = student claim, costs the code nothing; applied = discount actually given',
  `applied_by_type` enum('admin','teacher','student','system') NOT NULL DEFAULT 'admin',
  `applied_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `email_verification_codes`
--

CREATE TABLE `email_verification_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_type` enum('student','teacher','parent','admin') NOT NULL DEFAULT 'student',
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(190) NOT NULL,
  `code` varchar(10) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `exam_attempts`
--

CREATE TABLE `exam_attempts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('in_progress','submitted','graded') NOT NULL DEFAULT 'in_progress',
  `total_score` decimal(8,2) DEFAULT NULL,
  `max_score` decimal(8,2) NOT NULL DEFAULT 0.00,
  `started_at` timestamp NULL DEFAULT current_timestamp(),
  `submitted_at` datetime DEFAULT NULL,
  `graded_at` datetime DEFAULT NULL,
  `graded_by_type` enum('admin','teacher') DEFAULT NULL,
  `graded_by_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `exam_attempt_answers`
--

CREATE TABLE `exam_attempt_answers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `attempt_id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `mcq_option_id` bigint(20) UNSIGNED DEFAULT NULL,
  `true_false_answer` tinyint(1) DEFAULT NULL,
  `written_answer_text` text DEFAULT NULL,
  `is_correct` tinyint(1) DEFAULT NULL,
  `score_awarded` decimal(8,2) DEFAULT NULL,
  `teacher_note` text DEFAULT NULL,
  `answered_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `exam_teachers`
--

CREATE TABLE `exam_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `homework`
--

CREATE TABLE `homework` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `homework_submissions`
--

CREATE TABLE `homework_submissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `homework_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `status` enum('submitted','reviewed') NOT NULL DEFAULT 'submitted',
  `feedback_text` text DEFAULT NULL,
  `feedback_rating` tinyint(3) UNSIGNED DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `hr_policy_settings`
--

CREATE TABLE `hr_policy_settings` (
  `id` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `teacher_max_absence_with_permission_per_month` int(10) UNSIGNED NOT NULL DEFAULT 2,
  `teacher_max_absence_without_permission` int(10) UNSIGNED NOT NULL DEFAULT 2,
  `teacher_max_reschedule_per_month` int(10) UNSIGNED NOT NULL DEFAULT 3,
  `teacher_grace_minutes` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `teacher_late_fine_per_minute` decimal(10,2) NOT NULL DEFAULT 0.00,
  `teacher_absence_fine_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `student_max_absence_with_permission_per_month` int(10) UNSIGNED NOT NULL DEFAULT 2,
  `student_max_absence_without_permission` int(10) UNSIGNED NOT NULL DEFAULT 2,
  `student_max_reschedule_per_month` int(10) UNSIGNED NOT NULL DEFAULT 3,
  `student_grace_minutes` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `default_pay_model` enum('hourly','per_session','per_minute') NOT NULL DEFAULT 'per_session',
  `default_pay_rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `hr_policy_settings`
--

INSERT INTO `hr_policy_settings` (`id`, `teacher_max_absence_with_permission_per_month`, `teacher_max_absence_without_permission`, `teacher_max_reschedule_per_month`, `teacher_grace_minutes`, `teacher_late_fine_per_minute`, `teacher_absence_fine_amount`, `student_max_absence_with_permission_per_month`, `student_max_absence_without_permission`, `student_max_reschedule_per_month`, `student_grace_minutes`, `default_pay_model`, `default_pay_rate`, `updated_at`) VALUES
(1, 2, 2, 2, 10, 1.00, 15.00, 3, 2, 3, 10, 'hourly', 1.00, '2026-09-13 09:11:38');

-- --------------------------------------------------------

--
-- Table structure for table `ip_country_cache`
--

CREATE TABLE `ip_country_cache` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `iso2` char(2) DEFAULT NULL COMMENT 'NULL = looked up, no answer',
  `failures` int(11) NOT NULL DEFAULT 0 COMMENT 'Consecutive failed lookups, for the provider row',
  `looked_up_at` datetime NOT NULL COMMENT 'UTC'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `item_country_prices`
--

CREATE TABLE `item_country_prices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `item_type` enum('course','book') NOT NULL DEFAULT 'course',
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `country_id` bigint(20) UNSIGNED NOT NULL,
  `currency_code` char(3) NOT NULL COMMENT 'Copied from the country when the price was entered',
  `price` decimal(14,3) NOT NULL DEFAULT 0.000,
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Off means fall back to the base price',
  `created_by_type` enum('admin','teacher') DEFAULT NULL,
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `item_country_prices`
--

INSERT INTO `item_country_prices` (`id`, `item_type`, `item_id`, `country_id`, `currency_code`, `price`, `is_active`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`) VALUES
(1, 'course', 320, 1, 'EGP', 1200.000, 1, 'admin', 1, '2026-09-28 10:37:38', '2026-09-28 10:37:38'),
(2, 'course', 320, 4, 'KWD', 20.000, 1, 'admin', 1, '2026-09-28 10:37:38', '2026-09-28 10:37:38'),
(3, 'course', 288, 1, 'EGP', 1200.000, 1, 'admin', 1, '2026-09-28 11:08:15', '2026-09-28 11:08:15'),
(4, 'course', 288, 2, 'SAR', 20.000, 1, 'admin', 1, '2026-09-28 11:08:15', '2026-09-28 11:08:15');

-- --------------------------------------------------------

--
-- Table structure for table `languages`
--

CREATE TABLE `languages` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `code` varchar(10) NOT NULL,
  `direction` enum('rtl','ltr') NOT NULL DEFAULT 'ltr',
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `languages`
--

INSERT INTO `languages` (`id`, `code`, `direction`, `is_default`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'ar', 'rtl', 1, 1, 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 'en', 'ltr', 0, 2, 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `languages_translations`
--

CREATE TABLE `languages_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `translated_language_id` smallint(5) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `languages_translations`
--

INSERT INTO `languages_translations` (`id`, `translated_language_id`, `language_id`, `name`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'العربية', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'Arabic', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'الإنجليزية', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'English', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `identifier` varchar(191) NOT NULL COMMENT 'The email that was tried, lowercased',
  `ip_address` varchar(45) NOT NULL,
  `role` varchar(20) NOT NULL COMMENT 'student / teacher / parent / admin',
  `failures` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL COMMENT 'UTC. Null = not locked. Expires on its own.',
  `last_failure_at` datetime DEFAULT NULL COMMENT 'UTC',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mcq_options`
--

CREATE TABLE `mcq_options` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `option_key` varchar(10) DEFAULT NULL,
  `option_image` varchar(500) DEFAULT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `mcq_options_translations`
--

CREATE TABLE `mcq_options_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `mcq_option_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `option_text` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_type` varchar(50) NOT NULL DEFAULT 'admin',
  `sender_id` bigint(20) UNSIGNED DEFAULT NULL,
  `target_type` varchar(50) NOT NULL,
  `channels` varchar(50) NOT NULL DEFAULT 'push',
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `data` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `notification_recipients`
--

CREATE TABLE `notification_recipients` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `notification_id` bigint(20) UNSIGNED NOT NULL,
  `user_type` varchar(50) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `is_sent` tinyint(1) NOT NULL DEFAULT 0,
  `is_email_sent` tinyint(1) NOT NULL DEFAULT 0,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `error` varchar(500) DEFAULT NULL,
  `email_error` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `offline_payment_requests`
--

CREATE TABLE `offline_payment_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `item_type` enum('course','book') NOT NULL DEFAULT 'course',
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `payment_account_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Which of our accounts they say they paid into',
  `original_amount` decimal(14,3) NOT NULL DEFAULT 0.000 COMMENT 'The listed price when the request was filed',
  `discount_code_id` bigint(20) UNSIGNED DEFAULT NULL,
  `discount_amount` decimal(14,3) NOT NULL DEFAULT 0.000,
  `amount` decimal(14,3) NOT NULL DEFAULT 0.000 COMMENT 'What the student says they transferred',
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `country_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'The country the price was quoted for',
  `sender_name` varchar(191) DEFAULT NULL COMMENT 'The name on the sending account, when it is not the student',
  `sender_reference` varchar(191) DEFAULT NULL COMMENT 'Transaction / reference number from the transfer',
  `transferred_at` datetime DEFAULT NULL COMMENT 'When the student says they sent it',
  `receipt_image` varchar(500) DEFAULT NULL,
  `student_note` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `reviewed_by_type` enum('admin','teacher') DEFAULT NULL,
  `reviewed_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `review_note` text DEFAULT NULL COMMENT 'Why it was rejected, or anything the reviewer wants on the record',
  `granted_ref_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'The subscription row this created, once approved',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `points_spent` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Points the student spent on this request',
  `points_discount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'What those points were worth, in the request currency'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parents`
--

CREATE TABLE `parents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `city_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password` varchar(255) NOT NULL,
  `image` longtext DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `parent_students`
--

CREATE TABLE `parent_students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `password_reset_codes`
--

CREATE TABLE `password_reset_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_type` enum('student','teacher','parent','admin') NOT NULL DEFAULT 'student',
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(190) NOT NULL,
  `code` varchar(10) NOT NULL,
  `reset_token` varchar(100) DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `payment_accounts`
--

CREATE TABLE `payment_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `method` varchar(40) NOT NULL DEFAULT 'other' COMMENT 'instapay / vodafone_cash / etihad_cash / orange_cash / we_pay / bank / other',
  `label_ar` varchar(150) NOT NULL,
  `label_en` varchar(150) NOT NULL,
  `bank_name` varchar(191) DEFAULT NULL COMMENT 'The receiving bank',
  `account_name` varchar(191) DEFAULT NULL COMMENT 'The name the transfer should be addressed to',
  `account_number` varchar(191) NOT NULL COMMENT 'Wallet number, IBAN, InstaPay address',
  `swift_code` varchar(40) DEFAULT NULL COMMENT 'SWIFT / BIC',
  `currency_code` char(3) NOT NULL DEFAULT 'USD' COMMENT 'The currency this account receives',
  `instructions_ar` text DEFAULT NULL,
  `instructions_en` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `payment_transactions`
--

CREATE TABLE `payment_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `item_type` enum('course','book') NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `status` enum('pending','paid','failed','cancelled') NOT NULL DEFAULT 'pending',
  `easykash_ref` varchar(100) DEFAULT NULL,
  `payment_method` varchar(100) DEFAULT NULL,
  `granted_ref_id` bigint(20) UNSIGNED DEFAULT NULL,
  `raw_callback` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `paid_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `name` varchar(150) NOT NULL,
  `module` varchar(50) NOT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Whether it appears on the admin permission screen',
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `code`, `name`, `module`, `is_visible`, `description`, `created_at`) VALUES
(1, 'dashboard.view', 'View Dashboard', 'dashboard', 0, 'Access dashboard metrics', '2026-08-10 16:00:00'),
(2, 'students.manage', 'Manage Students', 'students', 0, 'Create, edit and review student accounts', '2026-08-10 16:00:00'),
(3, 'teachers.manage', 'Manage Teachers', 'teachers', 0, 'Create, edit and review teacher accounts', '2026-08-10 16:00:00'),
(4, 'courses.manage', 'Manage Courses', 'courses', 0, 'Manage courses, units and videos', '2026-08-10 16:00:00'),
(5, 'exams.manage', 'Manage Exams', 'exams', 0, 'Manage exams, questions and attempts', '2026-08-10 16:00:00'),
(6, 'subscriptions.manage', 'Manage Subscriptions', 'subscriptions', 0, 'Manage subscriptions and activation codes', '2026-08-10 16:00:00'),
(7, 'transactions.manage', 'Manage Transactions', 'transactions', 0, 'Review payments and transaction records', '2026-08-10 16:00:00'),
(8, 'content.manage', 'Manage Resources', 'content', 0, 'Manage books, files, banners and advertisements', '2026-08-10 16:00:00'),
(9, 'reports.view', 'View Reports', 'reports', 0, 'Access operational and student reports', '2026-08-10 16:00:00'),
(10, 'support.manage', 'Manage Support', 'support', 0, 'Handle consultations and reschedule requests', '2026-08-10 16:00:00'),
(11, 'settings.manage', 'Manage Settings', 'settings', 0, 'Manage site configuration', '2026-08-10 16:00:00'),
(12, 'roles.manage', 'Manage Roles', 'security', 0, 'Manage roles and permissions', '2026-08-10 16:00:00'),
(13, 'view_dashboard', 'View Dashboard & Statistics', 'dashboard', 1, 'Access dashboard and statistics', '2026-08-30 13:04:02'),
(14, 'manage_admins', 'Manage Admins & Permissions', 'admins', 1, 'Add, edit, and delete admin users', '2026-08-30 13:04:02'),
(15, 'manage_roles', 'Manage Roles', 'roles', 1, 'Full CRUD access for roles and permissions', '2026-08-30 13:04:02'),
(16, 'manage_students', 'Manage Students', 'students', 1, 'Add, edit, and delete students', '2026-08-30 13:04:02'),
(17, 'manage_teachers', 'Manage Teachers', 'teachers', 1, 'Add, edit, approve, and delete teachers, and manage their content (units, videos, books, exams, certificates)', '2026-08-30 13:04:02'),
(18, 'manage_parents', 'Manage Parents & Student Linkage', 'parents', 1, 'Add, edit parents and link students', '2026-08-30 13:04:02'),
(19, 'manage_banners', 'Manage Banners & Analytics', 'banners', 1, 'Full CRUD access for banners and view analytics', '2026-08-30 13:04:02'),
(20, 'manage_languages', 'Manage Languages', 'languages', 1, 'Full CRUD access for languages', '2026-08-30 13:04:02'),
(21, 'manage_cities', 'Manage Regions', 'cities', 1, 'Full CRUD access for regions', '2026-08-30 13:04:02'),
(22, 'manage_school_types', 'Manage School Types', 'school_types', 0, 'Full CRUD access for school types', '2026-08-30 13:04:02'),
(23, 'manage_schools', 'Manage Schools', 'schools', 0, 'Full CRUD access for schools', '2026-08-30 13:04:02'),
(24, 'manage_subjects', 'Manage Subjects', 'subjects', 1, 'Full CRUD access for subjects', '2026-08-30 13:04:02'),
(25, 'manage_courses', 'Manage Courses', 'courses', 1, 'Full CRUD access for courses, units, videos, exams, questions, certificates and books', '2026-08-30 13:04:02'),
(26, 'manage_books', 'Manage Books & Purchase Requests', 'books', 1, 'Full CRUD access for books and purchase requests', '2026-08-30 13:04:02'),
(27, 'manage_academic_years', 'Manage Grades (Academic Years)', 'academic_years', 1, 'Full CRUD access for grades / academic years', '2026-08-30 13:04:02'),
(28, 'manage_course_categories', 'Manage Course Categories', 'course_categories', 1, 'Full CRUD access for course categories', '2026-08-30 13:04:02'),
(29, 'manage_discounts', 'Manage Discount Codes', 'discounts', 1, 'Create, edit, and delete discount codes, and review who redeemed them', '2026-09-27 21:02:00'),
(30, 'manage_settings', 'Manage Application Settings', 'app_settings', 1, 'Edit contact details, social links, registration and login protection', '2026-09-27 21:46:45'),
(32, 'manage_payments', 'Manage Offline Payments', 'payments', 1, 'Review offline payment requests and manage the accounts students transfer to', '2026-09-28 08:00:34'),
(34, 'manage_pricing', 'Manage Pricing & Currencies', 'pricing', 1, 'Set per-country prices, choose the base currency, and enable countries and currencies', '2026-09-28 10:00:00'),
(36, 'manage_packages', 'Manage Packages', 'packages', 1, 'Create and edit subscription packages', '2026-09-29 11:01:31'),
(37, 'manage_exams', 'Manage Exams', 'exams', 1, 'Create and edit exams, questions and review attempts', '2026-09-29 11:01:31'),
(38, 'manage_certificates', 'Manage Certificates', 'certificates', 1, 'Issue, revoke and review student certificates', '2026-09-29 11:01:31'),
(39, 'manage_subscriptions', 'Manage Subscriptions & Codes', 'subscriptions', 1, 'Grant, pause and cancel subscriptions, and manage subscription codes', '2026-09-29 11:01:31'),
(40, 'manage_sessions', 'Manage Live Sessions & Availability', 'sessions', 1, 'Live sessions, teacher availability and reschedule requests', '2026-09-29 11:01:31'),
(41, 'manage_consultations', 'Manage Consultations', 'consultations', 1, 'Review and answer student consultations', '2026-09-29 11:01:31'),
(42, 'manage_attendance', 'Manage Attendance & Exceptions', 'attendance', 1, 'Attendance exceptions and absence records', '2026-09-29 11:01:31'),
(43, 'manage_wallets', 'Manage Teacher Wallets & Appeals', 'wallets', 1, 'Teacher wallets, payouts and deduction appeals', '2026-09-29 11:01:31'),
(44, 'manage_hr', 'Manage Attendance & Salary Settings', 'hr', 1, 'Deduction rules and attendance policy', '2026-09-29 11:01:31'),
(101, 'manage_reports', 'Manage Reports', 'reports', 1, '', '2026-09-30 12:38:36'),
(102, 'manage_notifications', 'Manage Notifications', 'notifications', 1, '', '2026-09-30 12:38:36'),
(103, 'manage_chat', 'Manage Chat', 'chat', 1, '', '2026-09-30 12:38:36'),
(104, 'monitor_chat', 'Monitor Chat', 'chat_monitor', 1, '', '2026-09-30 12:38:36'),
(123, 'view_sales', 'Sales', 'sales', 1, '', '2026-09-30 13:19:36');

-- --------------------------------------------------------

--
-- Table structure for table `permissions_translations`
--

CREATE TABLE `permissions_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions_translations`
--

INSERT INTO `permissions_translations` (`id`, `permission_id`, `language_id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'عرض لوحة التحكم', 'Access dashboard metrics', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'View Dashboard', 'Access dashboard metrics', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'إدارة الطلاب', 'Create, edit and review student accounts', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'Manage Students', 'Create, edit and review student accounts', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 3, 1, 'إدارة المدرسين', 'Create, edit and review teacher accounts', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, 2, 'Manage Teachers', 'Create, edit and review teacher accounts', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 4, 1, 'إدارة الكورسات', 'Manage courses, units and videos', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 4, 2, 'Manage Courses', 'Manage courses, units and videos', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 5, 1, 'إدارة الامتحانات', 'Manage exams, questions and attempts', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 5, 2, 'Manage Exams', 'Manage exams, questions and attempts', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(11, 6, 1, 'إدارة الاشتراكات', 'Manage subscriptions and activation codes', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(12, 6, 2, 'Manage Subscriptions', 'Manage subscriptions and activation codes', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(13, 7, 1, 'إدارة المعاملات', 'Review payments and transaction records', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(14, 7, 2, 'Manage Transactions', 'Review payments and transaction records', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(15, 8, 1, 'إدارة المحتوى', 'Manage books, files, banners and advertisements', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(16, 8, 2, 'Manage Resources', 'Manage books, files, banners and advertisements', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(17, 9, 1, 'عرض التقارير', 'Access operational and student reports', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(18, 9, 2, 'View Reports', 'Access operational and student reports', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(19, 10, 1, 'إدارة الدعم', 'Handle consultations and reschedule requests', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(20, 10, 2, 'Manage Support', 'Handle consultations and reschedule requests', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(21, 11, 1, 'إدارة الإعدادات', 'Manage site configuration', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(22, 11, 2, 'Manage Settings', 'Manage site configuration', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(23, 12, 1, 'إدارة الأدوار والصلاحيات', 'Manage roles and permissions', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(24, 12, 2, 'Manage Roles', 'Manage roles and permissions', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(25, 27, 1, 'إدارة الصفوف الدراسية', 'إدارة كاملة للصفوف الدراسية', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(26, 14, 1, 'إدارة المشرفين والصلاحيات', 'إضافة وتعديل وحذف حسابات المشرفين وصلاحياتهم', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(27, 19, 1, 'إدارة البانرات والإحصائيات', 'إدارة كاملة للبانرات وعرض إحصائيات المشاهدة', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(28, 26, 1, 'إدارة الكتب وطلبات الشراء', 'إدارة كاملة للكتب وطلبات الشراء', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(29, 21, 1, 'إدارة المناطق', 'إدارة كاملة للمناطق الجغرافية', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(30, 28, 1, 'إدارة تصنيفات الكورسات', 'إدارة كاملة لتصنيفات الكورسات', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(31, 25, 1, 'إدارة الكورسات', 'إدارة كاملة للكورسات والوحدات والفيديوهات والامتحانات والأسئلة والشهادات والكتب', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(32, 20, 1, 'إدارة اللغات', 'إدارة كاملة للغات المتاحة في المنصة', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(33, 18, 1, 'إدارة أولياء الأمور', 'إضافة وتعديل أولياء الأمور وربطهم بالطلاب', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(34, 15, 1, 'إدارة الأدوار', 'إدارة كاملة للأدوار والصلاحيات (نظام قديم غير مستخدم حاليًا)', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(35, 22, 1, 'إدارة أنواع المدارس', 'إدارة كاملة لأنواع المدارس', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(36, 23, 1, 'إدارة المدارس', 'إدارة كاملة للمدارس', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(37, 16, 1, 'إدارة الطلاب', 'إضافة وتعديل وحذف الطلاب', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(38, 24, 1, 'إدارة المواد الدراسية', 'إدارة كاملة للمواد الدراسية', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(39, 17, 1, 'إدارة المدرسين', 'إضافة وتعديل وحذف المدرسين، وإدارة محتواهم من كورسات ووحدات وفيديوهات وامتحانات وشهادات', '2026-08-30 13:04:02', '2026-09-29 11:01:31'),
(40, 13, 1, 'عرض لوحة التحكم والإحصائيات', 'الوصول للوحة التحكم والإحصائيات', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(56, 13, 2, 'View Dashboard & Statistics', 'Access dashboard and statistics', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(57, 14, 2, 'Manage Admins & Permissions', 'Add, edit, and delete admin users', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(58, 15, 2, 'Manage Roles', 'Full CRUD access for roles and permissions', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(59, 16, 2, 'Manage Students', 'Add, edit, and delete students', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(60, 17, 2, 'Manage Teachers', 'Add, edit, approve, and delete teachers, and manage their content (units, videos, books, exams, certificates)', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(61, 18, 2, 'Manage Parents & Student Linkage', 'Add, edit parents and link students', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(62, 19, 2, 'Manage Banners & Analytics', 'Full CRUD access for banners and view analytics', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(63, 20, 2, 'Manage Languages', 'Full CRUD access for languages', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(64, 21, 2, 'Manage Regions', 'Full CRUD access for regions', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(65, 22, 2, 'Manage School Types', 'Full CRUD access for school types', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(66, 23, 2, 'Manage Schools', 'Full CRUD access for schools', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(67, 24, 2, 'Manage Subjects', 'Full CRUD access for subjects', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(68, 25, 2, 'Manage Courses', 'Full CRUD access for courses, units, videos, exams, questions, certificates and books', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(69, 26, 2, 'Manage Books & Purchase Requests', 'Full CRUD access for books and purchase requests', '2026-08-30 13:04:02', '2026-09-29 11:02:08'),
(70, 27, 2, 'Manage Grades (Academic Years)', 'Full CRUD access for grades / academic years', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(71, 28, 2, 'Manage Course Categories', 'Full CRUD access for course categories', '2026-08-30 13:04:02', '2026-08-30 13:04:02'),
(72, 29, 1, 'إدارة أكواد الخصم', 'إنشاء وتعديل وحذف أكواد الخصم، ومتابعة من استخدمها', '2026-09-27 21:02:00', '2026-09-27 21:02:00'),
(73, 29, 2, 'Manage Discount Codes', 'Create, edit, and delete discount codes, and review who redeemed them', '2026-09-27 21:02:00', '2026-09-27 21:02:00'),
(74, 30, 1, 'إدارة إعدادات التطبيق', 'تعديل بيانات التواصل وروابط التواصل الاجتماعي والتسجيل وحماية تسجيل الدخول', '2026-09-27 21:46:45', '2026-09-28 07:00:03'),
(75, 30, 2, 'Manage Application Settings', 'Edit contact details, social links, registration and login protection', '2026-09-27 21:46:45', '2026-09-28 07:00:04'),
(78, 32, 1, 'إدارة المدفوعات اليدوية', 'مراجعة طلبات الدفع اليدوي وإدارة الحسابات اللي الطلبة بيحوّلوا عليها', '2026-09-28 08:00:34', '2026-09-28 08:00:34'),
(79, 32, 2, 'Manage Offline Payments', 'Review offline payment requests and manage the accounts students transfer to', '2026-09-28 08:00:34', '2026-09-28 08:00:34'),
(82, 34, 1, 'إدارة الأسعار والعملات', 'تحديد أسعار الدول والعملة الأساسية وتفعيل الدول والعملات', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(83, 34, 2, 'Manage Pricing & Currencies', 'Set per-country prices, choose the base currency, and enable countries and currencies', '2026-09-28 10:00:00', '2026-09-29 11:02:08'),
(86, 36, 1, 'إدارة الباقات', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(87, 37, 1, 'إدارة الامتحانات', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(88, 38, 1, 'إدارة الشهادات', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(89, 39, 1, 'إدارة اشتراكات الطلاب وأكواد الاشتراك', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(90, 40, 1, 'إدارة الحصص المباشرة والمواعيد', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(91, 41, 1, 'إدارة الاستشارات', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(92, 42, 1, 'إدارة الحضور والاستثناءات', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(93, 43, 1, 'إدارة محافظ المدرسين والتظلمات', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(94, 44, 1, 'إدارة إعدادات الحضور والرواتب', NULL, '2026-09-29 11:01:31', '2026-09-30 12:38:36'),
(101, 36, 2, 'Manage Packages', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(102, 37, 2, 'Manage Exams', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(103, 38, 2, 'Manage Certificates', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(104, 39, 2, 'Manage Subscriptions & Codes', NULL, '2026-09-29 11:01:31', '2026-09-29 11:02:08'),
(105, 40, 2, 'Manage Live Sessions & Availability', NULL, '2026-09-29 11:01:31', '2026-09-29 11:02:08'),
(106, 41, 2, 'Manage Consultations', NULL, '2026-09-29 11:01:31', '2026-09-29 11:01:31'),
(107, 42, 2, 'Manage Attendance & Exceptions', NULL, '2026-09-29 11:01:31', '2026-09-29 11:02:08'),
(108, 43, 2, 'Manage Teacher Wallets & Appeals', NULL, '2026-09-29 11:01:31', '2026-09-29 11:02:08'),
(109, 44, 2, 'Manage Attendance & Salary Settings', NULL, '2026-09-29 11:01:31', '2026-09-30 12:38:36'),
(216, 101, 1, 'إدارة التقارير', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(217, 101, 2, 'Manage Reports', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(218, 102, 1, 'إدارة الإشعارات', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(219, 102, 2, 'Manage Notifications', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(220, 103, 1, 'إدارة المحادثات', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(221, 103, 2, 'Manage Chat', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(222, 104, 1, 'مراقبة المحادثات', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(223, 104, 2, 'Monitor Chat', NULL, '2026-09-30 12:38:36', '2026-09-30 12:38:36'),
(260, 123, 1, 'المبيعات', NULL, '2026-09-30 13:19:36', '2026-09-30 13:19:36'),
(261, 123, 2, 'Sales', NULL, '2026-09-30 13:19:36', '2026-09-30 13:19:36');

-- --------------------------------------------------------

--
-- Table structure for table `point_currency_values`
--

CREATE TABLE `point_currency_values` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `point_value` decimal(12,4) NOT NULL DEFAULT 1.0000 COMMENT 'How much one point is worth in this currency',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `point_currency_values`
--

INSERT INTO `point_currency_values` (`id`, `currency_code`, `point_value`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'AED', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(2, 'AFN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(3, 'ALL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(4, 'AMD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(5, 'ANG', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(6, 'AOA', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(7, 'ARS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(8, 'AUD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(9, 'AWG', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(10, 'AZN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(11, 'BAM', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(12, 'BBD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(13, 'BDT', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(14, 'BGN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(15, 'BHD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(16, 'BIF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(17, 'BND', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(18, 'BOB', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(19, 'BRL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(20, 'BSD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(21, 'BTN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(22, 'BWP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(23, 'BYN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(24, 'BZD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(25, 'CAD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(26, 'CDF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(27, 'CHF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(28, 'CLP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(29, 'CNY', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(30, 'COP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(31, 'CRC', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(32, 'CUP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(33, 'CVE', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(34, 'CZK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(35, 'DJF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(36, 'DKK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(37, 'DOP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(38, 'DZD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(39, 'EGP', 0.2000, 1, '2026-09-30 07:34:09', '2026-09-30 07:56:10'),
(40, 'ERN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(41, 'ETB', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(42, 'EUR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(43, 'FJD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(44, 'GBP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(45, 'GEL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(46, 'GHS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(47, 'GMD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(48, 'GNF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(49, 'GTQ', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(50, 'GYD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(51, 'HKD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(52, 'HNL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(53, 'HTG', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(54, 'HUF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(55, 'IDR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(56, 'ILS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(57, 'INR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(58, 'IQD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(59, 'IRR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(60, 'ISK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(61, 'JMD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(62, 'JOD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(63, 'JPY', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(64, 'KES', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(65, 'KGS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(66, 'KHR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(67, 'KMF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(68, 'KPW', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(69, 'KRW', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(70, 'KWD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(71, 'KZT', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(72, 'LAK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(73, 'LBP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(74, 'LKR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(75, 'LRD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(76, 'LSL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(77, 'LYD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(78, 'MAD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(79, 'MDL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(80, 'MGA', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(81, 'MKD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(82, 'MMK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(83, 'MNT', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(84, 'MOP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(85, 'MRU', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(86, 'MUR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(87, 'MVR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(88, 'MWK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(89, 'MXN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(90, 'MYR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(91, 'MZN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(92, 'NAD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(93, 'NGN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(94, 'NIO', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(95, 'NOK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(96, 'NPR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(97, 'NZD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(98, 'OMR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(99, 'PAB', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(100, 'PEN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(101, 'PGK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(102, 'PHP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(103, 'PKR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(104, 'PLN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(105, 'PYG', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(106, 'QAR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(107, 'RON', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(108, 'RSD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(109, 'RUB', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(110, 'RWF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(111, 'SAR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(112, 'SBD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(113, 'SCR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(114, 'SDG', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(115, 'SEK', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(116, 'SGD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(117, 'SLE', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(118, 'SOS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(119, 'SRD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(120, 'SSP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(121, 'STN', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(122, 'SYP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(123, 'SZL', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(124, 'THB', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(125, 'TJS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(126, 'TMT', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(127, 'TND', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(128, 'TOP', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(129, 'TRY', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(130, 'TTD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(131, 'TWD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(132, 'TZS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(133, 'UAH', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(134, 'UGX', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(135, 'USD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(136, 'UYU', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(137, 'UZS', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(138, 'VES', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(139, 'VND', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(140, 'VUV', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(141, 'WST', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(142, 'XAF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(143, 'XCD', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(144, 'XOF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(145, 'XPF', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(146, 'YER', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(147, 'ZAR', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(148, 'ZMW', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09'),
(149, 'ZWG', 1.0000, 1, '2026-09-30 07:34:09', '2026-09-30 07:34:09');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `unit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `question_type` enum('mcq','true_false','written') NOT NULL,
  `order_num` int(11) NOT NULL DEFAULT 0,
  `score` decimal(8,2) NOT NULL DEFAULT 1.00,
  `question_image` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `subject_id` int(11) DEFAULT NULL,
  `created_by_type` varchar(80) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `questions_translations`
--

CREATE TABLE `questions_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `question_text` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `resources`
--

CREATE TABLE `resources` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `unit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `resource_type` enum('book','file') NOT NULL,
  `code` varchar(120) NOT NULL,
  `cover_image` varchar(500) DEFAULT NULL,
  `file_path` varchar(1000) DEFAULT NULL,
  `file_url` varchar(1000) DEFAULT NULL,
  `publish_status` enum('draft','published') NOT NULL DEFAULT 'draft',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `resources_translations`
--

CREATE TABLE `resources_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `resource_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `author` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `code`, `name`, `description`, `is_system`, `created_at`, `updated_at`) VALUES
(1, 'super-admin', 'مدير النظام', 'Full platform administration', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 'content-manager', 'مدير المحتوى', 'Manage learning content and catalog', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 'support-agent', 'مسؤول الدعم', 'Student and parent support operations', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `roles_translations`
--

CREATE TABLE `roles_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles_translations`
--

INSERT INTO `roles_translations` (`id`, `role_id`, `language_id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'مدير النظام', 'Full platform administration', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'Full platform administration', 'Full platform administration', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'مدير المحتوى', 'Manage learning content and catalog', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'Manage learning content and catalog', 'Manage learning content and catalog', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 3, 1, 'مسؤول الدعم', 'Student and parent support operations', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, 2, 'Student and parent support operations', 'Student and parent support operations', '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `created_at`) VALUES
(1, 1, 1, '2026-08-10 16:00:00'),
(2, 1, 2, '2026-08-10 16:00:00'),
(3, 1, 3, '2026-08-10 16:00:00'),
(4, 1, 4, '2026-08-10 16:00:00'),
(5, 1, 5, '2026-08-10 16:00:00'),
(6, 1, 6, '2026-08-10 16:00:00'),
(7, 1, 7, '2026-08-10 16:00:00'),
(8, 1, 8, '2026-08-10 16:00:00'),
(9, 1, 9, '2026-08-10 16:00:00'),
(10, 1, 10, '2026-08-10 16:00:00'),
(11, 1, 11, '2026-08-10 16:00:00'),
(12, 1, 12, '2026-08-10 16:00:00'),
(13, 2, 1, '2026-08-10 16:00:00'),
(14, 2, 3, '2026-08-10 16:00:00'),
(15, 2, 4, '2026-08-10 16:00:00'),
(16, 2, 5, '2026-08-10 16:00:00'),
(17, 2, 8, '2026-08-10 16:00:00'),
(18, 2, 9, '2026-08-10 16:00:00'),
(19, 3, 1, '2026-08-10 16:00:00'),
(20, 3, 2, '2026-08-10 16:00:00'),
(21, 3, 6, '2026-08-10 16:00:00'),
(22, 3, 7, '2026-08-10 16:00:00'),
(23, 3, 9, '2026-08-10 16:00:00'),
(24, 3, 10, '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `schools`
--

CREATE TABLE `schools` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_type_id` bigint(20) UNSIGNED NOT NULL,
  `city_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(120) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `schools`
--

INSERT INTO `schools` (`id`, `school_type_id`, `city_id`, `code`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 'cairo-future-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 3, NULL, 'giza-language-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, NULL, 'alex-private-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 4, NULL, 'cairo-intl-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 1, NULL, 'qalyubia-public-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, NULL, 'mansoura-language-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 2, NULL, 'sharqia-private-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 3, NULL, 'tanta-language-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 1, NULL, 'monufia-public-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 2, NULL, 'beheira-private-01', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `schools_translations`
--

CREATE TABLE `schools_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `schools_translations`
--

INSERT INTO `schools_translations` (`id`, `school_id`, `language_id`, `name`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'مدرسة المستقبل بالقاهرة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'Cairo Future School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'مدرسة الجيزة للغات', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'Giza Language School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 3, 1, 'مدرسة الإسكندرية الحديثة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, 2, 'Alexandria Modern School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 4, 1, 'مدرسة القاهرة الدولية الحديثة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 4, 2, 'Modern Cairo International School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 5, 1, 'مدرسة القليوبية الجديدة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 5, 2, 'New Qalyubia School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(11, 6, 1, 'مدرسة المنصورة للغات', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(12, 6, 2, 'Mansoura Language School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(13, 7, 1, 'مدرسة الشرقية الخاصة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(14, 7, 2, 'Sharqia Private School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(15, 8, 1, 'مدرسة طنطا للغات', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(16, 8, 2, 'Tanta Language School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(17, 9, 1, 'مدرسة المنوفية النموذجية', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(18, 9, 2, 'Monufia Model School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(19, 10, 1, 'مدرسة البحيرة الحديثة', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(20, 10, 2, 'Beheira Modern School', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `school_types`
--

CREATE TABLE `school_types` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `school_types`
--

INSERT INTO `school_types` (`id`, `code`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'public', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 'private', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 'language', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 'international', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `school_types_translations`
--

CREATE TABLE `school_types_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_type_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `school_types_translations`
--

INSERT INTO `school_types_translations` (`id`, `school_type_id`, `language_id`, `name`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'حكومي', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'Public', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'خاص', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'Private', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 3, 1, 'لغات', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, 2, 'Language', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 4, 1, 'دولي', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 4, 2, 'International', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `session_attendance`
--

CREATE TABLE `session_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `session_date` date NOT NULL,
  `status` enum('present','absent','late') NOT NULL DEFAULT 'present',
  `check_in_time` datetime DEFAULT NULL,
  `check_out_time` datetime DEFAULT NULL,
  `minutes_late` int(11) NOT NULL DEFAULT 0,
  `is_excused` tinyint(1) NOT NULL DEFAULT 0,
  `marked_by_teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `marked_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `session_files`
--

CREATE TABLE `session_files` (
  `id` int(10) UNSIGNED NOT NULL,
  `session_id` int(10) UNSIGNED NOT NULL,
  `uploaded_by_type` enum('admin','teacher') NOT NULL DEFAULT 'teacher',
  `uploaded_by_id` int(10) UNSIGNED NOT NULL,
  `file_type` enum('exam','homework','task','explanation','other') NOT NULL DEFAULT 'other',
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` text DEFAULT NULL,
  `file_path` varchar(500) NOT NULL,
  `original_name` varchar(255) NOT NULL DEFAULT '',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `session_file_submissions`
--

CREATE TABLE `session_file_submissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `session_file_id` int(10) UNSIGNED NOT NULL,
  `student_id` int(10) UNSIGNED NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `original_name` varchar(255) NOT NULL DEFAULT '',
  `note` text DEFAULT NULL,
  `status` enum('pending','graded') NOT NULL DEFAULT 'pending',
  `grade` decimal(5,2) DEFAULT NULL,
  `teacher_feedback` text DEFAULT NULL,
  `graded_by_id` int(10) UNSIGNED DEFAULT NULL,
  `graded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `session_reschedule_requests`
--

CREATE TABLE `session_reschedule_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `requested_by_type` enum('teacher','student') NOT NULL DEFAULT 'teacher',
  `requested_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `new_day` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `new_start_time` time DEFAULT NULL,
  `new_end_time` time DEFAULT NULL,
  `reason` text NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `admin_note` text DEFAULT NULL,
  `reviewed_by_type` enum('admin','teacher') DEFAULT NULL,
  `reviewed_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `site_settings`
--

CREATE TABLE `site_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `site_settings`
--

INSERT INTO `site_settings` (`id`, `setting_key`, `setting_value`, `created_at`, `updated_at`) VALUES
(1, 'site_name_ar', 'ناجح', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 'site_name_en', 'Najeh', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 'default_language', 'ar', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 'support_email', 'support@najeh-demo.com', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 'support_phone', '01000000000', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 'currency', 'EGP', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 'timezone', 'Africa/Cairo', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 'registration_enabled', '1', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 'maintenance_mode', '0', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 'max_login_attempts', '5', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(11, 'hero_badge_text_ar', 'أكثر من 40,000 طالب اختاروا Najeh', '2026-08-10 13:04:43', '2026-08-10 15:10:52'),
(12, 'hero_badge_text_en', 'Over 40,000 Students Chose Najeh', '2026-08-10 13:04:43', '2026-08-10 15:10:39'),
(13, 'hero_title_ar', 'مستقبلك الدراسي يبدأ من هنا، مع Najeh', '2026-08-10 13:04:43', '2026-08-10 15:11:00'),
(14, 'hero_title_en', 'Your Academic Future Starts Here, With Najeh', '2026-08-10 13:04:43', '2026-08-10 15:11:08'),
(15, 'hero_subtitle_ar', 'كورسات مسجلة، حصص مباشرة، وكتاب مذاكرة في مكان واحد — علشان توصل لأعلى تقدير وانت مطمئن على وقتك ومجهودك.', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(16, 'hero_subtitle_en', 'Recorded courses, live classes, and study notes all in one place — to achieve top grades effortlessly.', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(17, 'hero_primary_btn_text_ar', 'تصفح الكورسات', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(18, 'hero_primary_btn_text_en', 'Explore Courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(19, 'hero_primary_btn_link', '/courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(20, 'hero_secondary_btn_text_ar', 'خطط الاشتراك', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(21, 'hero_secondary_btn_text_en', 'Subscription Plans', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(22, 'hero_secondary_btn_link', '#plans', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(23, 'hero_success_rate', '94%', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(24, 'hero_live_sessions_count', '+1200', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(25, 'hero_rating', '4.9/5', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(26, 'stats_courses_count', '+3000', '2026-08-10 13:04:43', '2026-10-03 17:03:15'),
(27, 'stats_courses_label_ar', 'كورس تعليمي', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(28, 'stats_courses_label_en', 'Educational Courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(29, 'stats_books_count', '+4000', '2026-08-10 13:04:43', '2026-10-03 17:04:03'),
(30, 'stats_books_label_ar', 'كتاب ومذكرة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(31, 'stats_books_label_en', 'Books & Notes', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(32, 'stats_teachers_count', '+85', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(35, 'stats_students_count', '+100k', '2026-08-10 13:04:43', '2026-10-03 17:03:43'),
(36, 'stats_students_label_ar', 'طالب مسجل', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(37, 'stats_students_label_en', 'Enrolled Students', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(38, 'about_title_ar', 'من نحن', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(39, 'about_title_en', 'About Us', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(40, 'about_description_ar', 'منصة Najeh التعليمية، وجهتك لتعلّم مستمر بلا حدود. نقدم كورسات مباشرة ومسجلة إلى جانب كتب تعليمية مختارة بعناية، لنكون شريكك من أول خطوة في التعلم وحتّى الإتقان.', '2026-08-10 13:04:43', '2026-08-10 15:12:06'),
(41, 'about_description_en', 'Najeh Educational Platform, your destination for continuous learning without limits. We provide live and recorded courses along with carefully selected educational books.', '2026-08-10 13:04:43', '2026-08-10 15:11:58'),
(42, 'about_stats_courses', '150+', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(43, 'about_stats_books', '40+', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(44, 'about_stats_students', '20,000+', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(45, 'about_mission_title_ar', 'رسالتنا', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(46, 'about_mission_title_en', 'Our Mission', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(47, 'about_mission_text_ar', 'نؤمن أن التعليم الجيد يجب أن يكون متاحاً للجميع، في أي وقت ومن أي مكان. لهذا أسسنا Najeh لنجمع بين مرونة التعلم عن بعد وجودة المحتوى الموثوق، سواء كنت تفضل حضور بث مباشر، أو مشاهدة كورس مسجل في وقتك الخاص، أو التعمق أكثر عبر كتاب مطبوع يصلك إلى باب بيتك.', '2026-08-10 13:04:43', '2026-08-10 15:12:16'),
(48, 'about_mission_text_en', 'We believe quality education should be accessible to everyone, anywhere, anytime. That is why we founded Najeh to blend distant learning flexibility with trusted content quality.', '2026-08-10 13:04:43', '2026-08-10 15:12:34'),
(49, 'about_offering1_title_ar', 'كورسات مباشرة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(50, 'about_offering1_title_en', 'Live Courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(51, 'about_offering1_desc_ar', 'تفاعل مباشر مع المدرب واسأل أسئلتك لحظياً أثناء البث', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(52, 'about_offering1_desc_en', 'Direct interaction with instructors with real-time Q&A during streams', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(53, 'about_offering2_title_ar', 'كورسات مسجلة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(54, 'about_offering2_title_en', 'Recorded Courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(55, 'about_offering2_desc_ar', 'تعلم في وقتك الخاص وبالسرعة التي تناسبك من أي جهاز', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(56, 'about_offering2_desc_en', 'Learn at your own pace from any device', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(57, 'about_offering3_title_ar', 'كتب تعليمية', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(58, 'about_offering3_title_en', 'Educational Books', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(59, 'about_offering3_desc_ar', 'مصادر مطبوعة ومختارة بعناية تدعم رحلتك التعليمية', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(60, 'about_offering3_desc_en', 'Carefully selected printed resources supporting your learning journey', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(61, 'about_val1_title_ar', 'الجودة أولاً', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(62, 'about_val1_title_en', 'Quality First', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(63, 'about_val1_desc_ar', 'محتوى مدروس بعناية من مدربين متخصصين في مجالاتهم', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(64, 'about_val1_desc_en', 'Carefully designed content by domain expert instructors', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(65, 'about_val2_title_ar', 'مرونة كاملة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(66, 'about_val2_title_en', 'Full Flexibility', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(67, 'about_val2_desc_ar', 'تعلم في الوقت والمكان اللذين يناسبانك دون قيود', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(68, 'about_val2_desc_en', 'Learn anytime, anywhere without constraints', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(69, 'about_val3_title_ar', 'مجتمع داعم', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(70, 'about_val3_title_en', 'Supportive Community', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(71, 'about_val3_desc_ar', 'تفاعل مع زملائك ومدربيك في بيئة تعليمية محفزة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(72, 'about_val3_desc_en', 'Interact with peers and teachers in an inspiring ecosystem', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(73, 'about_val4_title_ar', 'شهادات معتمدة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(74, 'about_val4_title_en', 'Certified Credentials', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(75, 'about_val4_desc_ar', 'احصل على شهادة إتمام موثقة لكل كورس تنهيه بنجاح', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(76, 'about_val4_desc_en', 'Earn verified completion certificates for completed courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(77, 'about_cta_title_ar', 'ابدأ رحلتك التعليمية مع Najeh اليوم', '2026-08-10 13:04:43', '2026-08-10 15:12:59'),
(78, 'about_cta_title_en', 'Start Your Learning Journey With Najeh Today', '2026-08-10 13:04:43', '2026-08-10 15:13:07'),
(79, 'about_cta_subtitle_ar', 'انضم إلى آلاف المتعلمين الذين اختاروا Najeh لتطوير مهاراتهم', '2026-08-10 13:04:43', '2026-08-10 15:13:22'),
(80, 'about_cta_subtitle_en', 'Join thousands of learners who chose Najeh to upgrade their skills', '2026-08-10 13:04:43', '2026-08-10 15:13:30'),
(81, 'footer_description_ar', 'منصة تعليمية شاملة بتساعد الطالب يذاكر ويتابع تقدمه ويحقق أعلى الدرجات براحته.', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(82, 'footer_description_en', 'Comprehensive educational platform helping students study, track progress, and achieve top grades.', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(83, 'facebook_link', 'https://facebook.com', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(84, 'instagram_link', 'https://instagram.com', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(85, 'youtube_link', 'https://youtube.com', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(86, 'whatsapp_number', '+96179431793', '2026-08-10 13:04:43', '2026-10-03 16:59:11'),
(4343, 'max_devices_per_student', '1', '2026-09-27 17:54:43', '2026-09-27 17:54:43'),
(4344, 'student_device_limit_enabled', '1', '2026-09-27 17:54:43', '2026-09-27 17:54:43'),
(4345, 'tiktok_link', '', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4346, 'telegram_link', '', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4347, 'maintenance_message_ar', 'المنصة تحت الصيانة حاليًا، برجاء المحاولة بعد قليل.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4348, 'maintenance_message_en', 'The platform is under maintenance. Please try again shortly.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4349, 'registration_disabled_message_ar', 'تسجيل الحسابات الجديدة متوقف حاليًا. برجاء التواصل مع الدعم الفني.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4350, 'registration_disabled_message_en', 'New account registration is currently closed. Please contact support.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4351, 'login_lockout_enabled', '0', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4352, 'login_lockout_minutes', '15', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4376, 'base_currency', 'USD', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4377, 'country_pricing_enabled', '1', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4378, 'geoip_lookup_enabled', '1', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4379, 'geoip_provider_url', 'https://ipwho.is/{ip}', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4380, 'default_phone_dial_code', '961', '2026-09-29 09:09:18', '2026-10-04 12:35:56'),
(4381, 'permissions_catalogue_hash', '5d880135a9da93a16ec8170ef7e4a92d', '2026-09-29 11:02:08', '2026-09-30 13:19:36'),
(4382, 'referral_commission_type', 'percent', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4383, 'referral_commission_value', '10', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4384, 'points_redeem_enabled', '1', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4385, 'points_min_redeem', '50', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4395, 'announcement_bar_enabled', '1', '2026-10-03 12:04:29', '2026-10-03 12:04:29'),
(4396, 'announcement_bar_items', '[{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"},{\"text_ar\":\"Najeh AI - Coming Soon....\",\"text_en\":\"Najeh AI - Coming Soon....\"}]', '2026-10-03 12:04:29', '2026-10-03 16:50:22');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `school_id` bigint(20) UNSIGNED DEFAULT NULL,
  `city_id` bigint(20) UNSIGNED DEFAULT NULL,
  `country_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Set by the student, or from the first geo-IP lookup',
  `referred_by_student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `affiliate_code` varchar(50) DEFAULT NULL,
  `points_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `study_language` enum('arabic','english','french') NOT NULL DEFAULT 'arabic',
  `name` varchar(200) NOT NULL,
  `age` tinyint(3) UNSIGNED DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `phone_country_code` varchar(8) DEFAULT NULL COMMENT 'Dial code of the phone number, without the +',
  `phone_key` varchar(16) GENERATED ALWAYS AS (nullif(right(regexp_replace(ifnull(`phone`,''),'[^0-9]',''),9),'')) STORED COMMENT 'Last 9 digits of the phone, for logging in. Computed, never written.',
  `email` varchar(190) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `image` varchar(500) DEFAULT NULL,
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fcm_token` text DEFAULT NULL,
  `academic_year_id` bigint(20) UNSIGNED DEFAULT NULL,
  `max_devices` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL = use site_settings.max_devices_per_student',
  `sessions_revoked_at` datetime DEFAULT NULL COMMENT 'Tokens issued before this moment are rejected'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_book_progress`
--

CREATE TABLE `student_book_progress` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL,
  `open_count` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `last_page_number` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `total_pages` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_opened_at` datetime DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_book_purchase_requests`
--

CREATE TABLE `student_book_purchase_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by_type` enum('admin','teacher') DEFAULT NULL,
  `reviewed_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_book_subscriptions`
--

CREATE TABLE `student_book_subscriptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL,
  `granted_by_type` enum('admin','teacher','student') NOT NULL DEFAULT 'admin',
  `granted_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `price` double NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_certificates`
--

CREATE TABLE `student_certificates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `certificate_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `exam_id` bigint(20) UNSIGNED DEFAULT NULL,
  `certificate_code` varchar(100) NOT NULL,
  `pdf_url` varchar(500) DEFAULT NULL,
  `score_achieved` decimal(8,2) DEFAULT NULL,
  `grade_obtained` decimal(8,2) DEFAULT NULL,
  `issue_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_point_transactions`
--

CREATE TABLE `student_point_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `points` decimal(10,2) NOT NULL DEFAULT 0.00,
  `type` enum('earn_referral_purchase','redeem','refund','admin_adjustment') NOT NULL DEFAULT 'earn_referral_purchase',
  `reference_type` enum('course','book','affiliate_commission','other') DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `referred_student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_question_answers`
--

CREATE TABLE `student_question_answers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `unit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `mcq_option_id` bigint(20) UNSIGNED DEFAULT NULL,
  `true_false_answer` tinyint(1) DEFAULT NULL,
  `written_answer_text` text DEFAULT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT 0,
  `score_awarded` decimal(8,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_referrals`
--

CREATE TABLE `student_referrals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `referrer_student_id` bigint(20) UNSIGNED NOT NULL,
  `referred_student_id` bigint(20) UNSIGNED NOT NULL,
  `affiliate_code` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_reports`
--

CREATE TABLE `student_reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_type` enum('teacher','admin','system') NOT NULL DEFAULT 'teacher',
  `admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `session_id` bigint(20) UNSIGNED DEFAULT NULL,
  `exam_attempt_id` bigint(20) UNSIGNED DEFAULT NULL,
  `report_type` enum('academic_performance','behavior_discipline','exam_result','attendance') NOT NULL DEFAULT 'academic_performance',
  `term` varchar(100) DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `max_score` decimal(5,2) DEFAULT NULL,
  `grade_label` varchar(50) DEFAULT NULL,
  `percentage` decimal(5,2) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `strengths` longtext DEFAULT NULL CHECK (json_valid(`strengths`)),
  `improvements` longtext DEFAULT NULL CHECK (json_valid(`improvements`)),
  `report_date` date DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL DEFAULT 5,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_subscriptions`
--

CREATE TABLE `student_subscriptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `subscription_code_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subscription_type` enum('course','subject','teacher','package','custom','book') NOT NULL DEFAULT 'custom',
  `start_date` datetime NOT NULL DEFAULT current_timestamp(),
  `end_date` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `paused_at` datetime DEFAULT NULL COMMENT 'When an admin paused it. NULL once resumed.',
  `cancelled_at` datetime DEFAULT NULL COMMENT 'When an admin cancelled it outright',
  `status_reason` varchar(500) DEFAULT NULL COMMENT 'What the admin typed when pausing or cancelling',
  `status_changed_by` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'The admin who paused or cancelled it',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_subscription_books`
--

CREATE TABLE `student_subscription_books` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_subscription_courses`
--

CREATE TABLE `student_subscription_courses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_subscription_subjects`
--

CREATE TABLE `student_subscription_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_subscription_teachers`
--

CREATE TABLE `student_subscription_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `student_video_progress`
--

CREATE TABLE `student_video_progress` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `video_id` bigint(20) UNSIGNED NOT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  `watched_seconds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `total_seconds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_position_seconds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`id`, `code`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'arabic', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 'english', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 'mathematics', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 'chemistry', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 'geography', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 'philosophy-logic', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 'computer-science', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(11, 'french', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(13, 'economics', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(14, 'psychology', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(15, 'integrated-science', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(16, 'nahw', 1, '2026-09-21 00:15:57', '2026-09-21 00:15:57'),
(18, 'biology', 1, '2026-09-21 18:58:21', '2026-09-21 19:01:39'),
(20, 'physics', 1, '2026-09-24 18:19:26', '2026-09-24 18:19:26'),
(21, 'civics', 1, '2026-09-25 23:45:23', '2026-09-25 23:45:23'),
(22, 'sociology', 1, '2026-09-25 23:45:23', '2026-09-25 23:45:23'),
(23, 'history', 1, '2026-09-27 20:31:45', '2026-10-03 13:47:09'),
(24, 'official-exams', 1, '2026-10-03 14:33:54', '2026-10-03 14:33:54');

-- --------------------------------------------------------

--
-- Table structure for table `subjects_translations`
--

CREATE TABLE `subjects_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subjects_translations`
--

INSERT INTO `subjects_translations` (`id`, `subject_id`, `language_id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'اللغة العربية', 'النحو والبلاغة والقراءة والتعبير.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(2, 1, 2, 'Arabic Language', 'Arabic Language learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(3, 2, 1, 'اللغة الإنجليزية', 'Grammar, reading, writing and communication.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 2, 2, 'English Language', 'English Language learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(5, 3, 1, 'الرياضيات', 'الجبر والهندسة والتفاضل والإحصاء.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(6, 3, 2, 'Mathematics', 'Mathematics learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 5, 1, 'الكيمياء', 'الكيمياء العامة والعضوية والتحليلية.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 5, 2, 'Chemistry', 'Chemistry learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(15, 8, 1, 'الجغرافيا', 'الجغرافيا الطبيعية والبشرية والخرائط.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(16, 8, 2, 'Geography', 'Geography learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(17, 9, 1, 'الفلسفة والمنطق', 'التفكير النقدي والاستدلال والمنطق.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(18, 9, 2, 'Philosophy & Logic', 'Philosophy & Logic learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(19, 10, 1, 'علوم الحاسب', 'البرمجة والخوارزميات وقواعد البيانات.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(20, 10, 2, 'Computer Science', 'Computer Science learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(21, 11, 1, 'اللغة الفرنسية', 'Vocabulary, grammar and conversation.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(22, 11, 2, 'French Language', 'French Language learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(25, 13, 1, 'الاقتصاد', 'المفاهيم الاقتصادية والأسواق والقرارات المالية.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(26, 13, 2, 'Economics', 'Economics learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(27, 14, 1, 'علم النفس', 'السلوك والتعلم والدافعية والعمليات المعرفية.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(28, 14, 2, 'Psychology', 'Psychology learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(29, 15, 1, 'العلوم المتكاملة', 'المادة والطاقة والأحياء والأرض في إطار متكامل.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(30, 15, 2, 'Integrated Science', 'Integrated Science learning content with structured explanations, practice and assessment.', 1, '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(31, 16, 1, 'نحو', '', 1, '2026-09-21 00:15:57', '2026-09-21 00:15:57'),
(32, 16, 2, 'nahw', '', 1, '2026-09-21 00:15:57', '2026-09-21 00:15:57'),
(33, 18, 1, 'علوم حياة', '', 1, '2026-09-21 18:58:21', '2026-09-21 18:58:21'),
(34, 18, 2, 'biology', '', 1, '2026-09-21 18:58:21', '2026-09-21 18:58:21'),
(35, 20, 1, 'الفيزياء', '', 1, '2026-09-24 18:19:26', '2026-09-24 18:19:26'),
(36, 20, 2, 'physics', '', 1, '2026-09-24 18:19:26', '2026-09-24 18:19:26'),
(37, 21, 1, 'التربية الوطنية والتنشئة المدنية', 'التربية الوطنية والتنشئة المدنية وفق المنهج اللبنانيّ.', 1, '2026-09-25 23:45:23', '2026-09-25 23:45:23'),
(38, 21, 2, 'Civics and Citizenship', 'Civics and citizenship education following the Lebanese curriculum.', 1, '2026-09-25 23:45:23', '2026-09-25 23:45:23'),
(39, 22, 1, 'علم الاجتماع', 'علم الاجتماع وفق المنهج اللبنانيّ.', 1, '2026-09-25 23:45:23', '2026-09-25 23:45:23'),
(40, 22, 2, 'Sociology', 'Sociology following the Lebanese curriculum.', 1, '2026-09-25 23:45:23', '2026-09-25 23:45:23'),
(41, 23, 1, 'التاريخ', 'التاريخ وفق المنهج اللبنانيّ.', 1, '2026-09-27 20:31:45', '2026-09-27 20:31:45'),
(42, 23, 2, 'History', 'History following the Lebanese curriculum.', 1, '2026-09-27 20:31:45', '2026-09-27 20:31:45'),
(43, 24, 1, 'شامل — الامتحانات الرسمية', 'نماذج الامتحانات الرسمية السابقة لكل المواد مرتّبة حسب المادة والسنة.', 1, '2026-10-03 14:33:54', '2026-10-03 14:33:54'),
(44, 24, 2, 'Shamel — Official Exams', 'Past official exam papers for every subject, arranged by subject and year.', 1, '2026-10-03 14:33:54', '2026-10-03 14:33:54');

-- --------------------------------------------------------

--
-- Table structure for table `subject_academic_years`
--

CREATE TABLE `subject_academic_years` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `academic_year_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subject_academic_years`
--

INSERT INTO `subject_academic_years` (`id`, `subject_id`, `academic_year_id`, `is_active`, `created_at`) VALUES
(1, 1, 9, 1, '2026-08-10 16:00:00'),
(2, 1, 10, 1, '2026-08-10 16:00:00'),
(3, 1, 11, 1, '2026-08-10 16:00:00'),
(4, 1, 12, 1, '2026-08-10 16:00:00'),
(5, 2, 9, 1, '2026-08-10 16:00:00'),
(6, 2, 10, 1, '2026-08-10 16:00:00'),
(7, 2, 11, 1, '2026-08-10 16:00:00'),
(8, 2, 12, 1, '2026-08-10 16:00:00'),
(9, 3, 9, 1, '2026-08-10 16:00:00'),
(10, 3, 10, 1, '2026-08-10 16:00:00'),
(11, 3, 11, 1, '2026-08-10 16:00:00'),
(12, 3, 12, 1, '2026-08-10 16:00:00'),
(17, 5, 9, 1, '2026-08-10 16:00:00'),
(18, 5, 10, 1, '2026-08-10 16:00:00'),
(19, 5, 11, 1, '2026-08-10 16:00:00'),
(20, 5, 12, 1, '2026-08-10 16:00:00'),
(29, 8, 9, 1, '2026-08-10 16:00:00'),
(30, 8, 10, 1, '2026-08-10 16:00:00'),
(31, 8, 11, 1, '2026-08-10 16:00:00'),
(32, 8, 12, 1, '2026-08-10 16:00:00'),
(33, 9, 9, 1, '2026-08-10 16:00:00'),
(34, 9, 10, 1, '2026-08-10 16:00:00'),
(35, 9, 11, 1, '2026-08-10 16:00:00'),
(36, 9, 12, 1, '2026-08-10 16:00:00'),
(37, 10, 9, 1, '2026-08-10 16:00:00'),
(38, 10, 10, 1, '2026-08-10 16:00:00'),
(39, 10, 11, 1, '2026-08-10 16:00:00'),
(40, 10, 12, 1, '2026-08-10 16:00:00'),
(41, 11, 9, 1, '2026-08-10 16:00:00'),
(42, 11, 10, 1, '2026-08-10 16:00:00'),
(43, 11, 11, 1, '2026-08-10 16:00:00'),
(44, 11, 12, 1, '2026-08-10 16:00:00'),
(45, 15, 9, 1, '2026-08-10 16:00:00'),
(46, 15, 10, 1, '2026-08-10 16:00:00'),
(47, 15, 11, 1, '2026-08-10 16:00:00'),
(48, 15, 12, 1, '2026-08-10 16:00:00'),
(49, 20, 14, 1, '2026-09-24 18:20:17');

-- --------------------------------------------------------

--
-- Table structure for table `subscription_codes`
--

CREATE TABLE `subscription_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `max_uses` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `used_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `claimed_by_student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `duration_days` int(10) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `subscription_code_courses`
--

CREATE TABLE `subscription_code_courses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subscription_code_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `subscription_code_subjects`
--

CREATE TABLE `subscription_code_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subscription_code_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscription_code_teachers`
--

CREATE TABLE `subscription_code_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subscription_code_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `city_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password` varchar(255) NOT NULL,
  `whatsapp` varchar(30) DEFAULT NULL,
  `experience` text DEFAULT NULL,
  `specialization` varchar(200) DEFAULT NULL,
  `biography` text DEFAULT NULL,
  `qualifications` text DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `video` longtext DEFAULT NULL,
  `image` longtext DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `is_attendance_suspended` tinyint(1) NOT NULL DEFAULT 0,
  `wallet_balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `can_view_profile` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `teacher_availability_slots`
--

CREATE TABLE `teacher_availability_slots` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `slot_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `capacity` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `booked_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `status` enum('available','full','cancelled','completed') NOT NULL DEFAULT 'available',
  `is_online` tinyint(1) NOT NULL DEFAULT 1,
  `meeting_link` varchar(500) DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `teacher_deduction_appeals`
--

CREATE TABLE `teacher_deduction_appeals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `wallet_transaction_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `reason` text NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `admin_note` text DEFAULT NULL,
  `reviewed_by_admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `teacher_pay_rates`
--

CREATE TABLE `teacher_pay_rates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `pay_model` enum('hourly','per_session','per_minute') NOT NULL,
  `rate_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teacher_ratings`
--

CREATE TABLE `teacher_ratings` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `teacher_session_attendance`
--

CREATE TABLE `teacher_session_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `occurrence_date` date NOT NULL,
  `status` enum('present','late','absent') NOT NULL DEFAULT 'present',
  `check_in_time` datetime DEFAULT NULL,
  `check_out_time` datetime DEFAULT NULL,
  `minutes_late` int(11) NOT NULL DEFAULT 0,
  `is_excused` tinyint(1) NOT NULL DEFAULT 0,
  `recorded_by` enum('teacher','system') NOT NULL DEFAULT 'teacher',
  `earning_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `wallet_transaction_id` bigint(20) UNSIGNED DEFAULT NULL,
  `marked_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `teacher_subjects`
--

CREATE TABLE `teacher_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `academic_year_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `teacher_wallet_transactions`
--

CREATE TABLE `teacher_wallet_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('earning','fine','refund','admin_adjustment') NOT NULL,
  `amount` decimal(10,2) NOT NULL COMMENT 'positive = credit (earning/refund/positive adjustment), negative = debit (fine/negative adjustment)',
  `reference_type` enum('session','appeal','manual') NOT NULL DEFAULT 'manual',
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_by_type` enum('system','admin') NOT NULL DEFAULT 'system',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `transaction_code` varchar(80) NOT NULL,
  `transaction_type` enum('purchase','subscription','refund','payout','commission','adjustment') NOT NULL DEFAULT 'purchase',
  `direction` enum('incoming','outgoing') NOT NULL DEFAULT 'incoming',
  `payer_type` enum('student','parent','teacher','system','guest') NOT NULL DEFAULT 'student',
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `parent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `related_transaction_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fees_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `currency` char(3) NOT NULL DEFAULT 'EGP',
  `payment_method` enum('cash','card','wallet','bank_transfer','fawry','instapay','free','other') NOT NULL DEFAULT 'other',
  `payment_provider` varchar(100) DEFAULT NULL,
  `provider_reference` varchar(190) DEFAULT NULL,
  `status` enum('pending','processing','paid','failed','cancelled','refunded','partially_refunded') NOT NULL DEFAULT 'pending',
  `paid_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `refunded_at` datetime DEFAULT NULL,
  `billing_name` varchar(200) DEFAULT NULL,
  `billing_email` varchar(190) DEFAULT NULL,
  `billing_phone` varchar(30) DEFAULT NULL,
  `metadata` longtext DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `transactions_translations`
--

CREATE TABLE `transactions_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `transaction_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `notes` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `transaction_items`
--

CREATE TABLE `transaction_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `transaction_id` bigint(20) UNSIGNED NOT NULL,
  `item_type` varchar(50) NOT NULL,
  `item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quantity` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `unit_price` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `currency` char(3) NOT NULL DEFAULT 'EGP',
  `metadata` longtext DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `transaction_items_translations`
--

CREATE TABLE `transaction_items_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `transaction_item_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `true_false_answers`
--

CREATE TABLE `true_false_answers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `correct_answer` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `units`
--

CREATE TABLE `units` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(120) NOT NULL,
  `order_num` int(11) NOT NULL DEFAULT 0,
  `videos_drip_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `duration` int(10) UNSIGNED DEFAULT NULL,
  `duration_unit` enum('day','week','month') DEFAULT NULL,
  `lessons_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `units_translations`
--

CREATE TABLE `units_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `unit_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `unit_teachers`
--

CREATE TABLE `unit_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `unit_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `user_devices`
--

CREATE TABLE `user_devices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_type` enum('student','teacher','parent') NOT NULL DEFAULT 'student',
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `device_id` varchar(191) NOT NULL COMMENT 'Opaque id the client generates once and keeps',
  `device_name` varchar(255) DEFAULT NULL COMMENT 'Human label for the admin screen, e.g. Chrome on Windows',
  `platform` varchar(100) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 = revoked by an admin; the row is kept as history',
  `revoked_at` datetime DEFAULT NULL,
  `revoked_by_admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `first_seen_at` timestamp NULL DEFAULT current_timestamp(),
  `last_seen_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `videos`
--

CREATE TABLE `videos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `unit_id` bigint(20) UNSIGNED NOT NULL,
  `order_num` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `code` varchar(120) NOT NULL,
  `video_url` text DEFAULT NULL COMMENT 'Where the video plays from. Bunny, YouTube, or a direct file.',
  `duration_seconds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `publish_status` enum('draft','published') NOT NULL DEFAULT 'draft',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `videos_translations`
--

CREATE TABLE `videos_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `video_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `video_teachers`
--

CREATE TABLE `video_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `video_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `written_model_answers`
--

CREATE TABLE `written_model_answers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `written_model_answers_translations`
--

CREATE TABLE `written_model_answers_translations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `written_model_answer_id` bigint(20) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `model_answer` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `academic_years`
--
ALTER TABLE `academic_years`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_academic_years_code` (`code`);

--
-- Indexes for table `academic_years_translations`
--
ALTER TABLE `academic_years_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_academic_years_translations` (`academic_year_id`,`language_id`),
  ADD KEY `idx_academic_years_translations_language_id` (`language_id`);

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_admins_email` (`email`),
  ADD KEY `fk_admins_role` (`role_id`);

--
-- Indexes for table `admin_permissions`
--
ALTER TABLE `admin_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_admin_permission` (`admin_id`,`permission_id`),
  ADD KEY `idx_admin_permissions_admin` (`admin_id`),
  ADD KEY `idx_admin_permissions_permission` (`permission_id`);

--
-- Indexes for table `advertisements`
--
ALTER TABLE `advertisements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_advertisements_user` (`user_type`,`user_id`),
  ADD KEY `idx_advertisements_position` (`position`),
  ADD KEY `idx_advertisements_status` (`status`);

--
-- Indexes for table `advertisements_translations`
--
ALTER TABLE `advertisements_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_advertisements_translations` (`advertisement_id`,`language_id`),
  ADD KEY `idx_advertisements_translations_language_id` (`language_id`);

--
-- Indexes for table `affiliates`
--
ALTER TABLE `affiliates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_affiliates_code` (`affiliate_code`),
  ADD KEY `idx_affiliates_student_id` (`student_id`),
  ADD KEY `idx_affiliates_teacher_id` (`teacher_id`);

--
-- Indexes for table `affiliate_commissions`
--
ALTER TABLE `affiliate_commissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_affiliate_commissions_affiliate_id` (`affiliate_id`),
  ADD KEY `idx_affiliate_commissions_status` (`status`),
  ADD KEY `idx_affiliate_commissions_referred_student` (`referred_student_id`),
  ADD KEY `idx_affiliate_commissions_approved_by` (`approved_by_admin_id`);

--
-- Indexes for table `attendance_exception_requests`
--
ALTER TABLE `attendance_exception_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_aer_session_date` (`session_id`,`occurrence_date`),
  ADD KEY `idx_aer_requester` (`requested_by_type`,`requested_by_id`),
  ADD KEY `idx_aer_status` (`status`);

--
-- Indexes for table `availability_slot_bookings`
--
ALTER TABLE `availability_slot_bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_asb_slot_student` (`slot_id`,`student_id`),
  ADD KEY `idx_asb_student` (`student_id`),
  ADD KEY `idx_asb_slot` (`slot_id`),
  ADD KEY `idx_asb_subscription` (`student_subscription_id`),
  ADD KEY `idx_asb_status` (`status`);

--
-- Indexes for table `banners`
--
ALTER TABLE `banners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_banners_is_active` (`is_active`),
  ADD KEY `idx_banners_type` (`type`);

--
-- Indexes for table `banner_views`
--
ALTER TABLE `banner_views`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_banner_views_banner_id` (`banner_id`),
  ADD KEY `idx_banner_views_user_id` (`user_id`),
  ADD KEY `idx_banner_views_user_type` (`user_type`);

--
-- Indexes for table `book_teachers`
--
ALTER TABLE `book_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_book_teachers` (`book_id`,`teacher_id`),
  ADD KEY `idx_bt_book` (`book_id`),
  ADD KEY `idx_bt_teacher` (`teacher_id`);

--
-- Indexes for table `certificates`
--
ALTER TABLE `certificates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_cert_academic_year` (`academic_year_id`),
  ADD KEY `idx_cert_subject` (`subject_id`),
  ADD KEY `idx_cert_course` (`course_id`),
  ADD KEY `idx_cert_type` (`certificate_type`),
  ADD KEY `idx_cert_code` (`code`);

--
-- Indexes for table `certificates_translations`
--
ALTER TABLE `certificates_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_certificates_lang` (`certificate_id`,`language_id`),
  ADD KEY `idx_cert_trans_certificate` (`certificate_id`);

--
-- Indexes for table `certificate_teachers`
--
ALTER TABLE `certificate_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_certificate_teachers` (`certificate_id`,`teacher_id`),
  ADD KEY `idx_ct_cert` (`certificate_id`),
  ADD KEY `idx_ct_teacher` (`teacher_id`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cities_code` (`code`);

--
-- Indexes for table `cities_translations`
--
ALTER TABLE `cities_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cities_translations` (`city_id`,`language_id`),
  ADD KEY `idx_cities_translations_language_id` (`language_id`);

--
-- Indexes for table `class_sessions`
--
ALTER TABLE `class_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_csn_teacher` (`teacher_id`),
  ADD KEY `idx_csn_subject` (`subject_id`),
  ADD KEY `idx_csn_course` (`course_id`),
  ADD KEY `idx_csn_day` (`day_of_week`),
  ADD KEY `fk_class_sessions_academic_year` (`academic_year_id`);

--
-- Indexes for table `class_session_notification_log`
--
ALTER TABLE `class_session_notification_log`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_session_notify` (`session_id`,`notify_type`,`session_date`);

--
-- Indexes for table `code_redemptions_log`
--
ALTER TABLE `code_redemptions_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_crl_code` (`subscription_code_id`),
  ADD KEY `idx_crl_student` (`student_id`),
  ADD KEY `idx_crl_sub` (`student_subscription_id`);

--
-- Indexes for table `consultation_slots`
--
ALTER TABLE `consultation_slots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cs_teacher` (`teacher_id`),
  ADD KEY `idx_cs_student` (`student_id`),
  ADD KEY `idx_cs_date` (`slot_date`),
  ADD KEY `idx_cs_status` (`status`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_country_iso2` (`iso2`),
  ADD KEY `idx_country_active` (`is_active`,`sort_order`),
  ADD KEY `idx_country_currency` (`currency_code`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_courses_slug` (`slug`),
  ADD KEY `idx_courses_category_id` (`category_id`),
  ADD KEY `idx_courses_academic_year_id` (`academic_year_id`),
  ADD KEY `idx_courses_teacher_id` (`teacher_id`),
  ADD KEY `idx_courses_kind` (`kind`),
  ADD KEY `idx_courses_type` (`type`),
  ADD KEY `idx_courses_order_num` (`order_num`);

--
-- Indexes for table `courses_translations`
--
ALTER TABLE `courses_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_courses_translations` (`course_id`,`language_id`),
  ADD KEY `idx_courses_translations_language_id` (`language_id`);

--
-- Indexes for table `course_books`
--
ALTER TABLE `course_books`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cb_subject` (`subject_id`),
  ADD KEY `idx_cb_course` (`course_id`),
  ADD KEY `idx_cb_unit` (`unit_id`);

--
-- Indexes for table `course_books_translations`
--
ALTER TABLE `course_books_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_book_lang` (`book_id`,`language_id`),
  ADD KEY `idx_cbt_book` (`book_id`);

--
-- Indexes for table `course_categories`
--
ALTER TABLE `course_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_course_categories_code` (`code`);

--
-- Indexes for table `course_categories_translations`
--
ALTER TABLE `course_categories_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_course_categories_translations` (`course_category_id`,`language_id`),
  ADD KEY `idx_course_categories_translations_language_id` (`language_id`);

--
-- Indexes for table `course_exams`
--
ALTER TABLE `course_exams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ce_subject` (`subject_id`),
  ADD KEY `idx_ce_course` (`course_id`),
  ADD KEY `idx_ce_unit` (`unit_id`);

--
-- Indexes for table `course_exams_translations`
--
ALTER TABLE `course_exams_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_exam_lang` (`exam_id`,`language_id`),
  ADD KEY `idx_cet_exam` (`exam_id`);

--
-- Indexes for table `course_ratings`
--
ALTER TABLE `course_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_student_course_rating` (`student_id`,`course_id`),
  ADD KEY `idx_course_rating` (`course_id`),
  ADD KEY `idx_student_course_rating` (`student_id`);

--
-- Indexes for table `course_teachers`
--
ALTER TABLE `course_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_course_teachers` (`course_id`,`teacher_id`),
  ADD KEY `idx_ct_course` (`course_id`),
  ADD KEY `idx_ct_teacher` (`teacher_id`);

--
-- Indexes for table `course_videos`
--
ALTER TABLE `course_videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cv_subject` (`subject_id`),
  ADD KEY `idx_cv_course` (`course_id`),
  ADD KEY `idx_cv_unit` (`unit_id`);

--
-- Indexes for table `course_videos_translations`
--
ALTER TABLE `course_videos_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_video_lang` (`video_id`,`language_id`),
  ADD KEY `idx_cvt_video` (`video_id`);

--
-- Indexes for table `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_currency_code` (`code`),
  ADD KEY `idx_currency_active` (`is_active`);

--
-- Indexes for table `discount_codes`
--
ALTER TABLE `discount_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_dc_code` (`code`),
  ADD KEY `idx_dc_active` (`is_active`),
  ADD KEY `idx_dc_valid_to` (`valid_to`);

--
-- Indexes for table `discount_code_courses`
--
ALTER TABLE `discount_code_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_dcc` (`discount_code_id`,`course_id`),
  ADD KEY `idx_dcc_code` (`discount_code_id`),
  ADD KEY `idx_dcc_course` (`course_id`);

--
-- Indexes for table `discount_code_redemptions`
--
ALTER TABLE `discount_code_redemptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dcr_code` (`discount_code_id`),
  ADD KEY `idx_dcr_student` (`student_id`),
  ADD KEY `idx_dcr_course` (`course_id`),
  ADD KEY `idx_dcr_student_status` (`student_id`,`status`);

--
-- Indexes for table `email_verification_codes`
--
ALTER TABLE `email_verification_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email_verification_lookup` (`email`,`code`,`user_type`);

--
-- Indexes for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_exam_attempt_student` (`exam_id`,`student_id`),
  ADD KEY `idx_ea_exam` (`exam_id`),
  ADD KEY `idx_ea_student` (`student_id`),
  ADD KEY `idx_ea_status` (`status`);

--
-- Indexes for table `exam_attempt_answers`
--
ALTER TABLE `exam_attempt_answers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_attempt_question` (`attempt_id`,`question_id`),
  ADD KEY `idx_eaa_attempt` (`attempt_id`),
  ADD KEY `idx_eaa_question` (`question_id`);

--
-- Indexes for table `exam_teachers`
--
ALTER TABLE `exam_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_exam_teachers` (`exam_id`,`teacher_id`),
  ADD KEY `idx_et_exam` (`exam_id`),
  ADD KEY `idx_et_teacher` (`teacher_id`);

--
-- Indexes for table `homework`
--
ALTER TABLE `homework`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_hw_teacher` (`teacher_id`),
  ADD KEY `idx_hw_subject` (`subject_id`);

--
-- Indexes for table `homework_submissions`
--
ALTER TABLE `homework_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_hw_student` (`homework_id`,`student_id`),
  ADD KEY `idx_hws_homework` (`homework_id`),
  ADD KEY `idx_hws_student` (`student_id`);

--
-- Indexes for table `hr_policy_settings`
--
ALTER TABLE `hr_policy_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ip_country_cache`
--
ALTER TABLE `ip_country_cache`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_ip` (`ip_address`),
  ADD KEY `idx_looked_up` (`looked_up_at`);

--
-- Indexes for table `item_country_prices`
--
ALTER TABLE `item_country_prices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_item_country` (`item_type`,`item_id`,`country_id`),
  ADD KEY `idx_item` (`item_type`,`item_id`),
  ADD KEY `idx_country` (`country_id`);

--
-- Indexes for table `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_languages_code` (`code`),
  ADD KEY `idx_languages_sort_order` (`sort_order`);

--
-- Indexes for table `languages_translations`
--
ALTER TABLE `languages_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_languages_translations` (`translated_language_id`,`language_id`),
  ADD KEY `idx_languages_translations_language_id` (`language_id`);

--
-- Indexes for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_login_attempt` (`identifier`,`ip_address`,`role`),
  ADD KEY `idx_la_locked_until` (`locked_until`),
  ADD KEY `idx_la_last_failure` (`last_failure_at`);

--
-- Indexes for table `mcq_options`
--
ALTER TABLE `mcq_options`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_mcq_options_question_id` (`question_id`);

--
-- Indexes for table `mcq_options_translations`
--
ALTER TABLE `mcq_options_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_mcq_options_translations` (`mcq_option_id`,`language_id`),
  ADD KEY `idx_mcq_options_translations_language_id` (`language_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notification_recipients`
--
ALTER TABLE `notification_recipients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_nr_notification` (`notification_id`),
  ADD KEY `idx_nr_user` (`user_type`,`user_id`);

--
-- Indexes for table `offline_payment_requests`
--
ALTER TABLE `offline_payment_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_opr_student` (`student_id`,`status`),
  ADD KEY `idx_opr_status` (`status`,`created_at`),
  ADD KEY `idx_opr_item` (`item_type`,`item_id`);

--
-- Indexes for table `parents`
--
ALTER TABLE `parents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_parents_email` (`email`),
  ADD KEY `idx_parents_city_id` (`city_id`);

--
-- Indexes for table `parent_students`
--
ALTER TABLE `parent_students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_parent_students` (`parent_id`,`student_id`),
  ADD KEY `idx_parent_students_student_id` (`student_id`);

--
-- Indexes for table `password_reset_codes`
--
ALTER TABLE `password_reset_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_password_reset_lookup` (`email`,`code`,`user_type`,`is_used`);

--
-- Indexes for table `payment_accounts`
--
ALTER TABLE `payment_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pa_active` (`is_active`,`sort_order`);

--
-- Indexes for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pt_student` (`student_id`),
  ADD KEY `idx_pt_status` (`status`),
  ADD KEY `idx_pt_ref` (`easykash_ref`),
  ADD KEY `idx_pt_item` (`item_type`,`item_id`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_permissions_code` (`code`);

--
-- Indexes for table `permissions_translations`
--
ALTER TABLE `permissions_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_permissions_translations` (`permission_id`,`language_id`),
  ADD KEY `idx_permissions_translations_language` (`language_id`);

--
-- Indexes for table `point_currency_values`
--
ALTER TABLE `point_currency_values`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_point_currency` (`currency_code`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_questions_exam_id` (`exam_id`),
  ADD KEY `idx_questions_course_id` (`course_id`),
  ADD KEY `idx_questions_unit_id` (`unit_id`),
  ADD KEY `idx_questions_type` (`question_type`);

--
-- Indexes for table `questions_translations`
--
ALTER TABLE `questions_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_questions_translations` (`question_id`,`language_id`),
  ADD KEY `idx_questions_translations_language_id` (`language_id`);

--
-- Indexes for table `resources`
--
ALTER TABLE `resources`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_resources_code` (`code`),
  ADD KEY `idx_resources_course_id` (`course_id`),
  ADD KEY `idx_resources_unit_id` (`unit_id`),
  ADD KEY `idx_resources_type` (`resource_type`);

--
-- Indexes for table `resources_translations`
--
ALTER TABLE `resources_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_resources_translations` (`resource_id`,`language_id`),
  ADD KEY `idx_resources_translations_language_id` (`language_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_roles_code` (`code`);

--
-- Indexes for table `roles_translations`
--
ALTER TABLE `roles_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_roles_translations` (`role_id`,`language_id`),
  ADD KEY `idx_roles_translations_language` (`language_id`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_role_permissions` (`role_id`,`permission_id`),
  ADD KEY `fk_role_permissions_permission` (`permission_id`);

--
-- Indexes for table `schools`
--
ALTER TABLE `schools`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_schools_code` (`code`),
  ADD KEY `idx_schools_school_type_id` (`school_type_id`),
  ADD KEY `idx_schools_city_id` (`city_id`);

--
-- Indexes for table `schools_translations`
--
ALTER TABLE `schools_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_schools_translations` (`school_id`,`language_id`),
  ADD KEY `idx_schools_translations_language_id` (`language_id`);

--
-- Indexes for table `school_types`
--
ALTER TABLE `school_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_types_code` (`code`);

--
-- Indexes for table `school_types_translations`
--
ALTER TABLE `school_types_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_school_types_translations` (`school_type_id`,`language_id`),
  ADD KEY `idx_school_types_translations_language_id` (`language_id`);

--
-- Indexes for table `session_attendance`
--
ALTER TABLE `session_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sess_att` (`session_id`,`student_id`,`session_date`),
  ADD KEY `idx_sa_session` (`session_id`),
  ADD KEY `idx_sa_student` (`student_id`),
  ADD KEY `idx_sa_date` (`session_date`);

--
-- Indexes for table `session_files`
--
ALTER TABLE `session_files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_session_files_session_id` (`session_id`),
  ADD KEY `idx_session_files_file_type` (`file_type`),
  ADD KEY `idx_session_files_uploader` (`uploaded_by_type`,`uploaded_by_id`);

--
-- Indexes for table `session_file_submissions`
--
ALTER TABLE `session_file_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_submission_student_file` (`session_file_id`,`student_id`),
  ADD KEY `idx_submissions_student` (`student_id`),
  ADD KEY `idx_submissions_file` (`session_file_id`),
  ADD KEY `idx_submissions_status` (`status`);

--
-- Indexes for table `session_reschedule_requests`
--
ALTER TABLE `session_reschedule_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_srr_session` (`session_id`),
  ADD KEY `idx_srr_teacher` (`teacher_id`),
  ADD KEY `idx_srr_status` (`status`),
  ADD KEY `idx_srr_requested_by` (`requested_by_type`,`requested_by_id`);

--
-- Indexes for table `site_settings`
--
ALTER TABLE `site_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key_unique` (`setting_key`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_students_email` (`email`),
  ADD UNIQUE KEY `uq_students_affiliate_code` (`affiliate_code`),
  ADD KEY `idx_students_school_id` (`school_id`),
  ADD KEY `idx_students_city_id` (`city_id`),
  ADD KEY `idx_students_referred_by` (`referred_by_student_id`),
  ADD KEY `idx_students_country` (`country_id`),
  ADD KEY `idx_students_phone_key` (`phone_key`);

--
-- Indexes for table `student_book_progress`
--
ALTER TABLE `student_book_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_student_book` (`student_id`,`book_id`),
  ADD KEY `idx_sbp_student` (`student_id`),
  ADD KEY `idx_sbp_book` (`book_id`);

--
-- Indexes for table `student_book_purchase_requests`
--
ALTER TABLE `student_book_purchase_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `book_id` (`book_id`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `student_book_subscriptions`
--
ALTER TABLE `student_book_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `student_certificates`
--
ALTER TABLE `student_certificates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `certificate_code` (`certificate_code`),
  ADD KEY `idx_sc_cert` (`certificate_id`),
  ADD KEY `idx_sc_student` (`student_id`),
  ADD KEY `idx_sc_course` (`course_id`),
  ADD KEY `idx_sc_exam` (`exam_id`);

--
-- Indexes for table `student_point_transactions`
--
ALTER TABLE `student_point_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_student_point_tx_student` (`student_id`);

--
-- Indexes for table `student_question_answers`
--
ALTER TABLE `student_question_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sqa_student` (`student_id`),
  ADD KEY `idx_sqa_question` (`question_id`),
  ADD KEY `idx_sqa_unit` (`unit_id`),
  ADD KEY `idx_sqa_course` (`course_id`),
  ADD KEY `idx_sqa_student_question` (`student_id`,`question_id`);

--
-- Indexes for table `student_referrals`
--
ALTER TABLE `student_referrals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_student_referrals_referrer` (`referrer_student_id`),
  ADD KEY `idx_student_referrals_referred` (`referred_student_id`);

--
-- Indexes for table `student_reports`
--
ALTER TABLE `student_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sr_teacher` (`teacher_id`),
  ADD KEY `idx_sr_student` (`student_id`),
  ADD KEY `idx_sr_admin` (`admin_id`),
  ADD KEY `idx_sr_subject` (`subject_id`),
  ADD KEY `idx_sr_report_type` (`report_type`),
  ADD KEY `idx_sr_date` (`report_date`);

--
-- Indexes for table `student_subscriptions`
--
ALTER TABLE `student_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ss_student` (`student_id`),
  ADD KEY `idx_ss_code` (`subscription_code_id`),
  ADD KEY `idx_ss_active` (`is_active`),
  ADD KEY `idx_ss_end_date` (`end_date`);

--
-- Indexes for table `student_subscription_books`
--
ALTER TABLE `student_subscription_books`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_subscription_id` (`student_subscription_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `student_subscription_courses`
--
ALTER TABLE `student_subscription_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ss_crs` (`student_subscription_id`,`course_id`),
  ADD KEY `idx_ssc_sub` (`student_subscription_id`),
  ADD KEY `idx_ssc_crs` (`course_id`);

--
-- Indexes for table `student_subscription_subjects`
--
ALTER TABLE `student_subscription_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ss_subj` (`student_subscription_id`,`subject_id`),
  ADD KEY `idx_sss_sub` (`student_subscription_id`),
  ADD KEY `idx_sss_subj` (`subject_id`);

--
-- Indexes for table `student_subscription_teachers`
--
ALTER TABLE `student_subscription_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ss_teach` (`student_subscription_id`,`teacher_id`),
  ADD KEY `idx_sst_sub` (`student_subscription_id`),
  ADD KEY `idx_sst_teach` (`teacher_id`);

--
-- Indexes for table `student_video_progress`
--
ALTER TABLE `student_video_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_student_video` (`student_id`,`video_id`),
  ADD KEY `idx_svp_student` (`student_id`),
  ADD KEY `idx_svp_video` (`video_id`),
  ADD KEY `idx_svp_completed` (`is_completed`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_subjects_code` (`code`);

--
-- Indexes for table `subjects_translations`
--
ALTER TABLE `subjects_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_subjects_translations` (`subject_id`,`language_id`),
  ADD KEY `idx_subjects_translations_language_id` (`language_id`);

--
-- Indexes for table `subject_academic_years`
--
ALTER TABLE `subject_academic_years`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_subject_academic_year` (`subject_id`,`academic_year_id`),
  ADD KEY `idx_say_subject` (`subject_id`),
  ADD KEY `idx_say_academic_year` (`academic_year_id`);

--
-- Indexes for table `subscription_codes`
--
ALTER TABLE `subscription_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_sc_code` (`code`),
  ADD KEY `idx_sc_active` (`is_active`),
  ADD KEY `idx_sc_valid_to` (`valid_to`);

--
-- Indexes for table `subscription_code_courses`
--
ALTER TABLE `subscription_code_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sc_crs` (`subscription_code_id`,`course_id`),
  ADD KEY `idx_scc_code` (`subscription_code_id`),
  ADD KEY `idx_scc_crs` (`course_id`);

--
-- Indexes for table `subscription_code_subjects`
--
ALTER TABLE `subscription_code_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sc_subj` (`subscription_code_id`,`subject_id`),
  ADD KEY `idx_scs_code` (`subscription_code_id`),
  ADD KEY `idx_scs_subj` (`subject_id`);

--
-- Indexes for table `subscription_code_teachers`
--
ALTER TABLE `subscription_code_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sc_teach` (`subscription_code_id`,`teacher_id`),
  ADD KEY `idx_sct_code` (`subscription_code_id`),
  ADD KEY `idx_sct_teach` (`teacher_id`);

--
-- Indexes for table `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teachers_email` (`email`),
  ADD KEY `idx_teachers_subject_id` (`subject_id`),
  ADD KEY `idx_teachers_city_id` (`city_id`);

--
-- Indexes for table `teacher_availability_slots`
--
ALTER TABLE `teacher_availability_slots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tas_slot` (`teacher_id`,`slot_date`,`start_time`),
  ADD KEY `idx_tas_teacher_date` (`teacher_id`,`slot_date`),
  ADD KEY `idx_tas_date` (`slot_date`),
  ADD KEY `idx_tas_course` (`course_id`),
  ADD KEY `idx_tas_status` (`status`);

--
-- Indexes for table `teacher_deduction_appeals`
--
ALTER TABLE `teacher_deduction_appeals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tda_teacher` (`teacher_id`),
  ADD KEY `idx_tda_wallet_txn` (`wallet_transaction_id`),
  ADD KEY `idx_tda_status` (`status`);

--
-- Indexes for table `teacher_pay_rates`
--
ALTER TABLE `teacher_pay_rates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tpr_teacher` (`teacher_id`);

--
-- Indexes for table `teacher_ratings`
--
ALTER TABLE `teacher_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_student_teacher_rating` (`student_id`,`teacher_id`),
  ADD KEY `idx_teacher_rating` (`teacher_id`),
  ADD KEY `idx_student_teacher_rating` (`student_id`);

--
-- Indexes for table `teacher_session_attendance`
--
ALTER TABLE `teacher_session_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tsa_session_date` (`session_id`,`occurrence_date`),
  ADD KEY `idx_tsa_teacher` (`teacher_id`),
  ADD KEY `idx_tsa_date` (`occurrence_date`);

--
-- Indexes for table `teacher_subjects`
--
ALTER TABLE `teacher_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teacher_subjects` (`teacher_id`,`subject_id`,`academic_year_id`),
  ADD KEY `idx_teacher_subjects_subject` (`subject_id`),
  ADD KEY `fk_teacher_subjects_academic_year` (`academic_year_id`);

--
-- Indexes for table `teacher_wallet_transactions`
--
ALTER TABLE `teacher_wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_twt_teacher` (`teacher_id`),
  ADD KEY `idx_twt_type` (`type`),
  ADD KEY `idx_twt_reference` (`reference_type`,`reference_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_transactions_code` (`transaction_code`),
  ADD UNIQUE KEY `uq_transactions_provider_reference` (`provider_reference`),
  ADD KEY `idx_transactions_student_id` (`student_id`),
  ADD KEY `idx_transactions_parent_id` (`parent_id`),
  ADD KEY `idx_transactions_teacher_id` (`teacher_id`),
  ADD KEY `idx_transactions_related_id` (`related_transaction_id`),
  ADD KEY `idx_transactions_status` (`status`),
  ADD KEY `idx_transactions_type` (`transaction_type`),
  ADD KEY `idx_transactions_created_at` (`created_at`);

--
-- Indexes for table `transactions_translations`
--
ALTER TABLE `transactions_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_transactions_translations` (`transaction_id`,`language_id`),
  ADD KEY `idx_transactions_translations_language_id` (`language_id`);

--
-- Indexes for table `transaction_items`
--
ALTER TABLE `transaction_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_transaction_items_transaction_id` (`transaction_id`),
  ADD KEY `idx_transaction_items_reference` (`item_type`,`item_id`);

--
-- Indexes for table `transaction_items_translations`
--
ALTER TABLE `transaction_items_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_transaction_items_translations` (`transaction_item_id`,`language_id`),
  ADD KEY `idx_transaction_items_translations_language_id` (`language_id`);

--
-- Indexes for table `true_false_answers`
--
ALTER TABLE `true_false_answers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_true_false_answers_question_id` (`question_id`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_units_course_code` (`course_id`,`code`),
  ADD KEY `idx_units_course_id` (`course_id`);

--
-- Indexes for table `units_translations`
--
ALTER TABLE `units_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_units_translations` (`unit_id`,`language_id`),
  ADD KEY `idx_units_translations_language_id` (`language_id`);

--
-- Indexes for table `unit_teachers`
--
ALTER TABLE `unit_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_unit_teachers` (`unit_id`,`teacher_id`),
  ADD KEY `idx_ut_unit` (`unit_id`),
  ADD KEY `idx_ut_teacher` (`teacher_id`);

--
-- Indexes for table `user_devices`
--
ALTER TABLE `user_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_device` (`user_type`,`user_id`,`device_id`),
  ADD KEY `idx_ud_owner` (`user_type`,`user_id`,`is_active`),
  ADD KEY `idx_ud_last_seen` (`last_seen_at`);

--
-- Indexes for table `videos`
--
ALTER TABLE `videos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_videos_unit_code` (`unit_id`,`code`),
  ADD KEY `idx_videos_unit_id` (`unit_id`),
  ADD KEY `idx_videos_publish_status` (`publish_status`),
  ADD KEY `idx_videos_video_url` (`video_url`(64));

--
-- Indexes for table `videos_translations`
--
ALTER TABLE `videos_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_videos_translations` (`video_id`,`language_id`),
  ADD KEY `idx_videos_translations_language_id` (`language_id`);

--
-- Indexes for table `video_teachers`
--
ALTER TABLE `video_teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_video_teachers` (`video_id`,`teacher_id`),
  ADD KEY `idx_vt_video` (`video_id`),
  ADD KEY `idx_vt_teacher` (`teacher_id`);

--
-- Indexes for table `written_model_answers`
--
ALTER TABLE `written_model_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_written_model_answers_question_id` (`question_id`);

--
-- Indexes for table `written_model_answers_translations`
--
ALTER TABLE `written_model_answers_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_written_model_answers_translations` (`written_model_answer_id`,`language_id`),
  ADD KEY `idx_written_model_answers_translations_language_id` (`language_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `academic_years`
--
ALTER TABLE `academic_years`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `academic_years_translations`
--
ALTER TABLE `academic_years_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `admin_permissions`
--
ALTER TABLE `admin_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `advertisements`
--
ALTER TABLE `advertisements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `advertisements_translations`
--
ALTER TABLE `advertisements_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1013;

--
-- AUTO_INCREMENT for table `affiliates`
--
ALTER TABLE `affiliates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `affiliate_commissions`
--
ALTER TABLE `affiliate_commissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `attendance_exception_requests`
--
ALTER TABLE `attendance_exception_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `availability_slot_bookings`
--
ALTER TABLE `availability_slot_bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `banners`
--
ALTER TABLE `banners`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `banner_views`
--
ALTER TABLE `banner_views`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1121;

--
-- AUTO_INCREMENT for table `book_teachers`
--
ALTER TABLE `book_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1025;

--
-- AUTO_INCREMENT for table `certificates`
--
ALTER TABLE `certificates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `certificates_translations`
--
ALTER TABLE `certificates_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1040;

--
-- AUTO_INCREMENT for table `certificate_teachers`
--
ALTER TABLE `certificate_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1016;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `cities_translations`
--
ALTER TABLE `cities_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `class_sessions`
--
ALTER TABLE `class_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT for table `class_session_notification_log`
--
ALTER TABLE `class_session_notification_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `code_redemptions_log`
--
ALTER TABLE `code_redemptions_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1132;

--
-- AUTO_INCREMENT for table `consultation_slots`
--
ALTER TABLE `consultation_slots`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=155;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=213;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=506;

--
-- AUTO_INCREMENT for table `courses_translations`
--
ALTER TABLE `courses_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3059;

--
-- AUTO_INCREMENT for table `course_books`
--
ALTER TABLE `course_books`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7665;

--
-- AUTO_INCREMENT for table `course_books_translations`
--
ALTER TABLE `course_books_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43848;

--
-- AUTO_INCREMENT for table `course_categories`
--
ALTER TABLE `course_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `course_categories_translations`
--
ALTER TABLE `course_categories_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `course_exams`
--
ALTER TABLE `course_exams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1969;

--
-- AUTO_INCREMENT for table `course_exams_translations`
--
ALTER TABLE `course_exams_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17709;

--
-- AUTO_INCREMENT for table `course_ratings`
--
ALTER TABLE `course_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1071;

--
-- AUTO_INCREMENT for table `course_teachers`
--
ALTER TABLE `course_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=560;

--
-- AUTO_INCREMENT for table `course_videos`
--
ALTER TABLE `course_videos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3145;

--
-- AUTO_INCREMENT for table `course_videos_translations`
--
ALTER TABLE `course_videos_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7289;

--
-- AUTO_INCREMENT for table `currencies`
--
ALTER TABLE `currencies`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT for table `discount_codes`
--
ALTER TABLE `discount_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `discount_code_courses`
--
ALTER TABLE `discount_code_courses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `discount_code_redemptions`
--
ALTER TABLE `discount_code_redemptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `email_verification_codes`
--
ALTER TABLE `email_verification_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7097;

--
-- AUTO_INCREMENT for table `exam_attempt_answers`
--
ALTER TABLE `exam_attempt_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15455;

--
-- AUTO_INCREMENT for table `exam_teachers`
--
ALTER TABLE `exam_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1025;

--
-- AUTO_INCREMENT for table `homework`
--
ALTER TABLE `homework`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT for table `homework_submissions`
--
ALTER TABLE `homework_submissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT for table `ip_country_cache`
--
ALTER TABLE `ip_country_cache`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `item_country_prices`
--
ALTER TABLE `item_country_prices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `languages`
--
ALTER TABLE `languages`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `languages_translations`
--
ALTER TABLE `languages_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mcq_options`
--
ALTER TABLE `mcq_options`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85373;

--
-- AUTO_INCREMENT for table `mcq_options_translations`
--
ALTER TABLE `mcq_options_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=170713;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=635;

--
-- AUTO_INCREMENT for table `notification_recipients`
--
ALTER TABLE `notification_recipients`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2130;

--
-- AUTO_INCREMENT for table `offline_payment_requests`
--
ALTER TABLE `offline_payment_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parents`
--
ALTER TABLE `parents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=322;

--
-- AUTO_INCREMENT for table `parent_students`
--
ALTER TABLE `parent_students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1062;

--
-- AUTO_INCREMENT for table `password_reset_codes`
--
ALTER TABLE `password_reset_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `payment_accounts`
--
ALTER TABLE `payment_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=141;

--
-- AUTO_INCREMENT for table `permissions_translations`
--
ALTER TABLE `permissions_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=296;

--
-- AUTO_INCREMENT for table `point_currency_values`
--
ALTER TABLE `point_currency_values`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=405;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41943;

--
-- AUTO_INCREMENT for table `questions_translations`
--
ALTER TABLE `questions_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86485;

--
-- AUTO_INCREMENT for table `resources`
--
ALTER TABLE `resources`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=549;

--
-- AUTO_INCREMENT for table `resources_translations`
--
ALTER TABLE `resources_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10097;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `roles_translations`
--
ALTER TABLE `roles_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `schools`
--
ALTER TABLE `schools`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `schools_translations`
--
ALTER TABLE `schools_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `school_types`
--
ALTER TABLE `school_types`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `school_types_translations`
--
ALTER TABLE `school_types_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `session_attendance`
--
ALTER TABLE `session_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1232;

--
-- AUTO_INCREMENT for table `session_files`
--
ALTER TABLE `session_files`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `session_file_submissions`
--
ALTER TABLE `session_file_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `session_reschedule_requests`
--
ALTER TABLE `session_reschedule_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `site_settings`
--
ALTER TABLE `site_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4436;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1107;

--
-- AUTO_INCREMENT for table `student_book_progress`
--
ALTER TABLE `student_book_progress`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_book_purchase_requests`
--
ALTER TABLE `student_book_purchase_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `student_book_subscriptions`
--
ALTER TABLE `student_book_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `student_certificates`
--
ALTER TABLE `student_certificates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=130;

--
-- AUTO_INCREMENT for table `student_point_transactions`
--
ALTER TABLE `student_point_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `student_question_answers`
--
ALTER TABLE `student_question_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20137;

--
-- AUTO_INCREMENT for table `student_referrals`
--
ALTER TABLE `student_referrals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `student_reports`
--
ALTER TABLE `student_reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=191;

--
-- AUTO_INCREMENT for table `student_subscriptions`
--
ALTER TABLE `student_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1154;

--
-- AUTO_INCREMENT for table `student_subscription_books`
--
ALTER TABLE `student_subscription_books`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `student_subscription_courses`
--
ALTER TABLE `student_subscription_courses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1466;

--
-- AUTO_INCREMENT for table `student_subscription_subjects`
--
ALTER TABLE `student_subscription_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1098;

--
-- AUTO_INCREMENT for table `student_subscription_teachers`
--
ALTER TABLE `student_subscription_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1046;

--
-- AUTO_INCREMENT for table `student_video_progress`
--
ALTER TABLE `student_video_progress`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=683;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `subjects_translations`
--
ALTER TABLE `subjects_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `subject_academic_years`
--
ALTER TABLE `subject_academic_years`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `subscription_codes`
--
ALTER TABLE `subscription_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1973;

--
-- AUTO_INCREMENT for table `subscription_code_courses`
--
ALTER TABLE `subscription_code_courses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52696;

--
-- AUTO_INCREMENT for table `subscription_code_subjects`
--
ALTER TABLE `subscription_code_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1376;

--
-- AUTO_INCREMENT for table `subscription_code_teachers`
--
ALTER TABLE `subscription_code_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1016;

--
-- AUTO_INCREMENT for table `teachers`
--
ALTER TABLE `teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=216;

--
-- AUTO_INCREMENT for table `teacher_availability_slots`
--
ALTER TABLE `teacher_availability_slots`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `teacher_deduction_appeals`
--
ALTER TABLE `teacher_deduction_appeals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `teacher_pay_rates`
--
ALTER TABLE `teacher_pay_rates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `teacher_ratings`
--
ALTER TABLE `teacher_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1061;

--
-- AUTO_INCREMENT for table `teacher_session_attendance`
--
ALTER TABLE `teacher_session_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `teacher_subjects`
--
ALTER TABLE `teacher_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=535;

--
-- AUTO_INCREMENT for table `teacher_wallet_transactions`
--
ALTER TABLE `teacher_wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9061;

--
-- AUTO_INCREMENT for table `transactions_translations`
--
ALTER TABLE `transactions_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14121;

--
-- AUTO_INCREMENT for table `transaction_items`
--
ALTER TABLE `transaction_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10061;

--
-- AUTO_INCREMENT for table `transaction_items_translations`
--
ALTER TABLE `transaction_items_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15121;

--
-- AUTO_INCREMENT for table `true_false_answers`
--
ALTER TABLE `true_false_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10552;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4394;

--
-- AUTO_INCREMENT for table `units_translations`
--
ALTER TABLE `units_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10019;

--
-- AUTO_INCREMENT for table `unit_teachers`
--
ALTER TABLE `unit_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1073;

--
-- AUTO_INCREMENT for table `user_devices`
--
ALTER TABLE `user_devices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;

--
-- AUTO_INCREMENT for table `videos`
--
ALTER TABLE `videos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4302;

--
-- AUTO_INCREMENT for table `videos_translations`
--
ALTER TABLE `videos_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11731;

--
-- AUTO_INCREMENT for table `video_teachers`
--
ALTER TABLE `video_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1145;

--
-- AUTO_INCREMENT for table `written_model_answers`
--
ALTER TABLE `written_model_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9843;

--
-- AUTO_INCREMENT for table `written_model_answers_translations`
--
ALTER TABLE `written_model_answers_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30685;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `academic_years_translations`
--
ALTER TABLE `academic_years_translations`
  ADD CONSTRAINT `fk_academic_years_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_academic_years_translations_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `fk_admins_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `advertisements_translations`
--
ALTER TABLE `advertisements_translations`
  ADD CONSTRAINT `fk_advertisements_translations_advertisement` FOREIGN KEY (`advertisement_id`) REFERENCES `advertisements` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_advertisements_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `affiliates`
--
ALTER TABLE `affiliates`
  ADD CONSTRAINT `fk_affiliates_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_affiliates_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `affiliate_commissions`
--
ALTER TABLE `affiliate_commissions`
  ADD CONSTRAINT `fk_affiliate_commissions_affiliate` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `banner_views`
--
ALTER TABLE `banner_views`
  ADD CONSTRAINT `fk_banner_views_banner` FOREIGN KEY (`banner_id`) REFERENCES `banners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cities_translations`
--
ALTER TABLE `cities_translations`
  ADD CONSTRAINT `fk_cities_translations_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cities_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `class_sessions`
--
ALTER TABLE `class_sessions`
  ADD CONSTRAINT `fk_class_sessions_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `fk_courses_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_courses_category` FOREIGN KEY (`category_id`) REFERENCES `course_categories` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_courses_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `courses_translations`
--
ALTER TABLE `courses_translations`
  ADD CONSTRAINT `fk_courses_translations_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_courses_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `course_categories_translations`
--
ALTER TABLE `course_categories_translations`
  ADD CONSTRAINT `fk_course_categories_translations_category` FOREIGN KEY (`course_category_id`) REFERENCES `course_categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_course_categories_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `course_teachers`
--
ALTER TABLE `course_teachers`
  ADD CONSTRAINT `fk_ct_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ct_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  ADD CONSTRAINT `fk_exam_attempts_exam` FOREIGN KEY (`exam_id`) REFERENCES `course_exams` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_exam_attempts_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `exam_attempt_answers`
--
ALTER TABLE `exam_attempt_answers`
  ADD CONSTRAINT `fk_exam_attempt_answers_attempt` FOREIGN KEY (`attempt_id`) REFERENCES `exam_attempts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_exam_attempt_answers_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `languages_translations`
--
ALTER TABLE `languages_translations`
  ADD CONSTRAINT `fk_languages_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_languages_translations_translated_language` FOREIGN KEY (`translated_language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mcq_options`
--
ALTER TABLE `mcq_options`
  ADD CONSTRAINT `fk_mcq_options_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mcq_options_translations`
--
ALTER TABLE `mcq_options_translations`
  ADD CONSTRAINT `fk_mcq_options_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mcq_options_translations_option` FOREIGN KEY (`mcq_option_id`) REFERENCES `mcq_options` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notification_recipients`
--
ALTER TABLE `notification_recipients`
  ADD CONSTRAINT `fk_nr_notification` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `parents`
--
ALTER TABLE `parents`
  ADD CONSTRAINT `fk_parents_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `parent_students`
--
ALTER TABLE `parent_students`
  ADD CONSTRAINT `fk_parent_students_parent` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_parent_students_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `permissions_translations`
--
ALTER TABLE `permissions_translations`
  ADD CONSTRAINT `fk_permissions_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_permissions_translations_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_questions_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_questions_course_exam` FOREIGN KEY (`exam_id`) REFERENCES `course_exams` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_questions_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `questions_translations`
--
ALTER TABLE `questions_translations`
  ADD CONSTRAINT `fk_questions_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_questions_translations_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `resources`
--
ALTER TABLE `resources`
  ADD CONSTRAINT `fk_resources_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_resources_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `resources_translations`
--
ALTER TABLE `resources_translations`
  ADD CONSTRAINT `fk_resources_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_resources_translations_resource` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `roles_translations`
--
ALTER TABLE `roles_translations`
  ADD CONSTRAINT `fk_roles_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_roles_translations_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_role_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `schools`
--
ALTER TABLE `schools`
  ADD CONSTRAINT `fk_schools_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_schools_school_type` FOREIGN KEY (`school_type_id`) REFERENCES `school_types` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `schools_translations`
--
ALTER TABLE `schools_translations`
  ADD CONSTRAINT `fk_schools_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_schools_translations_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `school_types_translations`
--
ALTER TABLE `school_types_translations`
  ADD CONSTRAINT `fk_school_types_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_school_types_translations_school_type` FOREIGN KEY (`school_type_id`) REFERENCES `school_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `fk_students_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_students_referred_by` FOREIGN KEY (`referred_by_student_id`) REFERENCES `students` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_students_school` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `student_point_transactions`
--
ALTER TABLE `student_point_transactions`
  ADD CONSTRAINT `fk_student_point_tx_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `student_referrals`
--
ALTER TABLE `student_referrals`
  ADD CONSTRAINT `fk_student_referrals_referred` FOREIGN KEY (`referred_student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_student_referrals_referrer` FOREIGN KEY (`referrer_student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `subjects_translations`
--
ALTER TABLE `subjects_translations`
  ADD CONSTRAINT `fk_subjects_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_subjects_translations_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `subject_academic_years`
--
ALTER TABLE `subject_academic_years`
  ADD CONSTRAINT `fk_say_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_say_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `teachers`
--
ALTER TABLE `teachers`
  ADD CONSTRAINT `fk_teachers_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_teachers_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `teacher_subjects`
--
ALTER TABLE `teacher_subjects`
  ADD CONSTRAINT `fk_teacher_subjects_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_teacher_subjects_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_teacher_subjects_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `fk_transactions_parent` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transactions_related` FOREIGN KEY (`related_transaction_id`) REFERENCES `transactions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transactions_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transactions_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `transactions_translations`
--
ALTER TABLE `transactions_translations`
  ADD CONSTRAINT `fk_transactions_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transactions_translations_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transaction_items`
--
ALTER TABLE `transaction_items`
  ADD CONSTRAINT `fk_transaction_items_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transaction_items_translations`
--
ALTER TABLE `transaction_items_translations`
  ADD CONSTRAINT `fk_transaction_items_translations_item` FOREIGN KEY (`transaction_item_id`) REFERENCES `transaction_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaction_items_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `true_false_answers`
--
ALTER TABLE `true_false_answers`
  ADD CONSTRAINT `fk_true_false_answers_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `units`
--
ALTER TABLE `units`
  ADD CONSTRAINT `fk_units_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `units_translations`
--
ALTER TABLE `units_translations`
  ADD CONSTRAINT `fk_units_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_units_translations_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `videos`
--
ALTER TABLE `videos`
  ADD CONSTRAINT `fk_videos_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `videos_translations`
--
ALTER TABLE `videos_translations`
  ADD CONSTRAINT `fk_videos_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_videos_translations_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `written_model_answers`
--
ALTER TABLE `written_model_answers`
  ADD CONSTRAINT `fk_written_model_answers_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `written_model_answers_translations`
--
ALTER TABLE `written_model_answers_translations`
  ADD CONSTRAINT `fk_written_model_answers_translations_answer` FOREIGN KEY (`written_model_answer_id`) REFERENCES `written_model_answers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_written_model_answers_translations_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
