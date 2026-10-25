const path = require("path");
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const cookieParser = require("cookie-parser");
const pool = require("./config/database");
const { verifySchema } = require("./config/schema");
const { verifyRequestOrigin } = require("./middleware/auth.middleware");
const { notFound, errorHandler } = require("./middleware/error.middleware");

const app = express();
const allowedOrigins = (process.env.FRONTEND_ORIGIN || "")
  .split(",")
  .map(origin => origin.trim())
  .filter(Boolean);

app.set("trust proxy", 1);
app.disable("x-powered-by");
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      baseUri: ["'self'"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'", "https://fonts.gstatic.com", "data:"],
      formAction: ["'self'"],
      frameAncestors: ["'self'"],
      imgSrc: ["'self'", "data:", "https://images.unsplash.com"],
      objectSrc: ["'none'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"]
    }
  }
}));
app.use(cors({
  origin(origin, callback) {
    if (!origin) return callback(null, true);
    if (allowedOrigins.length === 0 || allowedOrigins.includes("*") || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(null, true);
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type"]
}));
app.use(verifyRequestOrigin);
app.use(express.json({ limit: "32kb" }));
app.use(cookieParser());

app.get("/api/health", async (req, res, next) => {
  try {
    await pool.query("SELECT 1");
    await verifySchema(pool);
    return res.json({ success: true, data: { status: "ok", database: "connected" } });
  } catch (error) {
    return next(error);
  }
});

app.get("/api/debug-db", async (req, res) => {
  const host = process.env.DB_HOST || process.env.MYSQLHOST || process.env.MYSQL_HOST;
  const user = process.env.DB_USER || process.env.MYSQLUSER || process.env.MYSQL_USER;
  const database = process.env.DB_NAME || process.env.MYSQLDATABASE || process.env.MYSQL_DATABASE;
  const port = process.env.DB_PORT || process.env.MYSQLPORT || 3306;
  const hasPassword = Boolean(process.env.DB_PASSWORD || process.env.MYSQLPASSWORD);

  if (!host || !user || !database) {
    return res.status(200).json({
      configured: false,
      message: "Environment variables belum lengkap di Vercel!",
      details: { host: Boolean(host), user: user || false, database: Boolean(database), hasPassword }
    });
  }

  try {
    await pool.query("SELECT 1");
    return res.status(200).json({
      configured: true,
      connected: true,
      message: "Database berhasil terhubung 100%!",
      database
    });
  } catch (err) {
    return res.status(200).json({
      configured: true,
      connected: false,
      message: "Gagal terhubung ke database!",
      error: err.message,
      code: err.code,
      debug: {
        host,
        user,
        database,
        passwordLength: (process.env.DB_PASSWORD || "").length
      }
    });
  }
});
app.use("/api/auth", require("./routes/auth.routes"));
app.use("/api", require("./routes/profile.routes"));
app.use("/api", require("./routes/dashboard.routes"));
app.use("/api", require("./routes/food.routes"));
app.use("/api", require("./routes/workout.routes"));
app.use("/api", require("./routes/progress.routes"));
app.use("/api", require("./routes/chatbot.routes"));

if (process.env.SERVE_FRONTEND !== "false") {
  app.use(express.static(path.resolve(__dirname, "../..")));
}
app.use(notFound);
app.use(errorHandler);

module.exports = app;
