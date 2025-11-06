-- ======================================================================
--   CRYPTOCURRENCY MANAGEMENT SYSTEM - FULL SQL SCRIPT
-- ======================================================================

-- 1️⃣ DATABASE CREATION
CREATE DATABASE IF NOT EXISTS Cryptocurrency;
USE Cryptocurrency;

-- ======================================================================
--   TABLES
-- ======================================================================

-- Users
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    JoinDate DATE NOT NULL,

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

-- Wallet
CREATE TABLE Wallet (
    WalletID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    WalletName VARCHAR(100) NOT NULL,
    CreatedDate DATE NOT NULL,
    BalanceUSD DECIMAL(18,8) NOT NULL DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Crypto
CREATE TABLE Crypto (
    CryptoID INT PRIMARY KEY AUTO_INCREMENT,
    Symbol VARCHAR(10) UNIQUE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Category ENUM('Coin','Token') NOT NULL,
    CurrentPriceUSD DECIMAL(18,8) NOT NULL
);

-- Transactions
CREATE TABLE Transactions (
    TxnID INT PRIMARY KEY AUTO_INCREMENT,
    WalletID INT NOT NULL,
    CryptoID INT NOT NULL,
    Quantity DECIMAL(20,8) NOT NULL,
    PriceAtTxn DECIMAL(18,8) NOT NULL,
    TxnType ENUM('Buy','Sell') NOT NULL,
    TxnDate DATETIME NOT NULL,
    FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE CASCADE,
    FOREIGN KEY (CryptoID) REFERENCES Crypto(CryptoID) ON DELETE CASCADE
);

-- Portfolio
CREATE TABLE Portfolio (
    PortfolioID INT PRIMARY KEY AUTO_INCREMENT,
    WalletID INT NOT NULL,
    CryptoID INT NOT NULL,
    QuantityHeld DECIMAL(20,8) NOT NULL,
    AvgBuyPrice DECIMAL(18,8) NOT NULL,
    CurrentValue DECIMAL(20,8)
        GENERATED ALWAYS AS (QuantityHeld * AvgBuyPrice) STORED,
    FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID) ON DELETE CASCADE,
    FOREIGN KEY (CryptoID) REFERENCES Crypto(CryptoID) ON DELETE CASCADE,
    UNIQUE (WalletID, CryptoID)
);

-- Price History
CREATE TABLE PriceHistory (
    HistoryID INT PRIMARY KEY AUTO_INCREMENT,
    CryptoID INT NOT NULL,
    Date DATE NOT NULL,
    OpenPrice DECIMAL(18,8) NOT NULL,
    ClosePrice DECIMAL(18,8) NOT NULL,
    High DECIMAL(18,8) NOT NULL,
    Low DECIMAL(18,8) NOT NULL,
    Volume DECIMAL(20,4) NOT NULL,
    FOREIGN KEY (CryptoID) REFERENCES Crypto(CryptoID) ON DELETE CASCADE,
    UNIQUE (CryptoID, Date)
);

-- ======================================================================
--   SAMPLE DATA
-- ======================================================================

INSERT INTO Users (FirstName, LastName, Email, Password, JoinDate)
VALUES 
('Alice', 'Smith', 'alice@example.com', 'pass123', '2024-01-10'),
('Bob', 'Jones', 'bob@example.com', 'pass456', '2024-03-21'),
('Charlie', 'Brown', 'charlie@example.com', 'pass789', '2024-05-12');

INSERT INTO UserPhonenumber VALUES
(1, '9876543210'), (1, '9123456789'), (2, '9988776655');

INSERT INTO Crypto (Symbol, Name, Category, CurrentPriceUSD) VALUES
('BTC','Bitcoin','Coin',68000.00),
('ETH','Ethereum','Coin',3400.75),
('SOL','Solana','Token',150.35),
('USDT','Tether','Token',1.00);

INSERT INTO Wallet (UserID, WalletName, CreatedDate, BalanceUSD) VALUES
(1,'Alice_Main_Wallet','2024-01-11',20000.00),
(2,'Bob_Crypto_Wallet','2024-03-22',5000.00),
(3,'Charlie_Portfolio','2024-05-13',7000.00);

