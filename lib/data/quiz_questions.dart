// Quiz questions for different levels and modules
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

// Beginner Level Questions
final List<QuizQuestion> beginnerSelectQuestions = [
  QuizQuestion(
    question: 'Which SQL statement is used to extract data from a database?',
    options: ['SELECT', 'EXTRACT', 'GET', 'QUERY'],
    correctAnswerIndex: 0,
    explanation: 'The SELECT statement is used to retrieve data from one or more tables in a database.',
  ),
  QuizQuestion(
    question: 'How do you select all columns from a table named "users"?',
    options: [
      'SELECT * FROM users',
      'SELECT [all] FROM users',
      'SELECT users',
      'ALL * FROM users'
    ],
    correctAnswerIndex: 0,
    explanation: 'SELECT * FROM users retrieves all columns from the users table. The asterisk (*) is a wildcard that represents all columns.',
  ),
  QuizQuestion(
    question: 'Which clause is used to select only distinct (different) values?',
    options: ['DIFFERENT', 'UNIQUE', 'DISTINCT', 'SEPARATE'],
    correctAnswerIndex: 2,
    explanation: 'The DISTINCT keyword is used to return only different values in a result set.',
  ),
  QuizQuestion(
    question: 'What is the correct SQL syntax to select a column named "FirstName" from a table named "Persons"?',
    options: [
      'SELECT Persons.FirstName',
      'EXTRACT FirstName FROM Persons',
      'SELECT FirstName FROM Persons',
      'SELECT FirstName IN Persons'
    ],
    correctAnswerIndex: 2,
    explanation: 'The correct syntax is SELECT column_name FROM table_name',
  ),
  QuizQuestion(
    question: 'How would you select columns named "name" and "email" from a table called "customers"?',
    options: [
      'GET name, email FROM customers',
      'SELECT name, email FROM customers',
      'SELECT name AND email FROM customers',
      'RETRIEVE name, email FROM customers'
    ],
    correctAnswerIndex: 1,
    explanation: 'To select multiple specific columns, you list them separated by commas after the SELECT keyword.',
  ),
];

final List<QuizQuestion> beginnerWhereQuestions = [
  QuizQuestion(
    question: 'Which clause is used to filter records in SQL?',
    options: ['FILTER', 'WHERE', 'HAVING', 'SEARCH'],
    correctAnswerIndex: 1,
    explanation: 'The WHERE clause is used to filter records based on specified conditions.',
  ),
  QuizQuestion(
    question: 'What operator is used to test for equality in a WHERE clause?',
    options: ['EQUALS', '==', '=', 'EQ'],
    correctAnswerIndex: 2,
    explanation: 'The single equals sign (=) is used to test for equality in SQL WHERE clauses.',
  ),
  QuizQuestion(
    question: 'How do you select all users with age greater than 18?',
    options: [
      'SELECT * FROM users IF age > 18',
      'SELECT * FROM users WHERE age > 18',
      'SELECT users WHERE age > 18',
      'SELECT * FROM users HAVING age > 18'
    ],
    correctAnswerIndex: 1,
    explanation: 'The correct syntax uses the WHERE clause with the greater than (>) operator.',
  ),
  QuizQuestion(
    question: 'Which operator is used in a WHERE clause to match a pattern?',
    options: [
      'SIMILAR TO',
      'MATCHES',
      'LIKE',
      'CONTAINS'
    ],
    correctAnswerIndex: 2,
    explanation: 'The LIKE operator is used to search for a specified pattern in a column.',
  ),
  QuizQuestion(
    question: 'How would you select employees with a salary between 50000 and 70000?',
    options: [
      'SELECT * FROM employees WHERE salary >= 50000 AND salary <= 70000',
      'SELECT * FROM employees WHERE salary BETWEEN 50000 AND 70000',
      'SELECT * FROM employees HAVING salary BETWEEN 50000 AND 70000',
      'SELECT * FROM employees WHERE salary IN (50000-70000)'
    ],
    correctAnswerIndex: 1,
    explanation: 'The BETWEEN operator selects values within a given range (inclusive).',
  ),
];

