-- ============================================================================
-- ADVANCED SQL ASSIGNMENT - EXECUTABLE CODE
-- Electronics Retail Company
-- Student: Christopher Garcia
-- Date: February 2, 2026
-- ============================================================================

-- ============================================================================
-- PART 1: ADVANCED SQL FUNCTIONS
-- ============================================================================

-- ============================================================================
-- QUERY 1.1: Total Sales Revenue by Product Category
-- ============================================================================

SELECT 
    c.Category_ID,
    c.Category_Name,
    COUNT(DISTINCT od.Order_ID) AS Order_Count,
    SUM(od.Quantity) AS Units_Sold,
    ROUND(SUM(od.Line_Total), 2) AS Total_Revenue
FROM 
    Categories c
INNER JOIN 
    Products p ON c.Category_ID = p.Category_ID
INNER JOIN 
    Order_Details od ON p.Product_ID = od.Product_ID
GROUP BY
    c.Category_ID,
    c.Category_Name
ORDER BY 
    Total_Revenue DESC,
    Category_Name ASC;


-- ============================================================================
-- QUERY 1.2: Formatted Product and Supplier Directory
-- ============================================================================

SELECT 
    p.Product_ID,
    p.Product_Name AS Original_Name,
    CONCAT('$', FORMAT(p.Unit_Price, 2)) AS Formatted_Price,
    UPPER(s.Supplier_Name) AS Supplier_Uppercase,
    CONCAT(s.Supplier_Name, ' | Phone: ', s.Phone) AS Contact_Info,
    LOWER(s.Email) AS Supplier_Email_Lowercase,
    CONCAT('Stock: ', p.QOH, ' units') AS Inventory_Display
FROM 
    Products p
INNER JOIN 
    Suppliers s ON p.Supplier_ID = s.Supplier_ID
ORDER BY 
    p.Product_Name ASC;


-- ============================================================================
-- QUERY 1.3: Orders Grouped by Purchase Month
-- ============================================================================

SELECT 
    YEAR(o.Order_Date) AS Order_Year,
    MONTH(o.Order_Date) AS Order_Month_Number,
    MONTHNAME(o.Order_Date) AS Order_Month_Name,
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS Year_Month,
    COUNT(o.Order_ID) AS Total_Orders,
    ROUND(SUM(o.Total_Amount), 2) AS Monthly_Revenue
FROM 
    Orders o
GROUP BY 
    YEAR(o.Order_Date),
    MONTH(o.Order_Date),
    MONTHNAME(o.Order_Date),
    DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY 
    Order_Year DESC,
    Order_Month_Number DESC;


-- ============================================================================
-- QUERY 1.4: Calculate 20% Discounted Price for Most Expensive Product
-- ============================================================================

SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Unit_Price AS Original_Price,
    ROUND(p.Unit_Price * 0.20, 2) AS Discount_Amount,
    ROUND(p.Unit_Price * 0.80, 2) AS Discounted_Price,
    ROUND((p.Unit_Price - (p.Unit_Price * 0.80)), 2) AS Savings,
    CONCAT('Save 20%!') AS Promotional_Message
FROM 
    Products p
WHERE 
    p.Unit_Price = (SELECT MAX(Unit_Price) FROM Products)
ORDER BY 
    p.Product_Name ASC;


-- ============================================================================
-- PART 2: SCHEMA OBJECTS AND BUSINESS LOGIC
-- ============================================================================

-- ============================================================================
-- OBJECT 2.1: View for Top 5 Best-Selling Products
-- ============================================================================

DROP VIEW IF EXISTS Top_Selling_Products;

CREATE VIEW Top_Selling_Products AS
SELECT 
    p.Product_ID,
    p.Product_Name,
    c.Category_Name,
    SUM(od.Quantity) AS Total_Units_Sold,
    COUNT(DISTINCT od.Order_ID) AS Times_Ordered,
    ROUND(SUM(od.Line_Total), 2) AS Total_Revenue
