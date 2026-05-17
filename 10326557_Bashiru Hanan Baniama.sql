-- ============================================================
--  Pine Valley Furniture Company (PVFC) Database
--  Student : Bashiru Hanan Baniama
--  Index No: 10326557
--  Course  : SQL Practical Exercise – Week 8 Assignment 2
--  Date    : 17 May 2026
--  Tool    : MySQL Workbench
-- ============================================================


-- ============================================================
-- PART 1: DATA DEFINITION LANGUAGE (DDL)
-- ============================================================

-- --------------------------------------------------------
-- 1.  Create the database
-- --------------------------------------------------------
CREATE DATABASE IF NOT EXISTS PineValleyFC;
USE PineValleyFC;


-- --------------------------------------------------------
-- 2a. Parent table: Customer_T
--     (must be created BEFORE Order_T which references it)
-- --------------------------------------------------------
CREATE TABLE Customer_T (
    CustomerID          INT             NOT NULL,
    CustomerName        VARCHAR(25)     NOT NULL,
    CustomerAddress     VARCHAR(30),
    CustomerCity        VARCHAR(20),
    CustomerState       VARCHAR(20),  
    CustomerPostalCode  VARCHAR(10),
    CONSTRAINT Customer_PK PRIMARY KEY (CustomerID)
);


-- --------------------------------------------------------
-- 2b. Child table: Order_T
--     (references Customer_T via CustomerID)
-- --------------------------------------------------------
CREATE TABLE Order_T (
    OrderID     INT     NOT NULL,
    OrderDate   DATE,
    CustomerID  INT,
    CONSTRAINT Order_PK PRIMARY KEY (OrderID),
    CONSTRAINT Order_FK FOREIGN KEY (CustomerID)
	REFERENCES Customer_T(CustomerID)
);


-- --------------------------------------------------------
-- 2c. Parent table: Product_T
-- --------------------------------------------------------
CREATE TABLE Product_T (
    ProductID               INT             NOT NULL,
    ProductDescription      VARCHAR(50),
    ProductFinish           VARCHAR(20)
	CHECK (ProductFinish IN (
            'Cherry', 'Natural Ash', 'White Ash',
            'Red Oak', 'Natural Oak', 'Walnut'
        )),
    ProductStandardPrice    DECIMAL(6,2),
    ProductLineID           INT,
    CONSTRAINT Product_PK PRIMARY KEY (ProductID)
);


-- --------------------------------------------------------
-- 2d. Child table: OrderLine_T
--     (references both Order_T and Product_T)
-- --------------------------------------------------------
CREATE TABLE OrderLine_T (
    OrderID          INT  NOT NULL,
    ProductID        INT  NOT NULL,
    OrderedQuantity  INT,
    CONSTRAINT OrderLine_PK  PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT OrderLine_FK1 FOREIGN KEY (OrderID) REFERENCES Order_T(OrderID),
    CONSTRAINT OrderLine_FK2 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID)
);


-- --------------------------------------------------------
-- 3.  Schema Modification: add CustomerEmail column
-- --------------------------------------------------------
ALTER TABLE Customer_T
    ADD COLUMN CustomerEmail VARCHAR(50);


-- --------------------------------------------------------
-- 4.  Index on ProductStandardPrice for query optimisation
-- --------------------------------------------------------
CREATE INDEX idx_product_price
    ON Product_T (ProductStandardPrice);


-- ============================================================
-- PART 2: DATA MANIPULATION LANGUAGE (DML)
-- ============================================================

-- --------------------------------------------------------
-- 2.1a  Insert at least 5 records into Customer_T
--        (CustomerID range 1100-1105; includes 'Joseph')
-- --------------------------------------------------------
INSERT INTO Customer_T
    (CustomerID, CustomerName, CustomerAddress, CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail)
VALUES
    (1100, 'Joseph Mensah',     '12 Liberation Road',    'Accra',     'Greater Accra', 'GA-100-001', 'joseph.mensah@email.com'),
    (1101, 'Ama Asante',        '45 Kejetia Market St',  'Kumasi',    'Ashanti',       'AS-100-002', 'ama.asante@email.com'),
    (1102, 'Kweku Boateng',     '8 Oxford Street',       'Accra',     'Greater Accra', 'GA-100-003', 'kweku.boateng@email.com'),
    (1103, 'Abena Osei',        '23 Harbour Road',       'Takoradi',  'Western',       'WR-100-004', 'abena.osei@email.com'),
    (1104, 'Kofi Darko',        '15 Central Market Rd',  'Kumasi',    'Ashanti',       'AS-100-005', 'kofi.darko@email.com'),
    (1105, 'Akosua Frimpong',   '33 Tamale Road',        'Tamale',    'Northern',      'NR-100-006', 'akosua.frimpong@email.com');


-- --------------------------------------------------------
-- 2.1a  Insert at least 5 records into Product_T
-- --------------------------------------------------------
INSERT INTO Product_T
    (ProductID, ProductDescription, ProductFinish, ProductStandardPrice, ProductLineID)
VALUES
    (101, 'Cherry Dining Table',   'Cherry',      800.00, 1),   -- This satisfies the request fro 2.1b
    (102, 'Office Workstation',    'Natural Ash', 650.00, 2),
    (103, 'Bedroom Dresser',       'Red Oak',     450.00, 1),
    (104, 'Bookshelf Unit',        'Walnut',      320.00, 3),
    (105, 'Coffee Table',          'White Ash',   280.00, 1),
    (106, 'Executive Desk',        'Natural Oak', 950.00, 2);


