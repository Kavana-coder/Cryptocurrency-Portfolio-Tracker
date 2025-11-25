import express from "express";
import db from "../db.js";
import { verifyToken } from "../middleware/auth.js";

const router = express.Router();

// ✅ Get alerts for the logged-in user
router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const userRole = req.user.role;

    let query = `SELECT * FROM Alerts`;
    let params = [];

    if (userRole !== "admin") {
      query += ` WHERE UserID = ?`;
      params.push(userId);
    }

    query += ` ORDER BY DateCreated DESC`;

    const [rows] = await db.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching alerts:", err);
    res.status(500).json({ error: "Failed to fetch alerts" });
  }
});

export default router;
