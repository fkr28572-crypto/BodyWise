-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 25, 2026 at 03:49 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bodywise`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `activity_type_id` int(10) UNSIGNED DEFAULT NULL,
  `activity_date` date NOT NULL,
  `duration_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `distance_km` decimal(8,2) DEFAULT NULL,
  `steps` int(10) UNSIGNED DEFAULT NULL,
  `calories_burned_kcal` decimal(8,2) DEFAULT NULL,
  `source` enum('manual','device','imported') DEFAULT 'manual',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `activity_types`
--

CREATE TABLE `activity_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` enum('walking','running','cycling','sports','daily','other') DEFAULT 'other',
  `default_met` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `activity_types`
--

INSERT INTO `activity_types` (`id`, `name`, `category`, `default_met`) VALUES
(1, 'Walking', 'walking', 3.50),
(2, 'Running', 'running', 8.00),
(3, 'Cycling', 'cycling', 7.50),
(4, 'Basketball', 'sports', 6.50),
(5, 'Swimming', 'sports', 6.00),
(6, 'Daily Activity', 'daily', 2.50);

-- --------------------------------------------------------

--
-- Table structure for table `assessments`
--

CREATE TABLE `assessments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `age_years` tinyint(3) UNSIGNED DEFAULT NULL,
  `height_cm` decimal(5,2) DEFAULT NULL,
  `weight_kg` decimal(6,2) DEFAULT NULL,
  `activity_level` enum('sedentary','light','moderate','active','very_active') DEFAULT NULL,
  `exercise_experience` enum('beginner','intermediate','advanced') DEFAULT NULL,
  `preferred_location` enum('home','gym','outdoor','mixed') DEFAULT NULL,
  `available_workout_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `assessed_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `body_measurements`
--

CREATE TABLE `body_measurements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `measurement_date` date NOT NULL,
  `waist_cm` decimal(6,2) DEFAULT NULL,
  `chest_cm` decimal(6,2) DEFAULT NULL,
  `arm_cm` decimal(6,2) DEFAULT NULL,
  `thigh_cm` decimal(6,2) DEFAULT NULL,
  `neck_cm` decimal(6,2) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exercises`
--

CREATE TABLE `exercises` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `target_muscle` varchar(150) DEFAULT NULL,
  `category` enum('strength','cardio','mobility','flexibility','core','full_body') DEFAULT 'strength',
  `difficulty` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `equipment` varchar(150) DEFAULT NULL,
  `location` enum('home','gym','outdoor','any') DEFAULT 'any',
  `instructions` text DEFAULT NULL,
  `common_mistakes` text DEFAULT NULL,
  `alternative_exercise_id` bigint(20) UNSIGNED DEFAULT NULL,
  `duration_seconds` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exercises`
--

INSERT INTO `exercises` (`id`, `name`, `description`, `target_muscle`, `category`, `difficulty`, `equipment`, `location`, `instructions`, `common_mistakes`, `alternative_exercise_id`, `duration_seconds`, `created_at`, `updated_at`) VALUES
(1, 'Push Up', 'Latihan dorong menggunakan berat badan.', 'Chest, Triceps, Shoulders', 'strength', 'beginner', 'None', 'home', 'Posisikan tubuh lurus, turunkan badan secara terkontrol, lalu dorong kembali.', NULL, NULL, NULL, '2026-09-17 14:27:51', '2026-09-17 14:27:51'),
(2, 'Bodyweight Squat', 'Latihan squat menggunakan berat badan.', 'Quadriceps, Glutes', 'strength', 'beginner', 'None', 'home', 'Turunkan pinggul dengan kontrol kemudian kembali berdiri.', NULL, NULL, NULL, '2026-09-17 14:27:51', '2026-09-17 14:27:51'),
(3, 'Reverse Lunge', 'Latihan satu kaki dengan gerakan lunge ke belakang.', 'Glutes, Quadriceps', 'strength', 'beginner', 'None', 'home', 'Langkahkan satu kaki ke belakang dan turunkan tubuh secara terkontrol.', NULL, NULL, NULL, '2026-09-17 14:27:51', '2026-09-17 14:27:51'),
(4, 'Plank', 'Latihan isometrik untuk core.', 'Core', 'core', 'beginner', 'None', 'home', 'Pertahankan tubuh tetap lurus selama durasi yang ditentukan.', NULL, NULL, NULL, '2026-09-17 14:27:51', '2026-09-17 14:27:51'),
(5, 'Jumping Jack', 'Latihan kardio sederhana.', 'Full Body', 'cardio', 'beginner', 'None', 'home', 'Lakukan gerakan membuka dan menutup kaki serta tangan secara berulang.', NULL, NULL, NULL, '2026-09-17 14:27:51', '2026-09-17 14:27:51');

