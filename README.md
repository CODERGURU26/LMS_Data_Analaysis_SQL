# 📚 Library Management System - SQL Project

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-Complete-success)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive Library Management System built using PostgreSQL to manage books, members, employees, branches, and transactions. This project demonstrates advanced SQL concepts including stored procedures, CTAS, complex joins, and data analysis.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Database Schema](#-database-schema)
- [Features](#-features)
- [Installation & Setup](#-installation--setup)
- [SQL Tasks & Queries](#-sql-tasks--queries)
- [Advanced Features](#-advanced-features)
- [Technologies Used](#-technologies-used)
- [SQL Concepts Demonstrated](#-sql-concepts-demonstrated)
- [Business Insights](#-business-insights)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

---

## 🎯 Project Overview

This Library Management System is designed to handle all aspects of library operations including:

- **Book Management**: Track book inventory, availability, and rental pricing
- **Member Management**: Manage member registrations and borrowing history
- **Transaction Processing**: Handle book issues and returns
- **Employee Management**: Track staff and their branch assignments
- **Branch Operations**: Monitor branch performance and metrics
- **Advanced Analytics**: Generate reports and insights from library data

The system includes 19 comprehensive tasks covering CRUD operations, data analysis, stored procedures, and performance reporting.

---

## 🗄️ Database Schema

The database consists of 6 interconnected tables:

### 1. **branch**
Stores library branch information
```sql
- branch_id (VARCHAR(15), PK)
- manager_id (VARCHAR(15))
- branch_address (VARCHAR(55))
- contact_no (VARCHAR(15))
```

### 2. **employees**
Contains employee details and branch assignments
```sql
- emp_id (VARCHAR(15), PK)
- emp_name (VARCHAR(25))
- position (VARCHAR(15))
- salary (INT)
- branch_id (VARCHAR(15), FK)
```

### 3. **books**
Manages book inventory and details
```sql
- isbn (VARCHAR(25), PK)
- book_title (VARCHAR(75))
- category (VARCHAR(35))
- rental_price (FLOAT)
- status (VARCHAR(10))
- author (VARCHAR(30))
- publisher (VARCHAR(55))
```

### 4. **members**
Tracks library member information
```sql
- member_id (VARCHAR(15), PK)
- member_name (VARCHAR(55))
- member_address (VARCHAR(75))
- reg_date (DATE)
```

### 5. **issued_status**
Records book issue transactions
```sql
- issued_id (VARCHAR(15), PK)
- issued_member_id (VARCHAR(15), FK)
- issued_book_name (VARCHAR(75))
- issued_date (DATE)
- issued_book_isbn (VARCHAR(25), FK)
- issued_emp_id (VARCHAR(15), FK)
```

### 6. **return_status**
Tracks book returns and quality assessment
```sql
- return_id (VARCHAR(15), PK)
- issued_id (VARCHAR(15), FK)
- return_book_name (VARCHAR(75))
- return_date (DATE)
- return_book_isbn (VARCHAR(25))
- book_quality (VARCHAR(15))
```

### Entity Relationship Diagram
```
branch ----< employees
              |
              |
members >---- issued_status ----< books
                    |
                    |
              return_status
```

---

## ✨ Features

### Core Functionality
- ✅ Complete CRUD operations for all entities
- ✅ Book issue and return workflow
- ✅ Member registration and tracking
- ✅ Employee and branch management
- ✅ Automated status updates using stored procedures

### Analytics & Reporting
- 📊 Branch performance reports
- 📈 Revenue tracking by category
- 👥 Active member identification
- 📚 Book popularity analysis
- ⚠️ Overdue book tracking
- 🏆 Top employee performance metrics

### Advanced Features
- 🔄 Stored procedures for automated workflows
- 📋 CTAS (Create Table As Select) for summary tables
- 🔍 Complex joins across multiple tables
- 📅 Date-based analysis and filtering
- 🎯 Risk assessment for damaged books

---

## 🚀 Installation & Setup

### Prerequisites
- PostgreSQL 12+
- pgAdmin or any PostgreSQL client
- Basic understanding of SQL and database concepts

### Step-by-Step Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/CODERGURU26/library-management-system.git
   cd library-management-system
   ```

2. **Create Database**
   ```sql
   CREATE DATABASE library_db;
   ```

3. **Execute Table Creation Script**
   ```bash
   psql -U your_username -d library_db -f LMS_TABLE.sql
   ```

4. **Load Sample Data** (if available)
   ```sql
   -- Import your CSV files or run INSERT statements
   ```

5. **Run Query Script**
   ```bash
   psql -U your_username -d library_db -f LMS_QUERY.sql
   ```

---

## 📝 SQL Tasks & Queries

### Basic CRUD Operations

**Task 1: Create a New Book Record**
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

**Task 2: Update Member Address**
```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete Issued Status Record**
```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve Books Issued by Employee**
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Task 5: Members with Multiple Books**
```sql
SELECT 
    issued_member_id,
    COUNT(issued_id) AS total_book_issued
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1;
```

### Data Analysis Tasks

**Task 7: Books by Category**
```sql
SELECT * FROM books 
WHERE category = 'Classic';
```

**Task 8: Rental Income by Category**
```sql
SELECT 
    category,
    SUM(rental_price) AS total_rental_income
FROM books
GROUP BY category;
```

**Task 9: Recent Member Registrations**
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Task 10: Employees with Branch Manager Details**
```sql
SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees AS e1
JOIN branch AS b ON b.branch_id = e1.branch_id
JOIN employees AS e2 ON b.manager_id = e2.emp_id;
```

### Advanced Analytics

**Task 13: Identify Overdue Books**
```sql
SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books as b ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rst ON rst.issued_id = ist.issued_id
WHERE 
    rst.return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY member_id;
```

**Task 15: Branch Performance Report**
```sql
CREATE TABLE branch_performance_report AS
SELECT 
    b.branch_id,
    COUNT(ist.issued_id) AS number_of_books_issued,
    COUNT(rst.return_id) AS number_of_books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status as ist
JOIN employees as e ON e.emp_id = ist.issued_emp_id
JOIN branch as b ON e.branch_id = b.branch_id
LEFT JOIN return_status as rst ON rst.issued_id = ist.issued_id
JOIN books as bk ON bk.isbn = ist.issued_book_isbn
GROUP BY b.branch_id
ORDER BY b.branch_id;
```

**Task 17: Top 3 Employees by Book Issues**
```sql
SELECT 
    e.emp_name as employee_name,
    COUNT(ist.issued_id) AS number_of_books_processed,
    b.branch_address AS branch
FROM issued_status as ist
JOIN employees as e ON e.emp_id = ist.issued_emp_id
JOIN branch as b ON b.branch_id = e.branch_id
GROUP BY e.emp_name, b.branch_address
ORDER BY number_of_books_processed DESC
LIMIT 3;
```

---

## 🔧 Advanced Features

### Stored Procedure 1: Book Return Processing

**Task 14: Automated Book Return & Status Update**
```sql
CREATE OR REPLACE PROCEDURE book_records(p_return_id VARCHAR(15), p_issued_id VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(75);
BEGIN 
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank You for returning the book: %', v_book_name;
END;
$$
```

**Usage:**
```sql
CALL book_records('RS125', 'IS133');
```

### Stored Procedure 2: Book Issuance with Availability Check

**Task 19: Smart Book Issuance System**
```sql
CREATE OR REPLACE PROCEDURE issued_book_status(
    p_issued_id VARCHAR(15), 
    p_issued_member_id VARCHAR(15),
    p_issued_book_isbn VARCHAR(25), 
    p_issued_emp_id VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(15);
BEGIN
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn: %', p_issued_book_isbn;
    ELSE
        RAISE NOTICE 'Sorry, book isbn: % is currently unavailable', p_issued_book_isbn;
    END IF;
END;
$$
```

### CTAS (Create Table As Select) Examples

**Task 6: Book Issue Count Summary**
```sql
CREATE TABLE book_cnt AS
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS no_issued
FROM books as b
JOIN issued_status as ist ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```

**Task 16: Active Members Table**
```sql
CREATE TABLE active_members AS
SELECT * FROM members 
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '1.8 Year'
);
```

---

## 🛠️ Technologies Used

- **Database**: PostgreSQL 12+
- **Language**: SQL, PL/pgSQL
- **Concepts**: 
  - Database Design & Normalization
  - Foreign Key Constraints
  - Stored Procedures
  - Triggers & Functions
  - Complex Joins
  - Aggregate Functions
  - Window Functions
  - CTEs (Common Table Expressions)

---

## 📚 SQL Concepts Demonstrated

### Database Design
- ✅ Normalized table structure (3NF)
- ✅ Primary and Foreign Key relationships
- ✅ Referential integrity constraints

### Data Manipulation
- ✅ INSERT, UPDATE, DELETE operations
- ✅ Complex SELECT queries with multiple joins
- ✅ Subqueries and nested queries
- ✅ CTAS for table generation

### Advanced SQL
- ✅ Stored Procedures with parameters
- ✅ PL/pgSQL programming
- ✅ Exception handling with RAISE NOTICE
- ✅ Variables and control structures (IF-ELSE)
- ✅ Date arithmetic and intervals
- ✅ Aggregate functions (COUNT, SUM, AVG)
- ✅ GROUP BY and HAVING clauses
- ✅ LEFT JOIN for optional relationships

### Analytics
- ✅ Performance metrics calculation
- ✅ Trend analysis over time periods
- ✅ Member activity tracking
- ✅ Revenue analysis by category
- ✅ Risk assessment queries

---

## 💡 Business Insights

This Library Management System provides valuable insights for:

### Operational Efficiency
- Track overdue books and send reminders
- Monitor employee performance
- Identify peak borrowing periods

### Financial Analysis
- Calculate revenue by category
- Track rental income by branch
- Identify high-value book categories

### Member Management
- Identify active vs inactive members
- Track member borrowing patterns
- Flag members with damaged book history

### Inventory Management
- Monitor book availability status
- Track popular books for restocking
- Identify underperforming categories

### Branch Performance
- Compare branch performance metrics
- Optimize staff allocation
- Track returns vs issues ratio

---

## 📂 Project Structure

```
library-management-system/
│
├── LMS_TABLE.sql                 # Database schema and table creation
├── LMS_QUERY.sql                 # All queries and tasks
├── README.md                     # Project documentation
├── data/                         # Sample data files (optional)
│   ├── books.csv
│   ├── members.csv
│   └── ...
└── reports/                      # Generated reports (optional)
    ├── branch_performance.csv
    └── overdue_books.csv
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution
- Add more complex analytical queries
- Implement additional stored procedures
- Create views for common queries
- Add data visualization scripts
- Improve documentation

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Gururaj Krishna Sharma**

- GitHub: [@CODERGURU26](https://github.com/CODERGURU26)
- Project Link: [Library Management System](https://github.com/CODERGURU26/library-management-system)

---

## 🌟 Acknowledgments

- Inspired by real-world library management challenges
- Built to demonstrate advanced SQL and database design skills
- Thanks to the PostgreSQL community for excellent documentation

---

## 📞 Support

If you have any questions or run into issues:
- Open an issue in the GitHub repository
- Check the SQL comments in the code files
- Review the PostgreSQL documentation

---

⭐ **If you found this project helpful, please consider giving it a star!** ⭐

---

**Happy Querying! 📚✨**
