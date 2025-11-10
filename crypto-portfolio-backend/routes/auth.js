import express from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import db from "../db.js";
import dotenv from "dotenv";
dotenv.config();

const router = express.Router();

// 🧠 LOGIN
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const [rows] = await db.query("SELECT * FROM Users WHERE Email = ?", [email]);
    if (rows.length === 0) return res.status(401).json({ error: "Invalid credentials" });

    const user = rows[0];

    // ✅ For now: plaintext password check (you can later replace with bcrypt)
    const passwordMatch = password === user.Password;

    if (!passwordMatch) return res.status(401).json({ error: "Invalid credentials" });

    // ✅ Determine role
    let role = "user";
    if (user.Email === "admin@example.com") {
      role = "admin";
    }

    // ✅ Generate JWT
    const token = jwt.sign(
      { userId: user.UserID, email: user.Email, role },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.json({ token, role });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// 🆕 REGISTER
router.post("/register", async (req, res) => {
  const { firstName, lastName, email, password } = req.body;
  try {
    const [exists] = await db.query("SELECT * FROM Users WHERE Email = ?", [email]);
    if (exists.length > 0) return res.status(400).json({ error: "User already exists" });

    const [result] = await db.query(
      `INSERT INTO Users (FirstName, LastName, Email, Password, JoinDate, BalanceUSD)
       VALUES (?, ?, ?, ?, CURDATE(), 0)`,
      [firstName, lastName, email, password]
    );

    const walletName = `${firstName}_Wallet`;
    await db.query(
      `INSERT INTO Wallet (UserID, WalletName, CreatedDate, BalanceUSD)
       VALUES (?, ?, CURDATE(), 0)`,
      [result.insertId, walletName]
    );

    res.json({ message: "✅ User registered successfully!" });
  } catch (err) {
    console.error("Register error:", err);
    res.status(500).json({ error: "Registration failed" });
  }
});

export default router;
