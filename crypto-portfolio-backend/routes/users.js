import express from "express";
import db from "../db.js";

const router = express.Router();

// ✅ Get all users
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        u.UserID,
        u.FirstName,
        u.LastName,
        u.Email,
        u.JoinDate,
        u.BalanceUSD
      FROM Users u
      ORDER BY u.UserID
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching users:", err);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// ✅ Add new user + auto-create wallet
router.post("/", async (req, res) => {
  const { firstName, lastName, email, password, balance = 0 } = req.body;

  try {
    // Insert user with BalanceUSD
    const [result] = await db.query(
      `INSERT INTO Users (FirstName, LastName, Email, Password, JoinDate, BalanceUSD)
       VALUES (?, ?, ?, ?, CURDATE(), ?)`,
      [firstName, lastName, email, password, balance]
    );

    const newUserId = result.insertId;
    const walletName = `${firstName}_Wallet`;

    // Auto-create wallet with the same balance
    await db.query(
      `INSERT INTO Wallet (UserID, WalletName, CreatedDate, BalanceUSD)
       VALUES (?, ?, CURDATE(), ?)`,
      [newUserId, walletName, balance]
    );

    res.json({ message: "✅ User and wallet created successfully" });
  } catch (err) {
    console.error("Error adding user:", err);
    res.status(500).json({ error: err.message || "Failed to add user" });
  }
});

export default router;
