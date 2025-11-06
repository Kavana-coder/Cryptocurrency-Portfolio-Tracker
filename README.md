💹 Crypto Portfolio Management System

⚡️ A full-stack Cryptocurrency Management Platform built with Node.js, Express, MySQL, and React.js, offering real-time tracking, automated alerts, and intelligent wallet portfolio analysis — just like a professional crypto trading dashboard.


🪙 Overview
Crypto Portfolio Management System is a complete web-based solution that allows users to:


Manage multiple wallets 💼


Track real-time crypto prices 🪙


Execute buy/sell transactions with balance validation 🔄


Automatically generate alerts for market surges and drops 🔔


View detailed portfolio analytics and wallet valuations 📊


This project replicates the core functionalities of exchanges like Binance or CoinMarketCap, with a secure, well-structured backend and an interactive frontend dashboard.

🏗️ Tech Stack
| Layer           | Technology                               | Purpose                                    |
| --------------- | ---------------------------------------- | ------------------------------------------ |
| **Frontend**    | React.js, Axios, CSS (optional Tailwind) | Responsive UI and data visualization       |
| **Backend**     | Node.js + Express.js                     | RESTful APIs and business logic            |
| **Database**    | MySQL                                    | Data persistence and relational management |
| **Language**    | JavaScript (ES6+)                        | Core application logic                     |
| **ORM / Query** | MySQL2 (Promise API)                     | Database connectivity                      |
| **Environment** | dotenv                                   | Secure environment configuration           |

⚙️ Features
🧩 Core Functionalities

User Management — Register, update, and delete users (auto-creates wallets).
Wallet System — Each user has a dedicated wallet tracking USD balance and cryptos held.
Portfolio Management — Automatic updates of quantities, average buy prices, and total values.
Transaction System — Safe “Buy” and “Sell” operations validated against balance and holdings.
Price Tracking — Fetch and maintain live crypto prices.
Automated Alerts — Triggers when crypto prices change by ±5%.
Dashboard Visualization — Displays wallet balances, top 5 cryptos, and portfolio summaries.


🧠 Advanced Logic


Smart MySQL Triggers & Procedures for:
Auto-wallet balance updates
Portfolio recalculation
Alert generation on price change

Stored Functions like:
fn_WalletCurrentValue(walletID) → Calculates live wallet value
fn_GetQuantityHeld(walletID, cryptoID) → Retrieves crypto quantity




🛡️ Security
Safe Transactions (sp_AddTransaction_Safe) prevent invalid buys/sells.
User Privileges for app_user and dba_user in MySQL for secure access control.
CORS & dotenv for secure API handling and environment protection.



🧰 Database Schema
Database: Cryptocurrency
Tables:
Users, UserPhonenumber, Wallet, Crypto, Transactions, Portfolio, PriceHistory, Alerts
Automation:


4 Triggers

2 Stored Functions

2 Stored Procedures


All major operations are handled server-side with data integrity guaranteed through foreign key constraints and trigger logic.

🧠 Trigger Highlights
| Trigger                         | Event                          | Purpose                              |
| ------------------------------- | ------------------------------ | ------------------------------------ |
| `trg_after_insert_transactions` | `AFTER INSERT ON Transactions` | Updates portfolio & wallet balance   |
| `trg_after_insert_pricehistory` | `AFTER INSERT ON PriceHistory` | Syncs crypto current price           |
| `trg_after_update_crypto_price` | `AFTER UPDATE ON Crypto`       | Creates alerts for price changes ≥5% |
| `trg_after_wallet_update`       | `AFTER UPDATE ON Wallet`       | Auto-updates user total balance      |


✅ Backend runs on port 5000
✅ Frontend runs on port 3000

📡 API Endpoints
| Method | Endpoint            | Description                                  |
| ------ | ------------------- | -------------------------------------------- |
| GET    | `/api/users`        | Fetch all users                              |
| POST   | `/api/users`        | Add new user (auto-creates wallet)           |
| GET    | `/api/wallets`      | Get all wallets with portfolio values        |
| GET    | `/api/crypto`       | Fetch all cryptocurrencies                   |
| GET    | `/api/crypto/top5`  | Fetch top 5 cryptos                          |
| GET    | `/api/transactions` | List all transactions                        |
| POST   | `/api/transactions` | Add new transaction (calls stored procedure) |
| GET    | `/api/alerts`       | Fetch market alerts                          |
| GET    | `/api/portfolio`    | View portfolio summaries                     |

🔔 Automated Alert Flow

Admin or system updates a crypto’s CurrentPriceUSD
Trigger calculates % change
If ≥ ±5%, an entry is inserted into the Alerts table
Frontend Alerts.jsx auto-fetches and displays live updates



📊 Sample Dashboard Sections
| Section         | Data Source      | Description                         |
| --------------- | ---------------- | ----------------------------------- |
| Wallet Overview | `/api/wallets`   | Lists wallets and live balance      |
| Portfolio Table | `/api/portfolio` | Displays crypto holdings            |
| Market Data     | `/api/crypto`    | Shows crypto prices sorted by value |
| Alerts          | `/api/alerts`    | Shows surge/drop notifications      |

🧠 SQL Intelligence

Functions handle computation (fn_WalletCurrentValue, fn_GetQuantityHeld)
Triggers ensure automatic consistency
Procedures ensure safe operations
Views (optional) can be added for advanced analytics



🧩 Future Enhancements

📈 Real-time WebSocket updates for price changes

🔒 JWT authentication & role-based access

💰 Integration with live APIs (CoinGecko, Binance)

📱 Responsive mobile UI

🌙 Dark mode with glowing crypto aesthetic



🚀 How to Set Up Locally
🗄️ Step 1 — Database Setup
SOURCE /path/to/crypto_portfolio.sql;

⚙️ Step 2 — Environment Variables (.env)
PORT=5000
DB_USER=root
DB_PASS=your_password
DB_NAME=Cryptocurrency

💻 Step 3 — Start Backend
cd crypto-portfolio-backend
npm install
node server.js

🌐 Step 4 — Start Frontend
cd crypto-portfolio-ui
npm install
npm start


🏅 Key Highlights


🔧 Advanced SQL Engineering with triggers, functions, and procedures

⚡ Seamless backend-frontend integration

💾 Secure data consistency model

🎨 Customizable frontend dashboard

🧠 Real-world simulation of crypto platform mechanics



🧑‍💻 Contributors
| Name                  | Role                 | Contribution                                                                                         |
| --------------------- | -------------------- | ---------------------------------------------------------------------------------------------------- |
| **Kavana H**          | Full-Stack Developer | Database Design, Backend API Development, Frontend Dashboard Integration, Alerts & Wallet Automation |
| **Karanam Sumedha ** | Frontend Developer   | UI Design, React Components, Styling, User Interaction, and Dashboard Enhancements                   |

This project is licensed under the MIT License — feel free to fork and enhance.

🌟 Show Your Support
If you found this project helpful or educational:
⭐ Star this repository — it motivates further development!
