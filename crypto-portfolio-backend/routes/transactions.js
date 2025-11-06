import express from "express";
import db from "../db.js";

const router = express.Router();

// ✅ Get all transactions
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        t.TxnID,
        DATE_FORMAT(t.TxnDate, '%Y-%m-%d %H:%i:%s') AS TxnDate,
        t.TxnType,
        c.Symbol AS CryptoSymbol,
        t.Quantity,
        t.PriceAtTxn
      FROM Transactions t
      JOIN Crypto c ON t.CryptoID = c.CryptoID
      ORDER BY t.TxnDate DESC
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching transactions:", err);
    res.status(500).json({ error: "Failed to fetch transactions" });
  }
});

// ✅ Add new transaction
router.post("/", async (req, res) => {
  try {
    const { walletId, cryptoId, quantity, price, type } = req.body;

    if (!walletId || !cryptoId) {
      return res.status(400).json({ error: "Wallet and Crypto are required" });
    }

    await db.query("CALL sp_AddTransaction_Safe(?, ?, ?, ?, ?)", [
      walletId,
      cryptoId,
      quantity,
      price,
      type,
    ]);

    res.json({ message: "Transaction added successfully" });
  } catch (err) {
    console.error("Error adding transaction:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