INSERT INTO Portfolio (WalletID,CryptoID,QuantityHeld,AvgBuyPrice)
VALUES (1,1,0.5,65000.00),(3,2,1.2,2500.00);

INSERT INTO Alerts (UserID, Message, AlertType, DateCreated)
VALUES
(1,'Bitcoin dropped below $65,000!','PriceDrop',NOW()),
(2,'Ethereum surged by 5% today!','Surge',NOW()),
(3,'Portfolio updated successfully.','PortfolioUpdate',NOW());

-- ======================================================================
--   CONSTRAINT ALTERATIONS
-- ======================================================================
ALTER TABLE Users ADD COLUMN BalanceUSD DECIMAL(18,8) DEFAULT 0;

ALTER TABLE Wallet DROP FOREIGN KEY Wallet_ibfk_1;
ALTER TABLE Wallet
  ADD CONSTRAINT fk_wallet_user
  FOREIGN KEY (UserID) REFERENCES Users(UserID)
  ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Alerts MODIFY COLUMN UserID INT NULL;
ALTER TABLE Alerts DROP FOREIGN KEY Alerts_ibfk_1;
ALTER TABLE Alerts
  ADD CONSTRAINT fk_alerts_user
  FOREIGN KEY (UserID) REFERENCES Users(UserID)
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE Portfolio DROP FOREIGN KEY Portfolio_ibfk_1;
ALTER TABLE Portfolio
  ADD CONSTRAINT fk_portfolio_wallet
  FOREIGN KEY (WalletID) REFERENCES Wallet(WalletID)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- ======================================================================
--   USER CREATION & PRIVILEGES
-- ======================================================================

CREATE USER IF NOT EXISTS 'app_user'@'localhost' IDENTIFIED BY 'app_pass_123';
CREATE USER IF NOT EXISTS 'dba_user'@'localhost' IDENTIFIED BY 'dba_pass_123';

GRANT SELECT, INSERT, UPDATE, DELETE ON Cryptocurrency.* TO 'app_user'@'localhost';
GRANT ALL PRIVILEGES ON Cryptocurrency.* TO 'dba_user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- ======================================================================
--   STORED FUNCTIONS
-- ======================================================================

DELIMITER $$

CREATE FUNCTION fn_WalletCurrentValue(p_WalletID INT) RETURNS DECIMAL(30,8)
DETERMINISTIC
BEGIN
    DECLARE val DECIMAL(30,8) DEFAULT 0;
    SELECT IFNULL(SUM(p.QuantityHeld * c.CurrentPriceUSD),0)
    INTO val FROM Portfolio p
    JOIN Crypto c ON p.CryptoID = c.CryptoID
    WHERE p.WalletID = p_WalletID;
    RETURN val;
END$$

CREATE FUNCTION fn_GetQuantityHeld(p_WalletID INT, p_CryptoID INT) RETURNS DECIMAL(30,8)
DETERMINISTIC
BEGIN
    DECLARE q DECIMAL(30,8) DEFAULT 0;
    SELECT IFNULL(QuantityHeld,0) INTO q
    FROM Portfolio
    WHERE WalletID = p_WalletID AND CryptoID = p_CryptoID;
    RETURN q;
END$$

DELIMITER ;

-- ======================================================================
--   STORED PROCEDURES
-- ======================================================================

DELIMITER $$

CREATE PROCEDURE sp_AddTransaction_Safe(
    IN p_WalletID INT,
    IN p_CryptoID INT,
    IN p_Quantity DECIMAL(20,8),
    IN p_PriceAtTxn DECIMAL(18,8),
    IN p_TxnType ENUM('Buy','Sell')
)
BEGIN
    DECLARE currentBal DECIMAL(30,8);
    DECLARE required DECIMAL(30,8);

    SELECT BalanceUSD INTO currentBal FROM Wallet WHERE WalletID = p_WalletID FOR UPDATE;
    SET required = p_Quantity * p_PriceAtTxn;

    IF p_TxnType = 'Buy' THEN
        IF currentBal < required THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient wallet balance for BUY transaction';
        END IF;
    ELSEIF p_TxnType = 'Sell' THEN
        IF fn_GetQuantityHeld(p_WalletID,p_CryptoID) < p_Quantity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient crypto quantity to SELL';
        END IF;
    END IF;

    INSERT INTO Transactions (WalletID,CryptoID,Quantity,PriceAtTxn,TxnType,TxnDate)
    VALUES (p_WalletID,p_CryptoID,p_Quantity,p_PriceAtTxn,p_TxnType,NOW());
