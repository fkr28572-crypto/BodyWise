const mysql = require("mysql2/promise");
const { ensureDatabase } = require("./initDb");

function parseConfig() {
  let host = process.env.DB_HOST || process.env.MYSQLHOST || process.env.MYSQL_HOST;
  let user = process.env.DB_USER || process.env.MYSQLUSER || process.env.MYSQL_USER || process.env.MYSQL_USERNAME;
  let database = process.env.DB_NAME || process.env.MYSQLDATABASE || process.env.MYSQL_DATABASE;
  let password = process.env.DB_PASSWORD ?? process.env.MYSQLPASSWORD ?? process.env.MYSQL_PASSWORD ?? "";
  let port = Number(process.env.DB_PORT || process.env.MYSQLPORT || process.env.MYSQL_PORT || 3306);
  let ssl = process.env.DB_SSL === "true" || process.env.MYSQL_SSL === "true" ? { rejectUnauthorized: false } : undefined;

  const dbUrl = process.env.DATABASE_URL || process.env.MYSQL_URL;
  if (dbUrl) {
    try {
      const parsed = new URL(dbUrl);
      host = host || parsed.hostname;
      port = parsed.port ? Number(parsed.port) : port;
      user = user || decodeURIComponent(parsed.username);
      password = parsed.password ? decodeURIComponent(parsed.password) : password;
      database = database || parsed.pathname.slice(1);
      if (parsed.searchParams.get("sslmode") === "require" || parsed.searchParams.get("ssl") === "true") {
        ssl = { rejectUnauthorized: false };
      }
    } catch {
      // ignore parse error
    }
  }

  if (!host && process.env.NODE_ENV !== "production") {
    host = "127.0.0.1";
    user = "root";
    database = "bodywise_app";
  }

  return { host, port, user, password, database, ssl };
}

let realPool = null;
let initPromise = null;

function getPool() {
  if (realPool) return realPool;
  const cfg = parseConfig();

  if (!cfg.host || !cfg.user || !cfg.database) {
    return {
      query: async () => { throw new Error("Database belum dikonfigurasi. Masukkan variabel DB_HOST, DB_USER, DB_NAME (atau DATABASE_URL) di Vercel Environment Variables."); },
      execute: async () => { throw new Error("Database belum dikonfigurasi. Masukkan variabel DB_HOST, DB_USER, DB_NAME (atau DATABASE_URL) di Vercel Environment Variables."); },
      getConnection: async () => { throw new Error("Database belum dikonfigurasi. Masukkan variabel DB_HOST, DB_USER, DB_NAME (atau DATABASE_URL) di Vercel Environment Variables."); },
      end: async () => {}
    };
  }

  realPool = mysql.createPool({
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password,
    database: cfg.database,
    waitForConnections: true,
    connectionLimit: 5,
    queueLimit: 0,
    enableKeepAlive: true,
    ssl: cfg.ssl,
    timezone: "Z",
    dateStrings: true,
    decimalNumbers: true
  });

  return realPool;
}

const poolProxy = new Proxy({}, {
  get(target, prop) {
    if (prop === "query" || prop === "execute" || prop === "getConnection") {
      return async (...args) => {
        const pool = getPool();
        if (!initPromise && (process.env.DB_HOST || process.env.DATABASE_URL)) {
          initPromise = ensureDatabase().catch(err => {
            console.error("Auto ensureDatabase notice:", err.message);
          });
        }
        if (initPromise) {
          try {
            await initPromise;
          } catch {
            // ignore
          }
        }
        return pool[prop](...args);
      };
    }
    const pool = getPool();
    if (typeof pool[prop] === "function") {
      return pool[prop].bind(pool);
    }
    return pool[prop];
  }
});

module.exports = poolProxy;