final List<QuizQuestion> beginnerOrderByQuestions = [
  QuizQuestion(
    question: 'Which clause is used to sort the result set?',
    options: ['SORT BY', 'ORDER BY', 'ARRANGE BY', 'GROUP BY'],
    correctAnswerIndex: 1,
    explanation: 'The ORDER BY clause is used to sort the result set in ascending or descending order.',
  ),
  QuizQuestion(
    question: 'How do you sort results in descending order?',
    options: ['DESCENDING', 'DESC', 'DOWN', 'REVERSE'],
    correctAnswerIndex: 1,
    explanation: 'The DESC keyword is used to sort results in descending order.',
  ),
  QuizQuestion(
    question: 'What is the default sort order for ORDER BY if not specified?',
    options: [
      'Ascending (ASC)',
      'Descending (DESC)',
      'Random order',
      'No specific order'
    ],
    correctAnswerIndex: 0,
    explanation: "If you don't specify ASC or DESC, the default sort order is ascending (ASC).",
  ),
  QuizQuestion(
    question: 'How would you sort a result set by multiple columns?',
    options: [
      'SORT BY col1, col2',
      'ORDER col1, col2',
      'ORDER BY col1, col2',
      'ARRANGE BY col1 AND col2'
    ],
    correctAnswerIndex: 2,
    explanation: 'You can sort by multiple columns by listing them after ORDER BY separated by commas.',
  ),
  QuizQuestion(
    question: 'How would you sort customers by country in ascending order and then by name in descending order?',
    options: [
      'ORDER BY country ASC, name DESCENDING',
      'ORDER BY country ASCENDING AND name DESC',
      'ORDER BY country ASC, name DESC',
      'SORT BY country, name DESC'
    ],
    correctAnswerIndex: 2,
    explanation: 'You specify the sort direction (ASC or DESC) after each column name.',
  ),
];

// Intermediate Level Questions
final List<QuizQuestion> intermediateJoinQuestions = [
  QuizQuestion(
    question: 'Which JOIN returns only the matching rows from both tables?',
    options: ['LEFT JOIN', 'OUTER JOIN', 'RIGHT JOIN', 'INNER JOIN'],
    correctAnswerIndex: 3,
    explanation: 'INNER JOIN returns only the matching records from both tables.',
  ),
  QuizQuestion(
    question: 'What type of JOIN includes all records from the left table?',
    options: ['RIGHT JOIN', 'INNER JOIN', 'LEFT JOIN', 'FULL JOIN'],
    correctAnswerIndex: 2,
    explanation: 'LEFT JOIN returns all records from the left table and matching records from the right table.',
  ),
  QuizQuestion(
    question: 'What is the purpose of the ON clause in a JOIN statement?',
    options: [
      'To specify which columns to select',
      'To filter the joined data',
      'To specify the join condition',
      'To order the result set'
    ],
    correctAnswerIndex: 2,
    explanation: 'The ON clause specifies the condition on which the join should be based.',
  ),
  QuizQuestion(
    question: 'How would you join tables "orders" and "customers" on customer_id?',
    options: [
      'SELECT * FROM orders JOIN customers WHERE orders.customer_id = customers.id',
      'SELECT * FROM orders, customers ON orders.customer_id = customers.id',
      'SELECT * FROM orders INNER JOIN customers ON orders.customer_id = customers.id',
      'SELECT * FROM orders AND customers WHERE orders.customer_id = customers.id'
    ],
    correctAnswerIndex: 2,
    explanation: 'You use the INNER JOIN keyword with ON to specify the join condition.',
  ),
  QuizQuestion(
    question: 'What happens to non-matching rows in a RIGHT JOIN?',
    options: [
      'They are excluded from the result set',
      'They are included with NULL values for columns from the left table',
      'They produce an error',
      'They are included with default values'
    ],
    correctAnswerIndex: 1,
    explanation: 'In a RIGHT JOIN, all rows from the right table are included, with NULL values for columns from the left table when there is no match.',
  ),
];

