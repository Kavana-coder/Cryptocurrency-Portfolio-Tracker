CREATE DATABASE Cryptocurrency;
USE Cryptocurrency;

-- Users
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    JoinDate DATE NOT NULL
);

-- User Phone Numbers (1-to-many)
CREATE TABLE UserPhonenumber (
    UserID INT NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Alerts
CREATE TABLE Alerts (
    AlertID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Message TEXT NOT NULL,
    AlertType ENUM('PriceDrop', 'Surge', 'PortfolioUpdate') NOT NULL,
    DateCreated DATETIME NOT NULL,
    Status ENUM('Read', 'Unread') DEFAULT 'Unread',
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Wallet (added BalanceUSD as per ERD)
CREATE TABLE Wallet (
    WalletID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    WalletName VARCHAR(100) NOT NULL,
    CreatedDate DATE NOT NULL,
    BalanceUSD DECIMAL(18, 8) NOT NULL DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Crypto
CREATE TABLE Crypto (
    CryptoID INT PRIMARY KEY AUTO_INCREMENT,
    Symbol VARCHAR(10) UNIQUE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Category ENUM('Coin', 'Token') NOT NULL,
    CurrentPriceUSD DECIMAL(18, 8) NOT NULL
);

-- Transactions
CREATE TABLE Transactions (
    TxnID INT PRIMARY KEY AUTO_INCREMENT,
    WalletID INT NOT NULL,
    CryptoID INT NOT NULL,
    Quantity DECIMAL(20, 8) NOT NULL,
    PriceAtTxn DECIMAL(18, 8) NOT NULL,
    TxnType ENUM('Buy', 'Sell') NOT NULL,
    TxnDate DATETIME NOT NULL,
    FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE CASCADE,
    FOREIGN KEY (CryptoID) REFERENCES Crypto(CryptoID) ON DELETE CASCADE
);

-- Portfolio (added AvgBuyPrice and CurrentValue as per ERD)
CREATE TABLE Portfolio (
    PortfolioID INT PRIMARY KEY AUTO_INCREMENT,
    WalletID INT NOT NULL,
    CryptoID INT NOT NULL,
    QuantityHeld DECIMAL(20, 8) NOT NULL,
    AvgBuyPrice DECIMAL(18, 8) NOT NULL,
    CurrentValue DECIMAL(20, 8) GENERATED ALWAYS AS (QuantityHeld * AvgBuyPrice) STORED,
    FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE CASCADE,
    FOREIGN KEY (CryptoID) REFERENCES Crypto(CryptoID) ON DELETE CASCADE,
    UNIQUE (WalletID, CryptoID)
);

-- Price History
CREATE TABLE PriceHistory (
    HistoryID INT PRIMARY KEY AUTO_INCREMENT,
    CryptoID INT NOT NULL,
    Date DATE NOT NULL,
    OpenPrice DECIMAL(18, 8) NOT NULL,
    ClosePrice DECIMAL(18, 8) NOT NULL,
    High DECIMAL(18, 8) NOT NULL,
    Low DECIMAL(18, 8) NOT NULL,
    Volume DECIMAL(20, 4) NOT NULL,
    FOREIGN KEY (CryptoID) REFERENCES Crypto(CryptoID) ON DELETE CASCADE,
    UNIQUE (CryptoID, Date)  
);
