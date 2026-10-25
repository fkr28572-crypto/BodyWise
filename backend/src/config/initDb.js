const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");

async function ensureDatabase() {
  const host = process.env.DB_HOST || process.env.MYSQLHOST || process.env.MYSQL_HOST || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).hostname : "127.0.0.1");
  const user = process.env.DB_USER || process.env.MYSQLUSER || process.env.MYSQL_USER || process.env.MYSQL_USERNAME || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).username : "root");
  const dbName = process.env.DB_NAME || process.env.MYSQLDATABASE || process.env.MYSQL_DATABASE || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).pathname.slice(1) : "bodywise_app");
  const password = process.env.DB_PASSWORD ?? process.env.MYSQLPASSWORD ?? process.env.MYSQL_PASSWORD ?? (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).password : "");
  const port = Number(process.env.DB_PORT || process.env.MYSQLPORT || process.env.MYSQL_PORT || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).port : 3306) || 3306);

  let connection;
  try {
    connection = await mysql.createConnection({
      host,
      port,
      user,
      password,
      multipleStatements: true
    });
  } catch (err) {
    throw new Error(
      `Tidak dapat terhubung ke MySQL server (${host}:${port}) dengan user '${user}': ${err.message}. Pastikan MySQL sudah berjalan.`
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
