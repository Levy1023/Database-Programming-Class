-- ============================================================================
-- ELECTRONICS RETAIL COMPANY - SQL QUERIES
-- Executable Query Script
-- Author: Christopher Garcia
-- Date: January 17, 2025
-- ============================================================================

-- ============================================================================
-- PART 1: SINGLE-TABLE QUERIES
-- ============================================================================

-- Query 1.1: List all products with key information
SELECT 
    Product_Name,
    Category_ID,
    Unit_Price,
    QOH
FROM 
    Products
ORDER BY 
    Product_Name ASC;


-- Query 1.2: Find out-of-stock products
SELECT 
    Product_ID,
    Product_Name,
    Category_ID,
    Supplier_ID,
    Unit_Price,
    QOH
FROM 
    Products
WHERE 
    QOH = 0
ORDER BY 
    Category_ID ASC,
    Product_Name ASC;


-- Query 1.3: Products priced between $100 and $500
SELECT 
    Product_ID,
    Product_Name,
    Category_ID,
    Unit_Price,
    QOH
FROM 
    Products
WHERE 
    Unit_Price BETWEEN 100 AND 500
ORDER BY 
    Unit_Price ASC,
    Product_Name ASC;


-- Query 1.4: Count products per category
SELECT 
    Category_ID,
    COUNT(*) AS Product_Count
FROM 
    Products
GROUP BY 
    Category_ID
ORDER BY 
    Product_Count DESC,
    Category_ID ASC;


-- Query 1.5: Average price per category
SELECT 
    Category_ID,
    ROUND(AVG(Unit_Price), 2) AS Average_Price
FROM 
    Products
GROUP BY 
    Category_ID
ORDER BY 
    Average_Price DESC,
    Category_ID ASC;


-- ============================================================================
-- PART 2: MULTI-TABLE QUERIES WITH JOINS
-- ============================================================================

-- Query 2.1: Products with supplier contact information (INNER JOIN)
SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Unit_Price,
    p.QOH,
    s.Supplier_Name,
    s.Phone,
    s.Email
FROM 
    Products p
INNER JOIN 
    Suppliers s
    ON p.Supplier_ID = s.Supplier_ID
ORDER BY 
    s.Supplier_Name ASC,
    p.Product_Name ASC;


-- Query 2.2: Sales report with products, categories, and orders (Multiple JOINs)
SELECT 
    p.Product_Name,
    c.Category_Name,
    od.Quantity,
    od.Line_Total,
    o.Order_Date,
    o.Order_Time
FROM 
    Order_Details od
INNER JOIN 
    Products p
    ON od.Product_ID = p.Product_ID
INNER JOIN 
    Categories c
    ON p.Category_ID = c.Category_ID
INNER JOIN 
    Orders o
    ON od.Order_ID = o.Order_ID
ORDER BY 
    o.Order_Date DESC,
    o.Order_Time DESC,
    p.Product_Name ASC;


-- Query 2.3: All suppliers with their products (LEFT JOIN)
SELECT 
    s.Supplier_ID,
    s.Supplier_Name,
    s.Phone,
    s.Email,
    p.Product_ID,
    p.Product_Name,
    p.Unit_Price,
    p.QOH
FROM 
    Suppliers s
LEFT JOIN 
    Products p
    ON s.Supplier_ID = p.Supplier_ID
ORDER BY 
    s.Supplier_Name ASC,
    p.Product_Name ASC;


-- Query 2.4: All products and suppliers (FULL OUTER JOIN simulation)
SELECT 
    s.Supplier_ID,
    s.Supplier_Name,
    p.Product_ID,
    p.Product_Name,
    p.Unit_Price
FROM 
    Suppliers s
LEFT JOIN 
    Products p
    ON s.Supplier_ID = p.Supplier_ID

UNION

SELECT 
    s.Supplier_ID,
    s.Supplier_Name,
    p.Product_ID,
    p.Product_Name,
    p.Unit_Price
FROM 
    Suppliers s
RIGHT JOIN 
    Products p
    ON s.Supplier_ID = p.Supplier_ID
ORDER BY 
    Supplier_Name ASC,
    Product_Name ASC;


-- Query 2.5: Categories with more than 10 products in stock (HAVING clause)
SELECT 
    c.Category_ID,
    c.Category_Name,
    COUNT(p.Product_ID) AS Product_Count,
    SUM(p.QOH) AS Total_Stock
FROM 
    Categories c
INNER JOIN 
    Products p
    ON c.Category_ID = p.Category_ID
GROUP BY 
    c.Category_ID,
    c.Category_Name
HAVING 
    SUM(p.QOH) > 10
ORDER BY 
    Total_Stock DESC,
    Category_Name ASC;


-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Total product count
SELECT COUNT(*) AS Total_Products FROM Products;

-- Total categories
SELECT COUNT(*) AS Total_Categories FROM Categories;

-- Total suppliers
SELECT COUNT(*) AS Total_Suppliers FROM Suppliers;

-- Total orders
SELECT COUNT(*) AS Total_Orders FROM Orders;

-- Total order details
SELECT COUNT(*) AS Total_Order_Details FROM Order_Details;

-- Check for out-of-stock
SELECT COUNT(*) AS Out_Of_Stock_Count FROM Products WHERE QOH = 0;
