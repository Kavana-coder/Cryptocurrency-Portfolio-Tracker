import express from "express";
import db from "../db.js";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();
const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET;

// 🧠 Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "No token provided" });
  }

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // attach user info to request
    next();
  } catch (err) {
    console.error("JWT verification failed:", err.message);
    return res.status(403).json({ error: "Invalid or expired token" });
  }
};

// ✅ (1) GET all users – Admin only
router.get("/", verifyToken, async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ error: "Access denied: Admins only" });
    }

    const [rows] = await db.query(`
      SELECT 
        u.UserID,
        u.FirstName,
        u.LastName,
        u.Email,
        u.JoinDate,
        u.BalanceUSD,
        u.Role
      FROM Users u
      ORDER BY u.UserID;
    `);

    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching users:", err);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// ✅ (2) ADD new user + auto-create wallet – Admin only
router.post("/", verifyToken, async (req, res) => {
  const { firstName, lastName, email, password, balance = 0, role = "user" } = req.body;

  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ error: "Access denied: Admins only" });
    }

    const [result] = await db.query(
      `INSERT INTO Users (FirstName, LastName, Email, Password, JoinDate, BalanceUSD, Role)
       VALUES (?, ?, ?, ?, CURDATE(), ?, ?)`,
      [firstName, lastName, email, password, balance, role]
    );

    const newUserId = result.insertId;
    const walletName = `${firstName}_Wallet`;

    await db.query(
      `INSERT INTO Wallet (UserID, WalletName, CreatedDate, BalanceUSD)
       VALUES (?, ?, CURDATE(), ?)`,
      [newUserId, walletName, balance]
    );

    res.json("✅ User and wallet created successfully!");
  } catch (err) {
    console.error("❌ Error adding user:", err.message);
    res.status(500).json(err.message || "Failed to add user");
  }
});

// ✅ (3) UPDATE user – Admin only
router.put("/:id", verifyToken, async (req, res) => {
  const { id } = req.params;
  const { firstName, lastName, email, balance, role } = req.body;

  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ error: "Access denied: Admins only" });
    }

    const safeBalance = balance !== "" ? balance : 0;
    const [result] = await db.query(
      `UPDATE Users 
       SET FirstName = ?, LastName = ?, Email = ?, BalanceUSD = ?, Role = ?
       WHERE UserID = ?`,
      [firstName, lastName, email, safeBalance, role, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json("User not found");
    }

    res.json("✅ User updated successfully!");
  } catch (err) {
    console.error("❌ Error updating user:", err.message);
    res.status(500).json("Failed to update user");
  }
});

// ✅ (4) DELETE user – Admin only
router.delete("/:id", verifyToken, async (req, res) => {
  const { id } = req.params;

  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ error: "Access denied: Admins only" });
    }

    const [result] = await db.query(`DELETE FROM Users WHERE UserID = ?`, [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json("User not found");
    }

    res.json("🗑️ User deleted successfully!");
  } catch (err) {
    console.error("❌ SQL Delete Error:", err.sqlMessage || err.message);
    res.status(500).json(err.sqlMessage || "Failed to delete user");
  }
});

// ✅ (5) Get current logged-in user's own info
router.get("/me", verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId; // Corrected: use `userId` from token
    const [rows] = await db.query(
      `SELECT UserID, FirstName, LastName, Email, JoinDate, BalanceUSD, Role
       FROM Users
       WHERE UserID = ?`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("❌ Error fetching user profile:", err.message);
    res.status(500).json({ error: "Failed to fetch user profile" });
  }
});

export default router;
