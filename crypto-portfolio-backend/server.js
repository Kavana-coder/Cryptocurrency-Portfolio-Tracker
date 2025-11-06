import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import userRoutes from "./routes/users.js";
import walletRoutes from "./routes/wallet.js";
import cryptoRoutes from "./routes/crypto.js";
import alertRoutes from "./routes/alerts.js";
import transactionRoutes from "./routes/transactions.js";
import portfolio from "./routes/portfolio.js";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/users", userRoutes);
app.use("/api/wallets", walletRoutes);
app.use("/api/crypto", cryptoRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/transactions", transactionRoutes);
app.use("/api/portfolio",portfolio);

app.listen(process.env.PORT, () => console.log(`🚀 Server running on port ${process.env.PORT}`));
