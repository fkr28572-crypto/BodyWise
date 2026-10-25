const pool = require("../config/database");
const { asyncHandler } = require("../middleware/async.middleware");
const { badRequest, isDate } = require("../middleware/validate.middleware");

const programSlug = "program-latihan-pemula-4-minggu";

function mondayOf(date) {
  const monday = new Date(`${date}T00:00:00Z`);
  monday.setUTCDate(monday.getUTCDate() - ((monday.getUTCDay() + 6) % 7));
  return monday.toISOString().slice(0, 10);
}

function getProgramWeek(startDate, date) {
  const elapsed = Math.max(0, Date.parse(`${date}T00:00:00Z`) - Date.parse(`${startDate}T00:00:00Z`));
  return (Math.floor(elapsed / (7 * 24 * 60 * 60 * 1000)) % 4) + 1;
}

async function ensureWorkoutProgram() {
  await pool.execute(
    `INSERT INTO workout_programs (id, slug, name, level, duration_weeks, session_duration, frequency, safety_notes)
     VALUES (1, 'program-latihan-pemula-4-minggu', 'Program Latihan Pemula 4 Minggu', 'Pemula', 4, '45-60 menit', '3-4 hari per minggu', 'Lakukan pemanasan sebelum latihan dan pendinginan setelahnya.')
     ON DUPLICATE KEY UPDATE name = VALUES(name)`
  );
  await pool.execute(
    `INSERT IGNORE INTO workout_program_days (id, program_id, day_number, day_name, focus, duration_min, duration_max, notes, is_rest) VALUES
     (1, 1, 1, 'Senin', 'Latihan Tubuh Atas & Core', 45, 60, 'Fokus pada bentuk gerakan dan kontrol napas.', FALSE),
     (2, 1, 2, 'Selasa', 'Pemulihan Aktif', 20, 30, 'Jalan santai atau peregangan ringan.', TRUE),
     (3, 1, 3, 'Rabu', 'Latihan Tubuh Bawah', 45, 60, 'Jaga keseimbangan dan kedalaman squat.', FALSE),
     (4, 1, 4, 'Kamis', 'Istirahat Total', 0, 0, 'Istirahat dan hidrasi cukup.', TRUE),
     (5, 1, 5, 'Jumat', 'Full Body & Kardio', 45, 60, 'Kombinasi kekuatan dan stamina.', FALSE),
     (6, 1, 6, 'Sabtu', 'Mobilitas & Kardio Ringan', 30, 45, 'Aktivitas luar ruangan atau treadmill.', FALSE),
     (7, 1, 7, 'Minggu', 'Istirahat Total', 0, 0, 'Persiapan untuk minggu berikutnya.', TRUE)`
  );
  await pool.execute(
    `INSERT IGNORE INTO workout_program_movements (program_day_id, exercise_id, location, sequence_number, muscle_group, supporting_muscles, equipment, sets, reps, rep_unit, rest_seconds, tips, home_alternative) VALUES
     (1, 1, 'rumah', 1, 'Dada', 'Trisep, Bahu', 'Tanpa alat', 3, '10-12', 'rep', 60, 'Jaga punggung tetap lurus.', 'Push up bertumpu pada lutut'),
     (1, 1, 'gym', 1, 'Dada', 'Trisep, Bahu', 'Bench', 3, '10-12', 'rep', 60, 'Dorong secara terkontrol.', 'Dumbbell press'),
     (1, 14, 'rumah', 2, 'Core', 'Perut, Pinggang', 'Matras', 3, '30-45', 'detik', 45, 'Tahan otot perut.', 'Plank lutut'),
     (1, 14, 'gym', 2, 'Core', 'Perut, Pinggang', 'Matras', 3, '30-45', 'detik', 45, 'Tahan otot perut.', 'Plank lutut'),
     (3, 11, 'rumah', 1, 'Kaki', 'Paha, Bokong', 'Tanpa alat', 3, '12-15', 'rep', 60, 'Lutut tidak melebihi ujung jari kaki.', 'Squat bersandar dinding'),
     (3, 11, 'gym', 1, 'Kaki', 'Paha, Bokong', 'Barbell / Dumbbell', 3, '10-12', 'rep', 90, 'Turun terkontrol hingga paha sejajar lantai.', 'Goblet squat'),
     (5, 1, 'rumah', 1, 'Full Body', 'Dada, Lengan', 'Tanpa alat', 3, '10-12', 'rep', 60, 'Gerakan ritmis stabil.', 'Push up dinding'),
     (5, 1, 'gym', 1, 'Full Body', 'Dada, Lengan', 'Dumbbell', 3, '10-12', 'rep', 60, 'Gerakan ritmis stabil.', 'Chest press machine')`
  );
  await pool.execute(
    `INSERT IGNORE INTO workout_program_progression (program_id, week_number, focus, guidance) VALUES
     (1, 1, 'Adaptasi', 'Fokus pada mempelajari teknik dan mempertahankan konsistensi.'),
     (1, 2, 'Peningkatan Repetisi', 'Jika gerakan terasa nyaman, tambahkan 1-2 repetisi per set.'),
     (1, 3, 'Efisiensi', 'Perpendek waktu istirahat antar set menjadi 45-60 detik.'),
     (1, 4, 'Konsolidasi', 'Uji peningkatan stamina dan catat pencapaian.')`
  );
  await pool.execute(
    `INSERT IGNORE INTO workout_program_warmups (program_id, phase, sequence_number, name, duration) VALUES
     (1, 'pemanasan', 1, 'Pemanasan Dinamis & Putar Sendi', '3-5 menit'),
     (1, 'pemanasan', 2, 'Jumping Jack Ringan / Jalan di Tempat', '2 menit'),
     (1, 'pendinginan', 1, 'Peregangan Statis Otot Utama', '3-5 menit'),
     (1, 'pendinginan', 2, 'Pernapasan Dalam & Relaksasi', '2 menit')`
  );
}

