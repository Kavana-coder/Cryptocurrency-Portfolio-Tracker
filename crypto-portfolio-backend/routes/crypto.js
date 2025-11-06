import express from "express";
import db from "../db.js";
const router = express.Router();

// ✅ Get all cryptos
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        CryptoID, 
        Symbol, 
        Name, 
        Category, 
        CurrentPriceUSD 
      FROM Crypto
      ORDER BY CurrentPriceUSD DESC
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching cryptos:", err);
    res.status(500).json({ error: "Failed to fetch cryptos" });
  }
});

// ✅ Get top 5
router.get("/top5", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        CryptoID, 
        Symbol, 
        Name, 
        Category, 
        CurrentPriceUSD 
      FROM Crypto
      ORDER BY CurrentPriceUSD DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching top 5 cryptos:", err);
    res.status(500).json({ error: "Failed to fetch top 5 cryptos" });
  }
});

export default router;