final List<QuizQuestion> intermediateGroupByQuestions = [
  QuizQuestion(
    question: 'Which function returns the number of rows in a group?',
    options: ['SUM()', 'AVG()', 'COUNT()', 'MAX()'],
    correctAnswerIndex: 2,
    explanation: 'COUNT() function returns the number of rows in a group.',
  ),
  QuizQuestion(
    question: 'What clause is used to filter groups in a GROUP BY query?',
    options: ['WHERE', 'HAVING', 'FILTER', 'GROUP FILTER'],
    correctAnswerIndex: 1,
    explanation: 'The HAVING clause is used to filter groups based on aggregate functions.',
  ),
  QuizQuestion(
    question: 'What is the difference between WHERE and HAVING clauses?',
    options: [
      'WHERE filters rows before grouping, HAVING filters after grouping',
      'WHERE allows aggregate functions, HAVING does not',
      'WHERE is used with SELECT, HAVING is used with INSERT',
      'There is no difference, they are interchangeable'
    ],
    correctAnswerIndex: 0,
    explanation: 'WHERE filters rows before they are grouped, while HAVING filters groups after the GROUP BY is applied.',
  ),
  QuizQuestion(
    question: 'Which function calculates the average of values in a group?',
    options: [
      'AVERAGE()',
      'MEAN()',
      'SUM()/COUNT()',
      'AVG()'
    ],
    correctAnswerIndex: 3,
    explanation: 'The AVG() function returns the average value of a numeric column.',
  ),
  QuizQuestion(
    question: 'How would you count the number of orders for each customer?',
    options: [
      'SELECT customer_id, COUNT(*) FROM orders GROUP WITH customer_id',
      'SELECT customer_id, COUNT(*) FROM orders GROUP ON customer_id',
      'SELECT customer_id, COUNT(*) FROM orders GROUP BY customer_id',
      'SELECT customer_id, COUNT(*) FROM orders HAVING customer_id'
    ],
    correctAnswerIndex: 2,
    explanation: 'The GROUP BY clause groups rows that have the same values into summary rows.',
  ),
];

final List<QuizQuestion> intermediateSubqueryQuestions = [
  QuizQuestion(
    question: 'What is a subquery?',
    options: [
      'A table join',
      'A query within another query',
      'A main query',
      'A database view'
    ],
    correctAnswerIndex: 1,
    explanation: 'A subquery is a query nested inside another query.',
  ),
  QuizQuestion(
    question: 'Which operator can be used with a subquery that returns multiple rows?',
    options: [
      '= (equals)',
      'IN',
      '> (greater than)',
      '< (less than)'
    ],
    correctAnswerIndex: 1,
    explanation: 'The IN operator allows you to specify multiple values in a WHERE clause, which works with subqueries returning multiple rows.',
  ),
  QuizQuestion(
    question: 'What is a correlated subquery?',
    options: [
      'A subquery that executes once for the entire main query',
      'A subquery that references columns from the outer query',
      'A subquery that returns exactly one row',
      'A subquery that uses JOIN operations'
    ],
    correctAnswerIndex: 1,
    explanation: 'A correlated subquery is one that references columns from the outer query, causing it to be executed once for each row processed by the outer query.',
  ),
  QuizQuestion(
    question: 'Where can a subquery be used?',
    options: [
      'Only in the WHERE clause',
      'Only in the SELECT clause',
      'In SELECT, FROM, WHERE, or HAVING clauses',
      'Only in JOIN operations'
    ],
    correctAnswerIndex: 2,
    explanation: 'Subqueries can be used in various parts of a SQL statement, including SELECT, FROM, WHERE, and HAVING clauses.',
  ),
  QuizQuestion(
    question: 'How would you find employees who earn more than the average salary?',
    options: [
      'SELECT * FROM employees WHERE salary > AVG(salary)',
      'SELECT * FROM employees WHERE salary > (SELECT AVG(salary) FROM employees)',
      'SELECT * FROM employees HAVING salary > AVG(salary)',
      'SELECT * FROM employees WHERE salary > AVERAGE'
    ],
    correctAnswerIndex: 1,
    explanation: 'You need to use a subquery to calculate the average salary first, then compare each employee\'s salary to that average.',
  ),
];