-- --------------------------------------------------------
-- 2.1a  Insert at least 5 records into Order_T
--        (includes two orders dated before 01-Jan-2023
--         so the Part 2.4 deletion query has rows to remove)
-- --------------------------------------------------------
INSERT INTO Order_T (OrderID, OrderDate, CustomerID)
VALUES
    (2001, '2024-03-15', 1100),
    (2002, '2024-04-20', 1101),
    (2003, '2024-05-10', 1102),
    (2004, '2022-06-15', 1103),   -- before 2023 – will be deleted in Part 2.4
    (2005, '2024-07-20', 1104),
    (2006, '2022-11-10', 1105),   -- before 2023 – will be deleted in Part 2.4
    (2007, '2024-08-05', 1100);


-- --------------------------------------------------------
-- 2.1a  Insert at least 5 records into OrderLine_T
-- --------------------------------------------------------
INSERT INTO OrderLine_T (OrderID, ProductID, OrderedQuantity)
VALUES
    (2001, 101,  3),
    (2001, 102,  5),
    (2002, 103,  4),
    (2002, 104,  6),
    (2003, 101,  2),
    (2003, 105,  8),
    (2005, 102,  7),
    (2005, 103,  8),
    (2007, 104,  5),
    (2007, 106,  2);
-- Note: OrderLines for orders 2004 and 2006 are intentionally
--       omitted so the deletion in Part 2.4 has no FK conflicts.


-- --------------------------------------------------------
-- 2.1b  (Already included above as ProductID 101)
--        Explicit statement per assignment instruction:
-- --------------------------------------------------------


-- --------------------------------------------------------
-- 2.2a  Filtering & Sorting
--        List CustomerName, CustomerCity, CustomerState
--        for customers in 'Greater Accra' or 'Ashanti'
--        sorted alphabetically by CustomerName
-- --------------------------------------------------------
SELECT
    CustomerName,
    CustomerCity,
    CustomerState
FROM Customer_T
WHERE CustomerState IN ('Greater Accra', 'Ashanti')
ORDER BY CustomerName ASC;


-- --------------------------------------------------------
-- 2.2b  Aggregate Functions
--        MAX, MIN, AVG product price
-- --------------------------------------------------------
SELECT
    MAX(ProductStandardPrice) AS Max_Price,
    MIN(ProductStandardPrice) AS Min_Price,
    AVG(ProductStandardPrice) AS Avg_Price
FROM Product_T;


-- --------------------------------------------------------
-- 2.2c  Inner Join
--        Display OrderID and CustomerName for every order
-- --------------------------------------------------------
SELECT
    o.OrderID,
    c.CustomerName
FROM Order_T o
    INNER JOIN Customer_T c ON o.CustomerID = c.CustomerID;


-- --------------------------------------------------------
-- 2.2d / 2.2e / 2.2f  Group By & Having
--        Total quantity ordered per product;
--        only show products where total quantity > 10
-- --------------------------------------------------------
SELECT
    ProductID,
    SUM(OrderedQuantity) AS TotalQuantityOrdered
FROM OrderLine_T
GROUP BY ProductID
HAVING SUM(OrderedQuantity) > 10;


-- --------------------------------------------------------
-- 2.3  Update
--       Change CustomerCity to 'Koforidua' for CustomerID 1100
--       (first customer in our 1100-1105 range)
-- --------------------------------------------------------
UPDATE Customer_T
SET    CustomerCity = 'Koforidua'
WHERE  CustomerID = 1100;


-- --------------------------------------------------------
-- 2.4  Deletion
--       Remove orders placed before 01 January 2023
-- --------------------------------------------------------
SET SQL_SAFE_UPDATES = 0; -- Turn off safe mode
DELETE FROM Order_T WHERE OrderDate < '2023-01-01';
SET SQL_SAFE_UPDATES = 1;  -- turn it back on after


-- ============================================================
-- PART 3: DATA CONTROL LANGUAGE (DCL)
-- ============================================================

-- --------------------------------------------------------
-- 3.1  Grant SELECT and INSERT on Order_T to Sales_Clerk
-- --------------------------------------------------------

-- Step 1: Create the user
CREATE USER 'Sales_Clerk'@'localhost' IDENTIFIED BY 'password';

-- Step 2: Grant the privileges
GRANT SELECT, INSERT 
    ON PineValleyFC.Order_T 
    TO 'Sales_Clerk'@'localhost';

-- Step 3: Apply the changes
FLUSH PRIVILEGES;
-- --------------------------------------------------------
-- 3.2  Revoke DELETE on Product_T from Sales_Clerk
-- --------------------------------------------------------
-- Step 1: First Grant the privileges to delete before you can revoke
GRANT DELETE
    ON PineValleyFC.Product_T 
    TO 'Sales_Clerk'@'localhost';
    
-- Step 2: Apply the changes
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'Sales_Clerk'@'localhost';

-- Step 3: Delete now
REVOKE DELETE 
    ON PineValleyFC.Product_T 
    FROM 'Sales_Clerk'@'localhost';
    

-- ============================================================
-- END OF SCRIPT
-- ============================================================