END$$

CREATE PROCEDURE sp_RecalcAvgBuyPrice(IN p_WalletID INT, IN p_CryptoID INT)
BEGIN
    DECLARE totalBoughtQty DECIMAL(30,8);
    DECLARE weightedSum DECIMAL(30,8);
    SELECT IFNULL(SUM(Quantity),0), IFNULL(SUM(Quantity * PriceAtTxn),0)
    INTO totalBoughtQty, weightedSum
    FROM Transactions
    WHERE WalletID=p_WalletID AND CryptoID=p_CryptoID AND TxnType='Buy';
    IF totalBoughtQty=0 THEN
        UPDATE Portfolio SET AvgBuyPrice=0 WHERE WalletID=p_WalletID AND CryptoID=p_CryptoID;
    ELSE
        UPDATE Portfolio
        SET AvgBuyPrice = weightedSum / totalBoughtQty
        WHERE WalletID=p_WalletID AND CryptoID=p_CryptoID;
    END IF;
END$$

DELIMITER ;

-- ======================================================================
--   TRIGGERS
-- ======================================================================

DELIMITER $$

CREATE TRIGGER trg_after_insert_transactions
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE walletBal DECIMAL(30,8);
    DECLARE existingQty DECIMAL(30,8);
    DECLARE newQty DECIMAL(30,8);
    DECLARE currentAvg DECIMAL(30,8);

    SELECT BalanceUSD INTO walletBal FROM Wallet WHERE WalletID=NEW.WalletID FOR UPDATE;

    IF NEW.TxnType='Buy' THEN
        UPDATE Wallet SET BalanceUSD=BalanceUSD-(NEW.Quantity*NEW.PriceAtTxn) WHERE WalletID=NEW.WalletID;
    ELSEIF NEW.TxnType='Sell' THEN
        UPDATE Wallet SET BalanceUSD=BalanceUSD+(NEW.Quantity*NEW.PriceAtTxn) WHERE WalletID=NEW.WalletID;
    END IF;

    SELECT IFNULL(QuantityHeld,0), IFNULL(AvgBuyPrice,0) INTO existingQty, currentAvg
    FROM Portfolio WHERE WalletID=NEW.WalletID AND CryptoID=NEW.CryptoID FOR UPDATE;

    IF ROW_COUNT()=0 THEN
        IF NEW.TxnType='Buy' THEN
            INSERT INTO Portfolio (WalletID,CryptoID,QuantityHeld,AvgBuyPrice)
            VALUES (NEW.WalletID,NEW.CryptoID,NEW.Quantity,NEW.PriceAtTxn);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Attempt to SELL non-held crypto';
        END IF;
    ELSE
        IF NEW.TxnType='Buy' THEN
            SET newQty=existingQty+NEW.Quantity;
            SET currentAvg=(existingQty*currentAvg+NEW.Quantity*NEW.PriceAtTxn)/newQty;
            UPDATE Portfolio SET QuantityHeld=newQty, AvgBuyPrice=currentAvg
            WHERE WalletID=NEW.WalletID AND CryptoID=NEW.CryptoID;
        ELSE
            SET newQty=existingQty-NEW.Quantity;
            IF newQty<0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Attempt to SELL more than held';
            ELSEIF newQty=0 THEN
                UPDATE Portfolio SET QuantityHeld=0, AvgBuyPrice=0 WHERE WalletID=NEW.WalletID AND CryptoID=NEW.CryptoID;
            ELSE
                UPDATE Portfolio SET QuantityHeld=newQty WHERE WalletID=NEW.WalletID AND CryptoID=NEW.CryptoID;
            END IF;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_after_insert_pricehistory
AFTER INSERT ON PriceHistory
FOR EACH ROW
BEGIN
    UPDATE Crypto SET CurrentPriceUSD=NEW.ClosePrice WHERE CryptoID=NEW.CryptoID;
END$$

