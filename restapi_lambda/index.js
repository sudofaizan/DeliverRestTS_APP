const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: { rejectUnauthorized: false },
});

exports.handler = async (event) => {
  const path = event.resource;
  const method = event.httpMethod;
  const body = event.body ? JSON.parse(event.body) : {};

  if (path === "/tasks" && method === "GET") {
    const result = await pool.query("SELECT * FROM tasks ORDER BY created_at DESC");
    return { statusCode: 200, body: JSON.stringify(result.rows) };
  }

  if (path === "/tasks" && method === "POST") {
    if (!body.description) {
      return { statusCode: 400, body: JSON.stringify({ error: "Description is required" }) };
    }
    const result = await pool.query("INSERT INTO tasks (description) VALUES ($1) RETURNING *", [
      body.description,
    ]);
    return { statusCode: 201, body: JSON.stringify(result.rows[0]) };
  }

  return { statusCode: 404, body: JSON.stringify({ error: "Not Found" }) };
};