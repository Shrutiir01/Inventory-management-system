# Inventory-management-system
Inventory Management System using SQL & PL/SQL
1. Products Management
•	Tracks product name, category, price, and available stock.
•	Supports multiple product categories (e.g., Electronics, Accessories, etc.)
2. Sales Processing
•	Records product sales.
•	Automatically updates product stock when a sale is made.
3. Stock Monitoring
•	A trigger checks if stock drops below a set threshold (e.g., 10 units).
•	If stock is low, a record is inserted into the ReorderLog table.
4. Reporting and Queries
•	Retrieve current stock level using a PL/SQL function.
•	View sales history and reorder alerts.
5. Tools/Technologies
•	SQL: DDL, DML, joins, sequences, subqueries
•	PL/SQL: Procedures, triggers, functions, exception handling
•	Environment: Oracle PLSQL Developer.
