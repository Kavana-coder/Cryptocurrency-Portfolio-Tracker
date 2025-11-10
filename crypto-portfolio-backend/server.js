import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import userRoutes from "./routes/users.js";
import walletRoutes from "./routes/wallet.js";
import cryptoRoutes from "./routes/crypto.js";
import alertRoutes from "./routes/alerts.js";
import transactionRoutes from "./routes/transactions.js";
import portfolioRoutes from "./routes/portfolio.js";
import authRoutes from "./routes/auth.js";

dotenv.config();
const app = express();

// ✅ FIXED: CORS Configuration
app.use(cors({
  origin: ["http://localhost:3000", "http://localhost:5173"], // ✅ allow both
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
}));

app.use(express.json());

// ✅ Routes
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/wallets", walletRoutes);
app.use("/api/crypto", cryptoRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/transactions", transactionRoutes);
app.use("/api/portfolio", portfolioRoutes);

// 🩵 Health Check
app.get("/", (req, res) => res.send("✅ Cryptocurrency Portfolio Tracker API is running..."));

// ✅ Server Start
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
