const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");

async function ensureDatabase() {
  const dbName = process.env.DB_NAME || "bodywise_app";

  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || "127.0.0.1",
      port: Number(process.env.DB_PORT || 3306),
      user: process.env.DB_USER || "root",
      password: process.env.DB_PASSWORD || "",
      multipleStatements: true
    });
  } catch (err) {
    throw new Error(
      `Tidak dapat terhubung ke MySQL server (${process.env.DB_HOST}:${process.env.DB_PORT || 3306}) dengan user '${process.env.DB_USER}': ${err.message}. Pastikan MySQL (misal XAMPP) sudah dijalankan.`
    );
  }

  try {
    await connection.query(
      `CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
    );
    await connection.query(`USE \`${dbName}\``);

    const [tables] = await connection.query("SHOW TABLES");
    if (tables.length < 18) {
      console.log(`Menyiapkan tabel dan data awal untuk database '${dbName}'...`);
      const sqlPath = path.resolve(__dirname, "../../../setup_database.sql");
      if (fs.existsSync(sqlPath)) {
        const sql = fs.readFileSync(sqlPath, "utf8");
        await connection.query(sql);
        console.log(`Database '${dbName}' berhasil diinisialisasi secara otomatis.`);
      }
    } else {
      try {
        const [programs] = await connection.query("SELECT COUNT(*) AS count FROM workout_programs");
        if (programs[0].count === 0) {
          const sqlPath = path.resolve(__dirname, "../../../setup_database.sql");
          if (fs.existsSync(sqlPath)) {
            const sql = fs.readFileSync(sqlPath, "utf8");
            await connection.query(sql);
          }
        }
      } catch {
        // Ignored
      }
    }
  } catch (err) {
    throw new Error(`Gagal menyiapkan database '${dbName}': ${err.message}`);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

module.exports = { ensureDatabase };
