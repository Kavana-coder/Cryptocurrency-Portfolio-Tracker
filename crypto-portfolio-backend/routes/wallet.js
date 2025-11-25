import express from "express";
import db from "../db.js";
import { verifyToken } from "../middleware/auth.js";

const router = express.Router();

// ✅ Fetch wallets for logged-in user (or all if admin)
router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const userRole = req.user.role;

    let query = `
      SELECT 
        w.WalletID, 
        w.WalletName, 
        w.BalanceUSD,
        COALESCE(fn_WalletCurrentValue(w.WalletID), 0) AS PortfolioValue
      FROM Wallet w
    `;
    let params = [];

    if (userRole !== "admin") {
      query += ` WHERE w.UserID = ?`;
      params.push(userId);
    }

    const [rows] = await db.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching wallets:", err);
    res.status(500).json({ error: "Failed to fetch wallets" });
  }
});

export default router;