-- --------------------------------------------------------

--
-- Table structure for table `foods`
--

CREATE TABLE `foods` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `serving_size` decimal(8,2) DEFAULT 100.00,
  `serving_unit` varchar(30) DEFAULT 'g',
  `calories_kcal` decimal(8,2) DEFAULT 0.00,
  `protein_g` decimal(8,2) DEFAULT 0.00,
  `carbohydrates_g` decimal(8,2) DEFAULT 0.00,
  `fat_g` decimal(8,2) DEFAULT 0.00,
  `fiber_g` decimal(8,2) DEFAULT 0.00,
  `sodium_mg` decimal(9,2) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `source_name` varchar(150) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `food_categories`
--

CREATE TABLE `food_categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `food_categories`
--

INSERT INTO `food_categories` (`id`, `name`, `description`) VALUES
(1, 'Staple Food', 'Makanan pokok'),
(2, 'Protein', 'Sumber protein'),
(3, 'Vegetables', 'Sayuran'),
(4, 'Fruit', 'Buah-buahan'),
(5, 'Snack', 'Camilan'),
(6, 'Beverage', 'Minuman'),
(7, 'Indonesian Food', 'Makanan Indonesia');

-- --------------------------------------------------------

--
-- Table structure for table `food_logs`
--

CREATE TABLE `food_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `meal_type` enum('breakfast','lunch','dinner','snack','other') NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `logged_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `food_log_items`
--

CREATE TABLE `food_log_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `food_log_id` bigint(20) UNSIGNED NOT NULL,
  `food_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` decimal(8,2) DEFAULT 1.00,
  `serving_size` decimal(8,2) NOT NULL,
  `serving_unit` varchar(30) NOT NULL,
  `calories_kcal` decimal(8,2) DEFAULT 0.00,
  `protein_g` decimal(8,2) DEFAULT 0.00,
  `carbohydrates_g` decimal(8,2) DEFAULT 0.00,
  `fat_g` decimal(8,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goals`
--

CREATE TABLE `goals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `goal_type` enum('lose','gain','maintain') NOT NULL,
  `starting_weight_kg` decimal(6,2) DEFAULT NULL,
  `target_weight_kg` decimal(6,2) DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `target_calories_kcal` decimal(7,2) DEFAULT NULL,
  `target_water_ml` int(10) UNSIGNED DEFAULT NULL,
  `target_workout_days_per_week` tinyint(3) UNSIGNED DEFAULT NULL,
  `target_steps_per_day` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('active','completed','paused','cancelled') DEFAULT 'active',
  `started_at` date NOT NULL,
  `completed_at` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `habit_logs`
--

CREATE TABLE `habit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `habit_type_id` int(10) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `value` decimal(8,2) DEFAULT NULL,
  `completed` tinyint(1) DEFAULT 0,
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `habit_types`
--

CREATE TABLE `habit_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `unit` varchar(50) DEFAULT NULL,
  `default_target` decimal(8,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `habit_types`
--

INSERT INTO `habit_types` (`id`, `name`, `description`, `unit`, `default_target`, `is_active`) VALUES
(1, 'Drink Water', 'Mencapai target konsumsi air harian', 'ml', 2000.00, 1),
(2, 'Workout', 'Melakukan latihan sesuai rencana', 'session', 1.00, 1),
(3, 'Food Tracking', 'Mencatat makanan harian', 'day', 1.00, 1),
(4, 'Walking', 'Mencapai target langkah harian', 'steps', 8000.00, 1),
(5, 'Sleep', 'Menjaga kebiasaan tidur', 'hours', 7.00, 1);

-- --------------------------------------------------------

--
-- Table structure for table `program_adjustments`
--

CREATE TABLE `program_adjustments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `user_workout_program_id` bigint(20) UNSIGNED DEFAULT NULL,
  `evaluation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `adjustment_type` enum('increase','decrease','replace','schedule_change','duration_change','intensity_change','other') NOT NULL,
  `reason` varchar(255) NOT NULL,
  `old_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_value`)),
  `new_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_value`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `progress_evaluations`
--