FROM 
    Products p
INNER JOIN 
    Order_Details od ON p.Product_ID = od.Product_ID
INNER JOIN 
    Categories c ON p.Category_ID = c.Category_ID
GROUP BY 
    p.Product_ID,
    p.Product_Name,
    c.Category_Name
ORDER BY 
    Total_Units_Sold DESC
LIMIT 5;

-- Query the view
SELECT * FROM Top_Selling_Products;


-- ============================================================================
-- OBJECT 2.2: Stored Procedure for Product Sales Analysis
-- ============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS Get_Product_Sales_Info;

CREATE PROCEDURE Get_Product_Sales_Info(
    IN input_product_id INT
)
BEGIN
    DECLARE total_quantity_sold INT DEFAULT 0;
    DECLARE total_revenue DECIMAL(10,2) DEFAULT 0.00;
    DECLARE product_exists INT DEFAULT 0;
    
    -- Check if product exists
    SELECT COUNT(*) INTO product_exists
    FROM Products
    WHERE Product_ID = input_product_id;
    
    IF product_exists = 0 THEN
        SELECT 
            'ERROR' AS Status,
            CONCAT('Product ID ', input_product_id, ' not found') AS Message;
    ELSE
        -- Calculate sales statistics
        SELECT 
            COALESCE(SUM(od.Quantity), 0),
            COALESCE(SUM(od.Line_Total), 0)
        INTO 
            total_quantity_sold,
            total_revenue
        FROM 
            Order_Details od
        WHERE 
            od.Product_ID = input_product_id;
        
        -- Return comprehensive result set
        SELECT 
            'SUCCESS' AS Status,
            p.Product_ID,
            p.Product_Name,
            c.Category_Name,
            p.Unit_Price AS Current_Price,
            total_quantity_sold AS Total_Quantity_Sold,
            total_revenue AS Total_Revenue_Generated,
            ROUND(total_revenue / NULLIF(total_quantity_sold, 0), 2) AS Avg_Sale_Price
        FROM 
            Products p
        INNER JOIN 
            Categories c ON p.Category_ID = c.Category_ID
        WHERE 
            p.Product_ID = input_product_id;
    END IF;
END //

DELIMITER ;

-- Execute the stored procedure
CALL Get_Product_Sales_Info(1);
CALL Get_Product_Sales_Info(6);
CALL Get_Product_Sales_Info(9999);  -- Test error handling


-- ============================================================================
-- OBJECT 2.3: Trigger for Inventory Audit Logging
-- ============================================================================

-- Create audit table
DROP TABLE IF EXISTS Inventory_Audit;

CREATE TABLE Inventory_Audit (
    Audit_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_ID INT NOT NULL,
    Old_QOH INT,
    New_QOH INT,
    Change_Amount INT,
    Change_Type VARCHAR(20),
    Changed_By VARCHAR(100) DEFAULT USER(),
    Change_Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_audit (Product_ID),
    INDEX idx_timestamp (Change_Timestamp)
);

-- Create trigger
DROP TRIGGER IF EXISTS After_Product_QOH_Update;

DELIMITER //

CREATE TRIGGER After_Product_QOH_Update
    AFTER UPDATE ON Products
    FOR EACH ROW
BEGIN
    IF OLD.QOH != NEW.QOH THEN
        INSERT INTO Inventory_Audit (
            Product_ID,
            Old_QOH,
            New_QOH,
            Change_Amount,
            Change_Type
        ) VALUES (
            NEW.Product_ID,
            OLD.QOH,
            NEW.QOH,
            NEW.QOH - OLD.QOH,
            CASE 
                WHEN NEW.QOH > OLD.QOH THEN 'INCREASE'
                WHEN NEW.QOH < OLD.QOH THEN 'DECREASE'
                ELSE 'NO_CHANGE'
            END
        );
    END IF;
END //

DELIMITER ;