async function loadProgram(req, res) {
  const date = req.query.date || new Date().toISOString().slice(0, 10);
  if (!isDate(date)) throw badRequest("Tanggal harus berformat YYYY-MM-DD.");
  let [programRows] = await pool.execute(
    `SELECT id, name, level, duration_weeks, session_duration, frequency, safety_notes
     FROM workout_programs WHERE slug = ? LIMIT 1`,
    [programSlug]
  );
  if (!programRows[0]) {
    try {
      await ensureWorkoutProgram();
      const [retry] = await pool.execute(
        `SELECT id, name, level, duration_weeks, session_duration, frequency, safety_notes
         FROM workout_programs WHERE slug = ? LIMIT 1`,
        [programSlug]
      );
      programRows = retry;
    } catch {
      // Ignored
    }
  }
  const program = programRows[0];
  if (!program) {
    const error = new Error("Program latihan belum diimpor. Jalankan migrasi 004 lalu impor dataset program latihan.");
    error.status = 503;
    throw error;
  }

  await pool.execute(
    `INSERT IGNORE INTO user_workout_preferences (user_id, program_id, location, start_date)
     VALUES (?, ?, 'rumah', ?)`,
    [req.user.id, program.id, mondayOf(date)]
  );
  const [preferenceRows] = await pool.execute(
    "SELECT location, start_date FROM user_workout_preferences WHERE user_id = ?",
    [req.user.id]
  );
  const preference = preferenceRows[0];
  const [dayRows] = await pool.execute(
    `SELECT id, day_number, day_name, focus, duration_min, duration_max, notes, is_rest
     FROM workout_program_days WHERE program_id = ? ORDER BY day_number`,
    [program.id]
  );
  const dayIds = dayRows.map(day => day.id);
  const movementMap = new Map(dayIds.map(id => [Number(id), []]));
  if (dayIds.length) {
    const placeholders = dayIds.map(() => "?").join(", ");
    const [movementRows] = await pool.execute(
      `SELECT m.program_day_id, m.exercise_id, e.name AS exercise_name, m.sequence_number,
        m.muscle_group, m.supporting_muscles, m.equipment, m.sets, m.reps, m.rep_unit,
        m.rest_seconds, m.tips, m.home_alternative
       FROM workout_program_movements m JOIN exercises e ON e.id = m.exercise_id
       WHERE m.program_day_id IN (${placeholders}) AND m.location = ?
       ORDER BY m.program_day_id, m.sequence_number`,
      [...dayIds, preference.location]
    );
    for (const movement of movementRows) movementMap.get(Number(movement.program_day_id)).push(movement);
  }
  const [progressionRows] = await pool.execute(
    `SELECT week_number, focus, guidance FROM workout_program_progression
     WHERE program_id = ? ORDER BY week_number`,
    [program.id]
  );
  const [warmupRows] = await pool.execute(
    `SELECT phase, sequence_number, name, duration FROM workout_program_warmups
     WHERE program_id = ? ORDER BY phase, sequence_number`,
    [program.id]
  );
  const weekNumber = getProgramWeek(preference.start_date, date);
  const progression = progressionRows.find(week => Number(week.week_number) === weekNumber) || null;
  const days = dayRows.map(day => ({
    ...day,
    movements: movementMap.get(Number(day.id)) || []
  }));

  const [goalRows] = await pool.execute(
    `SELECT goal_type, target_weight_kg FROM weight_goals
     WHERE user_id = ? AND status = 'active' AND start_date <= ? AND target_date >= ?
     ORDER BY created_at DESC LIMIT 1`,
    [req.user.id, date, date]
  );
  return res.json({
    success: true,
    data: {
      program,
      date,
      preference,
      weekNumber,
      progression,
      days,
      selectedDay: days.find(day => Number(day.day_number) === ((new Date(`${date}T00:00:00Z`).getUTCDay() + 6) % 7) + 1) || null,
      warmups: {
        pemanasan: warmupRows.filter(item => item.phase === "pemanasan"),
        pendinginan: warmupRows.filter(item => item.phase === "pendinginan")
      },
      activeGoal: goalRows[0] || null
    }
  });
}

async function updatePreference(req, res) {
  const { location } = req.body;
  if (!["gym", "rumah"].includes(location)) throw badRequest("Lokasi latihan harus gym atau rumah.");
  let [programRows] = await pool.execute(
    "SELECT id FROM workout_programs WHERE slug = ? LIMIT 1",
    [programSlug]
  );
  if (!programRows[0]) {
    try {
      await ensureWorkoutProgram();
      const [retry] = await pool.execute(
        "SELECT id FROM workout_programs WHERE slug = ? LIMIT 1",
        [programSlug]
      );
      programRows = retry;
    } catch {
      // Ignored
    }
  }
  if (!programRows[0]) {
    const error = new Error("Program latihan belum diimpor. Jalankan migrasi 004 lalu impor dataset program latihan.");
    error.status = 503;
    throw error;
  }
  const startDate = mondayOf(new Date().toISOString().slice(0, 10));
  await pool.execute(
    `INSERT INTO user_workout_preferences (user_id, program_id, location, start_date)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE location = VALUES(location)`,
    [req.user.id, programRows[0].id, location, startDate]
  );
  return res.json({ success: true, data: { preference: { location } } });
}

module.exports = {
  loadProgram: asyncHandler(loadProgram),
  updatePreference: asyncHandler(updatePreference)
};