CREATE TABLE `progress_evaluations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `goal_id` bigint(20) UNSIGNED DEFAULT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `starting_weight_kg` decimal(6,2) DEFAULT NULL,
  `ending_weight_kg` decimal(6,2) DEFAULT NULL,
  `weight_change_kg` decimal(7,2) DEFAULT NULL,
  `workout_days_completed` tinyint(3) UNSIGNED DEFAULT NULL,
  `food_tracking_days` tinyint(3) UNSIGNED DEFAULT NULL,
  `activity_days` tinyint(3) UNSIGNED DEFAULT NULL,
  `water_target_days` tinyint(3) UNSIGNED DEFAULT NULL,
  `sleep_average_minutes` decimal(7,2) DEFAULT NULL,
  `habit_completion_rate` decimal(5,2) DEFAULT NULL,
  `consistency_score` decimal(5,2) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reminders`
--

CREATE TABLE `reminders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(150) NOT NULL,
  `reminder_type` enum('workout','meal','water','sleep','weight','habit','tracking','other') DEFAULT 'other',
  `message` varchar(255) DEFAULT NULL,
  `reminder_time` time NOT NULL,
  `days_of_week` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`days_of_week`)),
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reminder_logs`
--

CREATE TABLE `reminder_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reminder_id` bigint(20) UNSIGNED NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `sent_at` datetime DEFAULT NULL,
  `opened_at` datetime DEFAULT NULL,
  `status` enum('scheduled','sent','opened','completed','missed') DEFAULT 'scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sleep_logs`
--

CREATE TABLE `sleep_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `sleep_date` date NOT NULL,
  `bedtime` datetime DEFAULT NULL,
  `wake_time` datetime DEFAULT NULL,
  `duration_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `sleep_quality` tinyint(3) UNSIGNED DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `status`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'Fatur ', 'fatur12@gmail.com', 'fatur1234', 'user', 'active', NULL, '2026-10-25 14:28:31', '2026-10-25 14:28:31');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `birth_date` date DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') DEFAULT NULL,
  `height_cm` decimal(5,2) DEFAULT NULL,
  `activity_level` enum('sedentary','light','moderate','active','very_active') DEFAULT NULL,
  `exercise_experience` enum('beginner','intermediate','advanced') DEFAULT NULL,
  `preferred_location` enum('home','gym','outdoor','mixed') DEFAULT NULL,
  `available_workout_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `equipment_notes` varchar(255) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'Asia/Jakarta',
  `profile_photo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_workout_programs`
--

CREATE TABLE `user_workout_programs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `program_id` bigint(20) UNSIGNED NOT NULL,
  `goal_id` bigint(20) UNSIGNED DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('active','completed','paused','replaced') DEFAULT 'active',
  `adjustment_reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `water_logs`
--

CREATE TABLE `water_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `amount_ml` int(10) UNSIGNED NOT NULL,
  `logged_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `weight_logs`
--

CREATE TABLE `weight_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `weight_kg` decimal(6,2) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workout_logs`
--

CREATE TABLE `workout_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `user_workout_program_id` bigint(20) UNSIGNED DEFAULT NULL,
  `program_day_id` bigint(20) UNSIGNED DEFAULT NULL,
  `workout_date` date NOT NULL,
  `duration_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `status` enum('planned','completed','partial','skipped') DEFAULT 'completed',
  `notes` varchar(255) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workout_log_exercises`
--

CREATE TABLE `workout_log_exercises` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `workout_log_id` bigint(20) UNSIGNED NOT NULL,
  `exercise_id` bigint(20) UNSIGNED NOT NULL,
  `sets_completed` tinyint(3) UNSIGNED DEFAULT NULL,
  `reps_completed` varchar(30) DEFAULT NULL,
  `duration_seconds` int(10) UNSIGNED DEFAULT NULL,
  `weight_kg` decimal(7,2) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workout_programs`
--

CREATE TABLE `workout_programs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `goal_type` enum('lose','gain','maintain','general') DEFAULT 'general',
  `experience_level` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `location` enum('home','gym','outdoor','mixed') DEFAULT 'mixed',
  `duration_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `days_per_week` tinyint(3) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workout_program_days`
--

