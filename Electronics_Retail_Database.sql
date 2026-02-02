-- ============================================================================
-- ELECTRONICS RETAIL COMPANY DATABASE
-- Complete SQL Implementation Script
-- Author: Christopher Garcia
-- Date: January 17, 2025
-- ============================================================================

-- Drop existing tables
DROP TABLE IF EXISTS Order_Details;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Suppliers;

-- ============================================================================
-- DDL: CREATE TABLES
-- ============================================================================

CREATE TABLE Suppliers (
    Supplier_ID INT AUTO_INCREMENT PRIMARY KEY,
    Supplier_Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    CONSTRAINT chk_supplier_email CHECK (Email LIKE '%@%')
);

CREATE TABLE Categories (
    Category_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_Name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Products (
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Category_ID INT NOT NULL,
    Supplier_ID INT NOT NULL,
    Unit_Price DECIMAL(10,2) NOT NULL,
    QOH INT DEFAULT 0,
    CONSTRAINT fk_product_category FOREIGN KEY (Category_ID) 
        REFERENCES Categories(Category_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_product_supplier FOREIGN KEY (Supplier_ID) 
        REFERENCES Suppliers(Supplier_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_unit_price CHECK (Unit_Price > 0),
    CONSTRAINT chk_qoh CHECK (QOH >= 0)
);

CREATE TABLE Customers (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    CONSTRAINT chk_customer_email CHECK (Email LIKE '%@%')
);

CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Order_Time TIME NOT NULL,
    Order_Amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_customer FOREIGN KEY (Customer_ID) 
        REFERENCES Customers(Customer_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_order_amount CHECK (Order_Amount >= 0)
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Line_Total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_orderdetail_order FOREIGN KEY (Order_ID) 
        REFERENCES Orders(Order_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orderdetail_product FOREIGN KEY (Product_ID) 
        REFERENCES Products(Product_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_line_total CHECK (Line_Total >= 0)
);

-- Create indexes for performance
CREATE INDEX idx_products_category ON Products(Category_ID);
CREATE INDEX idx_products_supplier ON Products(Supplier_ID);
CREATE INDEX idx_orders_customer ON Orders(Customer_ID);
CREATE INDEX idx_orders_date ON Orders(Order_Date);
CREATE INDEX idx_orderdetails_order ON Order_Details(Order_ID);
CREATE INDEX idx_orderdetails_product ON Order_Details(Product_ID);

-- ============================================================================
-- DML: INSERT DATA
-- ============================================================================

-- SUPPLIERS
INSERT INTO Suppliers (Supplier_Name, Phone, Email) VALUES
('TechWare Solutions', '555-0101', 'contact@techware.com'),
('Global Electronics Inc', '555-0102', 'sales@globalelectronics.com'),
('Digital Depot', '555-0103', 'orders@digitaldepot.com'),
('SmartGadgets LLC', '555-0104', 'info@smartgadgets.com'),
('CompTech Distributors', '555-0105', 'support@comptech.com'),
('ElectroWorld Wholesale', '555-0106', 'wholesale@electroworld.com'),
('Prime Components', '555-0107', 'sales@primecomponents.com');

-- CATEGORIES
INSERT INTO Categories (Category_Name) VALUES
('Laptops'),
('Smartphones'),
('Tablets'),
('Accessories'),
('Audio'),
('Gaming'),
('Networking');

-- PRODUCTS
INSERT INTO Products (Product_Name, Category_ID, Supplier_ID, Unit_Price, QOH) VALUES
('Dell XPS 15 Laptop', 1, 1, 1299.99, 15),
('MacBook Pro 14-inch', 1, 1, 1999.99, 8),
('HP Pavilion Laptop', 1, 2, 799.99, 25),
('Lenovo ThinkPad X1', 1, 5, 1449.99, 12),
('ASUS ROG Gaming Laptop', 1, 7, 1899.99, 6),
('iPhone 15 Pro', 2, 3, 999.99, 30),
('Samsung Galaxy S24', 2, 3, 899.99, 35),
('Google Pixel 8', 2, 4, 699.99, 20),
('OnePlus 12', 2, 4, 799.99, 18),
('Motorola Edge 40', 2, 6, 599.99, 22),
('iPad Pro 12.9-inch', 3, 3, 1099.99, 14),
('Samsung Galaxy Tab S9', 3, 3, 849.99, 16),
('Microsoft Surface Pro 9', 3, 2, 1299.99, 10),
('Amazon Fire HD 10', 3, 6, 149.99, 40),
('Lenovo Tab P11 Pro', 3, 5, 499.99, 25),
('AirPods Pro', 4, 3, 249.99, 50),
('Samsung Galaxy Buds', 4, 3, 149.99, 45),
('USB-C Hub Adapter', 4, 7, 39.99, 100),
('Wireless Mouse', 4, 5, 29.99, 80),
('Laptop Backpack', 4, 6, 49.99, 60),
('Sony WH-1000XM5 Headphones', 5, 4, 399.99, 20),
('Bose QuietComfort 45', 5, 4, 329.99, 18),
('JBL Flip 6 Speaker', 5, 6, 129.99, 35),
('Beats Studio Buds', 5, 3, 149.99, 28),
('Soundbar 5.1 System', 5, 2, 299.99, 12),
('PlayStation 5 Console', 6, 1, 499.99, 5),
('Xbox Series X', 6, 1, 499.99, 7),
('Nintendo Switch OLED', 6, 4, 349.99, 15),
('Gaming Headset RGB', 6, 7, 89.99, 40),
('Mechanical Gaming Keyboard', 6, 7, 129.99, 30),
('TP-Link WiFi 6 Router', 7, 5, 89.99, 25),
('Netgear Mesh System', 7, 5, 299.99, 12),
('Ethernet Switch 8-Port', 7, 7, 39.99, 35),
('WiFi Range Extender', 7, 5, 49.99, 40),
('Cat6 Ethernet Cables 10ft', 7, 7, 14.99, 100);

-- CUSTOMERS
INSERT INTO Customers (Customer_Name, Email, Phone) VALUES
('John Smith', 'john.smith@email.com', '555-1001'),
('Sarah Johnson', 'sarah.j@email.com', '555-1002'),
('Michael Williams', 'mwilliams@email.com', '555-1003'),
('Emily Brown', 'ebrown@email.com', '555-1004'),
('David Jones', 'djones@email.com', '555-1005'),
('Jessica Davis', 'jdavis@email.com', '555-1006'),
('Christopher Miller', 'cmiller@email.com', '555-1007'),
('Amanda Wilson', 'awilson@email.com', '555-1008');

-- ORDERS
INSERT INTO Orders (Customer_ID, Order_Date, Order_Time, Order_Amount) VALUES
(1, '2025-01-10', '10:30:00', 1549.98),
(2, '2025-01-11', '14:15:00', 999.99),
(3, '2025-01-11', '16:45:00', 2099.98),
(4, '2025-01-12', '09:20:00', 399.99),
(5, '2025-01-12', '11:00:00', 1449.99),
(6, '2025-01-13', '13:30:00', 679.97),
(1, '2025-01-14', '15:45:00', 249.99),
(7, '2025-01-15', '10:00:00', 3299.97);

-- ORDER DETAILS
INSERT INTO Order_Details (Order_ID, Product_ID, Quantity, Line_Total) VALUES
(1, 1, 1, 1299.99),
(1, 18, 1, 39.99),
(1, 19, 1, 29.99),
(1, 31, 2, 179.98),
(2, 6, 1, 999.99),
(3, 2, 1, 1999.99),
(3, 18, 1, 39.99),
(3, 20, 1, 49.99),
(4, 21, 1, 399.99),
(5, 4, 1, 1449.99),
(6, 8, 1, 699.99),
(6, 16, 1, 249.99),
(6, 35, 2, 29.98),
(7, 16, 1, 249.99),
(8, 26, 1, 499.99),
(8, 27, 1, 499.99),
(8, 1, 1, 1299.99),
(8, 29, 1, 89.99),
(8, 30, 1, 129.99),
(8, 31, 2, 179.98),
(8, 33, 1, 39.99),
(8, 35, 4, 59.96);

-- ============================================================================
-- DML: UPDATE STATEMENTS
-- ============================================================================

-- Update supplier phone
UPDATE Suppliers 
SET Phone = '555-0199' 
WHERE Supplier_Name = 'TechWare Solutions';

-- Update customer email
UPDATE Customers 
SET Email = 'john.smith.new@email.com' 
WHERE Customer_ID = 1;

-- ============================================================================
-- DML: DELETE STATEMENTS
-- ============================================================================

-- Delete test order detail
DELETE FROM Order_Details 
WHERE Order_ID = 8 AND Product_ID = 35;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- View all data
SELECT 'Suppliers' AS Table_Name, COUNT(*) AS Record_Count FROM Suppliers
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Order_Details', COUNT(*) FROM Order_Details;

-- View products with categories and suppliers
SELECT p.Product_ID, p.Product_Name, c.Category_Name, s.Supplier_Name, 
       p.Unit_Price, p.QOH
FROM Products p
JOIN Categories c ON p.Category_ID = c.Category_ID
JOIN Suppliers s ON p.Supplier_ID = s.Supplier_ID
ORDER BY c.Category_Name, p.Product_Name;

-- View orders with customer info
SELECT o.Order_ID, c.Customer_Name, o.Order_Date, o.Order_Amount
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
ORDER BY o.Order_Date DESC;

-- View order details
SELECT od.Order_ID, p.Product_Name, od.Quantity, od.Line_Total
FROM Order_Details od
JOIN Products p ON od.Product_ID = p.Product_ID
ORDER BY od.Order_ID;