// Advanced Level Questions
final List<QuizQuestion> advancedJoinQuestions = [
  QuizQuestion(
    question: 'Which JOIN type returns all records when there is a match in either left or right table?',
    options: ['LEFT JOIN', 'RIGHT JOIN', 'FULL OUTER JOIN', 'INNER JOIN'],
    correctAnswerIndex: 2,
    explanation: 'FULL OUTER JOIN returns all records when there is a match in either left or right table.',
  ),
  QuizQuestion(
    question: 'What is a self-join?',
    options: [
      'A join that combines a table with a copy of itself',
      'A join that only includes matching rows',
      'A join that doesn\'t require an ON clause',
      'A join that uses the same column for comparison'
    ],
    correctAnswerIndex: 0,
    explanation: 'A self-join is a regular join, but the table is joined with itself, often used to compare rows within the same table.',
  ),
  QuizQuestion(
    question: 'What is a CROSS JOIN?',
    options: [
      'Another term for INNER JOIN',
      'A join that produces the Cartesian product of two tables',
      'A join that works only with indexed columns',
      'A join that uses multiple conditions'
    ],
    correctAnswerIndex: 1,
    explanation: 'A CROSS JOIN returns the Cartesian product of both tables (all possible combinations of rows).',
  ),
  QuizQuestion(
    question: 'What is a NATURAL JOIN?',
    options: [
      'A join that doesn\'t need a condition',
      'A join that automatically joins tables on columns with the same name',
      'A join that works only with primary keys',
      'A join that combines columns with the same data type'
    ],
    correctAnswerIndex: 1,
    explanation: 'A NATURAL JOIN automatically joins tables based on columns with the same name in both tables.',
  ),
  QuizQuestion(
    question: 'In a complex query with multiple joins, what determines the join order?',
    options: [
      'The order in which joins appear in the query',
      'The database optimizer based on statistics and indexes',
      'The primary key relationships between tables',
      'The size of the tables being joined'
    ],
    correctAnswerIndex: 1,
    explanation: 'The database query optimizer determines the actual join order based on statistics, indexes, and other factors to optimize performance.',
  ),
];

final List<QuizQuestion> advancedWindowQuestions = [
  QuizQuestion(
    question: 'Which function is used to rank rows within a partition?',
    options: ['TOP()', 'RANK()', 'FIRST()', 'ORDER()'],
    correctAnswerIndex: 1,
    explanation: 'RANK() is a window function used to rank rows within a partition.',
  ),
  QuizQuestion(
    question: 'What clause is used to define the window in a window function?',
    options: [
      'GROUP BY',
      'WINDOW',
      'OVER',
      'PARTITION'
    ],
    correctAnswerIndex: 2,
    explanation: 'The OVER clause is used to define the window (partitioning and ordering) for window functions.',
  ),
  QuizQuestion(
    question: 'What is the difference between ROW_NUMBER() and RANK()?',
    options: [
      'ROW_NUMBER() assigns a unique sequential integer to rows, RANK() may assign the same number to ties',
      'ROW_NUMBER() works on numeric columns, RANK() works on text columns',
      'ROW_NUMBER() starts from 0, RANK() starts from 1',
      'There is no difference, they are identical functions'
    ],
    correctAnswerIndex: 0,
    explanation: 'ROW_NUMBER() gives a unique sequential number to each row, while RANK() assigns the same rank to tied values and skips the next ranks.',
  ),
  QuizQuestion(
    question: 'What does the PARTITION BY clause do in a window function?',
    options: [
      'It filters rows similarly to the WHERE clause',
      'It divides the result set into partitions to which the window function is applied separately',
      'It joins tables together based on a condition',
      'It groups rows for aggregate functions'
    ],
    correctAnswerIndex: 1,
    explanation: 'PARTITION BY divides the result set into partitions (groups) to which the window function is applied independently.',
  ),
  QuizQuestion(
    question: 'Which window function would you use to calculate a running total?',
    options: [
      'RANK()',
      'ROW_NUMBER()',
      'SUM() OVER (ORDER BY...)',
      'AVG() OVER (PARTITION BY...)'
    ],
    correctAnswerIndex: 2,
    explanation: 'SUM() with an OVER clause that includes ORDER BY creates a running total that accumulates values as it moves through the ordered rows.',
  ),
];