-- Add constraint to prevent negative QOH
ALTER TABLE Products
ADD CONSTRAINT chk_qoh_non_negative CHECK (QOH >= 0);

-- Test the trigger
UPDATE Products SET QOH = QOH + 10 WHERE Product_ID = 1;
SELECT * FROM Inventory_Audit WHERE Product_ID = 1 ORDER BY Audit_ID DESC LIMIT 1;


-- ============================================================================
-- OBJECT 2.4: Transaction Block for Order Processing
-- ============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS Process_Order_Transaction;

CREATE PROCEDURE Process_Order_Transaction(
    IN customer_id_param INT,
    IN product_id_param INT,
    IN quantity_param INT,
    OUT result_message VARCHAR(200)
)
BEGIN
    DECLARE current_stock INT;
    DECLARE product_price DECIMAL(10,2);
    DECLARE order_total DECIMAL(10,2);
    DECLARE new_order_id INT;
    
    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET result_message = 'ERROR: Transaction rolled back';
    END;
    
    START TRANSACTION;
    
    -- Check product availability with row lock
    SELECT QOH, Unit_Price 
    INTO current_stock, product_price
    FROM Products 
    WHERE Product_ID = product_id_param
    FOR UPDATE;
    
    IF current_stock < quantity_param THEN
        ROLLBACK;
        SET result_message = CONCAT(
            'ERROR: Insufficient stock. Available: ',
            current_stock,
            ', Requested: ',
            quantity_param
        );
    ELSE
        SET order_total = quantity_param * product_price;
        
        -- Create order record
        INSERT INTO Orders (
            Customer_ID,
            Order_Date,
            Order_Time,
            Total_Amount,
            Status
        ) VALUES (
            customer_id_param,
            CURDATE(),
            CURTIME(),
            order_total,
            'Processing'
        );
        
        SET new_order_id = LAST_INSERT_ID();
        
        -- Create order detail
        INSERT INTO Order_Details (
            Order_ID,
            Product_ID,
            Quantity,
            Unit_Price,
            Line_Total
        ) VALUES (
            new_order_id,
            product_id_param,
            quantity_param,
            product_price,
            order_total
        );
        
        -- Update inventory
        UPDATE Products
        SET QOH = QOH - quantity_param
        WHERE Product_ID = product_id_param;
        
        COMMIT;
        
        SET result_message = CONCAT(
            'SUCCESS: Order ',
            new_order_id,
            ' created. Inventory updated.'
        );
    END IF;
END //

DELIMITER ;

-- Test the transaction procedure
CALL Process_Order_Transaction(1, 6, 2, @result);
SELECT @result AS Transaction_Result;

-- Test with insufficient stock
CALL Process_Order_Transaction(1, 1, 10000, @result);
SELECT @result AS Transaction_Result;


-- ============================================================================
-- OBJECT 2.5: Performance Index on Order_Date
-- ============================================================================

CREATE INDEX idx_order_date ON Orders(Order_Date);

-- Verify index creation
SHOW INDEX FROM Orders WHERE Key_name = 'idx_order_date';

-- Test query performance with EXPLAIN
EXPLAIN SELECT * FROM Orders 
WHERE Order_Date BETWEEN '2025-01-01' AND '2025-01-31';


-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify all objects were created
SELECT 'Checking View' AS Check_Type;
SHOW CREATE VIEW Top_Selling_Products;

SELECT 'Checking Stored Procedures' AS Check_Type;
SHOW PROCEDURE STATUS WHERE Name LIKE '%Product%' OR Name LIKE '%Order%';

SELECT 'Checking Triggers' AS Check_Type;
SHOW TRIGGERS LIKE 'Products';

SELECT 'Checking Audit Table' AS Check_Type;
SELECT COUNT(*) AS Audit_Entries FROM Inventory_Audit;

SELECT 'Checking Indexes' AS Check_Type;
SHOW INDEX FROM Orders;

SELECT 'All objects created successfully!' AS Status;
