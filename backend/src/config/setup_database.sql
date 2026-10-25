-- ========================================================
-- BODYWISE DATABASE SETUP
-- Jalankan file ini di phpMyAdmin atau MySQL / MariaDB
-- ========================================================

CREATE DATABASE IF NOT EXISTS bodywise_app
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bodywise_app;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(254) NOT NULL,
  health_focus ENUM('energy', 'weight', 'strength', 'consistency') NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_profiles (
  user_id BIGINT UNSIGNED NOT NULL,
  birth_date DATE NULL,
  sex ENUM('male', 'female', 'other', 'prefer_not_to_say') NULL,
  height_cm DECIMAL(5,2) NULL,
  activity_level ENUM('sedentary', 'light', 'moderate', 'very_active') NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_profiles_height CHECK (height_cm IS NULL OR height_cm BETWEEN 100 AND 250)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS body_assessments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  assessed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  age_years TINYINT UNSIGNED NOT NULL,
  sex ENUM('male', 'female', 'other', 'prefer_not_to_say') NOT NULL,
  height_cm DECIMAL(5,2) NOT NULL,
  weight_kg DECIMAL(6,2) NOT NULL,
  activity_level ENUM('sedentary', 'light', 'moderate', 'very_active') NOT NULL,
  bmi DECIMAL(5,2) NOT NULL,
  bmr_kcal DECIMAL(7,2) NULL,
  tdee_kcal DECIMAL(7,2) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_assessments_user_date (user_id, assessed_at),
  CONSTRAINT fk_assessments_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_assessment_age CHECK (age_years BETWEEN 13 AND 100),
  CONSTRAINT chk_assessment_height CHECK (height_cm BETWEEN 100 AND 250),
  CONSTRAINT chk_assessment_weight CHECK (weight_kg BETWEEN 30 AND 300)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS weight_goals (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  goal_type ENUM('lose', 'maintain', 'gain') NOT NULL,
  target_weight_kg DECIMAL(6,2) NOT NULL,
  start_weight_kg DECIMAL(6,2) NULL,
  start_date DATE NOT NULL,
  target_date DATE NOT NULL,
  status ENUM('active', 'completed', 'cancelled') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_goals_user_status_date (user_id, status, target_date),
  CONSTRAINT fk_goals_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_goal_weight CHECK (target_weight_kg BETWEEN 30 AND 300),
  CONSTRAINT chk_goal_dates CHECK (target_date >= start_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS food_catalog (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  brand VARCHAR(120) NULL,
  category VARCHAR(80) NULL,
  calories_per_100g DECIMAL(7,2) NOT NULL,
  protein_g_per_100g DECIMAL(7,2) NOT NULL DEFAULT 0,
  carbs_g_per_100g DECIMAL(7,2) NOT NULL DEFAULT 0,
  fat_g_per_100g DECIMAL(7,2) NOT NULL DEFAULT 0,
  fiber_g_per_100g DECIMAL(7,2) NOT NULL DEFAULT 0,
  nutrition_verified BOOLEAN NOT NULL DEFAULT FALSE,
  source_note VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_food_name (name),
  CONSTRAINT chk_food_calories CHECK (calories_per_100g BETWEEN 0 AND 1000),
  CONSTRAINT chk_food_protein CHECK (protein_g_per_100g BETWEEN 0 AND 100),
  CONSTRAINT chk_food_carbs CHECK (carbs_g_per_100g BETWEEN 0 AND 100),
  CONSTRAINT chk_food_fat CHECK (fat_g_per_100g BETWEEN 0 AND 100),
  CONSTRAINT chk_food_fiber CHECK (fiber_g_per_100g BETWEEN 0 AND 100)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS food_aliases (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  food_id BIGINT UNSIGNED NOT NULL,
  alias VARCHAR(120) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_food_alias (alias),
  KEY idx_food_alias_food (food_id),
  CONSTRAINT fk_food_alias_food FOREIGN KEY (food_id) REFERENCES food_catalog (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS food_portions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  food_id BIGINT UNSIGNED NOT NULL,
  serving_name VARCHAR(80) NOT NULL,
  serving_grams DECIMAL(7,2) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_food_portion (food_id, serving_name),
  KEY idx_food_portion_default (food_id, is_default),
  CONSTRAINT fk_food_portion_food FOREIGN KEY (food_id) REFERENCES food_catalog (id) ON DELETE CASCADE,
  CONSTRAINT chk_food_portion_grams CHECK (serving_grams BETWEEN 1 AND 5000)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS food_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  food_id BIGINT UNSIGNED NULL,
  food_name VARCHAR(120) NOT NULL,
  meal_type ENUM('breakfast', 'lunch', 'snack', 'dinner', 'other') NOT NULL,
  quantity_g DECIMAL(7,2) NOT NULL,
  calories DECIMAL(8,2) NOT NULL,
  protein_g DECIMAL(8,2) NOT NULL DEFAULT 0,
  carbs_g DECIMAL(8,2) NOT NULL DEFAULT 0,
  fat_g DECIMAL(8,2) NOT NULL DEFAULT 0,
  fiber_g DECIMAL(8,2) NOT NULL DEFAULT 0,
  logged_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_food_logs_user_date (user_id, logged_at),
  CONSTRAINT fk_food_logs_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_food_logs_food FOREIGN KEY (food_id) REFERENCES food_catalog (id) ON DELETE SET NULL,
  CONSTRAINT chk_food_log_quantity CHECK (quantity_g BETWEEN 1 AND 5000),
  CONSTRAINT chk_food_log_calories CHECK (calories BETWEEN 0 AND 50000)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exercises (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  category ENUM('strength', 'cardio', 'mobility', 'bodyweight') NOT NULL,
  tracking_type ENUM('sets_reps', 'duration', 'distance', 'mixed') NOT NULL DEFAULT 'sets_reps',
  description VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_exercises_name (name),
  KEY idx_exercises_category_name (category, name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workout_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  started_at DATETIME NOT NULL,
  duration_minutes SMALLINT UNSIGNED NULL,
  status ENUM('planned', 'completed', 'cancelled') NOT NULL DEFAULT 'completed',
  notes VARCHAR(1000) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_workouts_user_date (user_id, started_at),
  CONSTRAINT fk_workouts_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_workout_duration CHECK (duration_minutes IS NULL OR duration_minutes BETWEEN 1 AND 1440)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workout_sets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  workout_session_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  set_number SMALLINT UNSIGNED NULL,
  reps SMALLINT UNSIGNED NULL,
  weight_kg DECIMAL(7,2) NULL,
  duration_seconds INT UNSIGNED NULL,
  distance_m DECIMAL(9,2) NULL,
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_workout_sets_session (workout_session_id),
  CONSTRAINT fk_sets_session FOREIGN KEY (workout_session_id) REFERENCES workout_sessions (id) ON DELETE CASCADE,
  CONSTRAINT fk_sets_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id),
  CONSTRAINT chk_set_reps CHECK (reps IS NULL OR reps BETWEEN 1 AND 1000),
  CONSTRAINT chk_set_weight CHECK (weight_kg IS NULL OR weight_kg BETWEEN 0 AND 2000)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS weight_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  weight_kg DECIMAL(6,2) NOT NULL,
  logged_on DATE NOT NULL,
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_weight_logs_user_date (user_id, logged_on),
  CONSTRAINT fk_weight_logs_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT chk_weight_log CHECK (weight_kg BETWEEN 30 AND 300)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS daily_habits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  habit_date DATE NOT NULL,
  water_completed BOOLEAN NOT NULL DEFAULT FALSE,
  workout_completed BOOLEAN NOT NULL DEFAULT FALSE,
  food_logged BOOLEAN NOT NULL DEFAULT FALSE,
  sleep_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_habits_user_day (user_id, habit_date),
  CONSTRAINT fk_habits_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chat_conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(120) NOT NULL DEFAULT 'Percakapan baru',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_conversations_user_updated (user_id, updated_at),
  CONSTRAINT fk_conversations_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chat_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  role ENUM('user', 'assistant') NOT NULL,
  content VARCHAR(2000) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_messages_conversation_created (conversation_id, created_at),
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES chat_conversations (id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT IGNORE INTO exercises (name, category, tracking_type) VALUES
  ('Push Up', 'bodyweight', 'sets_reps'),
  ('Pull Up', 'bodyweight', 'sets_reps'),
  ('Bench Press', 'strength', 'sets_reps'),
  ('Incline Dumbbell Press', 'strength', 'sets_reps'),
  ('Lat Pulldown', 'strength', 'sets_reps'),
  ('Barbell Row', 'strength', 'sets_reps'),
  ('Shoulder Press', 'strength', 'sets_reps'),
  ('Lateral Raise', 'strength', 'sets_reps'),
  ('Biceps Curl', 'strength', 'sets_reps'),
  ('Triceps Pushdown', 'strength', 'sets_reps'),
  ('Squat', 'strength', 'sets_reps'),
  ('Leg Press', 'strength', 'sets_reps'),
  ('Romanian Deadlift', 'strength', 'sets_reps'),
  ('Plank', 'bodyweight', 'duration'),
  ('Treadmill Walk', 'cardio', 'mixed');

CREATE TABLE IF NOT EXISTS workout_programs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(100) NOT NULL,
  name VARCHAR(120) NOT NULL,
  level VARCHAR(40) NOT NULL,
  duration_weeks TINYINT UNSIGNED NOT NULL,
  session_duration VARCHAR(20) NOT NULL,
  frequency VARCHAR(160) NOT NULL,
  safety_notes VARCHAR(1000) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_workout_program_slug (slug)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workout_program_days (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  program_id BIGINT UNSIGNED NOT NULL,
  day_number TINYINT UNSIGNED NOT NULL,
  day_name VARCHAR(20) NOT NULL,
  focus VARCHAR(120) NOT NULL,
  duration_min SMALLINT UNSIGNED NOT NULL,
  duration_max SMALLINT UNSIGNED NOT NULL,
  notes VARCHAR(500) NOT NULL DEFAULT '',
  is_rest BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_workout_program_day (program_id, day_number),
  CONSTRAINT fk_workout_program_days_program FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE,
  CONSTRAINT chk_workout_program_day_number CHECK (day_number BETWEEN 1 AND 7),
  CONSTRAINT chk_workout_program_duration CHECK (duration_max >= duration_min)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workout_program_movements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  program_day_id BIGINT UNSIGNED NOT NULL,
  exercise_id BIGINT UNSIGNED NOT NULL,
  location ENUM('gym', 'rumah') NOT NULL,
  sequence_number TINYINT UNSIGNED NOT NULL,
  muscle_group VARCHAR(80) NOT NULL,
  supporting_muscles VARCHAR(160) NOT NULL DEFAULT '',
  equipment VARCHAR(160) NOT NULL DEFAULT '',
  sets SMALLINT UNSIGNED NOT NULL,
  reps VARCHAR(40) NOT NULL,
  rep_unit VARCHAR(40) NOT NULL,
  rest_seconds SMALLINT UNSIGNED NOT NULL,
  tips VARCHAR(500) NOT NULL DEFAULT '',
  home_alternative VARCHAR(160) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  UNIQUE KEY uq_workout_program_movement (program_day_id, location, sequence_number),
  KEY idx_program_movement_exercise (exercise_id),
  CONSTRAINT fk_program_movement_day FOREIGN KEY (program_day_id) REFERENCES workout_program_days (id) ON DELETE CASCADE,
  CONSTRAINT fk_program_movement_exercise FOREIGN KEY (exercise_id) REFERENCES exercises (id),
  CONSTRAINT chk_program_movement_sequence CHECK (sequence_number BETWEEN 1 AND 30),
  CONSTRAINT chk_program_movement_sets CHECK (sets BETWEEN 1 AND 50)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workout_program_progression (
  program_id BIGINT UNSIGNED NOT NULL,
  week_number TINYINT UNSIGNED NOT NULL,
  focus VARCHAR(120) NOT NULL,
  guidance VARCHAR(500) NOT NULL,
  PRIMARY KEY (program_id, week_number),
  CONSTRAINT fk_workout_progression_program FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE,
  CONSTRAINT chk_workout_progression_week CHECK (week_number BETWEEN 1 AND 4)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workout_program_warmups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  program_id BIGINT UNSIGNED NOT NULL,
  phase ENUM('pemanasan', 'pendinginan') NOT NULL,
  sequence_number TINYINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  duration VARCHAR(80) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_workout_program_warmup (program_id, phase, sequence_number),
  CONSTRAINT fk_workout_warmups_program FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_workout_preferences (
  user_id BIGINT UNSIGNED NOT NULL,
  program_id BIGINT UNSIGNED NOT NULL,
  location ENUM('gym', 'rumah') NOT NULL DEFAULT 'rumah',
  start_date DATE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  KEY idx_workout_preferences_program (program_id),
  CONSTRAINT fk_workout_preferences_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_workout_preferences_program FOREIGN KEY (program_id) REFERENCES workout_programs (id)
) ENGINE=InnoDB;

-- Default Seeds untuk Food Catalog & Portions
INSERT INTO food_catalog
  (name, brand, calories_per_100g, protein_g_per_100g, carbs_g_per_100g, fat_g_per_100g, nutrition_verified, source_note)
SELECT seed.name, seed.brand, seed.calories, seed.protein, seed.carbs, seed.fat, FALSE,
  'Perkiraan nilai generik per 100 g; dapat berbeda menurut varietas, merek, dan cara memasak.'
FROM (
  SELECT 'Nasi putih matang' AS name, NULL AS brand, 130.00 AS calories, 2.69 AS protein, 28.17 AS carbs, 0.28 AS fat
  UNION ALL SELECT 'Nasi merah matang', NULL, 123.00, 2.74, 25.58, 0.97
  UNION ALL SELECT 'Telur ayam utuh', NULL, 143.00, 12.56, 0.72, 9.51
  UNION ALL SELECT 'Dada ayam matang', NULL, 165.00, 31.02, 0.00, 3.57
  UNION ALL SELECT 'Daging sapi matang', NULL, 217.00, 26.10, 0.00, 11.80
  UNION ALL SELECT 'Tempe', NULL, 193.00, 20.29, 7.64, 10.80
  UNION ALL SELECT 'Tahu putih', NULL, 76.00, 8.08, 1.87, 4.78
  UNION ALL SELECT 'Pisang', NULL, 89.00, 1.09, 22.84, 0.33
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM food_catalog existing WHERE existing.name = seed.name);

INSERT INTO food_aliases (food_id, alias)
SELECT f.id, aliases.alias
FROM (
  SELECT 'Nasi putih matang' AS food_name, 'nasi' AS alias UNION ALL
  SELECT 'Nasi putih matang', 'nasi putih' UNION ALL
  SELECT 'Nasi putih matang', 'beras putih matang' UNION ALL
  SELECT 'Nasi merah matang', 'nasi merah' UNION ALL
  SELECT 'Nasi merah matang', 'beras merah matang' UNION ALL
  SELECT 'Telur ayam utuh', 'telur' UNION ALL
  SELECT 'Telur ayam utuh', 'telor' UNION ALL
  SELECT 'Telur ayam utuh', 'telur ayam' UNION ALL
  SELECT 'Telur ayam utuh', 'telor ayam' UNION ALL
  SELECT 'Dada ayam matang', 'ayam' UNION ALL
  SELECT 'Dada ayam matang', 'dada ayam' UNION ALL
  SELECT 'Dada ayam matang', 'ayam tanpa kulit' UNION ALL
  SELECT 'Daging sapi matang', 'sapi' UNION ALL
  SELECT 'Daging sapi matang', 'daging sapi' UNION ALL
  SELECT 'Tempe', 'tempeh' UNION ALL
  SELECT 'Tahu putih', 'tahu' UNION ALL
  SELECT 'Tahu putih', 'tofu' UNION ALL
  SELECT 'Pisang', 'banana'
) AS aliases
JOIN food_catalog f ON f.name = aliases.food_name
WHERE NOT EXISTS (SELECT 1 FROM food_aliases existing WHERE existing.alias = aliases.alias);

INSERT INTO food_portions (food_id, serving_name, serving_grams, is_default)
SELECT f.id, portions.serving_name, portions.serving_grams, TRUE
FROM (
  SELECT 'Nasi putih matang' AS food_name, '1 centong (100 g)' AS serving_name, 100.00 AS serving_grams UNION ALL
  SELECT 'Nasi merah matang', '1 centong (100 g)', 100.00 UNION ALL
  SELECT 'Telur ayam utuh', '1 butir (50 g)', 50.00 UNION ALL
  SELECT 'Dada ayam matang', '1 potong (100 g)', 100.00 UNION ALL
  SELECT 'Daging sapi matang', '1 porsi (100 g)', 100.00 UNION ALL
  SELECT 'Tempe', '1 potong (25 g)', 25.00 UNION ALL
  SELECT 'Tahu putih', '1 potong (50 g)', 50.00 UNION ALL
  SELECT 'Pisang', '1 buah sedang (118 g)', 118.00
) AS portions
JOIN food_catalog f ON f.name = portions.food_name
WHERE NOT EXISTS (
  SELECT 1 FROM food_portions existing
  WHERE existing.food_id = f.id AND existing.serving_name = portions.serving_name
);

-- Default Seeds untuk Workout Program
INSERT INTO workout_programs (id, slug, name, level, duration_weeks, session_duration, frequency, safety_notes)
VALUES (1, 'program-latihan-pemula-4-minggu', 'Program Latihan Pemula 4 Minggu', 'Pemula', 4, '45-60 menit', '3-4 hari per minggu', 'Lakukan pemanasan sebelum latihan dan pendinginan setelahnya. Beristirahatlah jika merasa nyeri atau kelelahan berlebih.')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT IGNORE INTO workout_program_days (id, program_id, day_number, day_name, focus, duration_min, duration_max, notes, is_rest) VALUES
(1, 1, 1, 'Senin', 'Latihan Tubuh Atas & Core', 45, 60, 'Fokus pada bentuk gerakan dan kontrol napas.', FALSE),
(2, 1, 2, 'Selasa', 'Pemulihan Aktif', 20, 30, 'Jalan santai atau peregangan ringan.', TRUE),
(3, 1, 3, 'Rabu', 'Latihan Tubuh Bawah', 45, 60, 'Jaga keseimbangan dan kedalaman squat.', FALSE),
(4, 1, 4, 'Kamis', 'Istirahat Total', 0, 0, 'Istirahat dan hidrasi cukup.', TRUE),
(5, 1, 5, 'Jumat', 'Full Body & Kardio', 45, 60, 'Kombinasi kekuatan dan stamina.', FALSE),
(6, 1, 6, 'Sabtu', 'Mobilitas & Kardio Ringan', 30, 45, 'Aktivitas luar ruangan atau treadmill.', FALSE),
(7, 1, 7, 'Minggu', 'Istirahat Total', 0, 0, 'Persiapan untuk minggu berikutnya.', TRUE);

INSERT IGNORE INTO workout_program_movements (program_day_id, exercise_id, location, sequence_number, muscle_group, supporting_muscles, equipment, sets, reps, rep_unit, rest_seconds, tips, home_alternative) VALUES
(1, 1, 'rumah', 1, 'Dada', 'Trisep, Bahu', 'Tanpa alat', 3, '10-12', 'rep', 60, 'Jaga punggung tetap lurus.', 'Push up bertumpu pada lutut'),
(1, 1, 'gym', 1, 'Dada', 'Trisep, Bahu', 'Bench', 3, '10-12', 'rep', 60, 'Dorong secara terkontrol.', 'Dumbbell press'),
(1, 14, 'rumah', 2, 'Core', 'Perut, Pinggang', 'Matras', 3, '30-45', 'detik', 45, 'Tahan otot perut.', 'Plank lutut'),
(1, 14, 'gym', 2, 'Core', 'Perut, Pinggang', 'Matras', 3, '30-45', 'detik', 45, 'Tahan otot perut.', 'Plank lutut'),
(3, 11, 'rumah', 1, 'Kaki', 'Paha, Bokong', 'Tanpa alat', 3, '12-15', 'rep', 60, 'Lutut tidak melebihi ujung jari kaki.', 'Squat bersandar dinding'),
(3, 11, 'gym', 1, 'Kaki', 'Paha, Bokong', 'Barbell / Dumbbell', 3, '10-12', 'rep', 90, 'Turun terkontrol hingga paha sejajar lantai.', 'Goblet squat'),
(5, 1, 'rumah', 1, 'Full Body', 'Dada, Lengan', 'Tanpa alat', 3, '10-12', 'rep', 60, 'Gerakan ritmis stabil.', 'Push up dinding'),
(5, 1, 'gym', 1, 'Full Body', 'Dada, Lengan', 'Dumbbell', 3, '10-12', 'rep', 60, 'Gerakan ritmis stabil.', 'Chest press machine');

INSERT IGNORE INTO workout_program_progression (program_id, week_number, focus, guidance) VALUES
(1, 1, 'Adaptasi & Pembentukan Kebiasaan', 'Fokus pada mempelajari teknik dan mempertahankan konsistensi tanpa memaksakan beban berat.'),
(1, 2, 'Peningkatan Repetisi', 'Jika gerakan terasa nyaman, tambahkan 1-2 repetisi pada setiap set.'),
(1, 3, 'Efisiensi & Tempo', 'Perpendek waktu istirahat antar set menjadi 45-60 detik dan perhatikan kontrol tempo.'),
(1, 4, 'Konsolidasi & Evaluasi', 'Uji peningkatan stamina dan catat pencapaian selama 1 bulan latihan.');

INSERT IGNORE INTO workout_program_warmups (program_id, phase, sequence_number, name, duration) VALUES
(1, 'pemanasan', 1, 'Pemanasan Dinamis & Putar Sendi', '3-5 menit'),
(1, 'pemanasan', 2, 'Jumping Jack Ringan / Jalan di Tempat', '2 menit'),
(1, 'pendinginan', 1, 'Peregangan Statis Otot Utama', '3-5 menit'),
(1, 'pendinginan', 2, 'Pernapasan Dalam & Relaksasi', '2 menit');

