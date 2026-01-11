SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;

--Project Tasks
--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn , book_title , category , rental_price , status , author , publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

--Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT 
	issued_member_id ,
	COUNT(issued_id) AS total_book_issued
FROM 
	issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1;

--CTAS (Create Table As Select)
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**o
CREATE TABLE book_cnt
AS
SELECT 
	b.isbn ,
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
FROM books as b
JOIN 
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1 , 2;

SELECT * FROM book_cnt;

--Data Analysis & Findings
--Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books 
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:
SELECT 
	SUM(rental_price) AS total_rental_income , 
	category,
FROM
	books
GROUP BY category;

--Task 9 List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'

INSERT INTO members(member_id , member_name , member_address , reg_date)
VALUES
	('C209' , 'Guru' , '302 MG Road' , '2025-12-22'),
	('C210' , 'Pooja' , '20 Manikripa' , '2026-01-05');

--Task 10. List Employees with Their Branch Manager's Name and their branch details:
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name as manager
FROM employees AS e1
JOIN 
branch AS b
ON b.branch_id = e1.branch_id
JOIN 
employees AS e2 
ON b.manager_id = e2.emp_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

SELECT * FROM expensive_books;

--Task 12: Retrieve the List of Books Not Yet Returned
SELECT
	ist.issued_id,
 	ist.issued_book_name
FROM issued_status as ist
LEFT JOIN 
return_status as rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL
/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
SELECT 
	m.member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS overdue_days
FROM 
	issued_status AS ist
JOIN members AS m
ON m.member_id = ist.issued_member_id
JOIN books as b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rst
ON rst.issued_id = ist.issued_id
WHERE 
	rst.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY member_id;

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/
CREATE OR REPLACE PROCEDURE book_records(p_return_id VARCHAR(15), p_issued_id VARCHAR(15) )
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(75);
BEGIN 

	INSERT INTO return_status(return_id , issued_id , return_date)
	VALUES
	(p_return_id , p_issued_id , CURRENT_DATE);

	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank You for returning the book: %', v_book_name;
END;
$$

CALL book_records('RS125' , 'IS133');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, 
the number of books returned, 
and the total revenue generated from book rentals.
*/
CREATE TABLE branch_performance_report
AS
SELECT 
	b.branch_id,
	COUNT(ist.issued_id) AS number_of_books_issued,
	COUNT(rst.return_id) AS number_of_books_returned,
	SUM(bk.rental_price) AS total_revenue
	FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN 
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN 
return_status as rst
ON rst.issued_id = ist.issued_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
GROUP BY 1
ORDER BY 1;

SELECT * FROM  branch_performance_report;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) 
statement to create a new table active_members containing members who have issued at least one book in the last 1 YEAR 8 MONTHS.
*/
CREATE TABLE active_members
AS
SELECT * 
FROM members 
WHERE member_id IN(
	SELECT DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '1.8 Year'
);

SELECT * FROM active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
select 
	e.emp_name as employee_name,
	COUNT(ist.issued_id) AS number_of_books_processed,
	b.branch_address AS branch
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN 
branch as b
ON b.branch_id = e.branch_id
GROUP BY 1 , 3
ORDER BY 2 DESC
LIMIT 3;

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/
SELECT 
    m.member_name,
	bk.book_title,
    COUNT(rst.issued_id) AS damage_count
FROM issued_status AS ist
JOIN members AS m 
    ON m.member_id = ist.issued_member_id
JOIN 
books AS bk
ON bk.isbn = ist.issued_book_isbn
JOIN return_status AS rst 
    ON rst.issued_id = ist.issued_id
WHERE rst.book_quality = 'Damaged' 
GROUP BY  m.member_name , bk.book_title
HAVING COUNT(rst.issued_id) > 2;

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available.
*/
CREATE OR REPLACE PROCEDURE issued_book_status(p_issued_id VARCHAR(15), p_issued_member_id VARCHAR(15) ,
p_issued_book_isbn VARCHAR(25) , p_issued_emp_id VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_status VARCHAR(15);
	
BEGIN
	SELECT 
	status
	INTO
	v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id , issued_member_id , issued_date , issued_book_isbn , issued_emp_id)
		VALUES
		(p_issued_id , p_issued_member_id , CURRENT_DATE , p_issued_book_isbn ,p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Books records added successfully for boook isbn: %', p_issued_book_isbn;
	ELSE
		RAISE NOTICE 'Sorry to inform you that book isbn : % is currently unavailable' , p_issued_book_isbn;
	END IF;
END
$$

SELECT * FROM books
--"978-0-09-957807-9" -- yes
--"978-0-375-41398-8" -- no

SELECT * FROM issued_status
CALL issued_book_status('IS155' , 'C129' , '978-0-375-41398-8"' , 'E125')

SHOW data_directory;
