import express from "express";
import db from "../db.js";
import { verifyToken } from "../middleware/auth.js";

const router = express.Router();

// ✅ Get transactions for the logged-in user
router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const userRole = req.user.role;

    let query = `
      SELECT 
        t.TxnID,
        DATE_FORMAT(t.TxnDate, '%Y-%m-%d %H:%i:%s') AS TxnDate,
        t.TxnType,
        c.Symbol AS CryptoSymbol,
        t.Quantity,
        t.PriceAtTxn,
        w.WalletName
      FROM Transactions t
      JOIN Wallet w ON t.WalletID = w.WalletID
      JOIN Crypto c ON t.CryptoID = c.CryptoID
    `;

    // Normal users only see their own
    if (userRole !== "admin") {
      query += ` WHERE w.UserID = ? ORDER BY t.TxnDate DESC`;
      const [rows] = await db.query(query, [userId]);
      return res.json(rows);
    }

    // Admins see all
    query += ` ORDER BY t.TxnDate DESC`;
    const [rows] = await db.query(query);
    res.json(rows);

  } catch (err) {
    console.error("Error fetching transactions:", err);
    res.status(500).json({ error: "Failed to fetch transactions" });
  }
});

// ✅ Add new transaction (keep existing)
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