CREATE TRIGGER trg_after_update_crypto_price
AFTER UPDATE ON Crypto
FOR EACH ROW
BEGIN
    DECLARE oldprice DECIMAL(18,8);
    DECLARE pct_change DECIMAL(10,4);
    SET oldprice=OLD.CurrentPriceUSD;
    IF oldprice IS NULL OR oldprice=0 THEN
        SET pct_change=0;
    ELSE
        SET pct_change=((NEW.CurrentPriceUSD - oldprice)/oldprice)*100;
    END IF;

    IF ABS(pct_change)>=5 THEN
        INSERT INTO Alerts (UserID,Message,AlertType,DateCreated,Status)
        SELECT w.UserID,
               CONCAT('Price alert for ', (SELECT Symbol FROM Crypto WHERE CryptoID=NEW.CryptoID),
                      ': change = ', ROUND(pct_change,2), '%'),
               'Surge',NOW(),'Unread'
        FROM Wallet w
        JOIN Portfolio p ON p.WalletID=w.WalletID
        WHERE p.CryptoID=NEW.CryptoID;
    END IF;
END$$

-- 🟢 MISSING TRIGGER (added now)
CREATE TRIGGER trg_after_wallet_update
AFTER UPDATE ON Wallet
FOR EACH ROW
BEGIN
    UPDATE Users
    SET BalanceUSD = (
        SELECT SUM(BalanceUSD)
        FROM Wallet
        WHERE UserID = NEW.UserID
    )
    WHERE UserID = NEW.UserID;
END$$

DELIMITER ;

-- ======================================================================
--   SAMPLE QUERIES & TESTING
-- ======================================================================

CALL sp_AddTransaction_Safe(1,1,0.01,68000.00,'Buy');
CALL sp_AddTransaction_Safe(3,2,0.1,3400.75,'Sell');
CALL sp_RecalcAvgBuyPrice(1,1);
SELECT fn_WalletCurrentValue(1) AS AliceWalletValue;

SELECT u.UserID,u.FirstName,u.Email
FROM Users u
WHERE u.UserID IN (
  SELECT w.UserID FROM Wallet w
  JOIN Portfolio p ON p.WalletID=w.WalletID
  JOIN Crypto c ON c.CryptoID=p.CryptoID
  WHERE c.Symbol='BTC' AND p.QuantityHeld>1
);

SELECT w.WalletID,w.WalletName,SUM(p.QuantityHeld*c.CurrentPriceUSD) AS CurrentValueUSD
FROM Wallet w
LEFT JOIN Portfolio p ON p.WalletID=w.WalletID
LEFT JOIN Crypto c ON c.CryptoID=p.CryptoID
GROUP BY w.WalletID,w.WalletName
ORDER BY CurrentValueUSD DESC;

SELECT WalletID,WalletName,val
FROM (
  SELECT w.WalletID,w.WalletName,IFNULL(SUM(p.QuantityHeld*c.CurrentPriceUSD),0) AS val
  FROM Wallet w
  LEFT JOIN Portfolio p ON p.WalletID=w.WalletID
  LEFT JOIN Crypto c ON c.CryptoID=p.CryptoID
  GROUP BY w.WalletID
) AS t
WHERE val > (
  SELECT AVG(val) FROM (
    SELECT IFNULL(SUM(p.QuantityHeld*c.CurrentPriceUSD),0) AS val
    FROM Wallet w
    LEFT JOIN Portfolio p ON p.WalletID=w.WalletID
    LEFT JOIN Crypto c ON c.CryptoID=p.CryptoID
    GROUP BY w.WalletID
  ) AS sub
);

SELECT * FROM Alerts ORDER BY DateCreated DESC LIMIT 20;

SELECT Symbol,Name,CurrentPriceUSD FROM Crypto ORDER BY CurrentPriceUSD DESC LIMIT 5;

SELECT u.UserID,u.FirstName,SUM(p.QuantityHeld*c.CurrentPriceUSD) AS tot_val
FROM Users u
JOIN Wallet w ON w.UserID=u.UserID
JOIN Portfolio p ON p.WalletID=w.WalletID
JOIN Crypto c ON c.CryptoID=p.CryptoID
GROUP BY u.UserID HAVING tot_val>10000;

SELECT * FROM Crypto WHERE CryptoID NOT IN (SELECT DISTINCT CryptoID FROM PriceHistory);

-- ======================================================================
-- END OF SCRIPT
-- ======================================================================