CREATE TABLE `workout_program_days` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `program_id` bigint(20) UNSIGNED NOT NULL,
  `day_number` tinyint(3) UNSIGNED NOT NULL,
  `day_name` varchar(100) NOT NULL,
  `focus` varchar(100) DEFAULT NULL,
  `rest_day` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workout_program_exercises`
--

CREATE TABLE `workout_program_exercises` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `program_day_id` bigint(20) UNSIGNED NOT NULL,
  `exercise_id` bigint(20) UNSIGNED NOT NULL,
  `order_number` tinyint(3) UNSIGNED NOT NULL,
  `sets_count` tinyint(3) UNSIGNED DEFAULT NULL,
  `reps_target` varchar(30) DEFAULT NULL,
  `duration_seconds` int(10) UNSIGNED DEFAULT NULL,
  `rest_seconds` int(10) UNSIGNED DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `activity_type_id` (`activity_type_id`);

--
-- Indexes for table `activity_types`
--
ALTER TABLE `activity_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `assessments`
--
ALTER TABLE `assessments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `body_measurements`
--
ALTER TABLE `body_measurements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `exercises`
--
ALTER TABLE `exercises`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alternative_exercise_id` (`alternative_exercise_id`);

--
-- Indexes for table `foods`
--
ALTER TABLE `foods`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `food_categories`
--
ALTER TABLE `food_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `food_logs`
--
ALTER TABLE `food_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `food_log_items`
--
ALTER TABLE `food_log_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `food_log_id` (`food_log_id`),
  ADD KEY `food_id` (`food_id`);

--
-- Indexes for table `goals`
--
ALTER TABLE `goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `habit_logs`
--
ALTER TABLE `habit_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`habit_type_id`,`log_date`),
  ADD KEY `habit_type_id` (`habit_type_id`);

--
-- Indexes for table `habit_types`
--
ALTER TABLE `habit_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `program_adjustments`
--
ALTER TABLE `program_adjustments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `user_workout_program_id` (`user_workout_program_id`),
  ADD KEY `evaluation_id` (`evaluation_id`);

--
-- Indexes for table `progress_evaluations`
--
ALTER TABLE `progress_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `goal_id` (`goal_id`);

--
-- Indexes for table `reminders`
--
ALTER TABLE `reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `reminder_logs`
--
ALTER TABLE `reminder_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reminder_id` (`reminder_id`);

--
-- Indexes for table `sleep_logs`
--
ALTER TABLE `sleep_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `user_workout_programs`
--
ALTER TABLE `user_workout_programs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `program_id` (`program_id`),
  ADD KEY `goal_id` (`goal_id`);

--
-- Indexes for table `water_logs`
--
ALTER TABLE `water_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `weight_logs`
--
ALTER TABLE `weight_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`log_date`);

--
-- Indexes for table `workout_logs`
--
ALTER TABLE `workout_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `user_workout_program_id` (`user_workout_program_id`),
  ADD KEY `program_day_id` (`program_day_id`);

--
-- Indexes for table `workout_log_exercises`
--
ALTER TABLE `workout_log_exercises`
  ADD PRIMARY KEY (`id`),
  ADD KEY `workout_log_id` (`workout_log_id`),
  ADD KEY `exercise_id` (`exercise_id`);

--
-- Indexes for table `workout_programs`
--
ALTER TABLE `workout_programs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `workout_program_days`
--
ALTER TABLE `workout_program_days`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `program_id` (`program_id`,`day_number`);

--
-- Indexes for table `workout_program_exercises`
--
ALTER TABLE `workout_program_exercises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `program_day_id` (`program_day_id`,`order_number`),
  ADD KEY `exercise_id` (`exercise_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `activity_types`
--
ALTER TABLE `activity_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `assessments`
--
ALTER TABLE `assessments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `body_measurements`
--
ALTER TABLE `body_measurements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exercises`
--
ALTER TABLE `exercises`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `foods`
--
ALTER TABLE `foods`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `food_categories`
--
ALTER TABLE `food_categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `food_logs`
--
ALTER TABLE `food_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `food_log_items`
--
ALTER TABLE `food_log_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `goals`
--
ALTER TABLE `goals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `habit_logs`
--
ALTER TABLE `habit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `habit_types`
--
ALTER TABLE `habit_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `program_adjustments`
--
ALTER TABLE `program_adjustments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `progress_evaluations`
--
ALTER TABLE `progress_evaluations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reminders`
--
ALTER TABLE `reminders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reminder_logs`
--
ALTER TABLE `reminder_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sleep_logs`
--
ALTER TABLE `sleep_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_workout_programs`
--
ALTER TABLE `user_workout_programs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `water_logs`
--
ALTER TABLE `water_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `weight_logs`
--
ALTER TABLE `weight_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `workout_logs`
--
ALTER TABLE `workout_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `workout_log_exercises`
--
ALTER TABLE `workout_log_exercises`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `workout_programs`
--
ALTER TABLE `workout_programs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `workout_program_days`
--
ALTER TABLE `workout_program_days`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `workout_program_exercises`
--
ALTER TABLE `workout_program_exercises`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `activity_logs_ibfk_2` FOREIGN KEY (`activity_type_id`) REFERENCES `activity_types` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `assessments`
--
ALTER TABLE `assessments`
  ADD CONSTRAINT `assessments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `body_measurements`
--
ALTER TABLE `body_measurements`
  ADD CONSTRAINT `body_measurements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `exercises`
