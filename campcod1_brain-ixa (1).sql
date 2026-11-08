-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 07, 2026 at 08:59 AM
-- Server version: 10.11.19-MariaDB-cll-lve-log
-- PHP Version: 8.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `campcod1_brain-ixa`
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

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `phone_country_code` varchar(8) DEFAULT NULL COMMENT 'Dial code of the phone number, without the +',
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
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `email`, `phone`, `phone_country_code`, `password`, `image`, `fcm_token`, `role`, `role_id`, `is_email_verified`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Admin Brainixa', 'info@brainixa.com', '+20 109 847 6530', NULL, '$2y$10$x4RrI2i7Q1r6qDIYz/4h.eNpqPqidqyFRBsRRt3jVQdRMMhhKA0ne', NULL, NULL, 'super_admin', 1, 1, 1, '2026-10-07 16:00:00', '2026-10-26 11:37:35');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `affiliates`
--

INSERT INTO `affiliates` (`id`, `student_id`, `teacher_id`, `affiliate_code`, `commission_type`, `commission_value`, `is_active`, `created_at`, `updated_at`) VALUES
(46, 1109, NULL, 'NAJEH-STU-1109', 'fixed', 0.00, 1, '2026-10-17 13:36:50', '2026-10-17 13:36:50'),
(48, 1111, NULL, 'NAJEH-STU-1111', 'fixed', 0.00, 1, '2026-10-24 05:45:50', '2026-10-24 05:45:50');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `availability_slot_bookings`
--

