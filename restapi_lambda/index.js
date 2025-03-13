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

  // Default CORS headers
  const headers = {
    "Access-Control-Allow-Origin": "*",  // Allow all origins
    "Access-Control-Allow-Methods": "OPTIONS, GET, POST",
    "Access-Control-Allow-Headers": "Content-Type",
  };

  // Handle preflight (OPTIONS) request
  if (method === "OPTIONS") {
    return { statusCode: 200, headers, body: JSON.stringify({ message: "CORS preflight success" }) };
  }

  try {
    if (path === "/tasks" && method === "POST") {
        if (!body.id) {
          return { statusCode: 400, headers, body: JSON.stringify({ error: "id is required" }) };
        }
        const result = await pool.query("DELETE FROM tasks WHERE id = $1 RETURNING *", [
          body.id,
        ]);
        return { statusCode: 201, headers, body: JSON.stringify(result.rows[0]) };
      }
      
    if (path === "/tasks" && method === "GET") {
      const result = await pool.query("SELECT * FROM tasks ORDER BY created_at DESC");
      return { statusCode: 200, headers, body: JSON.stringify(result.rows) };
    }

    if (path === "/tasks" && method === "POST") {
      if (!body.description) {
        return { statusCode: 400, headers, body: JSON.stringify({ error: "Description is required" }) };
      }
      const result = await pool.query("INSERT INTO tasks (description) VALUES ($1) RETURNING *", [
        body.description,
      ]);
      return { statusCode: 201, headers, body: JSON.stringify(result.rows[0]) };
    }

    


    return { statusCode: 404, headers, body: JSON.stringify({ error: "Not Found" }) };
  } catch (error) {
    console.error("Database error:", error);
    return { statusCode: 500, headers, body: JSON.stringify({ error: "Internal Server Error" }) };
  }
};