--
ALTER TABLE `exercises`
  ADD CONSTRAINT `exercises_ibfk_1` FOREIGN KEY (`alternative_exercise_id`) REFERENCES `exercises` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `foods`
--
ALTER TABLE `foods`
  ADD CONSTRAINT `foods_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `food_categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `food_logs`
--
ALTER TABLE `food_logs`
  ADD CONSTRAINT `food_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `food_log_items`
--
ALTER TABLE `food_log_items`
  ADD CONSTRAINT `food_log_items_ibfk_1` FOREIGN KEY (`food_log_id`) REFERENCES `food_logs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `food_log_items_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `foods` (`id`);

--
-- Constraints for table `goals`
--
ALTER TABLE `goals`
  ADD CONSTRAINT `goals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `habit_logs`
--
ALTER TABLE `habit_logs`
  ADD CONSTRAINT `habit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `habit_logs_ibfk_2` FOREIGN KEY (`habit_type_id`) REFERENCES `habit_types` (`id`);

--
-- Constraints for table `program_adjustments`
--
ALTER TABLE `program_adjustments`
  ADD CONSTRAINT `program_adjustments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `program_adjustments_ibfk_2` FOREIGN KEY (`user_workout_program_id`) REFERENCES `user_workout_programs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `program_adjustments_ibfk_3` FOREIGN KEY (`evaluation_id`) REFERENCES `progress_evaluations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `progress_evaluations`
--
ALTER TABLE `progress_evaluations`
  ADD CONSTRAINT `progress_evaluations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `progress_evaluations_ibfk_2` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `reminders`
--
ALTER TABLE `reminders`
  ADD CONSTRAINT `reminders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reminder_logs`
--
ALTER TABLE `reminder_logs`
  ADD CONSTRAINT `reminder_logs_ibfk_1` FOREIGN KEY (`reminder_id`) REFERENCES `reminders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sleep_logs`
--
ALTER TABLE `sleep_logs`
  ADD CONSTRAINT `sleep_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_workout_programs`
--
ALTER TABLE `user_workout_programs`
  ADD CONSTRAINT `user_workout_programs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_workout_programs_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `workout_programs` (`id`),
  ADD CONSTRAINT `user_workout_programs_ibfk_3` FOREIGN KEY (`goal_id`) REFERENCES `goals` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `water_logs`
--
ALTER TABLE `water_logs`
  ADD CONSTRAINT `water_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `weight_logs`
--
ALTER TABLE `weight_logs`
  ADD CONSTRAINT `weight_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `workout_logs`
--
ALTER TABLE `workout_logs`
  ADD CONSTRAINT `workout_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `workout_logs_ibfk_2` FOREIGN KEY (`user_workout_program_id`) REFERENCES `user_workout_programs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `workout_logs_ibfk_3` FOREIGN KEY (`program_day_id`) REFERENCES `workout_program_days` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `workout_log_exercises`
--
ALTER TABLE `workout_log_exercises`
  ADD CONSTRAINT `workout_log_exercises_ibfk_1` FOREIGN KEY (`workout_log_id`) REFERENCES `workout_logs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `workout_log_exercises_ibfk_2` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`);

--
-- Constraints for table `workout_program_days`
--
ALTER TABLE `workout_program_days`
  ADD CONSTRAINT `workout_program_days_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `workout_programs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `workout_program_exercises`
--
ALTER TABLE `workout_program_exercises`
  ADD CONSTRAINT `workout_program_exercises_ibfk_1` FOREIGN KEY (`program_day_id`) REFERENCES `workout_program_days` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `workout_program_exercises_ibfk_2` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
