const mysql = require("mysql2/promise");

const host = process.env.DB_HOST || process.env.MYSQLHOST || process.env.MYSQL_HOST || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).hostname : undefined);
const user = process.env.DB_USER || process.env.MYSQLUSER || process.env.MYSQL_USER || process.env.MYSQL_USERNAME || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).username : undefined);
const database = process.env.DB_NAME || process.env.MYSQLDATABASE || process.env.MYSQL_DATABASE || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).pathname.slice(1) : undefined);
const password = process.env.DB_PASSWORD ?? process.env.MYSQLPASSWORD ?? process.env.MYSQL_PASSWORD ?? (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).password : "");
const port = Number(process.env.DB_PORT || process.env.MYSQLPORT || process.env.MYSQL_PORT || (process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).port : 3306) || 3306);

if (!host || !user || !database) {
  throw new Error("Missing required database configuration: set DB_HOST, DB_USER, DB_NAME or DATABASE_URL/MYSQLHOST");
}

const pool = mysql.createPool({
  host,
  port,
  user,
  password,
  database,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  ssl: process.env.DB_SSL === "true" ? { rejectUnauthorized: true } : undefined,
  timezone: "Z",
  dateStrings: true,
  decimalNumbers: true
});

module.exports = pool;
