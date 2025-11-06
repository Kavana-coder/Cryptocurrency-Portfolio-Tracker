import express from "express";
import db from "../db.js";
const router = express.Router();

// ✅ Get portfolio per wallet
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        w.WalletName,
        c.Symbol AS CryptoSymbol,
        p.QuantityHeld,
        p.AvgBuyPrice,
        ROUND(c.CurrentPriceUSD * p.QuantityHeld, 2) AS CurrentValue
      FROM Portfolio p
      JOIN Wallet w ON p.WalletID = w.WalletID
      JOIN Crypto c ON p.CryptoID = c.CryptoID
      ORDER BY w.WalletName
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching portfolio:", err);
    res.status(500).json({ error: "Failed to fetch portfolio" });
  }
});

export default router;