final List<QuizQuestion> advancedCTEQuestions = [
  QuizQuestion(
    question: 'What keyword is used to start a Common Table Expression (CTE)?',
    options: ['CTE', 'BEGIN', 'WITH', 'DECLARE'],
    correctAnswerIndex: 2,
    explanation: 'The WITH keyword is used to start a Common Table Expression (CTE).',
  ),
  QuizQuestion(
    question: 'What is a recursive CTE used for?',
    options: [
      'To perform aggregate functions efficiently',
      'To work with hierarchical data like organization charts or bill of materials',
      'To optimize complex joins',
      'To replace stored procedures'
    ],
    correctAnswerIndex: 1,
    explanation: 'Recursive CTEs are particularly useful for working with hierarchical or tree-structured data.',
  ),
  QuizQuestion(
    question: 'What are the advantages of using CTEs?',
    options: [
      'They execute faster than regular subqueries',
      'They can be referenced multiple times in the same query, improving readability',
      'They automatically create indexes',
      'They allow SQL procedures to be embedded in queries'
    ],
    correctAnswerIndex: 1,
    explanation: 'CTEs improve query readability and can be referenced multiple times in the same query, avoiding duplicate subqueries.',
  ),
  QuizQuestion(
    question: 'How many CTEs can you define in a single WITH clause?',
    options: [
      'Only one',
      'Maximum of three',
      'Multiple, separated by commas',
      'Depends on the database system'
    ],
    correctAnswerIndex: 2,
    explanation: 'You can define multiple CTEs in a single WITH clause, separating each by a comma.',
  ),
  QuizQuestion(
    question: 'What component is required in a recursive CTE?',
    options: [
      'UNION ALL between the anchor and recursive member',
      'A GROUP BY clause',
      'A HAVING clause',
      'An ORDER BY clause'
    ],
    correctAnswerIndex: 0,
    explanation: 'A recursive CTE requires a UNION ALL operator that combines the anchor member (initial query) with the recursive member (the part that references itself).',
  ),
];

// Expert Level Questions
final List<QuizQuestion> expertOptimizationQuestions = [
  QuizQuestion(
    question: 'Which of these helps improve query performance?',
    options: ['VIEW', 'TRIGGER', 'INDEX', 'PROCEDURE'],
    correctAnswerIndex: 2,
    explanation: 'An INDEX helps improve query performance by providing faster data retrieval.',
  ),
  QuizQuestion(
    question: 'What is query execution plan?',
    options: [
      'A documentation of SQL queries',
      'A step-by-step plan showing how the database will execute a query',
      'A list of all possible indexes',
      'A report of past query performance'
    ],
    correctAnswerIndex: 1,
    explanation: 'A query execution plan is a step-by-step plan that shows how the database engine will execute a query, including which indexes it will use and in what order operations will be performed.',
  ),
  QuizQuestion(
    question: 'What happens during a table scan?',
    options: [
      'The database checks for data integrity issues',
      'The database reads every row in a table to find matching data',
      'The database rebuilds indexes',
      'The database updates statistics'
    ],
    correctAnswerIndex: 1,
    explanation: 'During a table scan, the database reads every row in a table to find the requested data, which is usually inefficient for large tables.',
  ),
  QuizQuestion(
    question: 'Which of the following typically causes poor query performance?',
    options: [
      'Using primary keys in WHERE clauses',
      'Using indexes for filtering',
      'Using functions on indexed columns in WHERE clauses',
      'Using prepared statements'
    ],
    correctAnswerIndex: 2,
    explanation: 'Applying functions to indexed columns in WHERE clauses often prevents the database from using the index, resulting in slower performance.',
  ),
  QuizQuestion(
    question: 'What is a covering index?',
    options: [
      'An index that includes all columns referenced in a query',
      'An index on all columns in a table',
      'An index that automatically updates',
      'An index that combines multiple tables'
    ],
    correctAnswerIndex: 0,
    explanation: 'A covering index includes all columns referenced in a query, allowing the database to satisfy the query using only the index without accessing the table data.',
  ),
];