INSERT INTO `availability_slot_bookings` (`id`, `slot_id`, `student_id`, `student_subscription_id`, `status`, `booked_by_type`, `booked_by_id`, `notes`, `cancelled_at`, `created_at`, `updated_at`) VALUES
(19, 32, 1110, 1161, 'booked', 'teacher', 1, NULL, NULL, '2026-10-28 14:09:27', '2026-10-28 14:09:27'),
(20, 33, 1110, 1161, 'booked', 'student', 1110, NULL, NULL, '2026-10-28 19:42:57', '2026-10-28 19:42:57'),
(23, 38, 1110, 1161, 'booked', 'admin', 1, NULL, NULL, '2026-10-31 15:09:02', '2026-10-31 15:09:02'),
(24, 39, 1110, 1161, 'booked', 'admin', 1, NULL, NULL, '2026-10-31 15:12:35', '2026-10-31 15:12:35'),
(25, 40, 1113, 1162, 'booked', 'student', 1113, NULL, NULL, '2026-11-02 09:25:54', '2026-11-02 09:25:54'),
(26, 41, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-03 12:16:16', '2026-11-03 12:16:16'),
(27, 42, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-03 12:16:17', '2026-11-03 12:16:17'),
(28, 43, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-03 12:16:17', '2026-11-03 12:16:17'),
(29, 44, 1111, 1164, 'cancelled', 'admin', 1, NULL, '2026-11-03 16:40:58', '2026-11-03 12:16:17', '2026-11-03 14:40:58'),
(30, 45, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-03 12:16:17', '2026-11-03 12:16:17'),
(31, 48, 1111, 1164, 'booked', 'student', 1111, NULL, NULL, '2026-11-04 11:32:53', '2026-11-04 13:32:19'),
(32, 49, 1111, 1164, 'booked', 'student', 1111, NULL, NULL, '2026-11-04 11:32:54', '2026-11-05 08:52:42'),
(33, 50, 1111, 1164, 'cancelled', 'admin', 1, NULL, '2026-11-04 14:51:24', '2026-11-04 11:32:54', '2026-11-04 12:51:24'),
(34, 51, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:54', '2026-11-04 11:32:54'),
(35, 52, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:54', '2026-11-04 11:32:54'),
(36, 53, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:54', '2026-11-04 11:32:54'),
(37, 54, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:54', '2026-11-04 11:32:54'),
(38, 55, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:54', '2026-11-04 11:32:54'),
(39, 56, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:54', '2026-11-04 11:32:54'),
(40, 57, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(41, 58, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(42, 59, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(43, 60, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(44, 61, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(45, 62, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(46, 63, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(47, 64, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(48, 65, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(49, 66, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(50, 67, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:55', '2026-11-04 11:32:55'),
(51, 68, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(52, 69, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(53, 70, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(54, 71, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(55, 72, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(56, 73, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(57, 74, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(58, 75, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(59, 76, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(60, 77, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-04 11:32:56', '2026-11-04 11:32:56'),
(61, 104, 1111, 1164, 'booked', 'teacher', 1, NULL, NULL, '2026-11-04 13:52:38', '2026-11-04 13:52:38'),
(63, 106, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:27:41', '2026-11-05 09:27:41'),
(64, 107, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:27:41', '2026-11-05 09:27:41'),
(65, 108, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:27:42', '2026-11-05 09:27:42'),
(66, 109, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:27:42', '2026-11-05 09:27:42'),
(67, 110, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(68, 111, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(69, 112, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(70, 173, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(71, 113, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(72, 114, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(73, 115, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(74, 116, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(75, 117, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(76, 118, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(77, 119, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(78, 120, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(79, 121, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(80, 122, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(81, 123, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(82, 124, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(83, 125, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(84, 126, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(85, 127, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(86, 128, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(87, 129, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(88, 130, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18'),
(89, 174, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 11:45:52', '2026-11-05 11:45:52'),
(90, 175, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 11:45:52', '2026-11-05 11:45:52'),
(91, 176, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 11:45:52', '2026-11-05 11:45:52'),
(92, 177, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 11:45:53', '2026-11-05 11:45:53'),
(93, 178, 1109, 1165, 'booked', 'admin', 1, NULL, NULL, '2026-11-05 11:45:53', '2026-11-05 11:45:53'),
(94, 179, 1111, 1164, 'booked', 'admin', 1, NULL, NULL, '2026-11-07 10:49:54', '2026-11-07 10:49:54');

-- --------------------------------------------------------

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
-- Dumping data for table `banners`
--

INSERT INTO `banners` (`id`, `title_ar`, `title_en`, `image_ar`, `image_en`, `link`, `type`, `is_active`, `created_at`, `updated_at`) VALUES
(118, '', '', 'uploads/avatars/img_6aef067f1aab56.80766572.jpg', NULL, '', 'image', 1, '2026-11-07 11:07:43', '2026-11-07 11:07:43'),
(119, '', '', 'uploads/avatars/img_6aef07b6b6b293.13362125.jpg', NULL, '', 'image', 1, '2026-11-07 11:12:54', '2026-11-07 11:12:54'),
(120, '', '', 'uploads/avatars/img_6aef0988ad0229.03107644.jpg', NULL, '', 'image', 1, '2026-11-07 11:20:40', '2026-11-07 11:20:40'),
(121, '', '', 'uploads/avatars/img_6aef0992817214.72202167.jpg', NULL, '', 'image', 1, '2026-11-07 11:20:50', '2026-11-07 11:20:50'),
(122, '', '', 'uploads/avatars/img_6aef099bf13ca8.55968833.jpg', NULL, '', 'image', 1, '2026-11-07 11:20:59', '2026-11-07 11:20:59'),
(123, '', '', 'uploads/avatars/img_6aef09a382ecb6.56921400.jpg', NULL, '', 'image', 1, '2026-11-07 11:21:07', '2026-11-07 11:21:07'),
(124, '', '', 'uploads/avatars/img_6aef09abd61244.77974997.jpg', NULL, '', 'image', 1, '2026-11-07 11:21:15', '2026-11-07 11:21:15');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `book_teachers`
--

INSERT INTO `book_teachers` (`id`, `book_id`, `teacher_id`, `is_active`, `created_at`) VALUES
(1025, 7670, 1, 1, '2026-10-28 08:39:14'),
(1026, 7671, 1, 1, '2026-10-28 08:46:57'),
(1027, 7672, 1, 1, '2026-10-28 08:58:38');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`id`, `code`, `is_active`, `created_at`, `updated_at`) VALUES
(12, 'cairo', 1, '2026-10-11 08:44:33', '2026-10-11 08:44:33');

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

--
-- Dumping data for table `cities_translations`
--

INSERT INTO `cities_translations` (`id`, `city_id`, `language_id`, `name`, `is_active`, `created_at`, `updated_at`) VALUES
(23, 12, 1, 'القاهره', 1, '2026-10-11 08:44:33', '2026-10-11 08:44:33'),
(24, 12, 2, 'Cairo', 1, '2026-10-11 08:44:33', '2026-10-11 08:44:33');

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
-- Dumping data for table `class_sessions`
--

INSERT INTO `class_sessions` (`id`, `teacher_id`, `subject_id`, `course_id`, `code`, `day_of_week`, `start_time`, `end_time`, `room`, `is_online`, `meeting_link`, `grade`, `academic_year_id`, `is_active`, `created_at`) VALUES
(1, 1, 3, 1, 'MATH-LIVE-1', 'Sunday', '18:00:00', '19:00:00', NULL, 1, 'https://meet.google.com/demo-math-session', NULL, NULL, 1, '2026-10-07 16:00:00'),
(2, 2, 1, 2, 'ARABIC-LIVE-1', 'Tuesday', '17:00:00', '18:00:00', NULL, 1, 'https://meet.google.com/demo-arabic-session', NULL, NULL, 1, '2026-10-07 16:00:00'),
(148, 1, 1, 512, 'full-demo-session', 'Monday', '07:09:30', '08:19:30', NULL, 1, 'https://zoom.us/j/0000000000?pwd=demo', NULL, NULL, 1, '2026-11-02 09:20:30'),
(149, 1, NULL, 516, 'zoom-test-2005-Saturday', 'Saturday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18'),
(150, 1, NULL, 516, 'zoom-test-2005-Sunday', 'Sunday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18'),
(151, 1, NULL, 516, 'zoom-test-2005-Monday', 'Monday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18'),
(152, 1, NULL, 516, 'zoom-test-2005-Tuesday', 'Tuesday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18'),
(153, 1, NULL, 516, 'zoom-test-2005-Wednesday', 'Wednesday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18'),
(154, 1, NULL, 516, 'zoom-test-2005-Thursday', 'Thursday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18'),
(155, 1, NULL, 516, 'zoom-test-2005-Friday', 'Friday', '17:00:00', '18:00:00', NULL, 1, NULL, NULL, NULL, 1, '2026-11-05 09:55:18');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
  `price_per_hour` decimal(10,2) DEFAULT NULL,
  `is_booked` tinyint(1) NOT NULL DEFAULT 0,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `booked_at` timestamp NULL DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'available',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `meeting_link` varchar(500) DEFAULT NULL COMMENT 'Where the consultation is held - the link the Start button opens',
  `started_at` datetime DEFAULT NULL COMMENT 'When the admin or the teacher pressed Start',
  `ended_at` datetime DEFAULT NULL COMMENT 'When it was ended; the consultation reads as completed from here on',
  `zoom_meeting_id` varchar(32) DEFAULT NULL,
  `zoom_password` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `consultation_slots`
--

INSERT INTO `consultation_slots` (`id`, `teacher_id`, `subject_id`, `type`, `meeting_type`, `slot_date`, `slot_time`, `notes`, `price_per_hour`, `is_booked`, `student_id`, `booked_at`, `status`, `is_active`, `created_at`, `meeting_link`, `started_at`, `ended_at`, `zoom_meeting_id`, `zoom_password`) VALUES
(157, 1, 1, 'educational', 'video_call', '2026-11-02', '09:19:30', 'استشارة تجريبية — راجع خطة المذاكرة الأسبوعية.', NULL, 1, 1113, '2026-11-02 09:20:30', 'approved', 1, '2026-11-02 09:20:30', NULL, NULL, NULL, NULL, NULL),
(160, 1, NULL, 'educational', 'online', '2026-11-05', '12:00:00', 'zoom-test-student2005', NULL, 1, 1109, '2026-11-05 09:55:18', 'approved', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(161, 1, NULL, 'educational', 'online', '2026-11-05', '16:00:00', 'zoom-test-student2005', NULL, 1, 1109, '2026-11-05 09:55:18', 'approved', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(162, 1, NULL, 'educational', 'online', '2026-11-06', '12:00:00', 'zoom-test-student2005', NULL, 1, 1109, '2026-11-05 09:55:18', 'approved', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(163, 1, NULL, 'educational', 'online', '2026-11-07', '12:00:00', 'zoom-test-student2005', NULL, 1, 1109, '2026-11-05 09:55:18', 'approved', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(164, 1, NULL, 'educational', 'online', '2026-11-08', '12:00:00', 'zoom-test-student2005', NULL, 1, 1109, '2026-11-05 09:55:18', 'approved', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(165, 1, NULL, 'educational', 'online', '2026-11-06', '16:00:00', 'zoom-test-student2005', NULL, 1, 1109, '2026-11-05 11:52:51', 'pending', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(166, 1, NULL, 'educational', 'online', '2026-11-07', '16:00:00', 'zoom-test-student2005', NULL, 0, NULL, NULL, 'available', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(167, 1, NULL, 'educational', 'online', '2026-11-08', '16:00:00', 'zoom-test-student2005', NULL, 0, NULL, NULL, 'available', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(168, 1, NULL, 'educational', 'online', '2026-11-09', '16:00:00', 'zoom-test-student2005', NULL, 0, NULL, NULL, 'available', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL),
(169, 1, NULL, 'educational', 'online', '2026-11-10', '16:00:00', 'zoom-test-student2005', NULL, 0, NULL, NULL, 'available', 1, '2026-11-05 09:55:18', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

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
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`id`, `category_id`, `subject_id`, `academic_year_id`, `teacher_id`, `slug`, `type`, `kind`, `duration_months`, `allow_video_download`, `price`, `image`, `lessons_count`, `order_num`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`, `what_you_will_learn`, `video_preview_url`) VALUES
(511, NULL, NULL, NULL, 1, '-zoom-2', 'recorded', 'package', 1, 0, 0.00, NULL, 0, 0, 1, 1, 'teacher', 1, '2026-10-28 14:09:08', '2026-10-28 14:09:08', NULL, NULL),
(512, NULL, 1, NULL, 1, 'demo-full-pack-g11', 'recorded', 'normal', NULL, 0, 0.00, NULL, 4, 0, 1, 1, 'admin', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', NULL, NULL),
(513, NULL, 1, NULL, 1, 'demo-package-g11', 'recorded', 'package', 1, 0, 500.00, NULL, 0, 0, 1, 1, 'admin', 1, '2026-11-02 09:25:54', '2026-11-02 09:25:54', NULL, NULL),
(514, NULL, NULL, NULL, NULL, '-', 'recorded', 'package', 1, 0, 0.00, NULL, 0, 0, 1, 1, 'admin', NULL, '2026-11-03 12:06:53', '2026-11-03 12:10:58', NULL, NULL),
(516, NULL, NULL, NULL, 1, 'package-zoom-test-2026', 'recorded', 'package', 12, 0, 0.00, NULL, 0, 0, 1, 1, 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL);

-- --------------------------------------------------------

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
-- Dumping data for table `courses_translations`
--

INSERT INTO `courses_translations` (`id`, `course_id`, `language_id`, `name`, `description`, `is_active`, `created_at`, `updated_at`, `what_you_will_learn`) VALUES
(3069, 511, 1, 'باقة اختبار Zoom 2', '', 1, '2026-10-28 14:09:08', '2026-10-28 14:09:08', NULL),
(3070, 511, 2, 'باقة اختبار Zoom 2', '', 1, '2026-10-28 14:09:08', '2026-10-28 14:09:08', NULL),
(3071, 512, 1, 'باقة متكاملة — الصف الثاني الثانوي (تجريبي)', 'كورس تجريبي كامل: وحدات، فيديوهات، كتب، اختبار، حصّة يوميّة، واستشارة.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', NULL),
(3072, 512, 2, 'Full Package — Grade 11 (Demo)', 'A complete demo course: units, videos, books, exam, a daily session, and a consultation.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', NULL),
(3073, 513, 1, 'باقة شهرية — حصص فردية (تجريبي)', 'باقة شهرية: احجزي مواعيد فردية مباشرة مع المعلّم.', 1, '2026-11-02 09:25:54', '2026-11-02 09:25:54', NULL),
(3074, 513, 2, 'Monthly Package - One-to-One Sessions (Demo)', 'A monthly package: book one-to-one appointments with the teacher.', 1, '2026-11-02 09:25:54', '2026-11-02 09:25:54', NULL),
(3075, 514, 1, 'باقة شرح', '', 1, '2026-11-03 12:06:53', '2026-11-03 12:06:53', NULL),
(3076, 514, 2, 'باقة شرح', '', 1, '2026-11-03 12:06:53', '2026-11-03 12:06:53', NULL),
(3081, 516, 1, 'باقة اختبار البثّ المباشر (Zoom)', 'باقة مخصّصة لاختبار حصص Zoom داخل التطبيق: مواعيد محجوزة، ومواعيد متاحة للحجز، واستشارات.', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL),
(3082, 516, 2, 'Live Classes Test Package (Zoom)', 'A package dedicated to testing in-app Zoom classes: booked slots, open slots, and consultations.', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL);

-- --------------------------------------------------------

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
-- Dumping data for table `course_books`
--

INSERT INTO `course_books` (`id`, `subject_id`, `course_id`, `unit_id`, `file_type`, `category`, `extension`, `link`, `file_path`, `order_num`, `is_active`, `show_on_website`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`, `price`, `allow_download`, `cover_image`) VALUES
(7673, NULL, NULL, NULL, 'physical', 'summary', 'pdf', '', '', 1, 1, 1, 'admin', 1, '2026-11-01 13:37:25', '2026-11-01 13:37:25', 1250, 0, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600'),
(7674, NULL, NULL, NULL, 'physical', 'summary', 'pdf', '', '', 1, 1, 1, 'admin', 1, '2026-11-01 13:37:26', '2026-11-01 13:37:26', 790, 0, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600'),
(7675, NULL, NULL, NULL, 'physical', 'summary', 'pdf', '', '', 1, 1, 1, 'admin', 1, '2026-11-01 13:37:26', '2026-11-01 13:37:26', 0, 0, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600'),
(7676, NULL, NULL, NULL, 'pdf', 'summary', 'pdf', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', '', 1, 1, 1, 'admin', 1, '2026-11-01 13:37:26', '2026-11-01 13:37:26', 150, 0, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600'),
(7677, 1, 512, 4399, 'pdf', 'summary', 'pdf', NULL, 'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b694517e71.96169744.pdf', 1, 1, 1, 'admin', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', 0, 1, ''),
(7678, 1, 512, 4400, 'pdf', 'summary', 'pdf', NULL, 'https://camp-coding.online/brain-ixa/uploads/documents/doc_6ad4b695090043.74079801.pdf', 1, 1, 1, 'admin', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', 0, 1, '');

-- --------------------------------------------------------

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
-- Dumping data for table `course_books_translations`
--

INSERT INTO `course_books_translations` (`id`, `book_id`, `language_id`, `title`, `description`) VALUES
(43870, 7673, 1, 'سماعة رأس للمذاكرة', 'سماعة رأس بعزل ضوضاء، تُشحن للطالب بعد تأكيد الطلب.'),
(43871, 7673, 2, 'Study Headphones', 'Noise-isolating headphones, posted to the student once the order is confirmed.'),
(43872, 7674, 1, 'حقيبة مدرسية Brainixa', 'حقيبة ظهر بشعار المنصة، مقاس كبير.'),
(43873, 7674, 2, 'Brainixa School Bag', 'A branded backpack, large size.'),
(43874, 7675, 1, 'طقم أقلام وأدوات مكتبية', 'طقم أقلام ومسطرة وممحاة، يُسلَّم مع أول طلب.'),
(43875, 7675, 2, 'Stationery Set', 'Pens, a ruler and an eraser, delivered with the first order.'),
(43876, 7676, 1, 'مذكرة مراجعة الرياضيات', 'مذكرة PDF تُقرأ داخل المنصة.'),
(43877, 7676, 2, 'Maths Revision Notes', 'A PDF read inside the platform.'),
(43878, 7677, 1, 'كتاب الوحدة الأولى — الجبر والمتباينات', 'ملخّص ومسائل محلولة.'),
(43879, 7678, 1, 'كتاب الوحدة الثانية — حساب المثلثات', 'ملخّص ومسائل محلولة.'),
(43880, 7677, 2, 'Unit 1 Book - Algebra and Inequalities', 'Summary and worked problems.'),
(43881, 7678, 2, 'Unit 2 Book - Trigonometry', 'Summary and worked problems.');

-- --------------------------------------------------------

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
-- Dumping data for table `course_exams`
--

INSERT INTO `course_exams` (`id`, `subject_id`, `course_id`, `unit_id`, `order_num`, `duration_minutes`, `total_marks`, `pass_marks`, `is_active`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`) VALUES
(1, 3, 1, 1, 1, 15, 10, 5, 1, 'admin', 1, '2026-10-07 16:00:00', '2026-10-24 01:06:03'),
(1970, 3, 1, 4394, 1, 20, 3, 2, 1, 'admin', 1, '2026-10-18 11:56:52', '2026-10-18 11:56:52'),
(1972, 1, 512, 4399, 1, 20, 4, 3, 1, 'admin', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(1974, 1, 512, NULL, 2, 30, 2, 1, 1, 'admin', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(1975, 1, 513, NULL, 1, 20, 2, 1, 1, 'admin', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30');

-- --------------------------------------------------------

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
-- Dumping data for table `course_exams_translations`
--

INSERT INTO `course_exams_translations` (`id`, `exam_id`, `language_id`, `title`, `description`) VALUES
(1, 1, 1, 'اختبار الوحدة الأولى - رياضيات', NULL),
(2, 1, 2, 'Unit 1 Quiz - Mathematics', NULL),
(17711, 1970, 1, 'اختبار الوحدة الأولى — الجبر والمتباينات', 'ثلاثة أسئلة في عشرين دقيقة. النجاح بإجابتين صحيحتين.'),
(17712, 1970, 2, 'Unit 1 quiz - Algebra and Inequalities', 'Three questions, twenty minutes. Two correct answers to pass.'),
(17715, 1972, 1, 'اختبار الوحدة الأولى — الجبر والمتباينات', 'اختيار من متعدد، صواب وخطأ، وسؤال مقالي قصير.'),
(17716, 1972, 2, 'Unit 1 Exam - Algebra and Inequalities', 'MCQ, true/false, and a short written question.'),
(17719, 1974, 1, 'امتحان الكورس كاملًا', 'يغطّي الوحدتين معًا، لا وحدة بعينها.'),
(17720, 1974, 2, 'Full Course Exam', 'Covers both units, not a single one.'),
(17722, 1975, 1, 'امتحان الباقة', 'لكل طالب مشترك في هذه الباقة.'),
(17723, 1975, 2, 'Package Exam', 'For every student subscribed to this package.');

-- --------------------------------------------------------

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
-- Dumping data for table `course_ratings`
--

INSERT INTO `course_ratings` (`id`, `student_id`, `course_id`, `rating`, `comment`, `is_approved`, `created_at`, `updated_at`) VALUES
(1071, 1109, 1, 5, '12344', 1, '2026-10-20 10:41:31', '2026-10-20 10:41:31');

-- --------------------------------------------------------

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

--
-- Dumping data for table `course_teachers`
--

INSERT INTO `course_teachers` (`id`, `course_id`, `teacher_id`, `is_active`, `created_at`) VALUES
(562, 511, 1, 1, '2026-10-28 14:09:08'),
(563, 514, 1, 1, '2026-11-03 12:09:31'),
(565, 516, 1, 1, '2026-11-05 09:55:18');

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
-- Dumping data for table `course_videos`
--

INSERT INTO `course_videos` (`id`, `subject_id`, `course_id`, `unit_id`, `duration`, `video_url`, `order_num`, `is_active`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`) VALUES
(1, 3, 1, 1, '10:00', 'https://www.w3schools.com/html/mov_bbb.mp4', 1, 1, 'admin', 1, '2026-10-07 16:00:00', '2026-10-07 16:00:00'),
(2, 3, 1, 2, '10:00', 'https://www.w3schools.com/html/mov_bbb.mp4', 1, 1, 'admin', 1, '2026-10-07 16:00:00', '2026-10-07 16:00:00'),
(3, 1, 2, 3, '10:00', 'https://www.w3schools.com/html/mov_bbb.mp4', 1, 1, 'admin', 1, '2026-10-07 16:00:00', '2026-10-07 16:00:00');

-- --------------------------------------------------------

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
-- Dumping data for table `course_videos_translations`
--

INSERT INTO `course_videos_translations` (`id`, `video_id`, `language_id`, `title`, `description`) VALUES
(1, 1, 1, 'شرح المعادلات - الدرس 1', NULL),
(2, 1, 2, 'Equations Explained - Lesson 1', NULL),
(3, 2, 1, 'الأشكال الهندسية - الدرس 1', NULL),
(4, 2, 2, 'Geometric Shapes - Lesson 1', NULL),
(5, 3, 1, 'قواعد النحو - الدرس 1', NULL),
(6, 3, 2, 'Grammar Rules - Lesson 1', NULL);

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `email_verification_codes`
--

INSERT INTO `email_verification_codes` (`id`, `user_type`, `user_id`, `email`, `code`, `expires_at`, `is_used`, `created_at`) VALUES
(21, 'student', 1107, 'omartalaat1276@gmail.com', '530260', '2026-10-11 06:01:25', 1, '2026-10-11 08:46:25');

-- --------------------------------------------------------

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
-- Dumping data for table `exam_attempts`
--

INSERT INTO `exam_attempts` (`id`, `exam_id`, `student_id`, `status`, `total_score`, `max_score`, `started_at`, `submitted_at`, `graded_at`, `graded_by_type`, `graded_by_id`) VALUES
(7098, 1, 1109, 'graded', 0.00, 12.00, '2026-10-17 13:36:40', '2026-10-18 16:47:28', '2026-10-18 16:47:28', NULL, NULL),
(7100, 1, 1111, 'graded', 0.00, 12.00, '2026-10-25 00:07:33', '2026-10-25 03:07:41', '2026-10-25 03:07:41', NULL, NULL),
(7101, 1970, 1111, 'in_progress', NULL, 0.00, '2026-10-26 06:05:24', NULL, NULL, NULL, NULL),
(7102, 1972, 1109, 'in_progress', NULL, 4.00, '2026-11-02 10:47:04', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

--
-- Table structure for table `hero_slides`
--

CREATE TABLE `hero_slides` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title_ar` varchar(255) DEFAULT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `subtitle_ar` varchar(500) DEFAULT NULL,
  `subtitle_en` varchar(500) DEFAULT NULL,
  `btn_text_ar` varchar(120) DEFAULT NULL,
  `btn_text_en` varchar(120) DEFAULT NULL,
  `media_ar` varchar(500) NOT NULL,
  `media_en` varchar(500) DEFAULT NULL,
  `type` enum('image','video') NOT NULL DEFAULT 'image',
  `link` varchar(500) DEFAULT NULL,
  `order_num` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

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

-- --------------------------------------------------------

--
-- Table structure for table `homework_students`
--

CREATE TABLE `homework_students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `homework_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
-- Dumping data for table `ip_country_cache`
--

INSERT INTO `ip_country_cache` (`id`, `ip_address`, `iso2`, `failures`, `looked_up_at`) VALUES
(52, '156.203.191.100', 'EG', 0, '2026-10-07 11:45:15'),
(53, '41.39.161.175', 'EG', 0, '2026-10-07 19:52:01'),
(54, '41.46.134.150', 'EG', 0, '2026-10-07 21:13:31'),
(55, '54.183.149.156', 'US', 0, '2026-10-11 08:42:44'),
(56, '156.203.179.170', 'EG', 0, '2026-10-11 08:42:50'),
(57, '41.35.123.215', 'EG', 0, '2026-10-11 12:45:05'),
(58, '156.203.232.1', 'EG', 0, '2026-10-12 11:20:04'),
(59, '156.203.214.83', 'EG', 0, '2026-10-12 12:46:11'),
(60, '197.192.13.122', 'EG', 0, '2026-10-12 12:48:43'),
(61, '156.161.51.107', 'EG', 0, '2026-10-13 12:45:16'),
(62, '144.178.29.68', 'IE', 0, '2026-10-13 14:30:58'),
(63, '156.203.197.27', 'EG', 0, '2026-10-14 07:52:50'),
(64, '80.174.118.55', 'IT', 0, '2026-10-14 21:08:29'),
(65, '13.57.148.235', 'US', 0, '2026-10-15 08:46:48'),
(66, '156.203.184.206', 'EG', 0, '2026-10-15 22:35:21'),
(67, '156.203.131.156', 'EG', 0, '2026-10-17 13:31:43'),
(68, '156.205.90.232', 'EG', 0, '2026-10-18 08:41:49'),
(69, '156.203.171.49', 'EG', 0, '2026-10-18 11:40:15'),
(71, '74.125.210.38', 'US', 0, '2026-10-18 13:57:50'),
(72, '156.217.33.126', 'EG', 0, '2026-10-19 08:06:51'),
(73, '139.178.130.132', 'US', 0, '2026-10-20 11:53:08'),
(74, '156.203.203.108', 'EG', 0, '2026-10-24 00:38:13'),
(75, '139.178.130.133', 'US', 0, '2026-10-24 08:46:48'),
(76, '197.193.161.223', 'EG', 0, '2026-10-26 05:54:34'),
(77, '156.203.243.251', 'EG', 0, '2026-10-26 12:53:29'),
(78, '156.203.186.151', 'EG', 0, '2026-10-28 19:32:55'),
(79, '156.203.152.88', 'EG', 0, '2026-10-29 09:16:45'),
(80, '__provider__', NULL, 0, '2026-10-31 14:45:47'),
(81, '156.203.199.69', 'EG', 0, '2026-11-01 12:41:52'),
(82, '156.203.173.171', 'EG', 0, '2026-11-01 07:51:35'),
(84, '156.217.102.75', 'EG', 0, '2026-11-01 20:28:05'),
(85, '156.221.87.138', 'EG', 0, '2026-11-02 09:23:08'),
(86, '41.68.88.171', 'EG', 0, '2026-11-02 11:57:22'),
(87, '196.135.210.5', 'EG', 0, '2026-11-03 09:51:58'),
(88, '197.192.46.171', 'EG', 0, '2026-11-03 13:41:44'),
(89, '156.203.209.183', 'EG', 0, '2026-11-04 11:29:58'),
(90, '156.221.67.27', 'EG', 0, '2026-11-05 08:59:04'),
(91, '31.22.4.93', 'GB', 0, '2026-11-05 12:56:01'),
(92, '156.203.183.193', 'EG', 0, '2026-11-06 13:38:41'),
(93, '156.161.85.130', 'EG', 0, '2026-11-07 07:27:17');

-- --------------------------------------------------------

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
-- Table structure for table `manual_sales`
--

CREATE TABLE `manual_sales` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_name` varchar(191) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `phone_country_code` varchar(8) DEFAULT NULL COMMENT 'Dial code without the +',
  `item_type` enum('course','package','book') NOT NULL DEFAULT 'course',
  `item_name` varchar(255) NOT NULL,
  `item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `channel` enum('facebook','instagram','whatsapp','other') NOT NULL DEFAULT 'whatsapp',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `amount` decimal(14,3) NOT NULL DEFAULT 0.000,
  `currency` varchar(10) NOT NULL DEFAULT 'EGP',
  `student_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Linked platform account, when there is one',
  `note` text DEFAULT NULL,
  `transfer_receipt` varchar(255) DEFAULT NULL COMMENT 'Path to the transfer proof - image or PDF',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'The admin who wrote the row',
  `paid_at` datetime DEFAULT NULL COMMENT 'When the money arrived, as the owner remembers it',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
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
-- Dumping data for table `mcq_options`
--

INSERT INTO `mcq_options` (`id`, `question_id`, `option_key`, `option_image`, `is_correct`, `is_active`, `created_at`, `updated_at`) VALUES
(90021, 9002, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90022, 9002, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90023, 9002, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90024, 9002, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90031, 9003, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90032, 9003, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90033, 9003, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90034, 9003, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90041, 9004, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90042, 9004, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90043, 9004, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90044, 9004, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90061, 9006, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90062, 9006, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90063, 9006, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90064, 9006, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90081, 9008, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90082, 9008, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90083, 9008, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90084, 9008, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90091, 9009, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90092, 9009, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90093, 9009, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90094, 9009, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90101, 9010, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90102, 9010, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90103, 9010, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90104, 9010, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90141, 9014, 'A', 'https://picsum.photos/seed/brainixa-o-90141/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90142, 9014, 'B', 'https://picsum.photos/seed/brainixa-o-90142/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90143, 9014, 'C', 'https://picsum.photos/seed/brainixa-o-90143/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90144, 9014, 'D', 'https://picsum.photos/seed/brainixa-o-90144/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90161, 9016, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90162, 9016, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90163, 9016, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90164, 9016, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90171, 9017, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90172, 9017, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90173, 9017, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90174, 9017, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90201, 9020, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90202, 9020, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90203, 9020, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90204, 9020, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90211, 9021, 'A', 'https://picsum.photos/seed/brainixa-o-90211/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90212, 9021, 'B', 'https://picsum.photos/seed/brainixa-o-90212/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90213, 9021, 'C', 'https://picsum.photos/seed/brainixa-o-90213/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90214, 9021, 'D', 'https://picsum.photos/seed/brainixa-o-90214/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90221, 9022, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90222, 9022, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90223, 9022, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90224, 9022, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90231, 9023, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90232, 9023, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90233, 9023, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90234, 9023, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90271, 9027, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90272, 9027, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90273, 9027, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90274, 9027, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90281, 9028, 'A', 'https://picsum.photos/seed/brainixa-o-90281/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90282, 9028, 'B', 'https://picsum.photos/seed/brainixa-o-90282/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90283, 9028, 'C', 'https://picsum.photos/seed/brainixa-o-90283/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90284, 9028, 'D', 'https://picsum.photos/seed/brainixa-o-90284/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90301, 9030, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90302, 9030, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90303, 9030, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90304, 9030, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90321, 9032, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90322, 9032, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90323, 9032, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90324, 9032, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90331, 9033, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90332, 9033, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90333, 9033, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90334, 9033, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90341, 9034, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90342, 9034, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90343, 9034, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90344, 9034, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90351, 9035, 'A', 'https://picsum.photos/seed/brainixa-o-90351/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90352, 9035, 'B', 'https://picsum.photos/seed/brainixa-o-90352/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90353, 9035, 'C', 'https://picsum.photos/seed/brainixa-o-90353/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90354, 9035, 'D', 'https://picsum.photos/seed/brainixa-o-90354/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90361, 9036, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90362, 9036, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90363, 9036, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90364, 9036, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90371, 9037, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90372, 9037, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90373, 9037, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90374, 9037, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90391, 9039, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90392, 9039, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90393, 9039, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90394, 9039, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90411, 9041, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90412, 9041, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90413, 9041, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90414, 9041, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90421, 9042, 'A', 'https://picsum.photos/seed/brainixa-o-90421/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90422, 9042, 'B', 'https://picsum.photos/seed/brainixa-o-90422/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90423, 9042, 'C', 'https://picsum.photos/seed/brainixa-o-90423/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90424, 9042, 'D', 'https://picsum.photos/seed/brainixa-o-90424/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90431, 9043, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90432, 9043, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90433, 9043, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90434, 9043, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90441, 9044, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90442, 9044, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90443, 9044, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90444, 9044, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90451, 9045, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90452, 9045, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90453, 9045, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90454, 9045, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90461, 9046, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90462, 9046, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90463, 9046, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90464, 9046, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90491, 9049, 'A', 'https://picsum.photos/seed/brainixa-o-90491/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90492, 9049, 'B', 'https://picsum.photos/seed/brainixa-o-90492/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90493, 9049, 'C', 'https://picsum.photos/seed/brainixa-o-90493/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90494, 9049, 'D', 'https://picsum.photos/seed/brainixa-o-90494/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90501, 9050, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90502, 9050, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90503, 9050, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90504, 9050, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90511, 9051, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90512, 9051, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90513, 9051, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90514, 9051, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90541, 9054, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90542, 9054, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90543, 9054, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90544, 9054, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90551, 9055, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90552, 9055, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90553, 9055, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90554, 9055, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90571, 9057, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90572, 9057, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90573, 9057, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90574, 9057, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90601, 9060, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90602, 9060, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90603, 9060, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90604, 9060, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90611, 9061, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90612, 9061, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90613, 9061, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90614, 9061, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90621, 9062, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90622, 9062, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90623, 9062, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90624, 9062, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90631, 9063, 'A', 'https://picsum.photos/seed/brainixa-o-90631/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90632, 9063, 'B', 'https://picsum.photos/seed/brainixa-o-90632/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90633, 9063, 'C', 'https://picsum.photos/seed/brainixa-o-90633/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90634, 9063, 'D', 'https://picsum.photos/seed/brainixa-o-90634/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90671, 9067, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90672, 9067, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90673, 9067, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90674, 9067, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90681, 9068, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90682, 9068, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90683, 9068, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90684, 9068, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90721, 9072, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90722, 9072, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90723, 9072, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90724, 9072, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90731, 9073, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90732, 9073, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90733, 9073, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90734, 9073, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90751, 9075, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90752, 9075, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90753, 9075, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90754, 9075, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90761, 9076, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90762, 9076, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90763, 9076, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90764, 9076, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90771, 9077, 'A', 'https://picsum.photos/seed/brainixa-o-90771/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90772, 9077, 'B', 'https://picsum.photos/seed/brainixa-o-90772/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90773, 9077, 'C', 'https://picsum.photos/seed/brainixa-o-90773/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90774, 9077, 'D', 'https://picsum.photos/seed/brainixa-o-90774/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90781, 9078, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90782, 9078, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90783, 9078, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90784, 9078, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90801, 9080, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90802, 9080, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90803, 9080, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90804, 9080, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90821, 9082, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90822, 9082, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90823, 9082, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90824, 9082, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90831, 9083, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90832, 9083, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90833, 9083, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90834, 9083, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90841, 9084, 'A', 'https://picsum.photos/seed/brainixa-o-90841/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90842, 9084, 'B', 'https://picsum.photos/seed/brainixa-o-90842/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90843, 9084, 'C', 'https://picsum.photos/seed/brainixa-o-90843/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90844, 9084, 'D', 'https://picsum.photos/seed/brainixa-o-90844/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90851, 9085, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90852, 9085, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90853, 9085, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90854, 9085, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90891, 9089, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90892, 9089, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90893, 9089, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90894, 9089, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90921, 9092, 'A', 'https://picsum.photos/seed/brainixa-o-90921/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90922, 9092, 'B', 'https://picsum.photos/seed/brainixa-o-90922/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90923, 9092, 'C', 'https://picsum.photos/seed/brainixa-o-90923/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90924, 9092, 'D', 'https://picsum.photos/seed/brainixa-o-90924/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90941, 9094, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90942, 9094, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90943, 9094, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90944, 9094, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90951, 9095, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90952, 9095, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90953, 9095, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(90954, 9095, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91001, 9100, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91002, 9100, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91003, 9100, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91004, 9100, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91041, 9104, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91042, 9104, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91043, 9104, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91044, 9104, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91051, 9105, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91052, 9105, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91053, 9105, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91054, 9105, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91071, 9107, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91072, 9107, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91073, 9107, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91074, 9107, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91081, 9108, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91082, 9108, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91083, 9108, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91084, 9108, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91101, 9110, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91102, 9110, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91103, 9110, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91104, 9110, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91111, 9111, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91112, 9111, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91113, 9111, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91114, 9111, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91121, 9112, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91122, 9112, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91123, 9112, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91124, 9112, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91141, 9114, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91142, 9114, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91143, 9114, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91144, 9114, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91191, 9119, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91192, 9119, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91193, 9119, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91194, 9119, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91221, 9122, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91222, 9122, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91223, 9122, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91224, 9122, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91231, 9123, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91232, 9123, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91233, 9123, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91234, 9123, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91241, 9124, 'A', 'https://picsum.photos/seed/brainixa-o-91241/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91242, 9124, 'B', 'https://picsum.photos/seed/brainixa-o-91242/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91243, 9124, 'C', 'https://picsum.photos/seed/brainixa-o-91243/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91244, 9124, 'D', 'https://picsum.photos/seed/brainixa-o-91244/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91271, 9127, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91272, 9127, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91273, 9127, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91274, 9127, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91291, 9129, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91292, 9129, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91293, 9129, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91294, 9129, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91301, 9130, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91302, 9130, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91303, 9130, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91304, 9130, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91351, 9135, 'A', 'https://picsum.photos/seed/brainixa-o-91351/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91352, 9135, 'B', 'https://picsum.photos/seed/brainixa-o-91352/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91353, 9135, 'C', 'https://picsum.photos/seed/brainixa-o-91353/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91354, 9135, 'D', 'https://picsum.photos/seed/brainixa-o-91354/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91361, 9136, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91362, 9136, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91363, 9136, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91364, 9136, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91371, 9137, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91372, 9137, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91373, 9137, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91374, 9137, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91381, 9138, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91382, 9138, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91383, 9138, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91384, 9138, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91391, 9139, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91392, 9139, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91393, 9139, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91394, 9139, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91401, 9140, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91402, 9140, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91403, 9140, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91404, 9140, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91411, 9141, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91412, 9141, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91413, 9141, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91414, 9141, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91441, 9144, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91442, 9144, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91443, 9144, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91444, 9144, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91451, 9145, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91452, 9145, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91453, 9145, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91454, 9145, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91481, 9148, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91482, 9148, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91483, 9148, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91484, 9148, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91491, 9149, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91492, 9149, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91493, 9149, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91494, 9149, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91501, 9150, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91502, 9150, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91503, 9150, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91504, 9150, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91511, 9151, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91512, 9151, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91513, 9151, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91514, 9151, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91521, 9152, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91522, 9152, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91523, 9152, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91524, 9152, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91531, 9153, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91532, 9153, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91533, 9153, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91534, 9153, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91541, 9154, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91542, 9154, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91543, 9154, 'C', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91544, 9154, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91551, 9155, 'A', 'https://picsum.photos/seed/brainixa-o-91551/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91552, 9155, 'B', 'https://picsum.photos/seed/brainixa-o-91552/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91553, 9155, 'C', 'https://picsum.photos/seed/brainixa-o-91553/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91554, 9155, 'D', 'https://picsum.photos/seed/brainixa-o-91554/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91561, 9156, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91562, 9156, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91563, 9156, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91564, 9156, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91571, 9157, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91572, 9157, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91573, 9157, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91574, 9157, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91581, 9158, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91582, 9158, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91583, 9158, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91584, 9158, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91591, 9159, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91592, 9159, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91593, 9159, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91594, 9159, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91601, 9160, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91602, 9160, 'B', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91603, 9160, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91604, 9160, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91611, 9161, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91612, 9161, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91613, 9161, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91614, 9161, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91631, 9163, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91632, 9163, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91633, 9163, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91634, 9163, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91641, 9164, 'A', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91642, 9164, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91643, 9164, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91644, 9164, 'D', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91671, 9167, 'A', NULL, 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91672, 9167, 'B', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91673, 9167, 'C', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91674, 9167, 'D', NULL, 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91681, 9168, 'A', 'https://picsum.photos/seed/brainixa-o-91681/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91682, 9168, 'B', 'https://picsum.photos/seed/brainixa-o-91682/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91683, 9168, 'C', 'https://picsum.photos/seed/brainixa-o-91683/200/140', 1, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91684, 9168, 'D', 'https://picsum.photos/seed/brainixa-o-91684/200/140', 0, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(91701, 9001, 'A', '', 0, 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(91702, 9001, 'B', '', 0, 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(91703, 9001, 'C', '', 0, 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(91704, 9001, 'D', '', 1, 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(91722, 41951, 'A', NULL, 1, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(91723, 41951, 'B', NULL, 0, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(91724, 41951, 'C', NULL, 0, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(91725, 41954, 'A', NULL, 0, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(91726, 41954, 'B', NULL, 1, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(91728, 41956, 'A', NULL, 1, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(91729, 41956, 'B', NULL, 0, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30');

-- --------------------------------------------------------

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
-- Dumping data for table `mcq_options_translations`
--

INSERT INTO `mcq_options_translations` (`id`, `mcq_option_id`, `language_id`, `option_text`, `is_active`, `created_at`, `updated_at`) VALUES
(170761, 90021, 1, '28', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170762, 90021, 2, '28', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170763, 90022, 1, '41', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170764, 90022, 2, '41', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170765, 90023, 1, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170766, 90023, 2, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170767, 90024, 1, '35', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170768, 90024, 2, '35', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170769, 90031, 1, '4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170770, 90031, 2, '4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170771, 90032, 1, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170772, 90032, 2, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170773, 90033, 1, '0', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170774, 90033, 2, '0', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170775, 90034, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170776, 90034, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170777, 90041, 1, '91', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170778, 90041, 2, '91', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170779, 90042, 1, '88', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170780, 90042, 2, '88', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170781, 90043, 1, '82', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170782, 90043, 2, '82', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170783, 90044, 1, '90', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170784, 90044, 2, '90', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170785, 90061, 1, '27', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170786, 90061, 2, '27', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170787, 90062, 1, '31', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170788, 90062, 2, '31', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170789, 90063, 1, '25', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170790, 90063, 2, '25', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170791, 90064, 1, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170792, 90064, 2, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170793, 90081, 1, '2076', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170794, 90081, 2, '2076', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170795, 90082, 1, '2016', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170796, 90082, 2, '2016', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170797, 90083, 1, '1972', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170798, 90083, 2, '1972', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170799, 90084, 1, '1976', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170800, 90084, 2, '1976', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170801, 90091, 1, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170802, 90091, 2, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170803, 90092, 1, '49', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170804, 90092, 2, '49', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170805, 90093, 1, '50', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170806, 90093, 2, '50', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170807, 90094, 1, '56', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170808, 90094, 2, '56', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170809, 90101, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170810, 90101, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170811, 90102, 1, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170812, 90102, 2, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170813, 90103, 1, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170814, 90103, 2, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170815, 90104, 1, '16', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170816, 90104, 2, '16', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170817, 90141, 1, '6818', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170818, 90141, 2, '6818', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170819, 90142, 1, '6789', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170820, 90142, 2, '6789', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170821, 90143, 1, '6843', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170822, 90143, 2, '6843', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170823, 90144, 1, '6790', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170824, 90144, 2, '6790', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170825, 90161, 1, '-3', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170826, 90161, 2, '-3', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170827, 90162, 1, '2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170828, 90162, 2, '2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170829, 90163, 1, '3', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170830, 90163, 2, '3', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170831, 90164, 1, '-1', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170832, 90164, 2, '-1', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170833, 90171, 1, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170834, 90171, 2, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170835, 90172, 1, '35', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170836, 90172, 2, '35', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170837, 90173, 1, '30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170838, 90173, 2, '30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170839, 90174, 1, '34', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170840, 90174, 2, '34', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170841, 90201, 1, '64', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170842, 90201, 2, '64', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170843, 90202, 1, '69', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170844, 90202, 2, '69', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170845, 90203, 1, '57', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170846, 90203, 2, '57', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170847, 90204, 1, '61', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170848, 90204, 2, '61', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170849, 90211, 1, '39', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170850, 90211, 2, '39', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170851, 90212, 1, '27', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170852, 90212, 2, '27', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170853, 90213, 1, '32', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170854, 90213, 2, '32', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170855, 90214, 1, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170856, 90214, 2, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170857, 90221, 1, '27', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170858, 90221, 2, '27', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170859, 90222, 1, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170860, 90222, 2, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170861, 90223, 1, '25', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170862, 90223, 2, '25', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170863, 90224, 1, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170864, 90224, 2, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170865, 90231, 1, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170866, 90231, 2, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170867, 90232, 1, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170868, 90232, 2, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170869, 90233, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170870, 90233, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170871, 90234, 1, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170872, 90234, 2, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170873, 90271, 1, '17', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170874, 90271, 2, '17', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170875, 90272, 1, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170876, 90272, 2, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170877, 90273, 1, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170878, 90273, 2, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170879, 90274, 1, '18', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170880, 90274, 2, '18', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170881, 90281, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170882, 90281, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170883, 90282, 1, '17', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170884, 90282, 2, '17', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170885, 90283, 1, '13', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170886, 90283, 2, '13', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170887, 90284, 1, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170888, 90284, 2, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170889, 90301, 1, '2921', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170890, 90301, 2, '2921', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170891, 90302, 1, '2964', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170892, 90302, 2, '2964', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170893, 90303, 1, '3010', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170894, 90303, 2, '3010', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170895, 90304, 1, '2944', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170896, 90304, 2, '2944', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170897, 90321, 1, '62', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170898, 90321, 2, '62', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170899, 90322, 1, '57', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170900, 90322, 2, '57', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170901, 90323, 1, '53', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170902, 90323, 2, '53', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170903, 90324, 1, '56', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170904, 90324, 2, '56', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170905, 90331, 1, '104', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170906, 90331, 2, '104', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170907, 90332, 1, '107', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170908, 90332, 2, '107', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170909, 90333, 1, '106', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170910, 90333, 2, '106', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170911, 90334, 1, '98', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170912, 90334, 2, '98', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170913, 90341, 1, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170914, 90341, 2, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170915, 90342, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170916, 90342, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170917, 90343, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170918, 90343, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170919, 90344, 1, '12', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170920, 90344, 2, '12', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170921, 90351, 1, '127', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170922, 90351, 2, '127', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170923, 90352, 1, '133', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170924, 90352, 2, '133', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170925, 90353, 1, '124', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170926, 90353, 2, '124', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170927, 90354, 1, '128', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170928, 90354, 2, '128', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170929, 90361, 1, '2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170930, 90361, 2, '2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170931, 90362, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170932, 90362, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170933, 90363, 1, '12', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170934, 90363, 2, '12', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170935, 90364, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170936, 90364, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170937, 90371, 1, '18', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170938, 90371, 2, '18', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170939, 90372, 1, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170940, 90372, 2, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170941, 90373, 1, '17', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170942, 90373, 2, '17', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170943, 90374, 1, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170944, 90374, 2, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170945, 90391, 1, '1071', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170946, 90391, 2, '1071', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170947, 90392, 1, '1039', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170948, 90392, 2, '1039', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170949, 90393, 1, '1019', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170950, 90393, 2, '1019', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170951, 90394, 1, '1064', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170952, 90394, 2, '1064', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170953, 90411, 1, '38', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170954, 90411, 2, '38', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170955, 90412, 1, '31', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170956, 90412, 2, '31', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170957, 90413, 1, '32', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170958, 90413, 2, '32', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170959, 90414, 1, '29', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170960, 90414, 2, '29', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170961, 90421, 1, '265', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170962, 90421, 2, '265', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170963, 90422, 1, '260', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170964, 90422, 2, '260', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170965, 90423, 1, '220', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170966, 90423, 2, '220', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170967, 90424, 1, '195', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170968, 90424, 2, '195', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170969, 90431, 1, '338', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170970, 90431, 2, '338', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170971, 90432, 1, '322', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170972, 90432, 2, '322', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170973, 90433, 1, '352', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170974, 90433, 2, '352', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170975, 90434, 1, '347', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170976, 90434, 2, '347', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170977, 90441, 1, '1932', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170978, 90441, 2, '1932', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170979, 90442, 1, '1890', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170980, 90442, 2, '1890', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170981, 90443, 1, '1877', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170982, 90443, 2, '1877', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170983, 90444, 1, '1983', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170984, 90444, 2, '1983', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170985, 90451, 1, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170986, 90451, 2, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170987, 90452, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170988, 90452, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170989, 90453, 1, '11', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170990, 90453, 2, '11', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170991, 90454, 1, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170992, 90454, 2, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170993, 90461, 1, '22', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170994, 90461, 2, '22', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170995, 90462, 1, '29', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170996, 90462, 2, '29', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170997, 90463, 1, '21', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170998, 90463, 2, '21', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(170999, 90464, 1, '37', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171000, 90464, 2, '37', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171001, 90491, 1, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171002, 90491, 2, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171003, 90492, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171004, 90492, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171005, 90493, 1, '16', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171006, 90493, 2, '16', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171007, 90494, 1, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171008, 90494, 2, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171009, 90501, 1, '1370', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171010, 90501, 2, '1370', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171011, 90502, 1, '1430', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171012, 90502, 2, '1430', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171013, 90503, 1, '1469', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171014, 90503, 2, '1469', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171015, 90504, 1, '1425', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171016, 90504, 2, '1425', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171017, 90511, 1, '1414', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171018, 90511, 2, '1414', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171019, 90512, 1, '1456', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171020, 90512, 2, '1456', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171021, 90513, 1, '1421', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171022, 90513, 2, '1421', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171023, 90514, 1, '1499', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171024, 90514, 2, '1499', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171025, 90541, 1, '276', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171026, 90541, 2, '276', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171027, 90542, 1, '310', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171028, 90542, 2, '310', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171029, 90543, 1, '256', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171030, 90543, 2, '256', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171031, 90544, 1, '316', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171032, 90544, 2, '316', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171033, 90551, 1, '1520', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171034, 90551, 2, '1520', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171035, 90552, 1, '1495', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171036, 90552, 2, '1495', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171037, 90553, 1, '1521', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171038, 90553, 2, '1521', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171039, 90554, 1, '1557', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171040, 90554, 2, '1557', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171041, 90571, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171042, 90571, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171043, 90572, 1, '-1', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171044, 90572, 2, '-1', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171045, 90573, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171046, 90573, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171047, 90574, 1, '4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171048, 90574, 2, '4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171049, 90601, 1, '763', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171050, 90601, 2, '763', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171051, 90602, 1, '820', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171052, 90602, 2, '820', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171053, 90603, 1, '842', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171054, 90603, 2, '842', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171055, 90604, 1, '760', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171056, 90604, 2, '760', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171057, 90611, 1, '45', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171058, 90611, 2, '45', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171059, 90612, 1, '54', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171060, 90612, 2, '54', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171061, 90613, 1, '50', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171062, 90613, 2, '50', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171063, 90614, 1, '42', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171064, 90614, 2, '42', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171065, 90621, 1, '8606', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171066, 90621, 2, '8606', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171067, 90622, 1, '8571', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171068, 90622, 2, '8571', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171069, 90623, 1, '8531', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171070, 90623, 2, '8531', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171071, 90624, 1, '8556', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171072, 90624, 2, '8556', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171073, 90631, 1, '2877', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171074, 90631, 2, '2877', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171075, 90632, 1, '2911', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171076, 90632, 2, '2911', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171077, 90633, 1, '2868', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171078, 90633, 2, '2868', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171079, 90634, 1, '2940', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171080, 90634, 2, '2940', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171081, 90671, 1, '2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171082, 90671, 2, '2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171083, 90672, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171084, 90672, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171085, 90673, 1, '1', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171086, 90673, 2, '1', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171087, 90674, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171088, 90674, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171089, 90681, 1, '102', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171090, 90681, 2, '102', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171091, 90682, 1, '106', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171092, 90682, 2, '106', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171093, 90683, 1, '105', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171094, 90683, 2, '105', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171095, 90684, 1, '99', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171096, 90684, 2, '99', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171097, 90721, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171098, 90721, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171099, 90722, 1, '4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171100, 90722, 2, '4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171101, 90723, 1, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171102, 90723, 2, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171103, 90724, 1, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171104, 90724, 2, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171105, 90731, 1, '4441', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171106, 90731, 2, '4441', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171107, 90732, 1, '4422', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171108, 90732, 2, '4422', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171109, 90733, 1, '4426', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171110, 90733, 2, '4426', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171111, 90734, 1, '4374', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171112, 90734, 2, '4374', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171113, 90751, 1, '6534', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171114, 90751, 2, '6534', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171115, 90752, 1, '6523', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171116, 90752, 2, '6523', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171117, 90753, 1, '6498', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171118, 90753, 2, '6498', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171119, 90754, 1, '6492', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171120, 90754, 2, '6492', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171121, 90761, 1, '98', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171122, 90761, 2, '98', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171123, 90762, 1, '103', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171124, 90762, 2, '103', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171125, 90763, 1, '106', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171126, 90763, 2, '106', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171127, 90764, 1, '107', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171128, 90764, 2, '107', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171129, 90771, 1, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171130, 90771, 2, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171131, 90772, 1, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171132, 90772, 2, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171133, 90773, 1, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171134, 90773, 2, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171135, 90774, 1, '16', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171136, 90774, 2, '16', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171137, 90781, 1, '62', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171138, 90781, 2, '62', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171139, 90782, 1, '56', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171140, 90782, 2, '56', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171141, 90783, 1, '58', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171142, 90783, 2, '58', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171143, 90784, 1, '66', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171144, 90784, 2, '66', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171145, 90801, 1, '46', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171146, 90801, 2, '46', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171147, 90802, 1, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171148, 90802, 2, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171149, 90803, 1, '38', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171150, 90803, 2, '38', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171151, 90804, 1, '44', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171152, 90804, 2, '44', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171153, 90821, 1, '12', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171154, 90821, 2, '12', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171155, 90822, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171156, 90822, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171157, 90823, 1, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171158, 90823, 2, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171159, 90824, 1, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171160, 90824, 2, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171161, 90831, 1, '1677', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171162, 90831, 2, '1677', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171163, 90832, 1, '1622', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171164, 90832, 2, '1622', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171165, 90833, 1, '1655', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171166, 90833, 2, '1655', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171167, 90834, 1, '1638', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171168, 90834, 2, '1638', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171169, 90841, 1, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171170, 90841, 2, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171171, 90842, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171172, 90842, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171173, 90843, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171174, 90843, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171175, 90844, 1, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171176, 90844, 2, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171177, 90851, 1, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171178, 90851, 2, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171179, 90852, 1, '22', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171180, 90852, 2, '22', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171181, 90853, 1, '24', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171182, 90853, 2, '24', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171183, 90854, 1, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171184, 90854, 2, '15', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171185, 90891, 1, 'ط × نق²', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171186, 90891, 2, 'pi x r^2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171187, 90892, 1, 'نق²', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171188, 90892, 2, 'r^2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171189, 90893, 1, '2 × ط × نق', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171190, 90893, 2, '2 x pi x r', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171191, 90894, 1, 'ط × القطر²', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171192, 90894, 2, 'pi x d^2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171193, 90921, 1, 'الطول + العرض', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171194, 90921, 2, 'length + width', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171195, 90922, 1, 'الطول × العرض', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171196, 90922, 2, 'length x width', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171197, 90923, 1, 'الطول ÷ العرض', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171198, 90923, 2, 'length / width', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171199, 90924, 1, '2 × (الطول + العرض)', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171200, 90924, 2, '2 x (length + width)', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171201, 90941, 1, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171202, 90941, 2, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171203, 90942, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171204, 90942, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171205, 90943, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171206, 90943, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171207, 90944, 1, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171208, 90944, 2, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171209, 90951, 1, '270 درجة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171210, 90951, 2, '270 degrees', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171211, 90952, 1, '540 درجة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171212, 90952, 2, '540 degrees', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171213, 90953, 1, '360 درجة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171214, 90953, 2, '360 degrees', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171215, 90954, 1, '180 درجة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171216, 90954, 2, '180 degrees', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171217, 91001, 1, 'اسم مجرور وعلامة جره الكسرة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171218, 91001, 2, 'Genitive noun', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171219, 91002, 1, 'مبتدأ مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171220, 91002, 2, 'Inchoative, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171221, 91003, 1, 'مفعول به منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171222, 91003, 2, 'Object, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171223, 91004, 1, 'فاعل مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171224, 91004, 2, 'Subject, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171225, 91041, 1, 'فاعل مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171226, 91041, 2, 'Subject, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171227, 91042, 1, 'اسم مجرور وعلامة جره الكسرة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171228, 91042, 2, 'Genitive noun', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171229, 91043, 1, 'مبتدأ مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171230, 91043, 2, 'Inchoative, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171231, 91044, 1, 'مفعول به منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171232, 91044, 2, 'Object, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171233, 91051, 1, 'اسم مجرور وعلامة جره الكسرة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171234, 91051, 2, 'Genitive noun', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171235, 91052, 1, 'فاعل مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171236, 91052, 2, 'Subject (fail), nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171237, 91053, 1, 'مبتدأ مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171238, 91053, 2, 'Inchoative, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171239, 91054, 1, 'مفعول به منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171240, 91054, 2, 'Object, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171241, 91071, 1, 'خبر مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171242, 91071, 2, 'Predicate, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171243, 91072, 1, 'مفعول به منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171244, 91072, 2, 'Object, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171245, 91073, 1, 'فاعل مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171246, 91073, 2, 'Subject, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171247, 91074, 1, 'اسم إنَّ منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171248, 91074, 2, 'Noun of inna, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171249, 91081, 1, 'مبتدأ مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171250, 91081, 2, 'Inchoative, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171251, 91082, 1, 'خبر مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171252, 91082, 2, 'Predicate, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171253, 91083, 1, 'اسم مجرور وعلامة جره الكسرة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171254, 91083, 2, 'Genitive noun', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171255, 91084, 1, 'مفعول به منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171256, 91084, 2, 'Object, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171257, 91101, 1, 'خبر كان منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171258, 91101, 2, 'Predicate of kana, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171259, 91102, 1, 'خبر مرفوع وعلامة رفعه الضمة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171260, 91102, 2, 'Predicate, nominative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171261, 91103, 1, 'اسم مجرور وعلامة جره الكسرة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171262, 91103, 2, 'Genitive noun', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171263, 91104, 1, 'مفعول به منصوب وعلامة نصبه الفتحة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171264, 91104, 2, 'Object, accusative', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171265, 91111, 1, '139', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171266, 91111, 2, '139', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171267, 91112, 1, '135', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171268, 91112, 2, '135', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171269, 91113, 1, '124', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171270, 91113, 2, '124', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171271, 91114, 1, '127', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171272, 91114, 2, '127', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171273, 91121, 1, '74', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171274, 91121, 2, '74', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171275, 91122, 1, '70', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171276, 91122, 2, '70', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171277, 91123, 1, '59', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171278, 91123, 2, '59', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171279, 91124, 1, '64', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171280, 91124, 2, '64', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171281, 91141, 1, '90', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171282, 91141, 2, '90', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171283, 91142, 1, '82', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171284, 91142, 2, '82', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171285, 91143, 1, '92', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171286, 91143, 2, '92', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171287, 91144, 1, '100', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171288, 91144, 2, '100', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171289, 91191, 1, '-4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171290, 91191, 2, '-4', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171291, 91192, 1, '0', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171292, 91192, 2, '0', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171293, 91193, 1, '11', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171294, 91193, 2, '11', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171295, 91194, 1, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171296, 91194, 2, '6', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171297, 91221, 1, '72', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171298, 91221, 2, '72', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171299, 91222, 1, '84', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171300, 91222, 2, '84', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171301, 91223, 1, '85', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171302, 91223, 2, '85', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171303, 91224, 1, '74', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171304, 91224, 2, '74', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171305, 91231, 1, '48', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171306, 91231, 2, '48', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171307, 91232, 1, '53', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171308, 91232, 2, '53', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171309, 91233, 1, '45', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171310, 91233, 2, '45', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171311, 91234, 1, '40', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171312, 91234, 2, '40', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171313, 91241, 1, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171314, 91241, 2, '5', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171315, 91242, 1, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171316, 91242, 2, '26', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171317, 91243, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171318, 91243, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171319, 91244, 1, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171320, 91244, 2, '20', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171321, 91271, 1, '66', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171322, 91271, 2, '66', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171323, 91272, 1, '72', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171324, 91272, 2, '72', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171325, 91273, 1, '69', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171326, 91273, 2, '69', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171327, 91274, 1, '83', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171328, 91274, 2, '83', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171329, 91291, 1, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171330, 91291, 2, '33', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171331, 91292, 1, '34', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171332, 91292, 2, '34', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171333, 91293, 1, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171334, 91293, 2, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171335, 91294, 1, '30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171336, 91294, 2, '30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171337, 91301, 1, '109', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171338, 91301, 2, '109', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171339, 91302, 1, '101', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171340, 91302, 2, '101', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171341, 91303, 1, '79', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171342, 91303, 2, '79', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171343, 91304, 1, '100', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171344, 91304, 2, '100', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171345, 91351, 1, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171346, 91351, 2, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171347, 91352, 1, '24', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171348, 91352, 2, '24', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171349, 91353, 1, '28', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171350, 91353, 2, '28', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171351, 91354, 1, '22', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171352, 91354, 2, '22', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171353, 91361, 1, '18', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171354, 91361, 2, '18', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171355, 91362, 1, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171356, 91362, 2, '23', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171357, 91363, 1, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171358, 91363, 2, '19', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171359, 91364, 1, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171360, 91364, 2, '14', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171361, 91371, 1, '408', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171362, 91371, 2, '408', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171363, 91372, 1, '480', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171364, 91372, 2, '480', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171365, 91373, 1, '553', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171366, 91373, 2, '553', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171367, 91374, 1, '494', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171368, 91374, 2, '494', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171369, 91381, 1, '142', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171370, 91381, 2, '142', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171371, 91382, 1, '136', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171372, 91382, 2, '136', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171373, 91383, 1, '120', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171374, 91383, 2, '120', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171375, 91384, 1, '137', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171376, 91384, 2, '137', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171377, 91391, 1, '49/30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171378, 91391, 2, '49/30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171379, 91392, 1, '50/30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171380, 91392, 2, '50/30', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171381, 91393, 1, '9/11', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171382, 91393, 2, '9/11', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171383, 91394, 1, '49/31', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171384, 91394, 2, '49/31', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171385, 91401, 1, '64', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171386, 91401, 2, '64', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171387, 91402, 1, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171388, 91402, 2, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171389, 91403, 1, '55', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171390, 91403, 2, '55', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171391, 91404, 1, '59', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171392, 91404, 2, '59', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171393, 91411, 1, '118', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171394, 91411, 2, '118', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171395, 91412, 1, '125', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171396, 91412, 2, '125', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171397, 91413, 1, '126', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171398, 91413, 2, '126', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171399, 91414, 1, '145', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171400, 91414, 2, '145', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171401, 91441, 1, '61', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171402, 91441, 2, '61', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171403, 91442, 1, '75', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171404, 91442, 2, '75', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171405, 91443, 1, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171406, 91443, 2, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171407, 91444, 1, '78', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171408, 91444, 2, '78', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171409, 91451, 1, '47', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171410, 91451, 2, '47', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171411, 91452, 1, '67', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171412, 91452, 2, '67', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171413, 91453, 1, '52', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171414, 91453, 2, '52', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171415, 91454, 1, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171416, 91454, 2, '60', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171417, 91481, 1, '219', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171418, 91481, 2, '219', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171419, 91482, 1, '186', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171420, 91482, 2, '186', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171421, 91483, 1, '231', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13');
INSERT INTO `mcq_options_translations` (`id`, `mcq_option_id`, `language_id`, `option_text`, `is_active`, `created_at`, `updated_at`) VALUES
(171422, 91483, 2, '231', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171423, 91484, 1, '200', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171424, 91484, 2, '200', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171425, 91491, 1, 'at', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171426, 91491, 2, 'at', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171427, 91492, 1, 'for', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171428, 91492, 2, 'for', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171429, 91493, 1, 'on', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171430, 91493, 2, 'on', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171431, 91494, 1, 'to', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171432, 91494, 2, 'to', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171433, 91501, 1, 'angry', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171434, 91501, 2, 'angry', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171435, 91502, 1, 'sad', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171436, 91502, 2, 'sad', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171437, 91503, 1, 'glad', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171438, 91503, 2, 'glad', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171439, 91504, 1, 'tired', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171440, 91504, 2, 'tired', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171441, 91511, 1, 'be', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171442, 91511, 2, 'be', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171443, 91512, 1, 'are', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171444, 91512, 2, 'are', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171445, 91513, 1, 'am', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171446, 91513, 2, 'am', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171447, 91514, 1, 'is', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171448, 91514, 2, 'is', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171449, 91521, 1, 'well', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171450, 91521, 2, 'well', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171451, 91522, 1, 'good', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171452, 91522, 2, 'good', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171453, 91523, 1, 'better', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171454, 91523, 2, 'better', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171455, 91524, 1, 'best', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171456, 91524, 2, 'best', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171457, 91531, 1, 'finishing', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171458, 91531, 2, 'finishing', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171459, 91532, 1, 'finished', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171460, 91532, 2, 'finished', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171461, 91533, 1, 'finish', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171462, 91533, 2, 'finish', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171463, 91534, 1, 'finishes', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171464, 91534, 2, 'finishes', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171465, 91541, 1, 'a', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171466, 91541, 2, 'a', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171467, 91542, 1, 'the', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171468, 91542, 2, 'the', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171469, 91543, 1, 'an', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171470, 91543, 2, 'an', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171471, 91544, 1, 'some', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171472, 91544, 2, 'some', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171473, 91551, 1, 'stop', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171474, 91551, 2, 'stop', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171475, 91552, 1, 'start', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171476, 91552, 2, 'start', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171477, 91553, 1, 'end', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171478, 91553, 2, 'end', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171479, 91554, 1, 'close', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171480, 91554, 2, 'close', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171481, 91561, 1, 'going', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171482, 91561, 2, 'going', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171483, 91562, 1, 'gone', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171484, 91562, 2, 'gone', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171485, 91563, 1, 'go', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171486, 91563, 2, 'go', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171487, 91564, 1, 'goes', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171488, 91564, 2, 'goes', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171489, 91571, 1, 'will', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171490, 91571, 2, 'will', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171491, 91572, 1, 'were', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171492, 91572, 2, 'were', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171493, 91573, 1, 'have', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171494, 91573, 2, 'have', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171495, 91574, 1, 'would', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171496, 91574, 2, 'would', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171497, 91581, 1, 'hard', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171498, 91581, 2, 'hard', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171499, 91582, 1, 'simple', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171500, 91582, 2, 'simple', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171501, 91583, 1, 'light', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171502, 91583, 2, 'light', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171503, 91584, 1, 'easy', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171504, 91584, 2, 'easy', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171505, 91591, 1, 'clever', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171506, 91591, 2, 'clever', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171507, 91592, 1, 'silly', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171508, 91592, 2, 'silly', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171509, 91593, 1, 'lazy', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171510, 91593, 2, 'lazy', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171511, 91594, 1, 'weak', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171512, 91594, 2, 'weak', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171513, 91601, 1, 'small', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171514, 91601, 2, 'small', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171515, 91602, 1, 'large', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171516, 91602, 2, 'large', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171517, 91603, 1, 'thin', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171518, 91603, 2, 'thin', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171519, 91604, 1, 'short', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171520, 91604, 2, 'short', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171521, 91611, 1, 'quick', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171522, 91611, 2, 'quick', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171523, 91612, 1, 'slow', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171524, 91612, 2, 'slow', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171525, 91613, 1, 'heavy', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171526, 91613, 2, 'heavy', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171527, 91614, 1, 'late', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171528, 91614, 2, 'late', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171529, 91631, 1, 'H2O', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171530, 91631, 2, 'H2O', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171531, 91632, 1, 'CO2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171532, 91632, 2, 'CO2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171533, 91633, 1, 'O2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171534, 91633, 2, 'O2', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171535, 91634, 1, 'NaCl', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171536, 91634, 2, 'NaCl', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171537, 91641, 1, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171538, 91641, 2, '9', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171539, 91642, 1, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171540, 91642, 2, '7', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171541, 91643, 1, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171542, 91643, 2, '10', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171543, 91644, 1, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171544, 91644, 2, '8', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171545, 91671, 1, 'الجلد', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171546, 91671, 2, 'The skin', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171547, 91672, 1, 'الرئة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171548, 91672, 2, 'الرئة', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171549, 91673, 1, 'الكبد', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171550, 91673, 2, 'الكبد', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171551, 91674, 1, 'القلب', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171552, 91674, 2, 'القلب', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171553, 91681, 1, 'الهيدروجين', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171554, 91681, 2, 'الهيدروجين', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171555, 91682, 1, 'الأكسجين', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171556, 91682, 2, 'الأكسجين', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171557, 91683, 1, 'ثاني أكسيد الكربون', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171558, 91683, 2, 'Carbon dioxide', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171559, 91684, 1, 'النيتروجين', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171560, 91684, 2, 'النيتروجين', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(171601, 91701, 1, '10', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171602, 91701, 2, '10', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171603, 91702, 1, '8', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171604, 91702, 2, '8', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171605, 91703, 1, '11', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171606, 91703, 2, '11', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171607, 91704, 1, '14', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171608, 91704, 2, '14', 1, '2026-10-07 14:01:30', '2026-10-07 14:01:30'),
(171643, 91722, 1, '(x − 2)(x − 3)', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(171644, 91722, 2, '(x - 2)(x - 3)', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(171645, 91723, 1, '(x + 2)(x + 3)', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(171646, 91723, 2, '(x + 2)(x + 3)', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(171647, 91724, 1, '(x − 1)(x − 6)', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(171648, 91724, 2, '(x - 1)(x - 6)', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(171649, 91725, 1, 'الوحدة الأولى — الجبر والمتباينات', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171650, 91726, 1, 'الوحدة الثانية — الدوال المثلثية', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171651, 91725, 2, 'Unit 1 - Algebra and Inequalities', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171652, 91726, 2, 'Unit 2 - Trigonometric Functions', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171656, 91728, 1, 'موعد فردي (teacher_availability_slots)', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171657, 91729, 1, 'حصّة أسبوعية ثابتة (class_sessions)', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171658, 91728, 2, 'An individual appointment (teacher_availability_slots)', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(171659, 91729, 2, 'A fixed weekly class (class_sessions)', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30');

-- --------------------------------------------------------

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
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `sender_type`, `sender_id`, `target_type`, `channels`, `title`, `body`, `data`, `created_at`) VALUES
(635, 'system', NULL, 'admin', 'push', 'اشتراك جديد في كورس', 'الطالب محمد الطالب اشترك في كورس \"اختبار الدفع - ٢ جنيه (للحذف)\" (شراء مباشر).', '{\"type\":\"course_subscription\",\"student_id\":1,\"course_id\":506}', '2026-10-08 14:22:51'),
(636, 'system', NULL, 'admin', 'push', 'طالب جديد سجّل في المنصة', 'sief zidan (omartalaat1276@gmail.com) سجّل حساب جديد في المنصة.', '{\"type\":\"new_student_registration\",\"student_id\":1107}', '2026-10-11 08:44:57'),
(637, 'system', NULL, 'admin', 'push', 'طالب جديد سجّل في المنصة', 'City Test User (citytest1791708714@brainixa.cloud) سجّل حساب جديد في المنصة.', '{\"type\":\"new_student_registration\",\"student_id\":1108}', '2026-10-11 08:51:33'),
(638, 'system', NULL, 'teacher', 'push', 'طالب جديد اشترك في باقتك', 'الطالب محمد الطالب اشترك في باقة \"الحرب العالمية الاولي\" (منح إداري).', '{\"type\":\"course_subscription\",\"student_id\":1,\"course_id\":507}', '2026-10-13 05:47:14'),
(639, 'system', NULL, 'admin', 'push', 'طالب جديد سجّل في المنصة', 'Student (student1025@example.com) سجّل حساب جديد في المنصة.', '{\"type\":\"new_student_registration\",\"student_id\":1110}', '2026-10-18 13:57:49'),
(640, 'system', NULL, 'teacher', 'push', 'طالب جديد اشترك في كورسك', 'الطالب Bassem اشترك في كورس \"رياضيات - الصف الثاني الثانوي (تجريبي)\" (منح إداري).', '{\"type\":\"course_subscription\",\"student_id\":1111,\"course_id\":1}', '2026-10-24 23:45:58'),
(641, 'system', NULL, 'admin', 'push', 'طلب شراء كتاب جديد', 'الطالب Student طلب شراء الكتاب \"كتاب اختبار دورة الشراء\" وينتظر الموافقة.', '{\"type\":\"book_purchase_request\",\"student_id\":1110,\"book_id\":7672}', '2026-10-28 08:58:43'),
(642, 'system', NULL, 'admin', 'push', 'طلب شراء كتاب جديد', 'الطالب Student طلب شراء الكتاب \"كتاب اختبار دورة الشراء\" وينتظر الموافقة.', '{\"type\":\"book_purchase_request\",\"student_id\":1110,\"book_id\":7672}', '2026-10-28 08:58:48'),
(643, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-10-29 17:00', '{\"slot_id\":28}', '2026-10-28 12:18:50'),
(644, 'system', NULL, 'teacher', 'push', 'طالب جديد اشترك في باقتك', 'الطالب Student اشترك في باقة \"باقة اختبار Zoom\" (منح إداري).', '{\"type\":\"course_subscription\",\"student_id\":1110,\"course_id\":510}', '2026-10-28 12:36:35'),
(645, 'system', NULL, 'teacher', 'push', 'حجز موعد جديد', 'قام Student بحجز موعد بتاريخ 2026-10-28 15:45', '{\"slot_id\":29}', '2026-10-28 12:40:05'),
(646, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-10-28 15:51', '{\"slot_id\":30}', '2026-10-28 12:40:18'),
(647, 'system', NULL, 'student', 'push', 'إلغاء حجز موعد', 'تم إلغاء موعدك بتاريخ 2026-10-28 15:45', '{\"slot_id\":29}', '2026-10-28 12:45:04'),
(648, 'system', NULL, 'teacher', 'push', 'حجز موعد جديد', 'قام Student بحجز موعد بتاريخ 2026-10-28 15:45', '{\"slot_id\":29}', '2026-10-28 12:46:50'),
(649, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 15:45) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":29}', '2026-10-28 12:55:03'),
(650, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 15:45) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":29}', '2026-10-28 12:55:25'),
(651, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 15:45) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":29}', '2026-10-28 12:59:21'),
(652, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 15:45) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":29}', '2026-10-28 13:03:18'),
(653, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:04'),
(654, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:05'),
(655, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:05'),
(656, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:05'),
(657, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:05'),
(658, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:06'),
(659, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:06'),
(660, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:06'),
(661, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:25:06'),
(662, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 15:45) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":29}', '2026-10-28 13:30:32'),
(663, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:30:33'),
(664, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 15:45) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":29}', '2026-10-28 13:30:34'),
(665, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 15:45).', '{\"type\":\"availability_session_ended\",\"slot_id\":29}', '2026-10-28 13:30:35'),
(666, 'system', NULL, 'admin', 'push', 'استشارة جديدة من معلم', 'المعلم أحمد الرياضي أضاف موعد استشارة جديد يوم 2026-10-29 الساعة 10:00:00.', '{\"type\":\"consultation_created\",\"teacher_id\":1,\"subject_id\":null}', '2026-10-28 13:30:35'),
(667, 'system', NULL, 'teacher', 'push', 'طالب جديد اشترك في باقتك', 'الطالب Student اشترك في باقة \"باقة اختبار Zoom 2\" (منح إداري).', '{\"type\":\"course_subscription\",\"student_id\":1110,\"course_id\":511}', '2026-10-28 14:09:09'),
(668, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-10-28 17:14', '{\"slot_id\":32}', '2026-10-28 14:09:27'),
(669, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 17:14) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":32}', '2026-10-28 14:09:56'),
(670, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 17:14).', '{\"type\":\"availability_session_ended\",\"slot_id\":32}', '2026-10-28 14:48:07'),
(671, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 17:14).', '{\"type\":\"availability_session_ended\",\"slot_id\":32}', '2026-10-28 14:48:08'),
(672, 'system', NULL, 'teacher', 'push', 'حجز موعد جديد', 'قام Student بحجز موعد بتاريخ 2026-10-28 22:47', '{\"slot_id\":33}', '2026-10-28 19:42:57'),
(673, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-28 22:47) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":33}', '2026-10-28 19:43:04'),
(674, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-10-28 22:47).', '{\"type\":\"availability_session_ended\",\"slot_id\":33}', '2026-10-28 19:49:28'),
(675, 'system', NULL, 'admin', 'push', 'استشارة جديدة من معلم', 'المعلم أحمد الرياضي أضاف موعد استشارة جديد يوم 2026-10-30 الساعة 11:00:00.', '{\"type\":\"consultation_created\",\"teacher_id\":1,\"subject_id\":null}', '2026-10-28 19:50:25'),
(676, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-10-31 17:10', '{\"slot_id\":35}', '2026-10-31 15:05:15'),
(677, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-10-31 17:20', '{\"slot_id\":36}', '2026-10-31 15:06:30'),
(678, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-10-31 17:32', '{\"slot_id\":38}', '2026-10-31 15:09:03'),
(679, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-31 17:32) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":38}', '2026-10-31 15:09:28'),
(680, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-10-31 17:32) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":38}', '2026-10-31 15:10:24'),
(681, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-01 17:30', '{\"slot_id\":39}', '2026-10-31 15:12:35'),
(682, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-01 17:30) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":39}', '2026-10-31 15:13:35'),
(683, 'system', NULL, 'admin', 'push', 'طلب شراء كتاب جديد', 'الطالب mohamed ramadan طلب شراء الكتاب \"سماعة رأس للمذاكرة\" وينتظر الموافقة.', '{\"type\":\"book_purchase_request\",\"student_id\":1109,\"book_id\":7673}', '2026-11-02 11:51:51'),
(684, 'system', NULL, 'teacher', 'push', 'طالب جديد اشترك في باقتك', 'الطالب Bassem اشترك في باقة \"باقة اختبار Zoom 2\" (منح إداري).', '{\"type\":\"course_subscription\",\"student_id\":1111,\"course_id\":511}', '2026-11-03 12:05:27'),
(685, 'system', NULL, 'teacher', 'push', 'طالب جديد اشترك في باقتك', 'الطالب Bassem اشترك في باقة \"باقة شرح\" (منح إداري).', '{\"type\":\"course_subscription\",\"student_id\":1111,\"course_id\":514}', '2026-11-03 12:11:21'),
(686, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-03 14:20', '{\"slot_id\":41}', '2026-11-03 12:16:17'),
(687, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-10 14:20', '{\"slot_id\":42}', '2026-11-03 12:16:17'),
(688, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-17 14:20', '{\"slot_id\":43}', '2026-11-03 12:16:17'),
(689, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-24 14:20', '{\"slot_id\":44}', '2026-11-03 12:16:17'),
(690, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-12-01 14:20', '{\"slot_id\":45}', '2026-11-03 12:16:17'),
(691, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-03 14:20) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":41}', '2026-11-03 12:25:15'),
(692, 'system', NULL, 'teacher', 'push', 'إلغاء حجز موعد', 'قام Bassem بإلغاء حجز موعد بتاريخ 2026-11-24 14:20', '{\"slot_id\":44}', '2026-11-03 14:40:58'),
(693, 'system', NULL, 'admin', 'push', 'استشارة جديدة من معلم', 'المعلم أحمد الرياضي أضاف موعد استشارة جديد يوم 2026-11-04 الساعة 23:05:00.', '{\"type\":\"consultation_created\",\"teacher_id\":1,\"subject_id\":null}', '2026-11-04 11:05:25'),
(694, 'admin', 1, 'student', 'push', 'مواعيد استشارة', 'تم حجز 1 موعد استشارة لك مع أحمد الرياضي (2026-11-04).', '{\"type\":\"consultation_booked\",\"booked_by\":\"admin\",\"count\":1}', '2026-11-04 11:05:25'),
(695, 'admin', 1, 'teacher', 'push', 'حجز استشارات جديد', 'حجزت الإدارة 1 موعد استشارة لك مع الطالب Bassem (2026-11-04).', '{\"type\":\"consultation_booked\",\"booked_by\":\"admin\",\"count\":1}', '2026-11-04 11:05:25'),
(696, 'system', NULL, 'student', 'push', 'بدأت الاستشارة', 'بدأت الاستشارة مع أحمد الرياضي الآن، يمكنك الدخول.', '{\"type\":\"consultation_started\",\"slot_id\":158}', '2026-11-04 11:05:49'),
(697, 'system', NULL, 'student', 'push', 'انتهت الاستشارة', 'انتهت الاستشارة مع أحمد الرياضي.', '{\"type\":\"consultation_ended\",\"slot_id\":158}', '2026-11-04 11:06:54'),
(698, 'system', NULL, 'admin', 'push', 'استشارة جديدة من معلم', 'المعلم أحمد الرياضي أضاف موعد استشارة جديد يوم 2026-11-04 الساعة 12:08:00.', '{\"type\":\"consultation_created\",\"teacher_id\":1,\"subject_id\":null}', '2026-11-04 11:09:10'),
(699, 'admin', 1, 'student', 'push', 'مواعيد استشارة', 'تم حجز 1 موعد استشارة لك مع أحمد الرياضي (2026-11-04).', '{\"type\":\"consultation_booked\",\"booked_by\":\"admin\",\"count\":1}', '2026-11-04 11:09:10'),
(700, 'admin', 1, 'teacher', 'push', 'حجز استشارات جديد', 'حجزت الإدارة 1 موعد استشارة لك مع الطالب Bassem (2026-11-04).', '{\"type\":\"consultation_booked\",\"booked_by\":\"admin\",\"count\":1}', '2026-11-04 11:09:10'),
(701, 'system', NULL, 'student', 'push', 'بدأت الاستشارة', 'بدأت الاستشارة مع أحمد الرياضي الآن، يمكنك الدخول.', '{\"type\":\"consultation_started\",\"slot_id\":159}', '2026-11-04 11:10:07'),
(702, 'system', NULL, 'student', 'push', 'انتهت الاستشارة', 'انتهت الاستشارة مع أحمد الرياضي.', '{\"type\":\"consultation_ended\",\"slot_id\":159}', '2026-11-04 11:12:46'),
(703, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-04 13:35', '{\"slot_id\":48}', '2026-11-04 11:32:54'),
(704, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-05 13:35', '{\"slot_id\":49}', '2026-11-04 11:32:54'),
(705, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-06 13:35', '{\"slot_id\":50}', '2026-11-04 11:32:54'),
(706, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-07 13:35', '{\"slot_id\":51}', '2026-11-04 11:32:54'),
(707, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-08 13:35', '{\"slot_id\":52}', '2026-11-04 11:32:54'),
(708, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-09 13:35', '{\"slot_id\":53}', '2026-11-04 11:32:54'),
(709, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-10 13:35', '{\"slot_id\":54}', '2026-11-04 11:32:54'),
(710, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-11 13:35', '{\"slot_id\":55}', '2026-11-04 11:32:54'),
(711, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-12 13:35', '{\"slot_id\":56}', '2026-11-04 11:32:54'),
(712, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-13 13:35', '{\"slot_id\":57}', '2026-11-04 11:32:55'),
(713, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-14 13:35', '{\"slot_id\":58}', '2026-11-04 11:32:55'),
(714, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-15 13:35', '{\"slot_id\":59}', '2026-11-04 11:32:55'),
(715, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-16 13:35', '{\"slot_id\":60}', '2026-11-04 11:32:55'),
(716, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-17 13:35', '{\"slot_id\":61}', '2026-11-04 11:32:55'),
(717, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-18 13:35', '{\"slot_id\":62}', '2026-11-04 11:32:55'),
(718, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-19 13:35', '{\"slot_id\":63}', '2026-11-04 11:32:55'),
(719, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-20 13:35', '{\"slot_id\":64}', '2026-11-04 11:32:55'),
(720, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-21 13:35', '{\"slot_id\":65}', '2026-11-04 11:32:55'),
(721, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-22 13:35', '{\"slot_id\":66}', '2026-11-04 11:32:55'),
(722, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-23 13:35', '{\"slot_id\":67}', '2026-11-04 11:32:55'),
(723, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-24 13:35', '{\"slot_id\":68}', '2026-11-04 11:32:56'),
(724, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-25 13:35', '{\"slot_id\":69}', '2026-11-04 11:32:56'),
(725, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-26 13:35', '{\"slot_id\":70}', '2026-11-04 11:32:56'),
(726, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-27 13:35', '{\"slot_id\":71}', '2026-11-04 11:32:56'),
(727, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-28 13:35', '{\"slot_id\":72}', '2026-11-04 11:32:56'),
(728, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-29 13:35', '{\"slot_id\":73}', '2026-11-04 11:32:56'),
(729, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-30 13:35', '{\"slot_id\":74}', '2026-11-04 11:32:56'),
(730, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-12-01 13:35', '{\"slot_id\":75}', '2026-11-04 11:32:56'),
(731, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-12-02 13:35', '{\"slot_id\":76}', '2026-11-04 11:32:56'),
(732, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-12-03 13:35', '{\"slot_id\":77}', '2026-11-04 11:32:56'),
(733, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-04 13:35) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":48}', '2026-11-04 11:34:08'),
(734, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-04 13:35).', '{\"type\":\"availability_session_ended\",\"slot_id\":48}', '2026-11-04 11:38:00'),
(735, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-04 13:35) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":48}', '2026-11-04 11:38:06'),
(736, 'system', NULL, 'teacher', 'push', 'إلغاء حجز موعد', 'قام Bassem بإلغاء حجز موعد بتاريخ 2026-11-04 13:35', '{\"slot_id\":48}', '2026-11-04 12:50:31'),
(737, 'system', NULL, 'teacher', 'push', 'إلغاء حجز موعد', 'قام Bassem بإلغاء حجز موعد بتاريخ 2026-11-05 13:35', '{\"slot_id\":49}', '2026-11-04 12:50:41'),
(738, 'system', NULL, 'teacher', 'push', 'إلغاء حجز موعد', 'قام Bassem بإلغاء حجز موعد بتاريخ 2026-11-06 13:35', '{\"slot_id\":50}', '2026-11-04 12:51:24'),
(739, 'system', NULL, 'teacher', 'push', 'حجز موعد جديد', 'قام Bassem بحجز موعد بتاريخ 2026-11-04 13:35', '{\"slot_id\":48}', '2026-11-04 12:57:12'),
(740, 'system', NULL, 'teacher', 'push', 'إلغاء حجز موعد', 'قام Bassem بإلغاء حجز موعد بتاريخ 2026-11-04 13:35', '{\"slot_id\":48}', '2026-11-04 13:32:01'),
(741, 'system', NULL, 'teacher', 'push', 'حجز موعد جديد', 'قام Bassem بحجز موعد بتاريخ 2026-11-04 13:35', '{\"slot_id\":48}', '2026-11-04 13:32:19'),
(742, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-04 15:55', '{\"slot_id\":104}', '2026-11-04 13:52:38'),
(743, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-04 15:55) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":104}', '2026-11-04 13:54:34'),
(744, 'system', NULL, 'teacher', 'push', 'حجز موعد جديد', 'قام Bassem بحجز موعد بتاريخ 2026-11-05 13:35', '{\"slot_id\":49}', '2026-11-05 08:52:43'),
(745, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-05 05:00', '{\"slot_id\":105}', '2026-11-05 09:27:41'),
(746, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-12 05:00', '{\"slot_id\":106}', '2026-11-05 09:27:41'),
(747, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-19 05:00', '{\"slot_id\":107}', '2026-11-05 09:27:41'),
(748, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-26 05:00', '{\"slot_id\":108}', '2026-11-05 09:27:42'),
(749, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-12-03 05:00', '{\"slot_id\":109}', '2026-11-05 09:27:42'),
(750, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-05 04:00) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":173}', '2026-11-05 10:09:28'),
(751, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-05 10:00) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":110}', '2026-11-05 10:11:38'),
(752, 'system', NULL, 'teacher', 'push', 'طالب دخل الحصة', 'أحد الطلاب دخل الحصة بالفعل، برجاء عدم التأخير.', '{\"type\":\"other_party_checked_in\",\"session_id\":154}', '2026-11-05 10:41:00'),
(753, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-05 10:00).', '{\"type\":\"availability_session_ended\",\"slot_id\":110}', '2026-11-05 10:47:10'),
(754, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-05 04:00) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":173}', '2026-11-05 10:47:25'),
(755, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-05 04:00).', '{\"type\":\"availability_session_ended\",\"slot_id\":173}', '2026-11-05 10:57:28'),
(756, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-05 11:35) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":49}', '2026-11-05 11:32:35'),
(757, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-05 11:35).', '{\"type\":\"availability_session_ended\",\"slot_id\":49}', '2026-11-05 11:33:20'),
(758, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-05 14:00) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":111}', '2026-11-05 11:33:29'),
(759, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-05 14:00).', '{\"type\":\"availability_session_ended\",\"slot_id\":111}', '2026-11-05 11:40:01'),
(760, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-04 15:55).', '{\"type\":\"availability_session_ended\",\"slot_id\":104}', '2026-11-05 11:43:55'),
(761, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-05 06:00', '{\"slot_id\":174}', '2026-11-05 11:45:52'),
(762, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-12 06:00', '{\"slot_id\":175}', '2026-11-05 11:45:52'),
(763, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-19 06:00', '{\"slot_id\":176}', '2026-11-05 11:45:52'),
(764, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-26 06:00', '{\"slot_id\":177}', '2026-11-05 11:45:53'),
(765, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-12-03 06:00', '{\"slot_id\":178}', '2026-11-05 11:45:53'),
(766, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-05 06:00) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":174}', '2026-11-05 11:46:30'),
(767, 'system', NULL, 'student', 'push', 'انتهت الحصة', 'انتهت حصتك (2026-11-05 06:00).', '{\"type\":\"availability_session_ended\",\"slot_id\":174}', '2026-11-05 11:47:35'),
(768, 'system', 1109, 'student', 'push', 'موعد استشارة', 'تم تسجيل حجزك لاستشارة مع أحمد المعلم يوم 2026-11-06 16:00.', '{\"type\":\"consultation_booked\",\"slot_id\":165,\"booked_by\":\"student\"}', '2026-11-05 11:52:51'),
(769, 'system', 1109, 'teacher', 'push', 'حجز استشارة جديد', 'حجز الطالب mohamed ramadan موعد استشارة معك يوم 2026-11-06 16:00.', '{\"type\":\"consultation_booked\",\"slot_id\":165,\"booked_by\":\"student\"}', '2026-11-05 11:52:51'),
(770, 'system', NULL, 'student', 'push', 'حجز موعد جديد', 'تم تحديد موعد لك بتاريخ 2026-11-07 12:55', '{\"slot_id\":179}', '2026-11-07 10:49:55'),
(771, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-07 12:55) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":179}', '2026-11-07 10:50:59'),
(772, 'system', NULL, 'student', 'push', 'بدأت الحصة', 'بدأت حصتك (2026-11-07 13:35) الآن، يمكنك الدخول.', '{\"type\":\"availability_session_started\",\"slot_id\":51}', '2026-11-07 11:46:27');

-- --------------------------------------------------------

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
-- Dumping data for table `notification_recipients`
--

INSERT INTO `notification_recipients` (`id`, `notification_id`, `user_type`, `user_id`, `is_sent`, `is_email_sent`, `is_read`, `error`, `email_error`, `created_at`) VALUES
(2130, 635, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-08 14:22:51'),
(2131, 636, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-11 08:44:57'),
(2132, 637, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-11 08:51:34'),
(2133, 638, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-13 05:47:14'),
(2134, 639, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-18 13:57:49'),
(2135, 640, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-24 23:45:59'),
(2136, 641, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 08:58:43'),
(2137, 642, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 08:58:48'),
(2138, 643, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 12:18:51'),
(2139, 644, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 12:36:35'),
(2140, 645, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 12:40:05'),
(2141, 646, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 12:40:18'),
(2142, 647, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 12:45:04'),
(2143, 648, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 12:46:50'),
(2144, 649, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 12:55:03'),
(2145, 650, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 12:55:25'),
(2146, 651, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 12:59:21'),
(2147, 652, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:03:18'),
(2148, 653, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:04'),
(2149, 654, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:05'),
(2150, 655, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:05'),
(2151, 656, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:05'),
(2152, 657, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:06'),
(2153, 658, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:06'),
(2154, 659, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:06'),
(2155, 660, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:06'),
(2156, 661, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:25:06'),
(2157, 662, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:30:32'),
(2158, 663, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:30:33'),
(2159, 664, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:30:34'),
(2160, 665, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 13:30:35'),
(2161, 666, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 13:30:36'),
(2162, 667, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 14:09:09'),
(2163, 668, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 14:09:27'),
(2164, 669, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 14:09:56'),
(2165, 670, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 14:48:07'),
(2166, 671, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 14:48:08'),
(2167, 672, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 19:42:57'),
(2168, 673, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 19:43:04'),
(2169, 674, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-28 19:49:28'),
(2170, 675, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-10-28 19:50:25'),
(2171, 676, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:05:16'),
(2172, 677, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:06:30'),
(2173, 678, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:09:03'),
(2174, 679, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:09:28'),
(2175, 680, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:10:24'),
(2176, 681, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:12:35'),
(2177, 682, 'student', 1110, 0, 0, 0, 'Firebase send failed', NULL, '2026-10-31 15:13:35'),
(2178, 683, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-02 11:51:51'),
(2179, 684, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-03 12:05:27'),
(2180, 685, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-03 12:11:21'),
(2181, 686, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-03 12:16:17'),
(2182, 687, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-03 12:16:17'),
(2183, 688, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-03 12:16:17'),
(2184, 689, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-03 12:16:17'),
(2185, 690, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-03 12:16:17'),
(2186, 691, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-03 12:25:15'),
(2187, 692, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-03 14:40:58'),
(2188, 693, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 11:05:25'),
(2189, 694, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:05:25'),
(2190, 695, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 11:05:25'),
(2191, 696, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:05:49'),
(2192, 697, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:06:54'),
(2193, 698, 'admin', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 11:09:10'),
(2194, 699, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:09:10'),
(2195, 700, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 11:09:10'),
(2196, 701, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:10:07'),
(2197, 702, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:12:47'),
(2198, 703, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2199, 704, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2200, 705, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2201, 706, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2202, 707, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2203, 708, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2204, 709, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2205, 710, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:54'),
(2206, 711, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2207, 712, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2208, 713, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2209, 714, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2210, 715, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2211, 716, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2212, 717, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2213, 718, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2214, 719, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2215, 720, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2216, 721, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:55'),
(2217, 722, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2218, 723, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2219, 724, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2220, 725, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2221, 726, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2222, 727, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2223, 728, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2224, 729, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2225, 730, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2226, 731, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2227, 732, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:32:56'),
(2228, 733, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:34:08'),
(2229, 734, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:38:00'),
(2230, 735, 'student', 1111, 0, 0, 1, 'Firebase send failed', NULL, '2026-11-04 11:38:06'),
(2231, 736, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 12:50:31'),
(2232, 737, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 12:50:41'),
(2233, 738, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 12:51:24'),
(2234, 739, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 12:57:12'),
(2235, 740, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 13:32:01'),
(2236, 741, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-04 13:32:19'),
(2237, 742, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-04 13:52:38'),
(2238, 743, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-04 13:54:34'),
(2239, 744, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-05 08:52:43'),
(2240, 745, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 09:27:41'),
(2241, 746, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 09:27:41'),
(2242, 747, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 09:27:42'),
(2243, 748, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 09:27:42'),
(2244, 749, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 09:27:42'),
(2245, 750, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 10:09:29'),
(2246, 751, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 10:11:38'),
(2247, 752, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-05 10:41:00'),
(2248, 753, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 10:47:11'),
(2249, 754, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 10:47:25'),
(2250, 755, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 10:57:28'),
(2251, 756, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:32:35'),
(2252, 757, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:33:20'),
(2253, 758, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:33:29'),
(2254, 759, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:40:02'),
(2255, 760, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:43:55'),
(2256, 761, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:45:52'),
(2257, 762, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:45:52'),
(2258, 763, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:45:53'),
(2259, 764, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:45:53'),
(2260, 765, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:45:53'),
(2261, 766, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:46:30'),
(2262, 767, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:47:35'),
(2263, 768, 'student', 1109, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-05 11:52:51'),
(2264, 769, 'teacher', 1, 0, 0, 1, 'No FCM token registered', NULL, '2026-11-05 11:52:51'),
(2265, 770, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-07 10:49:55'),
(2266, 771, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-07 10:50:59'),
(2267, 772, 'student', 1111, 0, 0, 0, 'Firebase send failed', NULL, '2026-11-07 11:46:28');

-- --------------------------------------------------------

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
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `phone_country_code` varchar(8) DEFAULT NULL COMMENT 'Dial code of the phone number, without the +',
  `password` varchar(255) NOT NULL,
  `image` longtext DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `parents`
--

INSERT INTO `parents` (`id`, `city_id`, `name`, `email`, `phone`, `phone_country_code`, `password`, `image`, `fcm_token`, `is_email_verified`, `is_active`, `created_at`, `updated_at`) VALUES
(1, NULL, 'ولي أمر تجريبي', 'parent1@brainixa.cloud', NULL, NULL, '$2y$10$MrfZuFCLkYMlvrmguPqxXe0Nm4iU/4pSn0JzB47iBfW2EQ3xji8YK', NULL, NULL, 1, 1, '2026-10-07 16:00:00', '2026-10-25 04:23:59'),
(322, NULL, 'ولي امر', 'parent@parent.parent', '', NULL, '$2y$10$eHMUYUvnWY41rwDEnJ.N0./uLRe3EWt6YhDIHpwITZu19tpUg7G3G', '', NULL, 1, 1, '2026-10-25 04:24:55', '2026-10-26 11:39:58');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

--
-- Table structure for table `payment_transactions`
--

CREATE TABLE `payment_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `item_type` enum('course','book') NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `original_amount` decimal(10,2) DEFAULT NULL COMMENT 'The list price before any code or points. NULL on rows predating this.',
  `discount_code_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'The code quoted at checkout. Only SPENT once the payment succeeds, like the offline path.',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `points_spent` decimal(10,2) NOT NULL DEFAULT 0.00,
  `points_discount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'What those points were worth in `currency`.',
  `points_refunded_at` timestamp NULL DEFAULT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `status` enum('pending','paid','failed','cancelled') NOT NULL DEFAULT 'pending',
  `easykash_ref` varchar(100) DEFAULT NULL,
  `gateway_reference` varchar(64) DEFAULT NULL COMMENT 'The customerReference sent to EasyKash. Unique for all time; never reuse.',
  `payment_method` varchar(100) DEFAULT NULL,
  `granted_ref_id` bigint(20) UNSIGNED DEFAULT NULL,
  `raw_callback` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `paid_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payment_transactions`
--

INSERT INTO `payment_transactions` (`id`, `student_id`, `item_type`, `item_id`, `amount`, `original_amount`, `discount_code_id`, `discount_amount`, `points_spent`, `points_discount`, `points_refunded_at`, `currency`, `status`, `easykash_ref`, `gateway_reference`, `payment_method`, `granted_ref_id`, `raw_callback`, `created_at`, `paid_at`) VALUES
(1, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 11:30:36', NULL),
(2, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 11:31:16', NULL),
(3, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 11:31:31', NULL),
(4, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 11:48:34', NULL),
(5, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 12:21:50', NULL),
(6, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 12:29:58', NULL),
(7, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 12:34:01', NULL),
(8, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'failed', NULL, NULL, NULL, NULL, NULL, '2026-10-08 12:34:26', NULL),
(9, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX9-f0a36d49', NULL, NULL, NULL, '2026-10-08 12:43:44', NULL),
(10, 1, 'course', 2, 149.00, NULL, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX10-b186d80d', NULL, NULL, NULL, '2026-10-08 12:44:10', NULL),
(12, 1111, 'book', 7673, 1250.00, 1250.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX12-b01dba54', NULL, NULL, NULL, '2026-11-01 13:47:52', NULL),
(13, 1109, 'book', 7674, 790.00, 790.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX13-99c2bed2', NULL, NULL, NULL, '2026-11-02 09:15:56', NULL),
(14, 1109, 'book', 7674, 790.00, 790.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX14-696bfbc1', NULL, NULL, NULL, '2026-11-02 09:18:24', NULL),
(15, 1109, 'book', 7673, 1250.00, 1250.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX15-58a051c8', NULL, NULL, NULL, '2026-11-02 10:48:48', NULL),
(16, 1109, 'book', 7676, 150.00, 150.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX16-b1c734c6', NULL, NULL, NULL, '2026-11-02 11:51:41', NULL),
(17, 1109, 'book', 7673, 1250.00, 1250.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX17-4789543a', NULL, NULL, NULL, '2026-11-02 14:57:39', NULL),
(18, 1109, 'book', 7674, 790.00, 790.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX18-6bea5168', NULL, NULL, NULL, '2026-11-02 14:58:09', NULL),
(19, 1109, 'book', 7673, 1250.00, 1250.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX19-ef914428', NULL, NULL, NULL, '2026-11-02 14:58:30', NULL),
(20, 1111, 'course', 513, 500.00, 500.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX20-48ec2494', NULL, NULL, NULL, '2026-11-03 12:07:38', NULL),
(21, 1111, 'book', 7674, 790.00, 790.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX21-1b6435bc', NULL, NULL, NULL, '2026-11-03 12:30:56', NULL),
(22, 1111, 'course', 513, 500.00, 500.00, NULL, 0.00, 0.00, 0.00, NULL, 'EGP', 'pending', NULL, 'BX22-9e00028a', NULL, NULL, NULL, '2026-11-04 13:36:45', NULL);

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
(123, 'view_sales', 'Sales', 'sales', 1, '', '2026-09-30 13:19:36'),
(141, 'manage_hero_slides', 'Manage Hero Slides', 'hero_slides', 1, 'Manage the landing page hero background slides', '2026-10-26 10:02:35'),
(142, 'manage_manual_sales', 'Manage Manual Sales', 'manual_sales', 1, 'Record and review sales made outside the platform', '2026-10-27 08:24:47'),
(145, 'manage_homework', 'Manage Homework', 'homework', 1, 'Create homework, and review what students submit', '2026-11-05 12:31:06');

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
(261, 123, 2, 'Sales', NULL, '2026-09-30 13:19:36', '2026-09-30 13:19:36'),
(296, 141, 1, 'إدارة شرائح البانر الرئيسي', 'إدارة صور وفيديوهات خلفية البانر في الصفحة الرئيسية', '2026-10-26 10:02:35', '2026-10-26 10:02:35'),
(297, 141, 2, 'Manage Hero Slides', 'Manage the landing page hero background images and videos', '2026-10-26 10:02:36', '2026-10-26 10:02:36'),
(298, 142, 1, 'إدارة المبيعات اليدوية', 'تسجيل ومراجعة المبيعات التي تتم خارج المنصّة', '2026-10-27 08:24:47', '2026-10-27 08:24:47'),
(299, 142, 2, 'Manage Manual Sales', 'Record and review sales made outside the platform', '2026-10-27 08:24:47', '2026-10-27 08:24:47'),
(304, 145, 1, 'إدارة الواجبات', 'إنشاء الواجبات ومراجعة تسليمات الطلاب', '2026-11-05 12:31:06', '2026-11-05 12:31:06'),
(305, 145, 2, 'Manage Homework', 'Create homework, and review what students submit', '2026-11-05 12:31:06', '2026-11-05 12:31:06');

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
  `exam_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_bank` tinyint(1) NOT NULL DEFAULT 0,
  `bank_folder_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
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
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`id`, `exam_id`, `is_bank`, `bank_folder_id`, `course_id`, `unit_id`, `question_type`, `order_num`, `score`, `question_image`, `is_active`, `created_at`, `updated_at`, `subject_id`, `created_by_type`, `created_by_id`) VALUES
(9001, NULL, 1, 901, NULL, NULL, 'mcq', 1, 2.00, '', 1, '2026-10-07 13:33:12', '2026-10-07 13:58:42', NULL, 'admin', 1),
(9002, NULL, 1, 901, NULL, NULL, 'mcq', 2, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9003, NULL, 1, 901, NULL, NULL, 'mcq', 3, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9004, NULL, 1, 901, NULL, NULL, 'mcq', 4, 2.00, 'https://picsum.photos/seed/brainixa-q-9004/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9005, NULL, 1, 901, NULL, NULL, 'written', 5, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9006, NULL, 1, 901, NULL, NULL, 'mcq', 6, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9007, NULL, 1, 901, NULL, NULL, 'true_false', 7, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9008, NULL, 1, 901, NULL, NULL, 'mcq', 8, 2.00, 'https://picsum.photos/seed/brainixa-q-9008/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9009, NULL, 1, 901, NULL, NULL, 'mcq', 9, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9010, NULL, 1, 901, NULL, NULL, 'mcq', 10, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9011, NULL, 1, 901, NULL, NULL, 'written', 11, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9012, NULL, 1, 901, NULL, NULL, 'written', 12, 5.00, 'https://picsum.photos/seed/brainixa-q-9012/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9013, NULL, 1, 901, NULL, NULL, 'true_false', 13, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9014, NULL, 1, 901, NULL, NULL, 'mcq', 14, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9015, NULL, 1, 901, NULL, NULL, 'true_false', 15, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9016, NULL, 1, 901, NULL, NULL, 'mcq', 16, 2.00, 'https://picsum.photos/seed/brainixa-q-9016/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9017, NULL, 1, 901, NULL, NULL, 'mcq', 17, 2.00, NULL, 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9018, NULL, 1, 901, NULL, NULL, 'true_false', 18, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9019, NULL, 1, 901, NULL, NULL, 'written', 19, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9020, NULL, 1, 901, NULL, NULL, 'mcq', 20, 2.00, 'https://picsum.photos/seed/brainixa-q-9020/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9021, NULL, 1, 901, NULL, NULL, 'mcq', 21, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9022, NULL, 1, 901, NULL, NULL, 'mcq', 22, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9023, NULL, 1, 901, NULL, NULL, 'mcq', 23, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9024, NULL, 1, 901, NULL, NULL, 'true_false', 24, 1.00, 'https://picsum.photos/seed/brainixa-q-9024/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9025, NULL, 1, 901, NULL, NULL, 'true_false', 25, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9026, NULL, 1, 901, NULL, NULL, 'written', 26, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9027, NULL, 1, 901, NULL, NULL, 'mcq', 27, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9028, NULL, 1, 901, NULL, NULL, 'mcq', 28, 2.00, 'https://picsum.photos/seed/brainixa-q-9028/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9029, NULL, 1, 901, NULL, NULL, 'written', 29, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9030, NULL, 1, 901, NULL, NULL, 'mcq', 30, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9031, NULL, 1, 901, NULL, NULL, 'true_false', 31, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9032, NULL, 1, 901, NULL, NULL, 'mcq', 32, 2.00, 'https://picsum.photos/seed/brainixa-q-9032/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9033, NULL, 1, 901, NULL, NULL, 'mcq', 33, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9034, NULL, 1, 901, NULL, NULL, 'mcq', 34, 2.00, NULL, 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9035, NULL, 1, 901, NULL, NULL, 'mcq', 35, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9036, NULL, 1, 901, NULL, NULL, 'mcq', 36, 2.00, 'https://picsum.photos/seed/brainixa-q-9036/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9037, NULL, 1, 901, NULL, NULL, 'mcq', 37, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9038, NULL, 1, 901, NULL, NULL, 'written', 38, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9039, NULL, 1, 901, NULL, NULL, 'mcq', 39, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9040, NULL, 1, 901, NULL, NULL, 'written', 40, 5.00, 'https://picsum.photos/seed/brainixa-q-9040/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9041, NULL, 1, 901, NULL, NULL, 'mcq', 41, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9042, NULL, 1, 901, NULL, NULL, 'mcq', 42, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9043, NULL, 1, 901, NULL, NULL, 'mcq', 43, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9044, NULL, 1, 901, NULL, NULL, 'mcq', 44, 2.00, 'https://picsum.photos/seed/brainixa-q-9044/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9045, NULL, 1, 901, NULL, NULL, 'mcq', 45, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9046, NULL, 1, 901, NULL, NULL, 'mcq', 46, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9047, NULL, 1, 901, NULL, NULL, 'true_false', 47, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9048, NULL, 1, 901, NULL, NULL, 'written', 48, 5.00, 'https://picsum.photos/seed/brainixa-q-9048/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9049, NULL, 1, 901, NULL, NULL, 'mcq', 49, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9050, NULL, 1, 901, NULL, NULL, 'mcq', 50, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9051, NULL, 1, 901, NULL, NULL, 'mcq', 51, 2.00, NULL, 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9052, NULL, 1, 901, NULL, NULL, 'true_false', 52, 1.00, 'https://picsum.photos/seed/brainixa-q-9052/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9053, NULL, 1, 901, NULL, NULL, 'written', 53, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9054, NULL, 1, 901, NULL, NULL, 'mcq', 54, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9055, NULL, 1, 901, NULL, NULL, 'mcq', 55, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9056, NULL, 1, 901, NULL, NULL, 'true_false', 56, 1.00, 'https://picsum.photos/seed/brainixa-q-9056/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9057, NULL, 1, 901, NULL, NULL, 'mcq', 57, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9058, NULL, 1, 901, NULL, NULL, 'written', 58, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9059, NULL, 1, 901, NULL, NULL, 'true_false', 59, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9060, NULL, 1, 901, NULL, NULL, 'mcq', 60, 2.00, 'https://picsum.photos/seed/brainixa-q-9060/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9061, NULL, 1, 901, NULL, NULL, 'mcq', 61, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9062, NULL, 1, 901, NULL, NULL, 'mcq', 62, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9063, NULL, 1, 901, NULL, NULL, 'mcq', 63, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9064, NULL, 1, 901, NULL, NULL, 'true_false', 64, 1.00, 'https://picsum.photos/seed/brainixa-q-9064/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9065, NULL, 1, 901, NULL, NULL, 'true_false', 65, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9066, NULL, 1, 901, NULL, NULL, 'true_false', 66, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9067, NULL, 1, 901, NULL, NULL, 'mcq', 67, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9068, NULL, 1, 901, NULL, NULL, 'mcq', 68, 2.00, 'https://picsum.photos/seed/brainixa-q-9068/480/280', 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9069, NULL, 1, 901, NULL, NULL, 'true_false', 69, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9070, NULL, 1, 901, NULL, NULL, 'written', 70, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9071, NULL, 1, 901, NULL, NULL, 'written', 71, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9072, NULL, 1, 901, NULL, NULL, 'mcq', 72, 2.00, 'https://picsum.photos/seed/brainixa-q-9072/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9073, NULL, 1, 901, NULL, NULL, 'mcq', 73, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9074, NULL, 1, 901, NULL, NULL, 'true_false', 74, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9075, NULL, 1, 901, NULL, NULL, 'mcq', 75, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9076, NULL, 1, 901, NULL, NULL, 'mcq', 76, 2.00, 'https://picsum.photos/seed/brainixa-q-9076/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9077, NULL, 1, 901, NULL, NULL, 'mcq', 77, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9078, NULL, 1, 901, NULL, NULL, 'mcq', 78, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9079, NULL, 1, 901, NULL, NULL, 'written', 79, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9080, NULL, 1, 901, NULL, NULL, 'mcq', 80, 2.00, 'https://picsum.photos/seed/brainixa-q-9080/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9081, NULL, 1, 901, NULL, NULL, 'written', 81, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9082, NULL, 1, 901, NULL, NULL, 'mcq', 82, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9083, NULL, 1, 901, NULL, NULL, 'mcq', 83, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9084, NULL, 1, 901, NULL, NULL, 'mcq', 84, 2.00, 'https://picsum.photos/seed/brainixa-q-9084/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9085, NULL, 1, 901, NULL, NULL, 'mcq', 85, 2.00, NULL, 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9086, NULL, 1, 902, NULL, NULL, 'true_false', 1, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9087, NULL, 1, 902, NULL, NULL, 'true_false', 2, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9088, NULL, 1, 902, NULL, NULL, 'true_false', 3, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9089, NULL, 1, 902, NULL, NULL, 'mcq', 4, 2.00, 'https://picsum.photos/seed/brainixa-q-9089/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9090, NULL, 1, 902, NULL, NULL, 'true_false', 5, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9091, NULL, 1, 902, NULL, NULL, 'true_false', 6, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9092, NULL, 1, 902, NULL, NULL, 'mcq', 7, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9093, NULL, 1, 902, NULL, NULL, 'true_false', 8, 1.00, 'https://picsum.photos/seed/brainixa-q-9093/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9094, NULL, 1, 902, NULL, NULL, 'mcq', 9, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9095, NULL, 1, 902, NULL, NULL, 'mcq', 10, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9096, NULL, 1, 902, NULL, NULL, 'true_false', 11, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9097, NULL, 1, 902, NULL, NULL, 'true_false', 12, 1.00, 'https://picsum.photos/seed/brainixa-q-9097/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9098, NULL, 1, 902, NULL, NULL, 'true_false', 13, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9099, NULL, 1, 902, NULL, NULL, 'true_false', 14, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9100, NULL, 1, 903, NULL, NULL, 'mcq', 1, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9101, NULL, 1, 903, NULL, NULL, 'true_false', 2, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9102, NULL, 1, 903, NULL, NULL, 'true_false', 3, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9103, NULL, 1, 903, NULL, NULL, 'true_false', 4, 1.00, 'https://picsum.photos/seed/brainixa-q-9103/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9104, NULL, 1, 903, NULL, NULL, 'mcq', 5, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9105, NULL, 1, 903, NULL, NULL, 'mcq', 6, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9106, NULL, 1, 903, NULL, NULL, 'true_false', 7, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9107, NULL, 1, 903, NULL, NULL, 'mcq', 8, 2.00, 'https://picsum.photos/seed/brainixa-q-9107/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9108, NULL, 1, 903, NULL, NULL, 'mcq', 9, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9109, NULL, 1, 903, NULL, NULL, 'true_false', 10, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9110, NULL, 1, 903, NULL, NULL, 'mcq', 11, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 2),
(9111, NULL, 1, 904, NULL, NULL, 'mcq', 1, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9112, NULL, 1, 904, NULL, NULL, 'mcq', 2, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9113, NULL, 1, 904, NULL, NULL, 'written', 3, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9114, NULL, 1, 904, NULL, NULL, 'mcq', 4, 2.00, 'https://picsum.photos/seed/brainixa-q-9114/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9115, NULL, 1, 904, NULL, NULL, 'written', 5, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9116, NULL, 1, 904, NULL, NULL, 'written', 6, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9117, NULL, 1, 904, NULL, NULL, 'written', 7, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9118, NULL, 1, 904, NULL, NULL, 'written', 8, 5.00, 'https://picsum.photos/seed/brainixa-q-9118/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9119, NULL, 1, 904, NULL, NULL, 'mcq', 9, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9120, NULL, 1, 904, NULL, NULL, 'written', 10, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9121, NULL, 1, 904, NULL, NULL, 'written', 11, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9122, NULL, 1, 904, NULL, NULL, 'mcq', 12, 2.00, 'https://picsum.photos/seed/brainixa-q-9122/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9123, NULL, 1, 904, NULL, NULL, 'mcq', 13, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9124, NULL, 1, 904, NULL, NULL, 'mcq', 14, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9125, NULL, 1, 904, NULL, NULL, 'written', 15, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9126, NULL, 1, 904, NULL, NULL, 'written', 16, 5.00, 'https://picsum.photos/seed/brainixa-q-9126/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9127, NULL, 1, 904, NULL, NULL, 'mcq', 17, 2.00, NULL, 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9128, NULL, 1, 904, NULL, NULL, 'written', 18, 5.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9129, NULL, 1, 905, NULL, NULL, 'mcq', 1, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9130, NULL, 1, 905, NULL, NULL, 'mcq', 2, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9131, NULL, 1, 905, NULL, NULL, 'true_false', 3, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9132, NULL, 1, 905, NULL, NULL, 'true_false', 4, 1.00, 'https://picsum.photos/seed/brainixa-q-9132/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9133, NULL, 1, 905, NULL, NULL, 'true_false', 5, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9134, NULL, 1, 905, NULL, NULL, 'true_false', 6, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9135, NULL, 1, 905, NULL, NULL, 'mcq', 7, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9136, NULL, 1, 905, NULL, NULL, 'mcq', 8, 2.00, 'https://picsum.photos/seed/brainixa-q-9136/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9137, NULL, 1, 905, NULL, NULL, 'mcq', 9, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9138, NULL, 1, 905, NULL, NULL, 'mcq', 10, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9139, NULL, 1, 905, NULL, NULL, 'mcq', 11, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9140, NULL, 1, 905, NULL, NULL, 'mcq', 12, 2.00, 'https://picsum.photos/seed/brainixa-q-9140/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9141, NULL, 1, 905, NULL, NULL, 'mcq', 13, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9142, NULL, 1, 905, NULL, NULL, 'true_false', 14, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9143, NULL, 1, 905, NULL, NULL, 'true_false', 15, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9144, NULL, 1, 905, NULL, NULL, 'mcq', 16, 2.00, 'https://picsum.photos/seed/brainixa-q-9144/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9145, NULL, 1, 905, NULL, NULL, 'mcq', 17, 2.00, NULL, 0, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9146, NULL, 1, 905, NULL, NULL, 'true_false', 18, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9147, NULL, 1, 905, NULL, NULL, 'true_false', 19, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9148, NULL, 1, 905, NULL, NULL, 'mcq', 20, 2.00, 'https://picsum.photos/seed/brainixa-q-9148/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 1),
(9149, NULL, 1, 906, NULL, NULL, 'mcq', 1, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9150, NULL, 1, 906, NULL, NULL, 'mcq', 2, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9151, NULL, 1, 906, NULL, NULL, 'mcq', 3, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9152, NULL, 1, 906, NULL, NULL, 'mcq', 4, 2.00, 'https://picsum.photos/seed/brainixa-q-9152/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9153, NULL, 1, 906, NULL, NULL, 'mcq', 5, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9154, NULL, 1, 906, NULL, NULL, 'mcq', 6, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9155, NULL, 1, 906, NULL, NULL, 'mcq', 7, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9156, NULL, 1, 906, NULL, NULL, 'mcq', 8, 2.00, 'https://picsum.photos/seed/brainixa-q-9156/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9157, NULL, 1, 906, NULL, NULL, 'mcq', 9, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9158, NULL, 1, 906, NULL, NULL, 'mcq', 10, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9159, NULL, 1, 906, NULL, NULL, 'mcq', 11, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9160, NULL, 1, 906, NULL, NULL, 'mcq', 12, 2.00, 'https://picsum.photos/seed/brainixa-q-9160/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9161, NULL, 1, 906, NULL, NULL, 'mcq', 13, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'teacher', 3),
(9162, NULL, 1, 907, NULL, NULL, 'true_false', 1, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9163, NULL, 1, 907, NULL, NULL, 'mcq', 2, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9164, NULL, 1, 907, NULL, NULL, 'mcq', 3, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9165, NULL, 1, 907, NULL, NULL, 'true_false', 4, 1.00, 'https://picsum.photos/seed/brainixa-q-9165/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9166, NULL, 1, 907, NULL, NULL, 'true_false', 5, 1.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9167, NULL, 1, 907, NULL, NULL, 'mcq', 6, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9168, NULL, 1, 907, NULL, NULL, 'mcq', 7, 2.00, NULL, 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(9169, NULL, 1, 907, NULL, NULL, 'true_false', 8, 1.00, 'https://picsum.photos/seed/brainixa-q-9169/480/280', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12', NULL, 'admin', 1),
(41951, 1972, 0, NULL, 512, 4399, 'mcq', 1, 1.00, NULL, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', 1, 'admin', 1),
(41952, 1972, 0, NULL, 512, 4399, 'true_false', 2, 1.00, NULL, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', 1, 'admin', 1),
(41953, 1972, 0, NULL, 512, 4399, 'written', 3, 2.00, NULL, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30', 1, 'admin', 1),
(41954, 1974, 0, NULL, 512, NULL, 'mcq', 1, 1.00, NULL, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30', 1, 'admin', 1),
(41955, 1974, 0, NULL, 512, NULL, 'true_false', 2, 1.00, NULL, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30', 1, 'admin', 1),
(41956, 1975, 0, NULL, 513, NULL, 'mcq', 1, 1.00, NULL, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30', 1, 'admin', 1),
(41957, 1975, 0, NULL, 513, NULL, 'true_false', 2, 1.00, NULL, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30', 1, 'admin', 1);

-- --------------------------------------------------------

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
-- Dumping data for table `questions_translations`
--

INSERT INTO `questions_translations` (`id`, `question_id`, `language_id`, `question_text`, `is_active`, `created_at`, `updated_at`) VALUES
(86509, 9001, 1, 'حل المعادلة: 3 س + 10 =52 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:58:42'),
(86510, 9001, 2, 'حل المعادلة: 3 س + 10 =52 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:59:49'),
(86511, 9002, 1, 'ما ناتج 19 + 4 × 4 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86512, 9002, 2, 'What is 19 + 4 x 4 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86513, 9003, 1, 'ما ناتج 2 + 2 × 2 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86514, 9003, 2, 'What is 2 + 2 x 2 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86515, 9004, 1, 'ما ناتج 18 + 10 × 7 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86516, 9004, 2, 'What is 18 + 10 x 7 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86517, 9005, 1, 'اشرح خطوات حل معادلة من الدرجة الأولى في متغير واحد، مع مثال.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86518, 9005, 2, 'Explain how to solve a first-degree equation in one variable, with an example.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86519, 9006, 1, 'ما ناتج 6 + 7 × 3 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86520, 9006, 2, 'What is 6 + 7 x 3 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86521, 9007, 1, 'ناتج 36 + 34 يساوي 67.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86522, 9007, 2, '36 + 34 equals 67.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86523, 9008, 1, 'احسب ذهنيًا: 32 × 63', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86524, 9008, 2, 'Mental maths: 32 x 63', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86525, 9009, 1, 'ما ناتج 8 + 6 × 8 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86526, 9009, 2, 'What is 8 + 6 x 8 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86527, 9010, 1, 'حل المعادلة: 9 س + 23 = 149 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86528, 9010, 2, 'Solve 9x + 23 = 149. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86529, 9011, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 12 س + 40 = 232 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86530, 9011, 2, 'Explain step by step how to solve 12x + 40 = 232, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86531, 9012, 1, 'اشرح كيف تحسب النسبة المئوية لعدد، مع مثال من الحياة اليومية.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86532, 9012, 2, 'Explain how to compute a percentage of a number, with a real-life example.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86533, 9013, 1, 'ناتج 55 + 48 يساوي 103.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86534, 9013, 2, '55 + 48 equals 103.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86535, 9014, 1, 'احسب ذهنيًا: 97 × 70', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86536, 9014, 2, 'Mental maths: 97 x 70', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86537, 9015, 1, 'ناتج 13 + 45 يساوي 58.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86538, 9015, 2, '13 + 45 equals 58.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86539, 9016, 1, 'حل المعادلة: 8 س + 14 = 30 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86540, 9016, 2, 'Solve 8x + 14 = 30. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86541, 9017, 1, 'ما ناتج 9 + 7 × 3 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86542, 9017, 2, 'What is 9 + 7 x 3 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86543, 9018, 1, 'ناتج 44 + 43 يساوي 87.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86544, 9018, 2, '44 + 43 equals 87.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86545, 9019, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 6 س + 4 = 124 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86546, 9019, 2, 'Explain step by step how to solve 6x + 4 = 124, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86547, 9020, 1, 'ما ناتج 16 + 9 × 5 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86548, 9020, 2, 'What is 16 + 9 x 5 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86549, 9021, 1, 'ما ناتج 19 + 7 × 2 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86550, 9021, 2, 'What is 19 + 7 x 2 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86551, 9022, 1, 'ما ناتج 3 + 10 × 2 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86552, 9022, 2, 'What is 3 + 10 x 2 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86553, 9023, 1, 'حل المعادلة: 4 س + 17 = 53 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86554, 9023, 2, 'Solve 4x + 17 = 53. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86555, 9024, 1, 'ناتج 54 + 20 يساوي 74.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86556, 9024, 2, '54 + 20 equals 74.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86557, 9025, 1, 'ناتج 40 + 29 يساوي 68.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86558, 9025, 2, '40 + 29 equals 68.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86559, 9026, 1, 'اشرح الفرق بين المساحة والمحيط مع مثال على المستطيل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86560, 9026, 2, 'Explain the difference between area and perimeter, with a rectangle example.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86561, 9027, 1, 'حل المعادلة: 6 س + 17 = 125 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86562, 9027, 2, 'Solve 6x + 17 = 125. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86563, 9028, 1, 'حل المعادلة: 9 س + 25 = 178 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86564, 9028, 2, 'Solve 9x + 25 = 178. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86565, 9029, 1, 'أثبت أن مجموع أي عددين فرديين هو عدد زوجي.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86566, 9029, 2, 'Prove that the sum of any two odd numbers is even.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86567, 9030, 1, 'احسب ذهنيًا: 52 × 57', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86568, 9030, 2, 'Mental maths: 52 x 57', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86569, 9031, 1, 'ناتج 28 + 39 يساوي 67.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86570, 9031, 2, '28 + 39 equals 67.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86571, 9032, 1, 'ما ناتج 9 + 8 × 6 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86572, 9032, 2, 'What is 9 + 8 x 6 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86573, 9033, 1, 'ما ناتج 8 + 12 × 8 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86574, 9033, 2, 'What is 8 + 12 x 8 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86575, 9034, 1, 'حل المعادلة: 4 س + 3 = 43 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86576, 9034, 2, 'Solve 4x + 3 = 43. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86577, 9035, 1, 'ما ناتج 19 + 12 × 9 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86578, 9035, 2, 'What is 19 + 12 x 9 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86579, 9036, 1, 'حل المعادلة: 3 س + 18 = 39 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86580, 9036, 2, 'Solve 3x + 18 = 39. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86581, 9037, 1, 'حل المعادلة: 9 س + 28 = 190 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86582, 9037, 2, 'Solve 9x + 28 = 190. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86583, 9038, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 9 س + 3 = 48 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86584, 9038, 2, 'Explain step by step how to solve 9x + 3 = 48, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86585, 9039, 1, 'احسب ذهنيًا: 51 × 21', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86586, 9039, 2, 'Mental maths: 51 x 21', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86587, 9040, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 9 س + 18 = 126 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86588, 9040, 2, 'Explain step by step how to solve 9x + 18 = 126, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86589, 9041, 1, 'ما ناتج 14 + 6 × 3 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86590, 9041, 2, 'What is 14 + 6 x 3 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86591, 9042, 1, 'احسب ذهنيًا: 20 × 11', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86592, 9042, 2, 'Mental maths: 20 x 11', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86593, 9043, 1, 'احسب ذهنيًا: 26 × 13', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86594, 9043, 2, 'Mental maths: 26 x 13', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86595, 9044, 1, 'احسب ذهنيًا: 42 × 46', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86596, 9044, 2, 'Mental maths: 42 x 46', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86597, 9045, 1, 'ما ناتج 8 + 2 × 3 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86598, 9045, 2, 'What is 8 + 2 x 3 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86599, 9046, 1, 'ما ناتج 7 + 11 × 2 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86600, 9046, 2, 'What is 7 + 11 x 2 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86601, 9047, 1, 'ناتج 39 + 28 يساوي 70.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86602, 9047, 2, '39 + 28 equals 70.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86603, 9048, 1, 'متى يكون الكسر أكبر من واحد صحيح؟ اشرح مع مثالين.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86604, 9048, 2, 'When is a fraction greater than one? Explain with two examples.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86605, 9049, 1, 'حل المعادلة: 8 س + 9 = 161 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86606, 9049, 2, 'Solve 8x + 9 = 161. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86607, 9050, 1, 'احسب ذهنيًا: 65 × 22', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86608, 9050, 2, 'Mental maths: 65 x 22', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86609, 9051, 1, 'احسب ذهنيًا: 28 × 52', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86610, 9051, 2, 'Mental maths: 28 x 52', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86611, 9052, 1, 'ناتج 37 + 56 يساوي 91.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86612, 9052, 2, '37 + 56 equals 91.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86613, 9053, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 3 س + 24 = 75 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86614, 9053, 2, 'Explain step by step how to solve 3x + 24 = 75, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86615, 9054, 1, 'احسب ذهنيًا: 23 × 12', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86616, 9054, 2, 'Mental maths: 23 x 12', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86617, 9055, 1, 'احسب ذهنيًا: 38 × 40', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86618, 9055, 2, 'Mental maths: 38 x 40', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86619, 9056, 1, 'ناتج 31 + 53 يساوي 83.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86620, 9056, 2, '31 + 53 equals 83.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86621, 9057, 1, 'حل المعادلة: 6 س + 2 = 26 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86622, 9057, 2, 'Solve 6x + 2 = 26. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86623, 9058, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 8 س + 28 = 68 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86624, 9058, 2, 'Explain step by step how to solve 8x + 28 = 68, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86625, 9059, 1, 'ناتج 14 + 16 يساوي 30.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86626, 9059, 2, '14 + 16 equals 30.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86627, 9060, 1, 'احسب ذهنيًا: 20 × 41', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86628, 9060, 2, 'Mental maths: 20 x 41', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86629, 9061, 1, 'ما ناتج 2 + 12 × 4 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86630, 9061, 2, 'What is 2 + 12 x 4 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86631, 9062, 1, 'احسب ذهنيًا: 92 × 93', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86632, 9062, 2, 'Mental maths: 92 x 93', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86633, 9063, 1, 'احسب ذهنيًا: 41 × 71', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86634, 9063, 2, 'Mental maths: 41 x 71', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86635, 9064, 1, 'ناتج 12 + 12 يساوي 21.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86636, 9064, 2, '12 + 12 equals 21.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86637, 9065, 1, 'ناتج 32 + 23 يساوي 55.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86638, 9065, 2, '32 + 23 equals 55.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86639, 9066, 1, 'ناتج 30 + 32 يساوي 62.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86640, 9066, 2, '30 + 32 equals 62.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86641, 9067, 1, 'حل المعادلة: 4 س + 18 = 26 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86642, 9067, 2, 'Solve 4x + 18 = 26. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86643, 9068, 1, 'ما ناتج 16 + 10 × 9 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86644, 9068, 2, 'What is 16 + 10 x 9 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86645, 9069, 1, 'ناتج 38 + 52 يساوي 90.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86646, 9069, 2, '38 + 52 equals 90.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86647, 9070, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 6 س + 18 = 96 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86648, 9070, 2, 'Explain step by step how to solve 6x + 18 = 96, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86649, 9071, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 8 س + 32 = 136 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86650, 9071, 2, 'Explain step by step how to solve 8x + 32 = 136, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86651, 9072, 1, 'حل المعادلة: 9 س + 15 = 69 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86652, 9072, 2, 'Solve 9x + 15 = 69. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86653, 9073, 1, 'احسب ذهنيًا: 66 × 67', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86654, 9073, 2, 'Mental maths: 66 x 67', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86655, 9074, 1, 'ناتج 50 + 13 يساوي 63.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86656, 9074, 2, '50 + 13 equals 63.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86657, 9075, 1, 'احسب ذهنيًا: 66 × 99', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86658, 9075, 2, 'Mental maths: 66 x 99', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86659, 9076, 1, 'ما ناتج 7 + 11 × 9 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86660, 9076, 2, 'What is 7 + 11 x 9 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86661, 9077, 1, 'حل المعادلة: 4 س + 28 = 88 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86662, 9077, 2, 'Solve 4x + 28 = 88. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86663, 9078, 1, 'ما ناتج 2 + 8 × 7 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86664, 9078, 2, 'What is 2 + 8 x 7 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86665, 9079, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 2 س + 33 = 37 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86666, 9079, 2, 'Explain step by step how to solve 2x + 33 = 37, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86667, 9080, 1, 'ما ناتج 14 + 8 × 3 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86668, 9080, 2, 'What is 14 + 8 x 3 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86669, 9081, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 11 س + 12 = 45 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86670, 9081, 2, 'Explain step by step how to solve 11x + 12 = 45, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86671, 9082, 1, 'حل المعادلة: 4 س + 5 = 45 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86672, 9082, 2, 'Solve 4x + 5 = 45. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86673, 9083, 1, 'احسب ذهنيًا: 39 × 42', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86674, 9083, 2, 'Mental maths: 39 x 42', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86675, 9084, 1, 'حل المعادلة: 5 س + 13 = 38 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86676, 9084, 2, 'Solve 5x + 13 = 38. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86677, 9085, 1, 'حل المعادلة: 2 س + 20 = 60 ، فما قيمة س ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86678, 9085, 2, 'Solve 2x + 20 = 60. What is x ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86679, 9086, 1, 'مجموع زوايا المثلث يساوي 180 درجة.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86680, 9086, 2, 'The angles of a triangle add up to 180 degrees.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86681, 9087, 1, 'مساحة مربع طول ضلعه 19 سم تساوي 361 سم².', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86682, 9087, 2, 'The area of a square of side 19 cm is 361 cm^2.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86683, 9088, 1, 'مساحة مربع طول ضلعه 14 سم تساوي 196 سم².', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86684, 9088, 2, 'The area of a square of side 14 cm is 196 cm^2.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86685, 9089, 1, 'ما قانون محيط الدائرة؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86686, 9089, 2, 'Formula for the circumference of a circle?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86687, 9090, 1, 'محيط مربع طول ضلعه 7 سم يساوي 28 سم.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86688, 9090, 2, 'The perimeter of a square of side 7 cm is 28 cm.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86689, 9091, 1, 'مساحة مربع طول ضلعه 18 سم تساوي 324 سم².', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86690, 9091, 2, 'The area of a square of side 18 cm is 324 cm^2.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86691, 9092, 1, 'ما قانون مساحة المستطيل؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86692, 9092, 2, 'Formula for the area of a rectangle?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86693, 9093, 1, 'محيط مربع طول ضلعه 17 سم يساوي 68 سم.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86694, 9093, 2, 'The perimeter of a square of side 17 cm is 68 cm.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86695, 9094, 1, 'ما عدد أضلاع الشكل السداسي؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86696, 9094, 2, 'How many sides does a hexagon have?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86697, 9095, 1, 'كم مجموع قياسات زوايا الشكل الرباعي؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86698, 9095, 2, 'Sum of the interior angles of a quadrilateral?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86699, 9096, 1, 'محيط مربع طول ضلعه 4 سم يساوي 16 سم.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86700, 9096, 2, 'The perimeter of a square of side 4 cm is 16 cm.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86701, 9097, 1, 'محيط مربع طول ضلعه 13 سم يساوي 52 سم.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86702, 9097, 2, 'The perimeter of a square of side 13 cm is 52 cm.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86703, 9098, 1, 'محيط مربع طول ضلعه 8 سم يساوي 64 سم.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86704, 9098, 2, 'The perimeter of a square of side 8 cm is 64 cm.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86705, 9099, 1, 'مساحة مربع طول ضلعه 16 سم تساوي 256 سم².', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86706, 9099, 2, 'The area of a square of side 16 cm is 256 cm^2.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86707, 9100, 1, 'ما إعراب كلمة «المدرسةِ» في جملة: ذهبتُ إلى المدرسةِ ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86708, 9100, 2, 'What is the grammatical role of \"المدرسةِ\" in: ذهبتُ إلى المدرسةِ ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86709, 9101, 1, 'المفعول به دائمًا مرفوع.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86710, 9101, 2, 'The object is always nominative.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86711, 9102, 1, 'اسم إنَّ منصوب وخبرها مرفوع.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86712, 9102, 2, 'The noun of inna is accusative and its predicate nominative.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86713, 9103, 1, 'جمع المذكر السالم يُرفع بالواو.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86714, 9103, 2, 'The sound masculine plural takes waw in the nominative.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86715, 9104, 1, 'ما إعراب كلمة «الكتابَ» في جملة: قرأ محمدٌ الكتابَ ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86716, 9104, 2, 'What is the grammatical role of \"الكتابَ\" in: قرأ محمدٌ الكتابَ ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86717, 9105, 1, 'ما إعراب كلمة «الطالبُ» في جملة: نجح الطالبُ ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86718, 9105, 2, 'What is the grammatical role of \"الطالبُ\" in: نجح الطالبُ ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86719, 9106, 1, 'الفاعل دائمًا مرفوع.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86720, 9106, 2, 'The subject (fail) is always nominative.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86721, 9107, 1, 'ما إعراب كلمة «العلمَ» في جملة: إنَّ العلمَ نورٌ ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86722, 9107, 2, 'What is the grammatical role of \"العلمَ\" in: إنَّ العلمَ نورٌ ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86723, 9108, 1, 'ما إعراب كلمة «السماءُ» في جملة: السماءُ صافيةٌ ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86724, 9108, 2, 'What is the grammatical role of \"السماءُ\" in: السماءُ صافيةٌ ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86725, 9109, 1, 'الاسم بعد حرف الجر يكون منصوبًا.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86726, 9109, 2, 'A noun after a preposition is accusative.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86727, 9110, 1, 'ما إعراب كلمة «جميلًا» في جملة: كان الجوُّ جميلًا ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86728, 9110, 2, 'What is the grammatical role of \"جميلًا\" in: كان الجوُّ جميلًا ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86729, 9111, 1, 'إذا كان س + ص = 24 و س − ص = 6 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86730, 9111, 2, 'If x + y = 24 and x - y = 6, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86731, 9112, 1, 'إذا كان س + ص = 19 و س − ص = 9 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86732, 9112, 2, 'If x + y = 19 and x - y = 9, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86733, 9113, 1, 'اشرح خطوات حل معادلة من الدرجة الأولى في متغير واحد، مع مثال.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86734, 9113, 2, 'Explain how to solve a first-degree equation in one variable, with an example.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86735, 9114, 1, 'إذا كان س + ص = 19 و س − ص = 1 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86736, 9114, 2, 'If x + y = 19 and x - y = 1, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86737, 9115, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 8 س + 34 = 162 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86738, 9115, 2, 'Explain step by step how to solve 8x + 34 = 162, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86739, 9116, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 4 س + 35 = 95 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86740, 9116, 2, 'Explain step by step how to solve 4x + 35 = 95, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86741, 9117, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 4 س + 24 = 100 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86742, 9117, 2, 'Explain step by step how to solve 4x + 24 = 100, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86743, 9118, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 12 س + 19 = 55 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86744, 9118, 2, 'Explain step by step how to solve 12x + 19 = 55, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86745, 9119, 1, 'إذا كان س + ص = 5 و س − ص = -1 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86746, 9119, 2, 'If x + y = 5 and x - y = -1, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86747, 9120, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 3 س + 40 = 64 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86748, 9120, 2, 'Explain step by step how to solve 3x + 40 = 64, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86749, 9121, 1, 'اشرح كيف تحسب النسبة المئوية لعدد، مع مثال من الحياة اليومية.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86750, 9121, 2, 'Explain how to compute a percentage of a number, with a real-life example.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86751, 9122, 1, 'إذا كان س + ص = 20 و س − ص = -8 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86752, 9122, 2, 'If x + y = 20 and x - y = -8, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86753, 9123, 1, 'إذا كان س + ص = 14 و س − ص = -4 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86754, 9123, 2, 'If x + y = 14 and x - y = -4, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86755, 9124, 1, 'إذا كان س + ص = 9 و س − ص = -5 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86756, 9124, 2, 'If x + y = 9 and x - y = -5, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86757, 9125, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 7 س + 20 = 104 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86758, 9125, 2, 'Explain step by step how to solve 7x + 20 = 104, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86759, 9126, 1, 'متى يكون الكسر أكبر من واحد صحيح؟ اشرح مع مثالين.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86760, 9126, 2, 'When is a fraction greater than one? Explain with two examples.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86761, 9127, 1, 'إذا كان س + ص = 18 و س − ص = 6 ، فما قيمة س × ص ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86762, 9127, 2, 'If x + y = 18 and x - y = 6, what is x * y ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86763, 9128, 1, 'اشرح خطوة بخطوة كيف تحل المعادلة 7 س + 36 = 71 ، ثم تحقق من صحة الحل.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86764, 9128, 2, 'Explain step by step how to solve 7x + 36 = 71, then verify your answer.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86765, 9129, 1, 'كم يساوي 10% من 300 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86766, 9129, 2, 'What is 10% of 300 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86767, 9130, 1, 'كم يساوي 25% من 400 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86768, 9130, 2, 'What is 25% of 400 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86769, 9131, 1, '10% من 80 تساوي 3.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86770, 9131, 2, '10% of 80 is 3.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86771, 9132, 1, '20% من 300 تساوي 65.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86772, 9132, 2, '20% of 300 is 65.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86773, 9133, 1, '25% من 300 تساوي 75.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86774, 9133, 2, '25% of 300 is 75.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86775, 9134, 1, '50% من 80 تساوي 30.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86776, 9134, 2, '50% of 80 is 30.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86777, 9135, 1, 'كم يساوي 30% من 80 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86778, 9135, 2, 'What is 30% of 80 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86779, 9136, 1, 'كم يساوي 15% من 120 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86780, 9136, 2, 'What is 15% of 120 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86781, 9137, 1, 'كم يساوي 60% من 800 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86782, 9137, 2, 'What is 60% of 800 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86783, 9138, 1, 'كم يساوي 50% من 240 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86784, 9138, 2, 'What is 50% of 240 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86785, 9139, 1, 'ما ناتج 5/6 + 4/5 في أبسط صورة؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86786, 9139, 2, 'What is 5/6 + 4/5 in simplest form?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86787, 9140, 1, 'كم يساوي 20% من 300 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86788, 9140, 2, 'What is 20% of 300 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86789, 9141, 1, 'كم يساوي 25% من 500 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86790, 9141, 2, 'What is 25% of 500 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86791, 9142, 1, '50% من 80 تساوي 35.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86792, 9142, 2, '50% of 80 is 35.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86793, 9143, 1, '50% من 80 تساوي 40.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86794, 9143, 2, '50% of 80 is 40.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86795, 9144, 1, 'كم يساوي 15% من 500 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86796, 9144, 2, 'What is 15% of 500 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86797, 9145, 1, 'كم يساوي 30% من 200 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86798, 9145, 2, 'What is 30% of 200 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86799, 9146, 1, '25% من 120 تساوي 35.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86800, 9146, 2, '25% of 120 is 35.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86801, 9147, 1, '50% من 200 تساوي 100.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86802, 9147, 2, '50% of 200 is 100.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86803, 9148, 1, 'كم يساوي 50% من 400 ؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86804, 9148, 2, 'What is 50% of 400 ?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86805, 9149, 1, 'اختر الإجابة الصحيحة: We are waiting ____ the bus.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86806, 9149, 2, 'Choose the correct answer: We are waiting ____ the bus.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86807, 9150, 1, 'اختر المرادف لكلمة \"happy\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86808, 9150, 2, 'Choose the synonym of \"happy\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86809, 9151, 1, 'اختر الإجابة الصحيحة: They ____ playing football now.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86810, 9151, 2, 'Choose the correct answer: They ____ playing football now.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86811, 9152, 1, 'اختر الإجابة الصحيحة: This book is ____ than that one.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86812, 9152, 2, 'Choose the correct answer: This book is ____ than that one.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86813, 9153, 1, 'اختر الإجابة الصحيحة: He ____ his homework yesterday.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86814, 9153, 2, 'Choose the correct answer: He ____ his homework yesterday.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86815, 9154, 1, 'اختر الإجابة الصحيحة: I have ____ apple in my bag.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86816, 9154, 2, 'Choose the correct answer: I have ____ apple in my bag.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86817, 9155, 1, 'اختر المرادف لكلمة \"begin\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86818, 9155, 2, 'Choose the synonym of \"begin\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86819, 9156, 1, 'اختر الإجابة الصحيحة: She ____ to school every day.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86820, 9156, 2, 'Choose the correct answer: She ____ to school every day.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86821, 9157, 1, 'اختر الإجابة الصحيحة: If it rains, we ____ stay home.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86822, 9157, 2, 'Choose the correct answer: If it rains, we ____ stay home.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86823, 9158, 1, 'اختر المرادف لكلمة \"difficult\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86824, 9158, 2, 'Choose the synonym of \"difficult\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86825, 9159, 1, 'اختر المرادف لكلمة \"smart\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86826, 9159, 2, 'Choose the synonym of \"smart\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86827, 9160, 1, 'اختر المرادف لكلمة \"big\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86828, 9160, 2, 'Choose the synonym of \"big\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86829, 9161, 1, 'اختر المرادف لكلمة \"fast\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86830, 9161, 2, 'Choose the synonym of \"fast\":', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86831, 9162, 1, 'القمر يصدر ضوءه بنفسه.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86832, 9162, 2, 'The Moon produces its own light.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86833, 9163, 1, 'ما الرمز الكيميائي للماء؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86834, 9163, 2, 'Chemical symbol for water?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86835, 9164, 1, 'كم عدد كواكب المجموعة الشمسية؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86836, 9164, 2, 'How many planets are in the solar system?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86837, 9165, 1, 'الأكسجين ضروري لتنفس الإنسان.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86838, 9165, 2, 'Oxygen is necessary for human respiration.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86839, 9166, 1, 'الشمس كوكب وليست نجمًا.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86840, 9166, 2, 'The Sun is a planet, not a star.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86841, 9167, 1, 'ما أكبر عضو في جسم الإنسان؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86842, 9167, 2, 'What is the largest organ in the human body?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86843, 9168, 1, 'ما الغاز الذي تحتاجه النباتات للبناء الضوئي؟', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86844, 9168, 2, 'Which gas do plants need for photosynthesis?', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86845, 9169, 1, 'الماء يغلي عند 100 درجة مئوية عند الضغط الجوي العادي.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86846, 9169, 2, 'Water boils at 100 C at normal atmospheric pressure.', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(86871, 41951, 1, 'ما ناتج تحليل x² − 5x + 6 ؟', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(86872, 41951, 2, 'Factor x² − 5x + 6.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(86874, 41952, 1, 'مجموع جذري المعادلة أ س² + ب س + جـ = ٠ يساوي (−ب ÷ أ).', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(86875, 41952, 2, 'The sum of the roots of ax² + bx + c = 0 equals (-b / a).', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(86877, 41953, 1, 'اشرح، مع مثال، متى يفشل التحليل في إيجاد جذري معادلة تربيعية.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(86878, 41953, 2, 'Explain, with an example, when factoring a quadratic fails to find its roots.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(86879, 41954, 1, 'أي وحدة تتناول الدائرة المثلثية؟', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86880, 41954, 2, 'Which unit covers the unit circle?', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86882, 41955, 1, 'هذا الكورس يتكوّن من وحدتين بالضبط.', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86883, 41955, 2, 'This course has exactly two units.', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86885, 41956, 1, 'يُحجز موعد الباقة عبر:', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86886, 41956, 2, 'A package appointment is booked through:', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86888, 41957, 1, 'مدّة هذه الباقة التجريبية شهر واحد ثابت.', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(86889, 41957, 2, 'This package has a fixed one-month duration in this demo.', 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30');

-- --------------------------------------------------------

--
-- Table structure for table `question_bank_folders`
--

CREATE TABLE `question_bank_folders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by_type` varchar(80) NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `question_bank_folders`
--

INSERT INTO `question_bank_folders` (`id`, `name`, `description`, `is_active`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`) VALUES
(901, 'رياضيات — جبر', 'فولدر كبير عن قصد لاختبار الترقيم والبحث.', 1, 'admin', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(902, 'رياضيات — هندسة', 'زوايا ومساحات ومحيطات.', 1, 'admin', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(903, 'لغة عربية — نحو', 'إعراب وقواعد.', 1, 'teacher', 2, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(904, 'رياضيات — مسائل صعبة', 'أسئلة تحدٍّ للمتفوقين.', 1, 'teacher', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(905, 'رياضيات — كسور ونسب', 'كسور ونسب مئوية.', 1, 'teacher', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(906, 'لغة إنجليزية — Grammar & Vocabulary', 'Tenses, articles and synonyms.', 1, 'teacher', 3, '2026-10-07 13:33:12', '2026-10-07 13:33:12'),
(907, 'علوم — عام', 'أساسيات العلوم.', 1, 'admin', 1, '2026-10-07 13:33:12', '2026-10-07 13:33:12');

-- --------------------------------------------------------

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
(24, 3, 10, '2026-08-10 16:00:00'),
(25, 1, 141, '2026-10-26 10:02:36'),
(26, 1, 142, '2026-10-27 08:24:47'),
(29, 1, 145, '2026-11-05 12:31:06');

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
-- Dumping data for table `session_attendance`
--

INSERT INTO `session_attendance` (`id`, `session_id`, `student_id`, `session_date`, `status`, `check_in_time`, `check_out_time`, `minutes_late`, `is_excused`, `marked_by_teacher_id`, `marked_at`) VALUES
(1232, 154, 1109, '2026-11-05', 'present', '2026-11-05 12:41:00', NULL, 0, 0, NULL, '2026-11-05 10:41:00');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

--
-- Table structure for table `session_ratings`
--

CREATE TABLE `session_ratings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `occurrence_date` date NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

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

-- --------------------------------------------------------

--
-- Table structure for table `session_zoom_meetings`
--

CREATE TABLE `session_zoom_meetings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `session_date` date NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `meeting_id` varchar(32) NOT NULL,
  `host_user_id` varchar(64) NOT NULL DEFAULT 'me',
  `password` varchar(64) DEFAULT NULL,
  `join_url` text DEFAULT NULL,
  `status` enum('live','ended') NOT NULL DEFAULT 'live',
  `started_at` timestamp NULL DEFAULT current_timestamp(),
  `ended_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `session_zoom_meetings`
--

INSERT INTO `session_zoom_meetings` (`id`, `session_id`, `session_date`, `teacher_id`, `meeting_id`, `host_user_id`, `password`, `join_url`, `status`, `started_at`, `ended_at`) VALUES
(1, 1, '2026-10-28', 1, '87845838917', 'me', '783634', 'https://us06web.zoom.us/j/87845838917?pwd=bgQcswlk8VO9YKO0QKDfuh3h9C7DIr.1', 'live', '2026-10-28 10:39:11', NULL);

-- --------------------------------------------------------

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
(1, 'site_name_ar', 'Brainixa', '2026-08-10 16:00:00', '2026-10-07 12:03:27'),
(2, 'site_name_en', 'Brainixa', '2026-08-10 16:00:00', '2026-10-07 12:03:26'),
(3, 'default_language', 'ar', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(4, 'support_email', 'support@brainixa-demo.com', '2026-08-10 16:00:00', '2026-10-07 11:38:37'),
(5, 'support_phone', '201060044160', '2026-08-10 16:00:00', '2026-10-18 13:38:11'),
(6, 'currency', 'EGP', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(7, 'timezone', 'Africa/Cairo', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(8, 'registration_enabled', '1', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(9, 'maintenance_mode', '0', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(10, 'max_login_attempts', '5', '2026-08-10 16:00:00', '2026-08-10 16:00:00'),
(11, 'hero_badge_text_ar', 'أكثر من 40,000 طالب اختاروا Brainixa', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(12, 'hero_badge_text_en', 'Over 40,000 Students Chose Brainixa', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(13, 'hero_title_ar', 'مستقبلك الدراسي يبدأ من هنا، مع Brainixa', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(14, 'hero_title_en', 'Your Academic Future Starts Here, With Brainixa', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
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
(26, 'stats_courses_count', '+200', '2026-08-10 13:04:43', '2026-10-13 09:59:21'),
(27, 'stats_courses_label_ar', 'كورس تعليمي', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(28, 'stats_courses_label_en', 'Educational Courses', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(29, 'stats_books_count', '+300', '2026-08-10 13:04:43', '2026-10-13 09:59:21'),
(30, 'stats_books_label_ar', 'كتاب ومذكرة', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(31, 'stats_books_label_en', 'Books & Notes', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(32, 'stats_teachers_count', '+10', '2026-08-10 13:04:43', '2026-10-13 09:59:21'),
(35, 'stats_students_count', '+500', '2026-08-10 13:04:43', '2026-10-13 09:59:21'),
(36, 'stats_students_label_ar', 'طالب', '2026-08-10 13:04:43', '2026-10-13 09:59:21'),
(37, 'stats_students_label_en', 'Students', '2026-08-10 13:04:43', '2026-10-13 09:59:21'),
(38, 'about_title_ar', 'من نحن', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(39, 'about_title_en', 'About Us', '2026-08-10 13:04:43', '2026-11-05 08:58:49'),
(40, 'about_description_ar', 'منصة Brainixa التعليمية، وجهتك لتعلّم مستمر بلا حدود. نقدم كورسات مباشرة ومسجلة إلى جانب كتب تعليمية مختارة بعناية، لنكون شريكك من أول خطوة في التعلم وحتّى الإتقان.', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(41, 'about_description_en', 'Brainixa Educational Platform, your destination for continuous learning without limits. We provide live and recorded courses along with carefully selected educational books.', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(42, 'about_stats_courses', '150+', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(43, 'about_stats_books', '40+', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(44, 'about_stats_students', '20,000+', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(45, 'about_mission_title_ar', 'رسالتنا', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(46, 'about_mission_title_en', 'Our Mission', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(47, 'about_mission_text_ar', 'نؤمن أن التعليم الجيد يجب أن يكون متاحاً للجميع، في أي وقت ومن أي مكان. لهذا أسسنا Brainixa لنجمع بين مرونة التعلم عن بعد وجودة المحتوى الموثوق، سواء كنت تفضل حضور بث مباشر، أو مشاهدة كورس مسجل في وقتك الخاص، أو التعمق أكثر عبر كتاب مطبوع يصلك إلى باب بيتك.', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(48, 'about_mission_text_en', 'We believe quality education should be accessible to everyone, anywhere, anytime. That is why we founded Brainixa to blend distant learning flexibility with trusted content quality.', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
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
(77, 'about_cta_title_ar', 'ابدأ رحلتك التعليمية مع Brainixa اليوم', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(78, 'about_cta_title_en', 'Start Your Learning Journey With Brainixa Today', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(79, 'about_cta_subtitle_ar', 'انضم إلى آلاف المتعلمين الذين اختاروا Brainixa لتطوير مهاراتهم', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(80, 'about_cta_subtitle_en', 'Join thousands of learners who chose Brainixa to upgrade their skills', '2026-08-10 13:04:43', '2026-10-07 12:03:26'),
(81, 'footer_description_ar', 'منصة تعليمية شاملة بتساعد الطالب يذاكر ويتابع تقدمه ويحقق أعلى الدرجات.', '2026-08-10 13:04:43', '2026-10-13 11:43:37'),
(82, 'footer_description_en', 'Comprehensive educational platform helping students study, track progress, and achieve top grades.', '2026-08-10 13:04:43', '2026-08-10 15:10:19'),
(83, 'facebook_link', 'https://www.facebook.com/share/1JCezoMk7c/', '2026-08-10 13:04:43', '2026-10-14 10:21:40'),
(84, 'instagram_link', 'https://www.instagram.com/brainixa.academy', '2026-08-10 13:04:43', '2026-10-14 10:21:40'),
(85, 'youtube_link', '', '2026-08-10 13:04:43', '2026-10-14 10:21:40'),
(86, 'whatsapp_number', '201060044160', '2026-08-10 13:04:43', '2026-10-13 11:39:39'),
(4343, 'max_devices_per_student', '1', '2026-09-27 17:54:43', '2026-09-27 17:54:43'),
(4344, 'student_device_limit_enabled', '0', '2026-09-27 17:54:43', '2026-10-14 09:14:44'),
(4345, 'tiktok_link', '', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4346, 'telegram_link', '', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4347, 'maintenance_message_ar', 'المنصة تحت الصيانة حاليًا، برجاء المحاولة بعد قليل.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4348, 'maintenance_message_en', 'The platform is under maintenance. Please try again shortly.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4349, 'registration_disabled_message_ar', 'تسجيل الحسابات الجديدة متوقف حاليًا. برجاء التواصل مع الدعم الفني.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4350, 'registration_disabled_message_en', 'New account registration is currently closed. Please contact support.', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4351, 'login_lockout_enabled', '0', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4352, 'login_lockout_minutes', '15', '2026-09-27 21:46:45', '2026-09-27 21:46:45'),
(4376, 'base_currency', 'EGP', '2026-09-28 10:00:00', '2026-10-07 11:38:37'),
(4377, 'country_pricing_enabled', '1', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4378, 'geoip_lookup_enabled', '1', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4379, 'geoip_provider_url', 'https://ipwho.is/{ip}', '2026-09-28 10:00:00', '2026-09-28 10:00:00'),
(4380, 'default_phone_dial_code', '20', '2026-09-29 09:09:18', '2026-10-07 12:03:27'),
(4381, 'permissions_catalogue_hash', '5d880135a9da93a16ec8170ef7e4a92d', '2026-09-29 11:02:08', '2026-09-30 13:19:36'),
(4382, 'referral_commission_type', 'percent', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4383, 'referral_commission_value', '10', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4384, 'points_redeem_enabled', '1', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4385, 'points_min_redeem', '50', '2026-09-30 07:34:08', '2026-09-30 07:34:08'),
(4395, 'announcement_bar_enabled', '1', '2026-10-03 12:04:29', '2026-10-03 12:04:29'),
(4396, 'announcement_bar_items', '[{\"text_ar\":\"Brainixa AI - Coming Soon\",\"text_en\":\"Brainixa AI - Coming Soon\"},{\"text_ar\":\"Brainixa AI - Coming Soon\",\"text_en\":\"Brainixa AI - Coming Soon\"},{\"text_ar\":\"Brainixa AI - Coming Soon\",\"text_en\":\"Brainixa AI - Coming Soon\"},{\"text_ar\":\"Brainixa AI - Coming Soon\",\"text_en\":\"Brainixa AI - Coming Soon\"}]', '2026-10-03 12:04:29', '2026-10-25 04:56:33'),
(4504, 'stats_teachers_label', 'معلم متخصص', '2026-10-13 10:03:19', '2026-10-13 10:03:19'),
(4505, 'stats_students_label', 'طالب', '2026-10-13 10:03:19', '2026-10-13 10:03:19'),
(4507, 'stats_teachers_label_ar', 'معلم متخصص', '2026-10-13 10:04:50', '2026-10-13 10:04:50'),
(4508, 'stats_teachers_label_en', 'Expert Teachers', '2026-10-13 10:04:50', '2026-10-13 10:04:50'),
(4728, 'promo_offer_enabled', '1', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4729, 'promo_offer_image', 'https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fb950dab8.89379594.jpg', '2026-11-05 12:54:50', '2026-11-05 13:09:03'),
(4730, 'promo_offer_badge_ar', 'عرض محدود', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4731, 'promo_offer_badge_en', 'Limited offer', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4732, 'promo_offer_amount_ar', '٣٠٪', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4733, 'promo_offer_amount_en', '30%', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4734, 'promo_offer_title_ar', 'خصم على الكورسات المباشرة', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4735, 'promo_offer_title_en', 'off our live courses', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4736, 'promo_offer_subtitle_ar', 'لأول ١٠٠ طالب يسجّل في المنصة. احجز مكان طفلك قبل اكتمال العدد.', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4737, 'promo_offer_subtitle_en', 'For the first 100 students to register. Reserve your child\'s place before it fills up.', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4738, 'promo_offer_cta_ar', 'بادر بالحجز', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4739, 'promo_offer_cta_en', 'Book now', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4740, 'promo_offer_image_alt_ar', 'خصم ٣٠٪ على الكورسات المباشرة لأول ١٠٠ طالب يسجّل في منصة برينيكسا.', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4741, 'promo_offer_image_alt_en', '30% off live courses for the first 100 students to register with Brainixa.', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4742, 'promo_offer_pills', '[{\"text_ar\": \"حصص مباشرة\", \"text_en\": \"Live classes\"}, {\"text_ar\": \"معلمون متخصصون\", \"text_en\": \"Specialist teachers\"}, {\"text_ar\": \"متابعة لتقدّم طفلك\", \"text_en\": \"Progress you can follow\"}]', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4743, 'promo_video_enabled', '1', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4744, 'promo_video_url', 'https://camp-coding.online/brain-ixa/uploads/documents/vid_6aec7fd2ae0a25.49821725.mp4', '2026-11-05 12:54:50', '2026-11-05 13:09:03'),
(4745, 'promo_video_poster', 'https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fc77b2138.40997541.jpg', '2026-11-05 12:54:50', '2026-11-05 13:09:03'),
(4746, 'promo_video_title_ar', 'كل ما يحتاجه طفلك خلال رحلته التعليمية', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4747, 'promo_video_title_en', 'Everything your child needs on their learning journey', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4748, 'promo_video_subtitle_ar', 'حصص مباشرة، وكورسات مسجّلة، وكتب وتدريبات — في مكان واحد وعلى هاتفك.', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4749, 'promo_video_subtitle_en', 'Live classes, recorded courses, books and exercises - in one place, on your phone.', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4750, 'promo_video_cta_ar', 'ابدأ رحلتك التعليمية الآن', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4751, 'promo_video_cta_en', 'Start your learning journey', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4752, 'promo_video_points', '[{\"text_ar\": \"تشمل كل المراحل التعليمية\", \"text_en\": \"Covers every school stage\"}, {\"text_ar\": \"تشمل كل المواد الدراسية\", \"text_en\": \"Covers every school subject\"}, {\"text_ar\": \"متابعة لتقدّم طفلك أولًا بأول\", \"text_en\": \"Follow your child\'s progress as it happens\"}]', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4753, 'promo_gallery_enabled', '1', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4754, 'promo_gallery_subtitle_ar', 'تعرّف علينا', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4755, 'promo_gallery_subtitle_en', 'Get to know us', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4756, 'promo_gallery_title_ar', 'لماذا برينيكسا؟', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4757, 'promo_gallery_title_en', 'Why Brainixa?', '2026-11-05 12:54:50', '2026-11-05 12:54:50'),
(4758, 'promo_gallery_items', '[{\"image\": \"https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fc84a70d6.69549387.jpg\", \"caption_ar\": \"ليس مجرّد كورس، بل رحلة تعليمية كاملة: حصص مباشرة، ومعلّمون متخصّصون، وكورسات مسجّلة، وتدريبات وأنشطة.\", \"caption_en\": \"Not just a course - a complete learning journey: live online classes, specialist teachers, recorded courses, and exercises and activities.\"}, {\"image\": \"https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fc91c7043.03792594.jpg\", \"caption_ar\": \"نركّز على ما يحتاجه طفلك لتحقيق هدفه: نحدّد الهدف، ونبدأ من مستواه، ونساعده على التقدّم خطوة بخطوة.\", \"caption_en\": \"We focus on what your child needs to reach their goal: we set the goal, start from their level, and help them move forward step by step.\"}, {\"image\": \"https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fca72afe1.48485842.jpg\", \"caption_ar\": \"منصّة برينيكسا: التعلّم أصبح أيسر وأقرب إلى طفلك، وكلّ ما يحتاجه في مكان واحد.\", \"caption_en\": \"The Brainixa platform: learning made easier and closer to your child, with everything they need in one place.\"}, {\"image\": \"https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fcb43e378.18225062.jpg\", \"caption_ar\": \"منصّتنا وتطبيقنا جاهزان لاستقبال أطفالكم: إنشاء حساب، ثمّ اختيار الكورس، ثمّ بدء التعلّم.\", \"caption_en\": \"Our platform and app are ready for your children: create an account, choose a course, then start learning.\"}, {\"image\": \"https://camp-coding.online/brain-ixa/uploads/documents/img_6aec7fcc0efb86.20832062.jpg\", \"caption_ar\": \"كلّ احتياجات طفلك التعليمية في مكان واحد: اللغة العربية، واللغة الإنجليزية، والرياضيات، والعلوم، والدراسات الاجتماعية.\", \"caption_en\": \"Every educational need in one place: Arabic, English, Maths, Science and Social Studies.\"}]', '2026-11-05 12:54:50', '2026-11-05 13:09:03');

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
  `sessions_revoked_at` datetime DEFAULT NULL COMMENT 'Tokens issued before this moment are rejected',
  `is_demo_account` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Full catalogue access without paying; hidden from admin student lists'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `school_id`, `city_id`, `country_id`, `referred_by_student_id`, `affiliate_code`, `points_balance`, `study_language`, `name`, `age`, `phone`, `phone_country_code`, `email`, `password`, `image`, `is_email_verified`, `is_active`, `created_at`, `updated_at`, `fcm_token`, `academic_year_id`, `max_devices`, `sessions_revoked_at`, `is_demo_account`) VALUES
(1109, NULL, NULL, 1, NULL, 'BRX-STU-1109', 0.00, 'arabic', 'mohamed ramadan', NULL, '+201098476530', '20', 'student2005@example.com', '$2b$10$3lS8tBYLIKoH1oDOgnajzul6LsfMlkSEROaGVkCMnaDXSC4Z3Jz3a', NULL, 1, 1, '2026-10-12 11:17:40', '2026-11-05 11:32:21', 'cTJhiSZOQhiHCwVj2sEbyN:APA91bGpIE0Vjj47wCKl83PIKnUwpf-rTQO0v7gou0XR5DDbMRPg8iTWfNbduqXnjFqgI9Ia737jIsTgT5m6hOSDX-gXJArQxLWUMUrqAadY4mFi5p0rgK8', NULL, NULL, NULL, 1),
(1111, NULL, NULL, 1, NULL, 'BRX-STU-1111', 0.00, 'arabic', 'Bassem', 16, '+201111111111', '20', 'bbb@bbb.bbb', '$2y$10$Ag89XMCLpJrITKvDqB2CL./ENvTJjfdTJEhND3GYC9ZFEmCVHlZAe', 'uploads/avatars/img_6adeedc98e84a5.18368933.jpg', 1, 1, '2026-10-24 00:41:17', '2026-11-05 11:54:48', 'dG7pveavRCqUTcLowouUfb:APA91bEmzsa9zNC6qyq9Hbgq343va7nyJHfJaNvJNerpozodk8HXCY9ZnUzFMDoTs_7RejOK4-Gyb9jFrpvfO6NusswOEZWAx4DhAMtE_hZBUoI4zN90ZjA', NULL, 10, NULL, 0);

-- --------------------------------------------------------

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

--
-- Dumping data for table `student_book_progress`
--

INSERT INTO `student_book_progress` (`id`, `student_id`, `book_id`, `open_count`, `last_page_number`, `total_pages`, `last_opened_at`, `created_at`, `updated_at`) VALUES
(1, 1110, 7672, 1, 1, 0, '2026-10-28 12:09:11', '2026-10-28 09:09:11', '2026-10-28 09:09:11'),
(2, 1109, 7677, 1, 1, 0, '2026-11-02 13:59:18', '2026-11-02 11:59:18', '2026-11-02 11:59:18');

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
  `review_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `student_book_purchase_requests`
--

INSERT INTO `student_book_purchase_requests` (`id`, `student_id`, `book_id`, `status`, `reviewed_by_type`, `reviewed_by_id`, `notes`, `review_notes`, `created_at`, `updated_at`) VALUES
(11, 1111, 7675, 'approved', NULL, NULL, NULL, 'كتاب مجاني — مُنح تلقائيًا', '2026-11-01 13:47:39', '2026-11-01 13:47:39'),
(12, 1109, 7673, 'pending', NULL, NULL, NULL, NULL, '2026-11-02 11:51:50', '2026-11-02 11:51:50');

-- --------------------------------------------------------

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
-- Dumping data for table `student_book_subscriptions`
--

INSERT INTO `student_book_subscriptions` (`id`, `student_id`, `book_id`, `granted_by_type`, `granted_by_id`, `price`, `is_active`, `created_at`) VALUES
(10, 1111, 7675, 'student', 1111, 0, 1, '2026-11-01 13:47:39');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `student_question_answers`
--

INSERT INTO `student_question_answers` (`id`, `student_id`, `question_id`, `unit_id`, `course_id`, `mcq_option_id`, `true_false_answer`, `written_answer_text`, `is_correct`, `score_awarded`, `created_at`) VALUES
(20137, 1113, 41952, 4399, 512, NULL, 1, '', 1, 1.00, '2026-11-02 14:07:44');

-- --------------------------------------------------------

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
-- Dumping data for table `student_reports`
--

INSERT INTO `student_reports` (`id`, `sender_type`, `admin_id`, `teacher_id`, `student_id`, `subject_id`, `course_id`, `session_id`, `exam_attempt_id`, `report_type`, `term`, `score`, `max_score`, `grade_label`, `percentage`, `title`, `description`, `strengths`, `improvements`, `report_date`, `rating`, `created_at`) VALUES
(191, 'system', NULL, NULL, 1, 1, 2, NULL, 7097, 'exam_result', NULL, 5.00, 10.00, 'مقبول', 50.00, 'نتيجة امتحان: اختبار الوحدة الأولى - نحو', 'حصل الطالب على 5 من 10 (50%) في \"اختبار الوحدة الأولى - نحو\".', NULL, NULL, '2026-10-13', 5, '2026-10-13 06:29:10'),
(192, 'system', NULL, NULL, 1109, 3, 1, NULL, 7098, 'exam_result', NULL, 0.00, 12.00, 'راسب', 0.00, 'نتيجة امتحان: اختبار الوحدة الأولى - رياضيات', 'حصل الطالب على 0 من 12 (0%) في \"اختبار الوحدة الأولى - رياضيات\".', NULL, NULL, '2026-10-18', 5, '2026-10-18 13:47:28'),
(193, 'system', NULL, NULL, 1111, 3, 1, NULL, 7100, 'exam_result', NULL, 0.00, 12.00, 'راسب', 0.00, 'نتيجة امتحان: اختبار الوحدة الأولى - رياضيات', 'حصل الطالب على 0 من 12 (0%) في \"اختبار الوحدة الأولى - رياضيات\".', NULL, NULL, '2026-10-25', 5, '2026-10-25 00:07:41'),
(194, 'system', NULL, NULL, 1113, 1, 512, NULL, 7105, 'exam_result', NULL, 1.00, 2.00, 'مقبول', 50.00, 'نتيجة امتحان: امتحان الكورس كاملًا', 'حصل الطالب على 1 من 2 (50%) في \"امتحان الكورس كاملًا\".', NULL, NULL, '2026-11-02', 5, '2026-11-02 14:20:15');

-- --------------------------------------------------------

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
  `price` decimal(10,2) DEFAULT NULL COMMENT 'What was collected for a manually entered sale. NULL for grants made by a payment flow, which are counted at their own source.',
  `currency` varchar(10) DEFAULT NULL COMMENT 'Currency of `price`. Never assume the platform base: a sale can be agreed in the buyer''s own currency.',
  `sale_channel` varchar(30) DEFAULT NULL COMMENT 'whatsapp | cash | bank_transfer | other. NULL for grants made by a payment flow.',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `paused_at` datetime DEFAULT NULL COMMENT 'When an admin paused it. NULL once resumed.',
  `cancelled_at` datetime DEFAULT NULL COMMENT 'When an admin cancelled it outright',
  `status_reason` varchar(500) DEFAULT NULL COMMENT 'What the admin typed when pausing or cancelling',
  `status_changed_by` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'The admin who paused or cancelled it',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `student_subscriptions`
--

INSERT INTO `student_subscriptions` (`id`, `student_id`, `subscription_code_id`, `subscription_type`, `start_date`, `end_date`, `price`, `currency`, `sale_channel`, `is_active`, `paused_at`, `cancelled_at`, `status_reason`, `status_changed_by`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 'course', '2026-10-07 12:00:00', '2027-04-07 12:00:00', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-10-07 16:00:00', '2026-10-07 16:00:00'),
(2, 2, NULL, 'course', '2026-10-07 12:00:00', '2027-04-07 12:00:00', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-10-07 16:00:00', '2026-10-07 16:00:00'),
(3, 3, NULL, 'course', '2026-10-07 12:00:00', '2027-04-07 12:00:00', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-10-07 16:00:00', '2026-10-07 16:00:00'),
(1157, 1, NULL, 'package', '2026-10-13 08:47:14', '2026-11-13 08:47:14', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-10-13 05:47:14', '2026-10-13 05:47:14'),
(1158, 1111, NULL, 'course', '2026-10-25 02:45:58', '2026-11-24 02:45:58', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-10-24 23:45:58', '2026-10-24 23:45:58'),
(1160, 1110, NULL, 'package', '2026-10-28 15:36:35', '2026-10-28 16:57:32', NULL, NULL, NULL, 0, NULL, '2026-10-28 16:57:32', 'Zoom test cleanup', 1, '2026-10-28 12:36:35', '2026-10-28 13:57:32'),
(1161, 1110, NULL, 'package', '2026-10-28 17:09:09', '2026-11-28 17:09:09', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-10-28 14:09:09', '2026-10-28 14:09:09'),
(1162, 1113, NULL, 'course', '2026-11-02 04:20:30', '2027-05-02 04:20:30', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(1163, 1111, NULL, 'package', '2026-11-03 14:05:26', '2026-11-03 14:08:46', NULL, NULL, NULL, 0, NULL, '2026-11-03 14:08:46', NULL, 1, '2026-11-03 12:05:26', '2026-11-03 12:08:46'),
(1164, 1111, NULL, 'package', '2026-11-03 14:11:20', '2026-12-03 14:11:20', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-11-03 12:11:20', '2026-11-03 12:11:20'),
(1165, 1109, NULL, 'package', '2026-11-05 04:55:18', '2027-11-05 04:55:18', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-11-05 09:55:18', '2026-11-05 09:55:18');

-- --------------------------------------------------------

--
-- Table structure for table `student_subscription_books`
--

CREATE TABLE `student_subscription_books` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `book_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_subscription_courses`
--

CREATE TABLE `student_subscription_courses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `student_subscription_courses`
--

INSERT INTO `student_subscription_courses` (`id`, `student_subscription_id`, `course_id`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2),
(1469, 1157, 507),
(1470, 1158, 1),
(1472, 1160, 510),
(1473, 1161, 511),
(1474, 1162, 512),
(1475, 1162, 513),
(1476, 1163, 511),
(1477, 1164, 514),
(1478, 1165, 516);

-- --------------------------------------------------------

--
-- Table structure for table `student_subscription_subjects`
--

CREATE TABLE `student_subscription_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_subscription_teachers`
--

CREATE TABLE `student_subscription_teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_subscription_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

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
-- Dumping data for table `student_video_progress`
--

INSERT INTO `student_video_progress` (`id`, `student_id`, `video_id`, `is_completed`, `watched_seconds`, `total_seconds`, `last_position_seconds`, `completed_at`, `created_at`, `updated_at`) VALUES
(683, 1111, 4302, 0, 0, 0, 0, NULL, '2026-10-25 00:05:30', '2026-10-25 00:05:30'),
(684, 1113, 4313, 0, 3, 12, 4, NULL, '2026-11-02 09:23:05', '2026-11-02 09:23:08');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

--
-- Table structure for table `subscription_code_courses`
--

CREATE TABLE `subscription_code_courses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subscription_code_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

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
  `email` varchar(190) DEFAULT NULL,
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
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`id`, `subject_id`, `city_id`, `name`, `email`, `password`, `whatsapp`, `experience`, `specialization`, `biography`, `qualifications`, `rating`, `video`, `image`, `fcm_token`, `description`, `is_email_verified`, `is_active`, `is_attendance_suspended`, `wallet_balance`, `can_view_profile`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, 'أحمد المعلم', 'teacher1@brainixa.cloud', '$2y$10$x4RrI2i7Q1r6qDIYz/4h.eNpqPqidqyFRBsRRt3jVQdRMMhhKA0ne', '', '', 'Mathematics', '', '', 4.50, NULL, NULL, NULL, NULL, 1, 1, 0, 0.00, 1, '2026-10-07 16:00:00', '2026-11-05 07:07:58');

-- --------------------------------------------------------

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
  `status` varchar(20) NOT NULL DEFAULT 'available',
  `is_online` tinyint(1) NOT NULL DEFAULT 1,
  `meeting_link` varchar(500) DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by_type` enum('admin','teacher') NOT NULL DEFAULT 'admin',
  `created_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `started_at` datetime DEFAULT NULL COMMENT 'When the admin or the teacher pressed Start',
  `ended_at` datetime DEFAULT NULL COMMENT 'When it was ended; the session reads as completed from here on',
  `zoom_meeting_id` varchar(32) DEFAULT NULL COMMENT 'Set once Start creates the Zoom room; reused if Start is pressed again before End',
  `zoom_password` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `teacher_availability_slots`
--

INSERT INTO `teacher_availability_slots` (`id`, `teacher_id`, `course_id`, `subject_id`, `slot_date`, `start_time`, `end_time`, `capacity`, `booked_count`, `status`, `is_online`, `meeting_link`, `room`, `notes`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`, `started_at`, `ended_at`, `zoom_meeting_id`, `zoom_password`) VALUES
(32, 1, 511, NULL, '2026-10-28', '17:14:52', '17:29:52', 1, 1, 'completed', 1, NULL, NULL, NULL, 'teacher', 1, '2026-10-28 14:09:09', '2026-10-28 14:48:08', '2026-10-28 17:09:56', '2026-10-28 17:48:08', '83638019957', '708517'),
(33, 1, 511, NULL, '2026-10-28', '22:47:00', '22:52:00', 1, 1, 'completed', 1, NULL, NULL, NULL, 'teacher', 1, '2026-10-28 19:42:23', '2026-10-28 19:49:28', '2026-10-28 22:43:04', '2026-10-28 22:49:28', '89448876079', '069301'),
(38, 1, 511, NULL, '2026-10-31', '17:32:00', '17:40:00', 1, 1, 'in_progress', 1, NULL, NULL, NULL, 'admin', 1, '2026-10-31 15:09:02', '2026-10-31 15:10:25', '2026-10-31 17:10:24', NULL, '82430189055', '366035'),
(39, 1, 511, NULL, '2026-11-01', '17:30:00', '17:40:00', 1, 1, 'in_progress', 1, NULL, NULL, NULL, 'admin', 1, '2026-10-31 15:12:35', '2026-10-31 15:13:36', '2026-10-31 17:13:35', NULL, '84368963543', '920965'),
(40, 1, 513, 1, '2026-11-02', '10:19:30', '10:49:30', 1, 1, 'full', 1, 'https://zoom.us/j/1111111111?pwd=demo', NULL, 'full-demo-package-slot', 'admin', 1, '2026-11-02 09:25:54', '2026-11-02 12:19:30', NULL, NULL, NULL, NULL),
(41, 1, 514, NULL, '2026-11-03', '14:20:00', '15:20:00', 1, 1, 'in_progress', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 12:25:15', '2026-11-03 14:25:14', NULL, '82469823498', '926163'),
(42, 1, 514, NULL, '2026-11-10', '14:20:00', '15:20:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 12:16:17', NULL, NULL, NULL, NULL),
(43, 1, 514, NULL, '2026-11-17', '14:20:00', '15:20:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 12:16:17', NULL, NULL, NULL, NULL),
(44, 1, 514, NULL, '2026-11-24', '14:20:00', '15:20:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 14:40:58', NULL, NULL, NULL, NULL),
(45, 1, 514, NULL, '2026-12-01', '14:20:00', '15:20:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 12:16:17', NULL, NULL, NULL, NULL),
(46, 1, 514, NULL, '2026-12-08', '14:20:00', '15:20:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 12:16:16', NULL, NULL, NULL, NULL),
(47, 1, 514, NULL, '2026-12-15', '14:20:00', '15:20:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-03 12:16:16', '2026-11-03 12:16:16', NULL, NULL, NULL, NULL),
(48, 1, 514, NULL, '2026-11-04', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 13:32:19', '2026-11-04 13:38:06', NULL, '85645512004', '980677'),
(49, 1, 514, NULL, '2026-11-05', '15:05:50', '15:50:00', 1, 1, 'completed', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-05 13:04:49', '2026-11-05 13:32:34', '2026-11-05 13:33:20', '84013851247', '731787'),
(50, 1, 514, NULL, '2026-11-06', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 12:51:24', NULL, NULL, NULL, NULL),
(51, 1, 514, NULL, '2026-11-07', '13:35:00', '13:50:00', 1, 1, 'in_progress', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-07 11:46:28', '2026-11-07 13:46:27', NULL, '88053513271', '039936'),
(52, 1, 514, NULL, '2026-11-08', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:54', NULL, NULL, NULL, NULL),
(53, 1, 514, NULL, '2026-11-09', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:54', NULL, NULL, NULL, NULL),
(54, 1, 514, NULL, '2026-11-10', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:54', NULL, NULL, NULL, NULL),
(55, 1, 514, NULL, '2026-11-11', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:54', NULL, NULL, NULL, NULL),
(56, 1, 514, NULL, '2026-11-12', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:54', NULL, NULL, NULL, NULL),
(57, 1, 514, NULL, '2026-11-13', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(58, 1, 514, NULL, '2026-11-14', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(59, 1, 514, NULL, '2026-11-15', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(60, 1, 514, NULL, '2026-11-16', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(61, 1, 514, NULL, '2026-11-17', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(62, 1, 514, NULL, '2026-11-18', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(63, 1, 514, NULL, '2026-11-19', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(64, 1, 514, NULL, '2026-11-20', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(65, 1, 514, NULL, '2026-11-21', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(66, 1, 514, NULL, '2026-11-22', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(67, 1, 514, NULL, '2026-11-23', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:55', NULL, NULL, NULL, NULL),
(68, 1, 514, NULL, '2026-11-24', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(69, 1, 514, NULL, '2026-11-25', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(70, 1, 514, NULL, '2026-11-26', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(71, 1, 514, NULL, '2026-11-27', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(72, 1, 514, NULL, '2026-11-28', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(73, 1, 514, NULL, '2026-11-29', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(74, 1, 514, NULL, '2026-11-30', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(75, 1, 514, NULL, '2026-12-01', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(76, 1, 514, NULL, '2026-12-02', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(77, 1, 514, NULL, '2026-12-03', '13:35:00', '13:50:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:56', NULL, NULL, NULL, NULL),
(78, 1, 514, NULL, '2026-12-04', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(79, 1, 514, NULL, '2026-12-05', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(80, 1, 514, NULL, '2026-12-06', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(81, 1, 514, NULL, '2026-12-07', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(82, 1, 514, NULL, '2026-12-08', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(83, 1, 514, NULL, '2026-12-09', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(84, 1, 514, NULL, '2026-12-10', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(85, 1, 514, NULL, '2026-12-11', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(86, 1, 514, NULL, '2026-12-12', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(87, 1, 514, NULL, '2026-12-13', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(88, 1, 514, NULL, '2026-12-14', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(89, 1, 514, NULL, '2026-12-15', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(90, 1, 514, NULL, '2026-12-16', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(91, 1, 514, NULL, '2026-12-17', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(92, 1, 514, NULL, '2026-12-18', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(93, 1, 514, NULL, '2026-12-19', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(94, 1, 514, NULL, '2026-12-20', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(95, 1, 514, NULL, '2026-12-21', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(96, 1, 514, NULL, '2026-12-22', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(97, 1, 514, NULL, '2026-12-23', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(98, 1, 514, NULL, '2026-12-24', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(99, 1, 514, NULL, '2026-12-25', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(100, 1, 514, NULL, '2026-12-26', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(101, 1, 514, NULL, '2026-12-27', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(102, 1, 514, NULL, '2026-12-28', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(103, 1, 514, NULL, '2026-12-29', '13:35:00', '13:50:00', 1, 0, 'available', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-04 11:32:53', '2026-11-04 11:32:53', NULL, NULL, NULL, NULL),
(104, 1, 514, NULL, '2026-11-04', '15:55:00', '16:20:00', 1, 1, 'completed', 1, NULL, NULL, NULL, 'teacher', 1, '2026-11-04 13:52:38', '2026-11-05 11:43:55', '2026-11-04 15:54:32', '2026-11-05 13:43:55', '86919666503', '933578'),
(106, 1, 514, NULL, '2026-11-12', '05:00:00', '22:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 09:27:41', '2026-11-05 09:27:41', NULL, NULL, NULL, NULL),
(107, 1, 514, NULL, '2026-11-19', '05:00:00', '22:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 09:27:41', '2026-11-05 09:27:41', NULL, NULL, NULL, NULL),
(108, 1, 514, NULL, '2026-11-26', '05:00:00', '22:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 09:27:41', '2026-11-05 09:27:42', NULL, NULL, NULL, NULL),
(109, 1, 514, NULL, '2026-12-03', '05:00:00', '22:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 09:27:41', '2026-11-05 09:27:42', NULL, NULL, NULL, NULL),
(110, 1, 516, NULL, '2026-11-05', '10:00:00', '14:00:00', 5, 1, 'completed', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 10:47:10', '2026-11-05 12:11:37', '2026-11-05 12:47:10', '81648442917', '099633'),
(111, 1, 516, NULL, '2026-11-05', '14:00:00', '15:30:00', 5, 1, 'completed', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 11:40:01', '2026-11-05 13:33:29', '2026-11-05 13:40:01', '84272535643', '512922'),
(112, 1, 516, NULL, '2026-11-05', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(113, 1, 516, NULL, '2026-11-06', '10:00:00', '11:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(114, 1, 516, NULL, '2026-11-06', '14:00:00', '15:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(115, 1, 516, NULL, '2026-11-06', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(116, 1, 516, NULL, '2026-11-07', '10:00:00', '11:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(117, 1, 516, NULL, '2026-11-07', '14:00:00', '15:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(118, 1, 516, NULL, '2026-11-07', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(119, 1, 516, NULL, '2026-11-08', '10:00:00', '11:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(120, 1, 516, NULL, '2026-11-08', '14:00:00', '15:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(121, 1, 516, NULL, '2026-11-08', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(122, 1, 516, NULL, '2026-11-09', '10:00:00', '11:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(123, 1, 516, NULL, '2026-11-09', '14:00:00', '15:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(124, 1, 516, NULL, '2026-11-09', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(125, 1, 516, NULL, '2026-11-10', '10:00:00', '11:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(126, 1, 516, NULL, '2026-11-10', '14:00:00', '15:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(127, 1, 516, NULL, '2026-11-10', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(128, 1, 516, NULL, '2026-11-11', '10:00:00', '11:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(129, 1, 516, NULL, '2026-11-11', '14:00:00', '15:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(130, 1, 516, NULL, '2026-11-11', '18:00:00', '19:30:00', 5, 1, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(131, 1, 516, NULL, '2026-11-12', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(132, 1, 516, NULL, '2026-11-12', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(133, 1, 516, NULL, '2026-11-12', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(134, 1, 516, NULL, '2026-11-13', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(135, 1, 516, NULL, '2026-11-13', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(136, 1, 516, NULL, '2026-11-13', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(137, 1, 516, NULL, '2026-11-14', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(138, 1, 516, NULL, '2026-11-14', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(139, 1, 516, NULL, '2026-11-14', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(140, 1, 516, NULL, '2026-11-15', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(141, 1, 516, NULL, '2026-11-15', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(142, 1, 516, NULL, '2026-11-15', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(143, 1, 516, NULL, '2026-11-16', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(144, 1, 516, NULL, '2026-11-16', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(145, 1, 516, NULL, '2026-11-16', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(146, 1, 516, NULL, '2026-11-17', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(147, 1, 516, NULL, '2026-11-17', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(148, 1, 516, NULL, '2026-11-17', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(149, 1, 516, NULL, '2026-11-18', '10:00:00', '11:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(150, 1, 516, NULL, '2026-11-18', '14:00:00', '15:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(151, 1, 516, NULL, '2026-11-18', '18:00:00', '19:30:00', 5, 0, 'available', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 09:55:18', NULL, NULL, NULL, NULL),
(173, 1, 516, NULL, '2026-11-05', '04:00:00', '05:00:00', 5, 1, 'completed', 1, NULL, NULL, 'zoom-test-student2005', 'admin', 1, '2026-11-05 09:55:18', '2026-11-05 10:57:28', '2026-11-05 12:47:25', '2026-11-05 12:57:28', '89825904316', '569155'),
(174, 1, 516, NULL, '2026-11-05', '06:00:00', '21:00:00', 1, 1, 'completed', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 11:45:52', '2026-11-05 11:47:34', '2026-11-05 13:46:30', '2026-11-05 13:47:34', '81031274096', '056188'),
(175, 1, 516, NULL, '2026-11-12', '06:00:00', '21:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 11:45:52', '2026-11-05 11:45:52', NULL, NULL, NULL, NULL),
(176, 1, 516, NULL, '2026-11-19', '06:00:00', '21:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 11:45:52', '2026-11-05 11:45:52', NULL, NULL, NULL, NULL),
(177, 1, 516, NULL, '2026-11-26', '06:00:00', '21:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 11:45:52', '2026-11-05 11:45:53', NULL, NULL, NULL, NULL),
(178, 1, 516, NULL, '2026-12-03', '06:00:00', '21:00:00', 1, 1, 'full', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-05 11:45:52', '2026-11-05 11:45:53', NULL, NULL, NULL, NULL),
(179, 1, 514, NULL, '2026-11-07', '12:55:00', '13:25:00', 1, 1, 'in_progress', 1, NULL, NULL, NULL, 'admin', 1, '2026-11-07 10:49:54', '2026-11-07 10:51:00', '2026-11-07 12:50:59', NULL, '89757804672', '828117');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `true_false_answers`
--

INSERT INTO `true_false_answers` (`id`, `question_id`, `correct_answer`, `is_active`, `created_at`, `updated_at`) VALUES
(10556, 9007, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10557, 9013, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10558, 9015, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10559, 9018, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10560, 9024, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10561, 9025, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10562, 9031, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10563, 9047, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10564, 9052, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10565, 9056, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10566, 9059, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10567, 9064, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10568, 9065, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10569, 9066, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10570, 9069, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10571, 9074, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10572, 9086, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10573, 9087, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10574, 9088, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10575, 9090, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10576, 9091, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10577, 9093, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10578, 9096, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10579, 9097, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10580, 9098, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10581, 9099, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10582, 9101, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10583, 9102, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10584, 9103, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10585, 9106, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10586, 9109, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10587, 9131, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10588, 9132, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10589, 9133, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10590, 9134, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10591, 9142, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10592, 9143, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10593, 9146, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10594, 9147, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10595, 9162, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10596, 9165, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10597, 9166, 0, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10598, 9169, 1, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(10600, 41952, 1, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(10601, 41955, 1, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30'),
(10602, 41957, 1, 1, '2026-11-02 12:19:30', '2026-11-02 12:19:30');

-- --------------------------------------------------------

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
-- Dumping data for table `units`
--

INSERT INTO `units` (`id`, `course_id`, `subject_id`, `code`, `order_num`, `videos_drip_enabled`, `duration`, `duration_unit`, `lessons_count`, `is_active`, `created_by_type`, `created_by_id`, `created_at`, `updated_at`) VALUES
(4399, 512, 1, 'full-unit-1', 1, 0, NULL, NULL, 2, 1, 'admin', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(4400, 512, 1, 'full-unit-2', 2, 0, NULL, NULL, 2, 1, 'admin', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(4402, 513, 1, 'c513-u6828', 1, 0, NULL, NULL, 0, 1, 'teacher', 1, '2026-11-04 12:12:59', '2026-11-04 12:12:59');

-- --------------------------------------------------------

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
-- Dumping data for table `units_translations`
--

INSERT INTO `units_translations` (`id`, `unit_id`, `language_id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(10029, 4399, 1, 'الوحدة الأولى: الجبر والمتباينات', 'مقدّمة في الجبر والمتباينات.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(10030, 4399, 2, 'Unit 1: Algebra and Inequalities', 'An introduction to algebra and inequalities.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(10031, 4400, 1, 'الوحدة الثانية: الدوال المثلثية', 'الدوال المثلثية الأساسية وتطبيقاتها.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(10032, 4400, 2, 'Unit 2: Trigonometric Functions', 'Core trigonometric functions and their uses.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(10035, 4402, 1, 'الدرس الأول', 'الدرس', 1, '2026-11-04 12:12:59', '2026-11-04 12:12:59'),
(10036, 4402, 2, '', 'test', 1, '2026-11-04 12:12:59', '2026-11-04 12:12:59');

-- --------------------------------------------------------

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
-- Dumping data for table `unit_teachers`
--

INSERT INTO `unit_teachers` (`id`, `unit_id`, `teacher_id`, `is_active`, `created_at`) VALUES
(3, 3, 2, 1, '2026-10-07 16:00:00'),
(1073, 4401, 1, 1, '2026-11-04 12:08:33'),
(1074, 4402, 1, 1, '2026-11-04 12:12:59');

-- --------------------------------------------------------

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
-- Dumping data for table `user_devices`
--

INSERT INTO `user_devices` (`id`, `user_type`, `user_id`, `device_id`, `device_name`, `platform`, `user_agent`, `ip_address`, `is_active`, `revoked_at`, `revoked_by_admin_id`, `first_seen_at`, `last_seen_at`) VALUES
(149, 'student', 1, '748d83c5-ea21-4365-9825-caa38351574e', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '156.203.232.1', 1, NULL, NULL, '2026-10-07 14:03:43', '2026-10-13 09:47:20'),
(150, 'student', 1, '0483ceb9-8dea-4d66-84fb-995b9e297783', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '156.203.191.100', 1, NULL, NULL, '2026-10-08 11:29:18', '2026-10-08 14:10:00'),
(151, 'student', 1, 'claude-diag-001', 'diagnostic', NULL, 'curl/8.16.0', '156.203.191.100', 1, NULL, NULL, '2026-10-08 12:28:46', '2026-10-08 12:28:46'),
(154, 'student', 1, 'claude-audit', 'audit', NULL, 'curl/8.16.0', '156.203.232.1', 1, NULL, NULL, '2026-10-11 07:42:53', '2026-10-13 09:50:05'),
(155, 'student', 1109, '0483ceb9-8dea-4d66-84fb-995b9e297783', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.173.171', 1, NULL, NULL, '2026-10-12 11:20:18', '2026-11-02 09:15:34'),
(156, 'student', 1, 'ebc65523-d0bc-48e6-9e0c-6973e9e3dff3', 'Chrome · Android', 'Linux armv81', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36', '156.203.214.83', 1, NULL, NULL, '2026-10-12 12:48:50', '2026-10-14 13:34:43'),
(157, 'student', 1, '05c1bcf2-3465-49a3-9baf-da7168aa6ed8', 'Edge · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '156.203.184.206', 1, NULL, NULL, '2026-10-13 04:39:19', '2026-10-18 05:55:41'),
(166, 'student', 1109, '844208cf5b476512', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.12.0', '156.217.102.75', 1, NULL, NULL, '2026-10-18 11:39:16', '2026-11-05 10:40:52'),
(172, 'student', 1109, '91D50032-0A4A-481C-9FCD-F4A05C3D1110', 'Apple iPhone 15 Pro · Brainixa app', 'iOS 17.4', 'brainixa/1 CFNetwork/1494.0.7 Darwin/24.6.0', '156.203.131.156', 1, NULL, NULL, '2026-10-18 13:45:22', '2026-10-20 08:00:43'),
(173, 'student', 1110, '45b0a2c053729aa1', 'OnePlus OnePlus8Pro · Brainixa app', 'Android 11', 'okhttp/4.9.2', '66.249.88.227', 1, NULL, NULL, '2026-10-18 14:13:27', '2026-10-19 10:31:30'),
(176, 'student', 1110, '2b8ca5fb8c0e40c7', 'OnePlus OnePlus8Pro · Brainixa app', 'Android 11', 'okhttp/4.9.2', '66.249.84.106', 1, NULL, NULL, '2026-10-19 09:04:41', '2026-10-19 09:04:59'),
(183, 'student', 1109, 'C5DDFD53-9395-413E-AFF8-A8DF0EFCA74B', 'Apple iPhone · Brainixa app', 'iOS 26.5', 'brainixa/5 CFNetwork/3860.600.12 Darwin/25.5.0', '17.185.64.73', 1, NULL, NULL, '2026-10-20 11:04:53', '2026-10-20 11:04:53'),
(184, 'student', 1109, 'E778A665-87FC-4427-B1F6-7B590F8B1952', 'Apple iPhone SE · Brainixa app', 'iOS 27.0.1', 'brainixa/5 CFNetwork/3896.100.1.2.1 Darwin/27.0.0', '139.178.130.132', 1, NULL, NULL, '2026-10-20 11:50:46', '2026-10-20 11:50:46'),
(185, 'student', 1109, '33B67192-A57F-4708-B198-7770C1AA509E', 'Apple iPad · Brainixa app', 'iPadOS 27.0.1', 'brainixa/5 CFNetwork/3896.100.1.2.1 Darwin/27.0.0', '17.64.126.182', 1, NULL, NULL, '2026-10-21 10:11:36', '2026-10-21 10:14:13'),
(187, 'student', 1111, '05c1bcf2-3465-49a3-9baf-da7168aa6ed8', 'Edge · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', '156.203.209.183', 1, NULL, NULL, '2026-10-24 00:41:29', '2026-11-05 09:30:19'),
(188, 'student', 1111, 'fdfc4ab8a69f88f6', 'samsung SM-M515F · Brainixa app', 'Android 12', 'okhttp/4.9.2', '156.203.152.88', 1, NULL, NULL, '2026-10-24 05:45:32', '2026-10-27 05:15:04'),
(189, 'student', 1109, '80A136BF-5873-46BD-8A92-619595B84DC5', 'Apple iPhone SE · Brainixa app', 'iOS 27.0.1', 'brainixa/5 CFNetwork/3896.100.1.2.1 Darwin/27.0.0', '139.178.130.133', 1, NULL, NULL, '2026-10-24 08:46:19', '2026-10-24 08:46:19'),
(190, 'student', 1109, 'B2477FB7-7413-4495-AC53-60F67703C9CC', 'Apple iPhone · Brainixa app', 'iOS 26.5', 'brainixa/5 CFNetwork/3860.600.12 Darwin/25.5.0', '17.185.64.88', 1, NULL, NULL, '2026-10-24 08:47:23', '2026-10-24 08:47:23'),
(193, 'student', 1111, 'ebc65523-d0bc-48e6-9e0c-6973e9e3dff3', 'Chrome · Android', 'Linux armv81', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36', '156.161.85.130', 1, NULL, NULL, '2026-10-26 05:54:57', '2026-11-07 07:27:25'),
(195, 'student', 1112, '748d83c5-ea21-4365-9825-caa38351574e', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.243.251', 1, NULL, NULL, '2026-10-27 09:19:23', '2026-10-27 09:19:23'),
(196, 'student', 1109, '3F4796E9-97CF-4D81-9CD9-99BA341FBFE2', 'Apple iPad · Brainixa app', 'iPadOS 27.2', 'brainixa/5 CFNetwork/3896.200.41 Darwin/27.2.0', '84.203.5.35', 1, NULL, NULL, '2026-10-27 09:35:53', '2026-10-27 09:35:53'),
(197, 'student', 1111, '748d83c5-ea21-4365-9825-caa38351574e', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.199.69', 1, NULL, NULL, '2026-10-27 11:24:06', '2026-11-01 13:44:55'),
(198, 'student', 1110, '748d83c5-ea21-4365-9825-caa38351574e', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.243.251', 1, NULL, NULL, '2026-10-28 12:39:54', '2026-10-28 14:10:44'),
(199, 'student', 1109, '748d83c5-ea21-4365-9825-caa38351574e', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.243.251', 1, NULL, NULL, '2026-10-28 13:42:15', '2026-10-28 13:42:15'),
(203, 'student', 1111, '0483ceb9-8dea-4d66-84fb-995b9e297783', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.186.151', 1, NULL, NULL, '2026-10-29 09:52:09', '2026-10-29 09:52:09'),
(207, 'student', 1111, '07b9a403f3c82bfc', 'samsung SM-M515F · Brainixa app', 'Android 12', 'okhttp/4.12.0', '156.203.209.183', 1, NULL, NULL, '2026-10-31 13:39:58', '2026-11-05 11:54:47'),
(208, 'student', 1110, '0483ceb9-8dea-4d66-84fb-995b9e297783', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.199.69', 1, NULL, NULL, '2026-10-31 14:45:59', '2026-10-31 14:45:59'),
(213, 'student', 1110, '844208cf5b476512', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.9.2', '156.203.173.171', 1, NULL, NULL, '2026-11-02 08:53:34', '2026-11-03 14:36:39'),
(217, 'student', 1109, 'd178713e-f432-4aaf-a505-b718759d65a2', 'Edge · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', '156.203.173.171', 1, NULL, NULL, '2026-11-02 09:18:21', '2026-11-02 09:18:21'),
(218, 'student', 1113, '0483ceb9-8dea-4d66-84fb-995b9e297783', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.203.173.171', 1, NULL, NULL, '2026-11-02 09:22:24', '2026-11-02 09:22:24'),
(219, 'student', 1113, '844208cf5b476512', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.9.2', '156.203.173.171', 1, NULL, NULL, '2026-11-02 11:41:09', '2026-11-03 12:03:49'),
(220, 'student', 1109, '854c6580-ecb6-42f4-961f-22c52e639fd4', 'Chrome · Windows', 'Win32', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '156.217.102.75', 1, NULL, NULL, '2026-11-02 11:51:04', '2026-11-02 11:51:04'),
(224, 'student', 1113, 'eb01fb87dfd00d8a', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.9.2', '156.203.173.171', 1, NULL, NULL, '2026-11-03 07:11:54', '2026-11-03 07:11:54'),
(233, 'student', 1111, '844208cf5b476512', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.12.0', '156.203.173.171', 1, NULL, NULL, '2026-11-03 14:37:06', '2026-11-04 11:00:22'),
(237, 'student', 1111, 'eb01fb87dfd00d8a', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.12.0', '156.217.102.75', 1, NULL, NULL, '2026-11-05 08:51:38', '2026-11-05 09:51:05'),
(238, 'student', 1109, 'eb01fb87dfd00d8a', 'Redmi M2003J15SC · Brainixa app', 'Android 12', 'okhttp/4.12.0', '156.217.102.75', 1, NULL, NULL, '2026-11-05 09:25:48', '2026-11-05 11:32:21');

-- --------------------------------------------------------

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
-- Dumping data for table `videos`
--

INSERT INTO `videos` (`id`, `unit_id`, `order_num`, `code`, `video_url`, `duration_seconds`, `publish_status`, `is_active`, `created_at`, `updated_at`) VALUES
(4313, 4399, 1, 'full-alg-01', 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4', 860, 'published', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(4314, 4399, 2, 'full-alg-02', 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4', 780, 'published', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(4315, 4400, 1, 'full-trig-01', 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4', 1080, 'published', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(4316, 4400, 2, 'full-trig-02', 'https://camp-coding.online/brain-ixa/uploads/videos/vid_6ad4b3273623f8.23283842.mp4', 940, 'published', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30');

-- --------------------------------------------------------

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
-- Dumping data for table `videos_translations`
--

INSERT INTO `videos_translations` (`id`, `video_id`, `language_id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(11772, 4313, 1, 'المعادلات التربيعية — الحل بالتحليل', 'تحليل الحدّ الثلاثي إلى عاملين.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11773, 4313, 2, 'Quadratic Equations - Solving by Factoring', 'Factoring a trinomial into two factors.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11774, 4314, 1, 'المتباينات التربيعية', 'حلّ المتباينات ورسم خط الحل.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11775, 4314, 2, 'Quadratic Inequalities', 'Solving inequalities and the solution line.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11776, 4315, 1, 'الدائرة المثلثية والزوايا', 'تعريف الدائرة المثلثية وقياس الزوايا.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11777, 4315, 2, 'The Unit Circle and Angles', 'Defining the unit circle and measuring angles.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11778, 4316, 1, 'قانونا الجيب وجيب التمام', 'متى يُستعمل كل قانون، مع أمثلة.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(11779, 4316, 2, 'The Sine and Cosine Rules', 'When to use each rule, with examples.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30');

-- --------------------------------------------------------

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

-- --------------------------------------------------------

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
-- Dumping data for table `written_model_answers`
--

INSERT INTO `written_model_answers` (`id`, `question_id`, `is_active`, `created_at`, `updated_at`) VALUES
(9005, 9005, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9011, 9011, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9012, 9012, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9019, 9019, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9026, 9026, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9029, 9029, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9038, 9038, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9040, 9040, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9048, 9048, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9053, 9053, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9058, 9058, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9070, 9070, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9071, 9071, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9079, 9079, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9081, 9081, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9113, 9113, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9115, 9115, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9116, 9116, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9117, 9117, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9118, 9118, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9120, 9120, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9121, 9121, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9125, 9125, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9126, 9126, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9128, 9128, 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(9843, 41953, 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30');

-- --------------------------------------------------------

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
-- Dumping data for table `written_model_answers_translations`
--

INSERT INTO `written_model_answers_translations` (`id`, `written_model_answer_id`, `language_id`, `model_answer`, `is_active`, `created_at`, `updated_at`) VALUES
(30691, 9005, 1, 'نعزل المتغير: ننقل الحدود العددية للطرف الآخر مع تغيير الإشارة، ثم نقسم على معامل المتغير. مثال: 2س + 4 = 10 ← 2س = 6 ← س = 3.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30692, 9005, 2, 'Isolate the variable: move constants to the other side changing sign, then divide by the coefficient. Example: 2x + 4 = 10 -> 2x = 6 -> x = 3.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30693, 9011, 1, 'نطرح 40 من الطرفين: 12 س = 192، ثم نقسم على 12 فيكون س = 16. التحقق: 12 × 16 + 40 = 232.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30694, 9011, 2, 'Subtract 40 from both sides: 12x = 192, then divide by 12 giving x = 16. Check: 12 x 16 + 40 = 232.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30695, 9012, 1, 'نضرب العدد في النسبة ثم نقسم على 100. مثال: خصم 20% على 250 جنيه = 250 × 20 ÷ 100 = 50 جنيه.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30696, 9012, 2, 'Multiply the number by the rate and divide by 100. Example: 20% off 250 = 250 x 20 / 100 = 50.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30697, 9019, 1, 'نطرح 4 من الطرفين: 6 س = 120، ثم نقسم على 6 فيكون س = 20. التحقق: 6 × 20 + 4 = 124.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30698, 9019, 2, 'Subtract 4 from both sides: 6x = 120, then divide by 6 giving x = 20. Check: 6 x 20 + 4 = 124.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30699, 9026, 1, 'المحيط هو مجموع أطوال الأضلاع، والمساحة هي المسطح الداخلي. مستطيل 5×3: المحيط = 16، المساحة = 15.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30700, 9026, 2, 'Perimeter is the sum of the sides; area is the enclosed surface. For 5x3: perimeter = 16, area = 15.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30701, 9029, 1, 'ليكن العددان 2م+1 و 2ن+1. مجموعهما = 2(م + ن + 1)، وهو قابل للقسمة على 2، إذن المجموع زوجي.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30702, 9029, 2, 'Let them be 2m+1 and 2n+1. Their sum is 2(m + n + 1), divisible by 2, so it is even.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30703, 9038, 1, 'نطرح 3 من الطرفين: 9 س = 45، ثم نقسم على 9 فيكون س = 5. التحقق: 9 × 5 + 3 = 48.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30704, 9038, 2, 'Subtract 3 from both sides: 9x = 45, then divide by 9 giving x = 5. Check: 9 x 5 + 3 = 48.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30705, 9040, 1, 'نطرح 18 من الطرفين: 9 س = 108، ثم نقسم على 9 فيكون س = 12. التحقق: 9 × 12 + 18 = 126.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30706, 9040, 2, 'Subtract 18 from both sides: 9x = 108, then divide by 9 giving x = 12. Check: 9 x 12 + 18 = 126.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30707, 9048, 1, 'عندما يكون البسط أكبر من المقام. مثال: 7/4 و 9/5 كلاهما أكبر من 1.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30708, 9048, 2, 'When the numerator exceeds the denominator. For example 7/4 and 9/5 are both greater than 1.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30709, 9053, 1, 'نطرح 24 من الطرفين: 3 س = 51، ثم نقسم على 3 فيكون س = 17. التحقق: 3 × 17 + 24 = 75.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30710, 9053, 2, 'Subtract 24 from both sides: 3x = 51, then divide by 3 giving x = 17. Check: 3 x 17 + 24 = 75.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30711, 9058, 1, 'نطرح 28 من الطرفين: 8 س = 40، ثم نقسم على 8 فيكون س = 5. التحقق: 8 × 5 + 28 = 68.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30712, 9058, 2, 'Subtract 28 from both sides: 8x = 40, then divide by 8 giving x = 5. Check: 8 x 5 + 28 = 68.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30713, 9070, 1, 'نطرح 18 من الطرفين: 6 س = 78، ثم نقسم على 6 فيكون س = 13. التحقق: 6 × 13 + 18 = 96.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30714, 9070, 2, 'Subtract 18 from both sides: 6x = 78, then divide by 6 giving x = 13. Check: 6 x 13 + 18 = 96.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30715, 9071, 1, 'نطرح 32 من الطرفين: 8 س = 104، ثم نقسم على 8 فيكون س = 13. التحقق: 8 × 13 + 32 = 136.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30716, 9071, 2, 'Subtract 32 from both sides: 8x = 104, then divide by 8 giving x = 13. Check: 8 x 13 + 32 = 136.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30717, 9079, 1, 'نطرح 33 من الطرفين: 2 س = 4، ثم نقسم على 2 فيكون س = 2. التحقق: 2 × 2 + 33 = 37.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30718, 9079, 2, 'Subtract 33 from both sides: 2x = 4, then divide by 2 giving x = 2. Check: 2 x 2 + 33 = 37.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30719, 9081, 1, 'نطرح 12 من الطرفين: 11 س = 33، ثم نقسم على 11 فيكون س = 3. التحقق: 11 × 3 + 12 = 45.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30720, 9081, 2, 'Subtract 12 from both sides: 11x = 33, then divide by 11 giving x = 3. Check: 11 x 3 + 12 = 45.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30721, 9113, 1, 'نعزل المتغير: ننقل الحدود العددية للطرف الآخر مع تغيير الإشارة، ثم نقسم على معامل المتغير. مثال: 2س + 4 = 10 ← 2س = 6 ← س = 3.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30722, 9113, 2, 'Isolate the variable: move constants to the other side changing sign, then divide by the coefficient. Example: 2x + 4 = 10 -> 2x = 6 -> x = 3.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30723, 9115, 1, 'نطرح 34 من الطرفين: 8 س = 128، ثم نقسم على 8 فيكون س = 16. التحقق: 8 × 16 + 34 = 162.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30724, 9115, 2, 'Subtract 34 from both sides: 8x = 128, then divide by 8 giving x = 16. Check: 8 x 16 + 34 = 162.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30725, 9116, 1, 'نطرح 35 من الطرفين: 4 س = 60، ثم نقسم على 4 فيكون س = 15. التحقق: 4 × 15 + 35 = 95.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30726, 9116, 2, 'Subtract 35 from both sides: 4x = 60, then divide by 4 giving x = 15. Check: 4 x 15 + 35 = 95.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30727, 9117, 1, 'نطرح 24 من الطرفين: 4 س = 76، ثم نقسم على 4 فيكون س = 19. التحقق: 4 × 19 + 24 = 100.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30728, 9117, 2, 'Subtract 24 from both sides: 4x = 76, then divide by 4 giving x = 19. Check: 4 x 19 + 24 = 100.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30729, 9118, 1, 'نطرح 19 من الطرفين: 12 س = 36، ثم نقسم على 12 فيكون س = 3. التحقق: 12 × 3 + 19 = 55.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30730, 9118, 2, 'Subtract 19 from both sides: 12x = 36, then divide by 12 giving x = 3. Check: 12 x 3 + 19 = 55.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30731, 9120, 1, 'نطرح 40 من الطرفين: 3 س = 24، ثم نقسم على 3 فيكون س = 8. التحقق: 3 × 8 + 40 = 64.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30732, 9120, 2, 'Subtract 40 from both sides: 3x = 24, then divide by 3 giving x = 8. Check: 3 x 8 + 40 = 64.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30733, 9121, 1, 'نضرب العدد في النسبة ثم نقسم على 100. مثال: خصم 20% على 250 جنيه = 250 × 20 ÷ 100 = 50 جنيه.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30734, 9121, 2, 'Multiply the number by the rate and divide by 100. Example: 20% off 250 = 250 x 20 / 100 = 50.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30735, 9125, 1, 'نطرح 20 من الطرفين: 7 س = 84، ثم نقسم على 7 فيكون س = 12. التحقق: 7 × 12 + 20 = 104.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30736, 9125, 2, 'Subtract 20 from both sides: 7x = 84, then divide by 7 giving x = 12. Check: 7 x 12 + 20 = 104.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30737, 9126, 1, 'عندما يكون البسط أكبر من المقام. مثال: 7/4 و 9/5 كلاهما أكبر من 1.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30738, 9126, 2, 'When the numerator exceeds the denominator. For example 7/4 and 9/5 are both greater than 1.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30739, 9128, 1, 'نطرح 36 من الطرفين: 7 س = 35، ثم نقسم على 7 فيكون س = 5. التحقق: 7 × 5 + 36 = 71.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30740, 9128, 2, 'Subtract 36 from both sides: 7x = 35, then divide by 7 giving x = 5. Check: 7 x 5 + 36 = 71.', 1, '2026-10-07 13:33:13', '2026-10-07 13:33:13'),
(30741, 9843, 1, 'حين يكون المميّز سالبًا لا يوجد تحليل حقيقي؛ مثال: س² + س + ١ = ٠ ليس لها جذور حقيقية، فتُحلّ بالقانون العام أو يُكتب أنه لا يوجد حل حقيقي.', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30'),
(30742, 9843, 2, 'When the discriminant is negative there is no real factorisation; e.g. x² + x + 1 = 0 has no real roots, so it must be solved with the quadratic formula over complex numbers or left as \"no real solution\".', 1, '2026-11-02 09:20:30', '2026-11-02 09:20:30');

-- --------------------------------------------------------

--
-- Table structure for table `zoom_oauth_tokens`
--

CREATE TABLE `zoom_oauth_tokens` (
  `id` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `access_token` text NOT NULL,
  `expires_at` datetime NOT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `zoom_oauth_tokens`
--

INSERT INTO `zoom_oauth_tokens` (`id`, `access_token`, `expires_at`, `updated_at`) VALUES
(1, 'eyJzdiI6IjAwMDAwMyIsImFsZyI6IkhTNTEyIiwidiI6IjIuMCIsImtpZCI6IjRlMTdjZjY4LTcxNGUtNGIxMy04NjJhLTFhMTY0ZWFlN2NhYyJ9.eyJhdWQiOiJodHRwczovL29hdXRoLnpvb20udXMiLCJ1aWQiOiItcW95aDBIblFXcXlNMVJ4UDd6bGlnIiwidmVyIjoxMCwiYXVpZCI6IjFlM2IxYTY0M2NmM2UyZGVkNGNiZTY3Nzg0YjE1ODZhODZmNTFlMGQwMTRlZGIyNmZhN2ZjZGNhNWE3NDVlYjQiLCJuYmYiOjE3OTQwNTE5ODgsImNvZGUiOiJFRVVNdnVkV1E3bTVhd1ItUDdDLWJnd1JGcWk1cDNLMXUiLCJpc3MiOiJ6bTpjaWQ6cFJ4MjBLZG1TSXFqNEg3akZac1R2QSIsImdubyI6MCwiZXhwIjoxNzk0MDU1NTg4LCJ0eXBlIjozLCJpYXQiOjE3OTQwNTE5ODgsImFpZCI6Ims5aG16ZEIyUmM2MHkwYTN4R0lfTXcifQ.2TRetkNbNo1D9GfbiYUeXMYiEu9WkyaJogr-vwFEockTIhhIcjS9lIxD4FZaiPsUnTxFUSsbtRMWxQ_2wg-4rg', '2026-11-07 14:46:28', '2026-11-07 11:46:28');

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
-- Indexes for table `hero_slides`
--
ALTER TABLE `hero_slides`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_hero_slides_active_order` (`is_active`,`order_num`);

--
-- Indexes for table `homework`
--
ALTER TABLE `homework`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_hw_teacher` (`teacher_id`),
  ADD KEY `idx_hw_subject` (`subject_id`);

--
-- Indexes for table `homework_students`
--
ALTER TABLE `homework_students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_homework_student` (`homework_id`,`student_id`),
  ADD KEY `idx_homework_students_student` (`student_id`);

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
-- Indexes for table `manual_sales`
--
ALTER TABLE `manual_sales`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_manual_sales_status` (`status`),
  ADD KEY `idx_manual_sales_channel` (`channel`),
  ADD KEY `idx_manual_sales_item_type` (`item_type`),
  ADD KEY `idx_manual_sales_student` (`student_id`),
  ADD KEY `idx_manual_sales_created` (`created_at`);

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
  ADD UNIQUE KEY `uq_payment_transactions_gateway_reference` (`gateway_reference`),
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
  ADD KEY `idx_questions_type` (`question_type`),
  ADD KEY `idx_questions_bank_folder` (`is_bank`,`bank_folder_id`,`is_active`),
  ADD KEY `fk_questions_bank_folder` (`bank_folder_id`);

--
-- Indexes for table `questions_translations`
--
ALTER TABLE `questions_translations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_questions_translations` (`question_id`,`language_id`),
  ADD KEY `idx_questions_translations_language_id` (`language_id`);

--
-- Indexes for table `question_bank_folders`
--
ALTER TABLE `question_bank_folders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_qbf_owner` (`created_by_type`,`created_by_id`,`is_active`);

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
-- Indexes for table `session_ratings`
--
ALTER TABLE `session_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_session_rating` (`session_id`,`occurrence_date`,`student_id`),
  ADD KEY `idx_session_ratings_teacher` (`teacher_id`,`occurrence_date`),
  ADD KEY `idx_session_ratings_date` (`occurrence_date`),
  ADD KEY `fk_session_ratings_student` (`student_id`);

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
-- Indexes for table `session_zoom_meetings`
--
ALTER TABLE `session_zoom_meetings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_session_occurrence` (`session_id`,`session_date`),
  ADD KEY `idx_meeting_id` (`meeting_id`),
  ADD KEY `idx_teacher` (`teacher_id`,`session_date`);

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
  ADD KEY `idx_ss_end_date` (`end_date`),
  ADD KEY `idx_student_subscriptions_price` (`price`);

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
-- Indexes for table `zoom_oauth_tokens`
--
ALTER TABLE `zoom_oauth_tokens`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT for table `banners`
--
ALTER TABLE `banners`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `banner_views`
--
ALTER TABLE `banner_views`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1121;

--
-- AUTO_INCREMENT for table `book_teachers`
--
ALTER TABLE `book_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1028;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `cities_translations`
--
ALTER TABLE `cities_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `class_sessions`
--
ALTER TABLE `class_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=170;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=213;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=517;

--
-- AUTO_INCREMENT for table `courses_translations`
--
ALTER TABLE `courses_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3083;

--
-- AUTO_INCREMENT for table `course_books`
--
ALTER TABLE `course_books`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7679;

--
-- AUTO_INCREMENT for table `course_books_translations`
--
ALTER TABLE `course_books_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43882;

--
-- AUTO_INCREMENT for table `course_categories`
--
ALTER TABLE `course_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `course_categories_translations`
--
ALTER TABLE `course_categories_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `course_exams`
--
ALTER TABLE `course_exams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1976;

--
-- AUTO_INCREMENT for table `course_exams_translations`
--
ALTER TABLE `course_exams_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17724;

--
-- AUTO_INCREMENT for table `course_ratings`
--
ALTER TABLE `course_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1072;

--
-- AUTO_INCREMENT for table `course_teachers`
--
ALTER TABLE `course_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=566;

--
-- AUTO_INCREMENT for table `course_videos`
--
ALTER TABLE `course_videos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3153;

--
-- AUTO_INCREMENT for table `course_videos_translations`
--
ALTER TABLE `course_videos_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7305;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7106;

--
-- AUTO_INCREMENT for table `exam_attempt_answers`
--
ALTER TABLE `exam_attempt_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15462;

--
-- AUTO_INCREMENT for table `exam_teachers`
--
ALTER TABLE `exam_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1025;

--
-- AUTO_INCREMENT for table `hero_slides`
--
ALTER TABLE `hero_slides`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `homework`
--
ALTER TABLE `homework`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT for table `homework_students`
--
ALTER TABLE `homework_students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `homework_submissions`
--
ALTER TABLE `homework_submissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT for table `ip_country_cache`
--
ALTER TABLE `ip_country_cache`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

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
-- AUTO_INCREMENT for table `manual_sales`
--
ALTER TABLE `manual_sales`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mcq_options`
--
ALTER TABLE `mcq_options`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91730;

--
-- AUTO_INCREMENT for table `mcq_options_translations`
--
ALTER TABLE `mcq_options_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=171660;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=773;

--
-- AUTO_INCREMENT for table `notification_recipients`
--
ALTER TABLE `notification_recipients`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2268;

--
-- AUTO_INCREMENT for table `offline_payment_requests`
--
ALTER TABLE `offline_payment_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parents`
--
ALTER TABLE `parents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=323;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT for table `permissions_translations`
--
ALTER TABLE `permissions_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=310;

--
-- AUTO_INCREMENT for table `point_currency_values`
--
ALTER TABLE `point_currency_values`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=405;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41974;

--
-- AUTO_INCREMENT for table `questions_translations`
--
ALTER TABLE `questions_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86890;

--
-- AUTO_INCREMENT for table `question_bank_folders`
--
ALTER TABLE `question_bank_folders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=908;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1244;

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
-- AUTO_INCREMENT for table `session_ratings`
--
ALTER TABLE `session_ratings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `session_reschedule_requests`
--
ALTER TABLE `session_reschedule_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `session_zoom_meetings`
--
ALTER TABLE `session_zoom_meetings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `site_settings`
--
ALTER TABLE `site_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4763;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1114;

--
-- AUTO_INCREMENT for table `student_book_progress`
--
ALTER TABLE `student_book_progress`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `student_book_purchase_requests`
--
ALTER TABLE `student_book_purchase_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `student_book_subscriptions`
--
ALTER TABLE `student_book_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20138;

--
-- AUTO_INCREMENT for table `student_referrals`
--
ALTER TABLE `student_referrals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `student_reports`
--
ALTER TABLE `student_reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=195;

--
-- AUTO_INCREMENT for table `student_subscriptions`
--
ALTER TABLE `student_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1166;

--
-- AUTO_INCREMENT for table `student_subscription_books`
--
ALTER TABLE `student_subscription_books`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `student_subscription_courses`
--
ALTER TABLE `student_subscription_courses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1479;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=688;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=180;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=537;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10603;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4403;

--
-- AUTO_INCREMENT for table `units_translations`
--
ALTER TABLE `units_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10037;

--
-- AUTO_INCREMENT for table `unit_teachers`
--
ALTER TABLE `unit_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1075;

--
-- AUTO_INCREMENT for table `user_devices`
--
ALTER TABLE `user_devices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=250;

--
-- AUTO_INCREMENT for table `videos`
--
ALTER TABLE `videos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4317;

--
-- AUTO_INCREMENT for table `videos_translations`
--
ALTER TABLE `videos_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11780;

--
-- AUTO_INCREMENT for table `video_teachers`
--
ALTER TABLE `video_teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1145;

--
-- AUTO_INCREMENT for table `written_model_answers`
--
ALTER TABLE `written_model_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9844;

--
-- AUTO_INCREMENT for table `written_model_answers_translations`
--
ALTER TABLE `written_model_answers_translations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30743;

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
-- Constraints for table `homework_students`
--
ALTER TABLE `homework_students`
  ADD CONSTRAINT `fk_homework_students_homework` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_homework_students_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

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
  ADD CONSTRAINT `fk_questions_bank_folder` FOREIGN KEY (`bank_folder_id`) REFERENCES `question_bank_folders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
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
-- Constraints for table `session_ratings`
--
ALTER TABLE `session_ratings`
  ADD CONSTRAINT `fk_session_ratings_session` FOREIGN KEY (`session_id`) REFERENCES `class_sessions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_session_ratings_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_session_ratings_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

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
