// routes/auth.js
import express from "express";
import jwt from "jsonwebtoken";
import db from "../db.js";
import dotenv from "dotenv";
dotenv.config();

const router = express.Router();

const ACCESS_SECRET = process.env.JWT_SECRET;
const REFRESH_SECRET = process.env.REFRESH_SECRET || "myRefreshSecret";

// Temporary in-memory refresh tokens
let refreshTokens = [];

/* 🧠 LOGIN ROUTE */
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  console.log("📩 Login attempt received →", email, password);

  try {
    // 1️⃣ Find user in DB
    const [rows] = await db.query("SELECT * FROM Users WHERE Email = ?", [email]);
    console.log("🔍 DB rows:", rows);

    if (rows.length === 0) {
      console.log("❌ No user found with that email");
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const user = rows[0];
    console.log("✅ User found:", user.Email, "Stored password:", user.Password);

    // 2️⃣ Compare plain-text passwords
    if (password !== user.Password) {
      console.log("❌ Password mismatch → entered:", password, "| expected:", user.Password);
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // 3️⃣ Assign role
    const role = user.Role || (user.Email === "admin@example.com" ? "admin" : "user");
    console.log("🎭 Role identified as:", role);

    // 4️⃣ Generate tokens
    const accessToken = jwt.sign(
      { userId: user.UserID, email: user.Email, role },
      ACCESS_SECRET,
      { expiresIn: "1h" }
    );

    const refreshToken = jwt.sign(
      { userId: user.UserID, email: user.Email, role },
      REFRESH_SECRET,
      { expiresIn: "7d" }
    );

    refreshTokens.push(refreshToken);
    console.log("✅ Tokens generated, sending response...");

    // 5️⃣ Respond
    res.json({ accessToken, refreshToken, role });
  } catch (err) {
    console.error("💥 Login error:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

/* 🆕 REGISTER ROUTE */
router.post("/register", async (req, res) => {
  const { firstName, lastName, email, password } = req.body;

  try {
    const [exists] = await db.query("SELECT * FROM Users WHERE Email = ?", [email]);
    if (exists.length > 0)
      return res.status(400).json({ error: "User already exists" });

    // plain password is stored as-is
    const [result] = await db.query(
      `INSERT INTO Users (FirstName, LastName, Email, Password, JoinDate, BalanceUSD, Role)
       VALUES (?, ?, ?, ?, CURDATE(), 0, 'user')`,
      [firstName, lastName, email, password]
    );

    // Create default wallet
    const walletName = `${firstName}_Wallet`;
    await db.query(
      `INSERT INTO Wallet (UserID, WalletName, CreatedDate, BalanceUSD)
       VALUES (?, ?, CURDATE(), 0)`,
      [result.insertId, walletName]
    );

    console.log("✅ User registered successfully:", email);
    res.json({ message: "✅ User registered successfully!" });
  } catch (err) {
    console.error("💥 Register error:", err);
    res.status(500).json({ error: "Registration failed" });
  }
});

/* 🔁 REFRESH TOKEN ROUTE */
router.post("/refresh", (req, res) => {
  const { token } = req.body;
  if (!token || !refreshTokens.includes(token))
    return res.status(403).json({ error: "Invalid refresh token" });

  jwt.verify(token, REFRESH_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid refresh token" });

    const newAccessToken = jwt.sign(
      { userId: user.userId, email: user.email, role: user.role },
      ACCESS_SECRET,
      { expiresIn: "1h" }
    );

    res.json({ accessToken: newAccessToken });
  });
});

export default router;
