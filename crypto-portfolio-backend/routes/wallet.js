import express from "express";
import db from "../db.js";
const router = express.Router();

// ✅ Fetch all wallets with portfolio value
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        w.WalletID, 
        w.WalletName, 
        w.BalanceUSD,
        COALESCE(fn_WalletCurrentValue(w.WalletID), 0) AS PortfolioValue
      FROM Wallet w
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching wallets:", err);
    res.status(500).json({ error: "Failed to fetch wallets" });
  }
});

export default router;
