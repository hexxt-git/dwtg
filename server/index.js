const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  connectionString:
    "postgresql://neondb_owner:npg_eC0sATH2xOMc@ep-patient-hall-abyda3r7-pooler.eu-west-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require",
  ssl: {
    rejectUnauthorized: false,
  },
});

// Test database connection and create tables
pool.connect(async (err, client, release) => {
  if (err) {
    console.error("Error connecting to PostgreSQL:", err);
  } else {
    console.log("Connected to PostgreSQL database");

    // Create leaderboard table if it doesn't exist
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS leaderboard (
          id SERIAL PRIMARY KEY,
          player_name VARCHAR(50) NOT NULL,
          score INTEGER NOT NULL,
          kills INTEGER NOT NULL,
          play_time INTEGER NOT NULL,
          difficulty INTEGER NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
      console.log("Leaderboard table ready");
    } catch (error) {
      console.error("Error creating table:", error);
    }

    release();
  }
});

// Basic route
app.get("/", (req, res) => {
  res.json({ message: "amongi-garden Leaderboard Server is running!" });
});

// Health check route
app.get("/health", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json({
      status: "healthy",
      database: "connected",
      timestamp: result.rows[0].now,
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      database: "disconnected",
      error: error.message,
    });
  }
});

// Submit score to leaderboard
app.post("/api/leaderboard", async (req, res) => {
  try {
    const { player_name, score, kills, play_time, difficulty } = req.body;

    // Validate input
    if (
      !player_name ||
      score === undefined ||
      kills === undefined ||
      play_time === undefined ||
      difficulty === undefined
    ) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Insert score into database
    const result = await pool.query(
      "INSERT INTO leaderboard (player_name, score, kills, play_time, difficulty) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [player_name, score, kills, play_time, difficulty]
    );

    res.json({
      success: true,
      message: "Score submitted successfully",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Error submitting score:", error);
    res.status(500).json({ error: "Failed to submit score" });
  }
});

// Get leaderboard (top scores)
app.get("/api/leaderboard", async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const offset = parseInt(req.query.offset) || 0;

    const result = await pool.query(
      "SELECT player_name, score, kills, play_time, difficulty, created_at FROM leaderboard ORDER BY score DESC LIMIT $1 OFFSET $2",
      [limit, offset]
    );

    res.json({
      success: true,
      data: result.rows,
      count: result.rows.length,
    });
  } catch (error) {
    console.error("Error fetching leaderboard:", error);
    res.status(500).json({ error: "Failed to fetch leaderboard" });
  }
});

// Get leaderboard by difficulty
app.get("/api/leaderboard/difficulty/:difficulty", async (req, res) => {
  try {
    const difficulty = parseInt(req.params.difficulty);
    const limit = parseInt(req.query.limit) || 10;

    const result = await pool.query(
      "SELECT player_name, score, kills, play_time, difficulty, created_at FROM leaderboard WHERE difficulty = $1 ORDER BY score DESC LIMIT $2",
      [difficulty, limit]
    );

    res.json({
      success: true,
      data: result.rows,
      count: result.rows.length,
    });
  } catch (error) {
    console.error("Error fetching leaderboard by difficulty:", error);
    res.status(500).json({ error: "Failed to fetch leaderboard" });
  }
});

// Get player's best score
app.get("/api/leaderboard/player/:name", async (req, res) => {
  try {
    const playerName = req.params.name;

    const result = await pool.query(
      "SELECT player_name, score, kills, play_time, difficulty, created_at FROM leaderboard WHERE player_name = $1 ORDER BY score DESC LIMIT 1",
      [playerName]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Player not found" });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error("Error fetching player score:", error);
    res.status(500).json({ error: "Failed to fetch player score" });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