final List<QuizQuestion> expertDesignQuestions = [
  QuizQuestion(
    question: 'What is the highest normal form in database normalization?',
    options: ['3NF', '4NF', '5NF', '2NF'],
    correctAnswerIndex: 2,
    explanation: '5NF (Fifth Normal Form) is the highest normal form in database normalization.',
  ),
  QuizQuestion(
    question: 'What is database denormalization?',
    options: [
      'The process of removing redundant data',
      'The process of adding redundant data to improve query performance',
      'The process of creating more tables',
      'The process of removing indexes'
    ],
    correctAnswerIndex: 1,
    explanation: 'Denormalization is the process of deliberately adding redundant data to a database to improve read performance, at the cost of write performance and data integrity.',
  ),
  QuizQuestion(
    question: 'What constraint ensures that a column or set of columns has unique values across a table?',
    options: [
      'PRIMARY KEY',
      'FOREIGN KEY',
      'UNIQUE',
      'CHECK'
    ],
    correctAnswerIndex: 2,
    explanation: 'A UNIQUE constraint ensures that all values in a column or set of columns are distinct from each other.',
  ),
  QuizQuestion(
    question: 'What is a junction table (also known as a bridge table)?',
    options: [
      'A table that stores temporary results',
      'A table that connects two tables in a many-to-many relationship',
      'A table that stores database metadata',
      'A table that tracks database changes'
    ],
    correctAnswerIndex: 1,
    explanation: 'A junction table is used to connect two tables that have a many-to-many relationship, breaking it down into two one-to-many relationships.',
  ),
  QuizQuestion(
    question: 'What is database sharding?',
    options: [
      'Breaking a database into smaller pieces stored across multiple servers',
      'Encrypting sensitive database information',
      'Compressing database tables to save space',
      'Converting a database from one system to another'
    ],
    correctAnswerIndex: 0,
    explanation: 'Sharding is a database architecture pattern related to horizontal partitioning, where rows of a database table are stored separately rather than splitting by columns.',
  ),
];

final List<QuizQuestion> expertAdvancedQuestions = [
  QuizQuestion(
    question: 'Which feature allows automatic maintenance of derived data?',
    options: ['VIEW', 'PROCEDURE', 'TRIGGER', 'FUNCTION'],
    correctAnswerIndex: 2,
    explanation: 'TRIGGER is a database object that automatically executes when a specified event occurs.',
  ),
  QuizQuestion(
    question: 'What is a materialized view?',
    options: [
      'A virtual table that doesn\'t store data',
      'A stored query result that can be refreshed periodically',
      'A view with security restrictions',
      'A view that can only be accessed by the database administrator'
    ],
    correctAnswerIndex: 1,
    explanation: 'A materialized view is a database object that contains the results of a query, storing the results physically and updating them according to defined rules.',
  ),
  QuizQuestion(
    question: 'What is a stored procedure?',
    options: [
      'A database backup process',
      'A predefined set of SQL statements that can be saved and reused',
      'A security mechanism for databases',
      'A tool for designing database tables'
    ],
    correctAnswerIndex: 1,
    explanation: 'A stored procedure is a prepared SQL code that can be saved and reused, allowing for complex processing with parameters and control flow.',
  ),
  QuizQuestion(
    question: 'What is a database transaction?',
    options: [
      'The cost of running a database operation',
      'A unit of work performed within a database management system',
      'A data transfer between databases',
      'A database query log entry'
    ],
    correctAnswerIndex: 1,
    explanation: 'A transaction is a unit of work that is performed in a database, either completely or not at all, ensuring data integrity even in case of system failures.',
  ),
  QuizQuestion(
    question: 'What does the ACID principle represent in database systems?',
    options: [
      'Atomicity, Concurrency, Isolation, Durability',
      'Atomicity, Consistency, Isolation, Durability',
      'Availability, Consistency, Integration, Durability',
      'Availability, Concurrency, Integrity, Distribution'
    ],
    correctAnswerIndex: 1,
    explanation: 'ACID stands for Atomicity (all or nothing), Consistency (valid state), Isolation (concurrent transactions don\'t affect each other), and Durability (committed changes are permanent).',
  ),
]; 