--1.Table Creation

-----a)Products Management
----Tracks product name, category, price, and available stock.
CREATE TABLE Products(ProductID   NUMBER PRIMARY KEY
                     ,ProductName VARCHAR2(100)
                     ,Category    VARCHAR2(50)
                     ,Price       NUMBER(10,2)
                     ,Stock       NUMBER
                     );
                     
----b)Sales Processing

CREATE TABLE Sales(SaleID    NUMBER PRIMARY KEY
                  ,ProductID NUMBER
                  ,Quantity  NUMBER
                  ,SaleDate  DATE
                  ,CONSTRAINTS sales_ProductID_fk FOREIGN KEY (ProductID)
                                                  REFERENCES Products(ProductID)
                  );


---3. Stock Monitoring
----to maintain the stock record

CREATE TABLE ReorderLog(LogID NUMBER PRIMARY KEY
                       ,ProductID NUMBER
                       ,LogDate DATE
                       ,Message VARCHAR2(200)
                       ,CONSTRAINTS ReorderLog_ProductID_fk FOREIGN KEY (ProductID)
                                                       REFERENCES Products(ProductID)
                       );
                       
--2.Insert Operation
----To Add New Products
          
INSERT INTO Products VALUES (1, 'Laptop', 'Electronics', 75000, 15);
INSERT INTO Products VALUES (2, 'Mobile', 'Electronics', 25000, 30);
INSERT INTO Products VALUES (3, 'Keyboard', 'Accessories', 1500, 50);
INSERT INTO Products VALUES (4, 'Mouse', 'Accessories', 700, 75);
INSERT INTO Products VALUES (5, 'CPU', 'Accessories', 1000, 50);
INSERT INTO Products VALUES (6, 'Computer', 'Electronics', 55000, 25);

--3.Data Retrieval
----To fetch the data from Products
SELECT * FROM products

--4.Creating Procedure
----Records product sales.
----Automatically updates product stock when a sale is made

CREATE OR REPLACE PROCEDURE Add_Sale
(p_ProductID IN NUMBER
,p_Quantity  IN NUMBER
)
AS
  v_Stock   NUMBER(10);
  v_salesid NUMBER(10);
  v_count   NUMBER(10);
BEGIN
  SELECT Stock
  INTO   v_Stock
  FROM   Products
  WHERE  ProductID = p_ProductID
  ;

  IF v_Stock < p_Quantity
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock available.');
  ELSE
      SELECT COUNT(*)
      INTO   v_count
      FROM   Sales
      ;
      IF v_count IS NULL
      THEN
        SELECT MAX(SaleID)+1
        INTO   v_salesid
        FROM   Sales
        ;
        IF v_salesid IS NULL
        THEN
          v_salesid := 1;
        END IF;

        INSERT INTO Sales(SaleID
                         ,ProductID
                         ,Quantity
                         ,SaleDate
                         )
        VALUES           (v_salesid
                         ,p_ProductID
                         ,p_Quantity
                         ,SYSDATE
                         );
    ELSE
      UPDATE Products
      SET    Stock = Stock - p_Quantity
      WHERE  ProductID = p_ProductID
      ;
    END IF;
  END IF;
END;

--5.Creating Sequence

CREATE SEQUENCE Sales_SEQ
START WITH 1
INCREMENT BY 1
;

CREATE SEQUENCE ReorderLog_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE
;

--6.Creating Trigger
----A trigger checks if stock drops below a set threshold (e.g., 10 units).
----If stock is low, a record is inserted into the ReorderLog table.

CREATE OR REPLACE TRIGGER aw_reordercheck_trg
AFTER UPDATE ON Products
FOR EACH ROW
DECLARE
  v_msg   VARCHAR2(50);
  exc_val EXCEPTION;
BEGIN
  IF (NEW.Stock < 10)
  THEN
    v_msg := 'Stock Update needed';
    RAISE exc_val;
    
    INSERT INTO ReorderLog(LogID
                          ,ProductID
                          ,LogDate
                          ,Message
                          )
    VALUES                (ReorderLog_SEQ.NEXTVAL
                          ,:NEW.ProductID
                          ,SYSDATE
                          ,'Stock below threshold. Reorder needed.'
                          );
  END IF;
EXCEPTION
  WHEN exc_val
  THEN
    RAISE_APPLICATION_ERROR(-20900,v_msg);
END;


--4. Reporting and Queries
----Retrieve current stock level using a PL/SQL function.
----View sales history and reorder alerts.

CREATE OR REPLACE FUNCTION Get_Stock
(p_ProductID NUMBER)
RETURN NUMBER
AS
  v_Stock NUMBER;
BEGIN
    SELECT Stock
    INTO   v_Stock
    FROM   Products
    WHERE  ProductID = p_ProductID
    ;
    RETURN v_Stock;
END;

SELECT Get_Stock(ProductID)
FROM   PRODUCTS
;
