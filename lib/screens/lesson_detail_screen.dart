import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/sql_lesson.dart';
import '../widgets/sql_query_editor.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LessonDetailScreen extends StatefulWidget {
  final SQLLesson lesson;
  
  const LessonDetailScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExerciseMode = false;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  int _currentSection = 0;
  late GlobalKey _learnKey;
  late GlobalKey _syntaxKey;
  late GlobalKey _examplesKey;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _learnKey = GlobalKey();
    _syntaxKey = GlobalKey();
    _examplesKey = GlobalKey();
  }
  
  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 100;
    });
  }

  void _scrollToSection(int index) {
    setState(() {
      _currentSection = index;
    });
    
    GlobalKey targetKey;
    switch (index) {
      case 0:
        targetKey = _learnKey;
        break;
      case 1:
        targetKey = _syntaxKey;
        break;
      case 2:
        targetKey = _examplesKey;
        break;
      default:
        targetKey = _learnKey;
    }
    
    final context = targetKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Map<String, dynamic> lessonContent = _getLessonContent();
    
    return Scaffold(
      body: _isExerciseMode 
          ? _buildPracticeMode()
          : _buildLearnMode(isDarkMode, lessonContent),
      floatingActionButton: _isExerciseMode 
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isExerciseMode = false;
                });
              },
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.book),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _isExerciseMode = true;
                });
              },
              backgroundColor: Colors.green.shade700,
              icon: const Icon(Icons.code),
              label: const Text('Practice'),
            ),
    );
  }
  
  Widget _buildLearnMode(bool isDarkMode, Map<String, dynamic> lessonContent) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                lessonContent['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: isDarkMode
                            ? [Colors.indigo.shade900, Colors.blue.shade900]
                            : [Colors.blue.shade600, Colors.blue.shade900],
                      ),
                    ),
                  ),
                  // Simple pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),
                  ),
                  // Animation container
                  Positioned(
                    right: 0,
                    bottom: 0,
                    width: 120,
                    height: 120,
                    child: Opacity(
                      opacity: 0.8,
                      child: Lottie.asset(
                        widget.lesson.animationAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.code,
                              size: 64,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Difficulty badge
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(widget.lesson.difficulty).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.lesson.difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDarkMode ? Colors.white : Colors.blue.shade700,
                  unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  indicatorColor: isDarkMode ? Colors.white : Colors.blue.shade700,
                  indicatorWeight: 3,
                  onTap: _scrollToSection,
                  tabs: const [
                    Tab(text: 'OVERVIEW'),
                    Tab(text: 'SYNTAX'),
                    Tab(text: 'EXAMPLES'),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description card
            Container(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    lessonContent['description'],
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            
            // Progress indicator
            Container(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final progressPercent = userProvider.progressPercentage;
                  final progressValue = progressPercent / 100;
                  
                  return Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              height: 6,
                              width: MediaQuery.of(context).size.width * progressValue, 
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade400, Colors.green.shade400],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$progressPercent%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
            
            // Key Concepts Section
            Container(
              key: _learnKey,
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Key Concepts', Icons.lightbulb_outline),
                  const SizedBox(height: 16),
                  ...lessonContent['keyConcepts'].asMap().entries.map((entry) {
                    int idx = entry.key;
                    var concept = entry.value;
                    return _buildConceptCard(concept, idx, isDarkMode);
                  }).toList(),
                ],
              ),
            ),
            
            // Syntax Section
            Container(
              key: _syntaxKey,
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('SQL Syntax', Icons.code),
                  const SizedBox(height: 16),
                  ...lessonContent['syntax'].map((syntax) {
                    return _buildSyntaxCard(syntax, isDarkMode);
                  }).toList(),
                ],
              ),
            ),
            
            // Examples Section
            Container(
              key: _examplesKey,
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Examples', Icons.code_off),
                  const SizedBox(height: 16),
                  ...lessonContent['examples'].map((example) {
                    return _buildExampleCard(example, isDarkMode);
                  }).toList(),
                ],
              ),
            ),
            
            // Bottom padding
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue.shade700,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Widget _buildConceptCard(Map<String, dynamic> concept, int index, bool isDarkMode) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getConceptColor(index),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          concept['title'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              concept['description'],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSyntaxCard(Map<String, dynamic> syntax, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.terminal,
                  color: isDarkMode ? Colors.white : Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  syntax['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 64,
                    ),
                    child: SelectableText(
                      syntax['code'],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: isDarkMode ? Colors.greenAccent : Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              syntax['description'],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.content_copy, size: 16),
                  label: const Text('Copy Code'),
                  onPressed: () {
                    // Copy code to clipboard logic
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExampleCard(Map<String, dynamic> example, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                example['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            example['problem'],
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SQL Query:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    example['code'],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: isDarkMode ? Colors.greenAccent : Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Output:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    example['output'],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Explanation:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  example['explanation'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.content_copy, size: 16),
                      label: const Text('Copy Code'),
                      onPressed: () {
                        // Copy code to clipboard logic
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Try It'),
                      onPressed: () {
                        setState(() {
                          _isExerciseMode = true;
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeMode() {
    final exercises = _getExercises();
    
    return SQLQueryEditor(
      exercises: exercises,
      lessonTitle: widget.lesson.title,
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade700;
      case 'intermediate':
        return Colors.orange.shade700;
      case 'advanced':
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
  
  Color _getConceptColor(int index) {
    List<Color> colors = [
      Colors.blue.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.orange.shade700,
      Colors.pink.shade700,
      Colors.green.shade700,
      Colors.indigo.shade700,
      Colors.red.shade700,
      Colors.amber.shade700,
      Colors.cyan.shade700,
    ];
    
    return colors[index % colors.length];
  }
  
  Map<String, dynamic> _getLessonContent() {
    // Provide lesson content based on lesson ID
    switch (widget.lesson.id) {
      case 'basics':
        return {
          'title': 'SQL Basics',
          'description': 'SQL (Structured Query Language) is a standard language for storing, manipulating, and retrieving data in relational database management systems. This lesson covers the fundamental commands and concepts to help you build a solid foundation for working with databases.',
          'keyConcepts': [
            {
              'title': 'What is SQL?',
              'description': 'SQL stands for Structured Query Language. It is designed for managing data in relational database management systems (RDBMS). SQL is used to query, insert, update, and modify data. It has become the standard language for database communication and is used by major database platforms like MySQL, PostgreSQL, Oracle, SQL Server, and SQLite.'
            },
            {
              'title': 'Database Structure',
              'description': 'A database is a collection of tables. Tables contain rows (records) and columns (fields). Each column has a specific data type that determines what kind of data it can store (e.g., integers, text, dates). Tables can be related to each other using foreign keys, creating a relational database structure.'
            },
            {
              'title': 'SQL Commands Categories',
              'description': 'SQL commands are divided into several categories:\n• Data Query Language (DQL): Used to retrieve data (SELECT)\n• Data Definition Language (DDL): Used to define database structure (CREATE, ALTER, DROP)\n• Data Manipulation Language (DML): Used to manipulate data (INSERT, UPDATE, DELETE)\n• Data Control Language (DCL): Used to control access (GRANT, REVOKE)\n• Transaction Control Language (TCL): Used to manage transactions (COMMIT, ROLLBACK)'
            },
            {
              'title': 'Primary Keys and Foreign Keys',
              'description': 'A primary key is a column (or combination of columns) that uniquely identifies each row in a table. It must contain unique values and cannot be null. A foreign key is a column that creates a relationship with another table by referencing its primary key. This enables the creation of relationships between tables.'
            },
            {
              'title': 'Data Types',
              'description': 'SQL supports various data types to store different kinds of information:\n• Numeric types: INT, FLOAT, DECIMAL\n• String types: VARCHAR, CHAR, TEXT\n• Date/Time types: DATE, TIME, DATETIME\n• Boolean: BOOLEAN\n• Binary types: BLOB\nThe specific data types available may vary slightly between different database systems.'
            },
          ],
          'syntax': [
            {
              'title': 'SELECT Statement',
              'code': 'SELECT column1, column2, ...\nFROM table_name\nWHERE condition\nORDER BY column1 [ASC|DESC]\nLIMIT number;',
              'description': 'The SELECT statement is the most commonly used SQL command. It retrieves data from one or more tables.\n\n• FROM specifies the table to query\n• WHERE filters rows based on a condition\n• ORDER BY sorts the results\n• LIMIT restricts the number of returned rows\n\nYou can use * to select all columns: SELECT * FROM table_name;'
            },
            {
              'title': 'INSERT Statement',
              'code': '-- Insert a single row\nINSERT INTO table_name (column1, column2, ...)\nVALUES (value1, value2, ...);\n\n-- Insert multiple rows\nINSERT INTO table_name (column1, column2, ...)\nVALUES \n  (value1, value2, ...),\n  (value1, value2, ...),\n  (value1, value2, ...);',
              'description': 'The INSERT statement adds new records to a table. You can specify which columns to insert data into, and the VALUES clause provides the data. If you omit the column list, you must provide values for all columns in the correct order. You can insert multiple rows in a single statement for better performance.'
            },
            {
              'title': 'UPDATE Statement',
              'code': 'UPDATE table_name\nSET column1 = value1, column2 = value2, ...\nWHERE condition;',
              'description': 'The UPDATE statement modifies existing records in a table. The SET clause specifies which columns to update and their new values. The WHERE clause determines which rows to update. CAUTION: If you omit the WHERE clause, ALL rows in the table will be updated, which is rarely the intended behavior!'
            },
            {
              'title': 'DELETE Statement',
              'code': 'DELETE FROM table_name\nWHERE condition;',
              'description': 'The DELETE statement removes records from a table. The WHERE clause specifies which rows to delete. CAUTION: If you omit the WHERE clause, ALL rows in the table will be deleted! Always use the WHERE clause unless you genuinely want to empty the entire table.'
            },
            {
              'title': 'CREATE TABLE Statement',
              'code': 'CREATE TABLE table_name (\n  column1 datatype constraints,\n  column2 datatype constraints,\n  ...,\n  PRIMARY KEY (column_name)\n);',
              'description': 'The CREATE TABLE statement defines a new table in the database. You specify column names, their data types, and any constraints. Common constraints include:\n\n• PRIMARY KEY: Unique identifier for each row\n• NOT NULL: Column cannot contain NULL values\n• UNIQUE: All values in the column must be distinct\n• FOREIGN KEY: References a column in another table\n• DEFAULT: Specifies a default value'
            },
            {
              'title': 'WHERE Clause and Operators',
              'code': 'SELECT * FROM table_name\nWHERE condition1 AND condition2\n  OR condition3;\n\n-- Comparison operators\nWHERE age > 30\nWHERE price <= 100\nWHERE status = \'active\'\nWHERE quantity <> 0\n\n-- Pattern matching\nWHERE name LIKE \'A%\'  -- Names starting with A\nWHERE name LIKE \'%son\' -- Names ending with "son"\n\n-- Range check\nWHERE age BETWEEN 18 AND 30\n\n-- List check\nWHERE country IN (\'USA\', \'Canada\', \'Mexico\')',
              'description': 'The WHERE clause filters rows based on conditions. You can use logical operators (AND, OR, NOT) to combine conditions. Comparison operators include =, <>, >, <, >=, <=. LIKE is used for pattern matching with wildcards (% matches any sequence of characters, _ matches any single character). BETWEEN checks if a value is within a range. IN checks if a value matches any value in a list.'
            },
          ],
          'examples': [
            {
              'title': 'Basic SELECT Example',
              'problem': 'Retrieve all columns from the "Customers" table',
              'code': 'SELECT * FROM Customers;',
              'output': 'CustomerID | CustomerName     | ContactName     | Country | Email\n---------------------------------------------------------\n1         | Alfreds Futterkiste | Maria Anders     | Germany | maria@futterkiste.de\n2         | Ana Trujillo       | Ana Trujillo     | Mexico  | ana@trujillo.com\n3         | Antonio Moreno     | Antonio Moreno   | Mexico  | antonio@moreno.mx',
              'explanation': 'This query selects all columns (indicated by the * wildcard) from the Customers table, returning all customer records. This is useful when you need to see all data, but in production environments with large tables, it\'s better to select only the columns you need.'
            },
            {
              'title': 'Filtered SELECT Example',
              'problem': 'Retrieve customer names from Germany',
              'code': 'SELECT CustomerName, ContactName, City, Email\nFROM Customers\nWHERE Country = "Germany";',
              'output': 'CustomerName      | ContactName      | City     | Email\n--------------------------------------------------\nAlfreds Futterkiste | Maria Anders      | Berlin   | maria@futterkiste.de\nBerliner Platz     | Fabian Thompson   | Berlin   | fabian@berliner.de\nFrank\'s Trading    | Peter Franken     | Frankfurt| peter@franks.de',
              'explanation': 'This query selects specific columns (CustomerName, ContactName, City, Email) from Customers where the country is Germany. The WHERE clause filters the results to show only German customers. This demonstrates how to retrieve only the data you need, which is more efficient.'
            },
            {
              'title': 'Sorting Results Example',
              'problem': 'Retrieve products ordered by price from highest to lowest',
              'code': 'SELECT ProductName, Category, Price\nFROM Products\nORDER BY Price DESC;',
              'output': 'ProductName | Category    | Price\n-----------------------------------\nLaptop      | Electronics | 800\nMonitor     | Electronics | 150\nPrinter     | Electronics | 120\nKeyboard    | Electronics | 55\nMouse       | Electronics | 25\nHeadphones  | Electronics | 30',
              'explanation': 'This query selects product details and sorts them by price in descending order (DESC). The ORDER BY clause arranges the results based on the specified column. By default, ORDER BY sorts in ascending order (ASC), but we\'ve explicitly requested descending order to see the most expensive products first.'
            },
            {
              'title': 'INSERT Example',
              'problem': 'Add a new customer to the database',
              'code': 'INSERT INTO Customers (CustomerName, ContactName, Address, City, Country, Email)\nVALUES ("Cardinal", "Tom B. Erichsen", "Skagen 21", "Stavanger", "Norway", "tom@cardinal.no");',
              'output': '1 row(s) affected',
              'explanation': 'This query inserts a new customer record into the Customers table. We specify the column names and then provide the corresponding values in the same order. The database confirms that one row was affected (inserted). If you don\'t specify column names, you must provide values for all columns in the exact order they appear in the table schema.'
            },
            {
              'title': 'UPDATE Example',
              'problem': 'Update the email address for a customer',
              'code': 'UPDATE Customers\nSET Email = "maria.anders@futterkiste.de"\nWHERE CustomerID = 1;',
              'output': '1 row(s) affected',
              'explanation': 'This query updates the Email column for the customer with CustomerID 1. The SET clause specifies the new value, and the WHERE clause ensures only the intended customer is updated. Always include a WHERE clause with UPDATE unless you want to update all records, which is rarely the case.'
            },
            {
              'title': 'DELETE Example',
              'problem': 'Remove a discontinued product from the database',
              'code': 'DELETE FROM Products\nWHERE ProductID = 7 AND Discontinued = 1;',
              'output': '1 row(s) affected',
              'explanation': 'This query deletes a specific product (ProductID = 7) that is marked as discontinued. The WHERE clause with multiple conditions ensures we only delete the exact record we intend to remove. This demonstrates how to safely remove data by using specific conditions.'
            },
          ]
        };
      case 'queries_joins':
        return {
          'title': 'Queries & Joins',
          'description': 'Learn how to write complex queries and combine data from multiple tables using SQL JOINs. One of the most powerful features of relational databases is the ability to connect related data across tables. This lesson explores various types of joins, complex querying techniques, and how to retrieve meaningful insights from your data.',
          'keyConcepts': [
            {
              'title': 'Relational Database Design',
              'description': 'In a well-designed relational database, data is organized into multiple tables to minimize redundancy. For example, instead of storing customer details with every order, an Orders table would reference a separate Customers table. This structure requires the ability to combine or "join" tables when querying data, which is where SQL JOINs become essential.'
            },
            {
              'title': 'SQL JOINs',
              'description': 'SQL JOINs are used to combine rows from two or more tables based on a related column between them. There are several types of JOINs:\n\n• INNER JOIN: Returns records with matching values in both tables\n• LEFT JOIN (or LEFT OUTER JOIN): Returns all records from the left table and matching records from the right table\n• RIGHT JOIN (or RIGHT OUTER JOIN): Returns all records from the right table and matching records from the left table\n• FULL JOIN (or FULL OUTER JOIN): Returns all records when there\'s a match in either table\n• CROSS JOIN: Returns the Cartesian product of both tables (every possible combination of rows)'
            },
            {
              'title': 'Keys and Relationships',
              'description': 'Joins rely on relationships between tables, typically established using keys:\n\n• Primary Key: A column that uniquely identifies each row in a table\n• Foreign Key: A column in one table that refers to a primary key in another table\n\nExample: An Orders table might have a CustomerID column (foreign key) that references the CustomerID primary key in the Customers table. This creates a relationship you can use in JOIN operations.'
            },
            {
              'title': 'Aliasing Tables and Columns',
              'description': 'When working with multiple tables, you can use aliases to create shorter, more readable names:\n\nSELECT c.CustomerName, o.OrderDate\nFROM Customers c\nJOIN Orders o ON c.CustomerID = o.CustomerID;\n\nHere, "c" is an alias for Customers and "o" is an alias for Orders. This is especially helpful when table names are long or when joining a table to itself.'
            },
            {
              'title': 'Aggregate Functions and GROUP BY',
              'description': 'Aggregate functions perform calculations on a set of values and return a single value. Common aggregate functions include:\n\n• COUNT(): Counts the number of rows\n• SUM(): Calculates the sum of values\n• AVG(): Calculates the average value\n• MIN(): Finds the minimum value\n• MAX(): Finds the maximum value\n\nThe GROUP BY clause groups rows with the same values in specified columns, often used with aggregate functions to find statistics like "total sales per customer" or "average order value per region."'
            },
            {
              'title': 'Complex Filtering with HAVING',
              'description': 'While WHERE filters individual rows before grouping, the HAVING clause filters groups after the GROUP BY is applied. This allows you to filter based on aggregate values:\n\nSELECT Country, COUNT(*) as CustomerCount\nFROM Customers\nGROUP BY Country\nHAVING COUNT(*) > 5;\n\nThis query finds countries with more than 5 customers.'
            },
          ],
          'syntax': [
            {
              'title': 'INNER JOIN',
              'code': 'SELECT columns\nFROM table1\nINNER JOIN table2\nON table1.column_name = table2.column_name;',
              'description': 'The INNER JOIN returns only the rows where there is a match in both tables based on the join condition. If a record in the first table doesn\'t have a matching record in the second table, it is excluded from the results. INNER JOIN is the most common type of join and is the default in many SQL dialects (sometimes written simply as JOIN).'
            },
            {
              'title': 'LEFT JOIN',
              'code': 'SELECT columns\nFROM table1\nLEFT JOIN table2\nON table1.column_name = table2.column_name;',
              'description': 'The LEFT JOIN returns all records from the left table (table1) and the matched records from the right table (table2). If there is no match, NULL values are returned for columns from the right table. This is useful when you want to ensure all records from the first table are included, even if they don\'t have corresponding records in the second table.'
            },
            {
              'title': 'RIGHT JOIN',
              'code': 'SELECT columns\nFROM table1\nRIGHT JOIN table2\nON table1.column_name = table2.column_name;',
              'description': 'The RIGHT JOIN returns all records from the right table (table2) and the matched records from the left table (table1). If there is no match, NULL values are returned for columns from the left table. This is less commonly used than LEFT JOIN, as the same result can be achieved by reversing the table order and using a LEFT JOIN.'
            },
            {
              'title': 'FULL JOIN',
              'code': 'SELECT columns\nFROM table1\nFULL JOIN table2\nON table1.column_name = table2.column_name;',
              'description': 'The FULL JOIN returns all records when there is a match in either table. If there is no match, NULL values are returned for columns from the table without a match. Not all database systems support FULL JOIN (e.g., MySQL does not). In those cases, you can simulate it by combining the results of a LEFT JOIN and a RIGHT JOIN with UNION.'
            },
            {
              'title': 'Joining Multiple Tables',
              'code': 'SELECT o.OrderID, c.CustomerName, e.LastName as EmployeeName\nFROM Orders o\nJOIN Customers c ON o.CustomerID = c.CustomerID\nJOIN Employees e ON o.EmployeeID = e.EmployeeID;',
              'description': 'You can join more than two tables by adding additional JOIN clauses. Each join is processed sequentially. For example, this query first joins Orders with Customers, and then joins the result with Employees. Table aliases (o, c, e) make the query more readable.'
            },
            {
              'title': 'Aggregate Functions with GROUP BY',
              'code': 'SELECT column_name, COUNT(*) as count\nFROM table_name\nGROUP BY column_name;\n\n-- Example with JOIN\nSELECT c.Country, COUNT(o.OrderID) as OrderCount\nFROM Customers c\nLEFT JOIN Orders o ON c.CustomerID = o.CustomerID\nGROUP BY c.Country\nORDER BY OrderCount DESC;',
              'description': 'Aggregate functions (COUNT, SUM, AVG, MIN, MAX) perform calculations on groups of rows. The GROUP BY clause divides the rows into groups based on one or more columns. Each group is then condensed into a single row in the result. When using GROUP BY, each column in the SELECT clause must either be included in the GROUP BY clause or be an aggregate function.'
            },
            {
              'title': 'Self Join',
              'code': 'SELECT e1.FirstName, e1.LastName, e2.FirstName as ManagerFirstName, e2.LastName as ManagerLastName\nFROM Employees e1\nLEFT JOIN Employees e2 ON e1.ManagerID = e2.EmployeeID;',
              'description': 'A self join is a regular join, but the table is joined with itself. This is useful for hierarchical data (like an employee-manager relationship) or for comparing rows within the same table. Table aliases (e1, e2) are essential in self joins to distinguish between the two instances of the same table.'
            },
          ],
          'examples': [
            {
              'title': 'INNER JOIN Example',
              'problem': 'List all orders with customer information',
              'code': 'SELECT Orders.OrderID, Customers.CustomerName, Orders.OrderDate\nFROM Orders\nINNER JOIN Customers\nON Orders.CustomerID = Customers.CustomerID;',
              'output': 'OrderID | CustomerName | OrderDate\n-------------------------------------------\n10308   | Ana Trujillo     | 2022-09-18\n10309   | Antonio Moreno   | 2022-09-19\n10310   | Alfreds Futterkiste | 2022-09-20\n10311   | Around the Horn  | 2022-09-21',
              'explanation': 'This query joins the Orders and Customers tables on the CustomerID field, showing order information along with the customer\'s name. Only orders with valid customer references are included in the results (INNER JOIN). This is essential information for order processing, customer service, and reporting.'
            },
            {
              'title': 'LEFT JOIN Example',
              'problem': 'Find customers who have not placed any orders',
              'code': 'SELECT Customers.CustomerName, Orders.OrderID\nFROM Customers\nLEFT JOIN Orders\nON Customers.CustomerID = Orders.CustomerID\nWHERE Orders.OrderID IS NULL;',
              'output': 'CustomerName     | OrderID\n--------------------------\nJohannes Gutenberg | NULL\nPicasso Paintings  | NULL\nRiver Boat Tours   | NULL',
              'explanation': 'This query uses a LEFT JOIN to include all customers regardless of whether they have orders. The WHERE clause then filters to show only customers with NULL in the OrderID column, meaning they have no associated orders. This could be useful for marketing campaigns targeting inactive customers.'
            },
            {
              'title': 'Aggregation with JOIN Example',
              'problem': 'Count the number of orders placed by each customer',
              'code': 'SELECT Customers.CustomerName, COUNT(Orders.OrderID) AS NumberOfOrders\nFROM Customers\nLEFT JOIN Orders\nON Customers.CustomerID = Orders.CustomerID\nGROUP BY Customers.CustomerID, Customers.CustomerName\nORDER BY NumberOfOrders DESC;',
              'output': 'CustomerName     | NumberOfOrders\n-----------------------------------\nAlfreds Futterkiste | 6\nAntonio Moreno     | 5\nAna Trujillo       | 4\nAround the Horn    | 3\nBerliner Platz     | 3\nJohannes Gutenberg | 0',
              'explanation': 'This query counts the number of orders for each customer using COUNT() and GROUP BY. The LEFT JOIN ensures that customers with zero orders are included in the results. We order by order count in descending order to see the most active customers first. This provides valuable customer activity metrics for business analysis.'
            },
            {
              'title': 'Multi-table JOIN Example',
              'problem': 'Get detailed order information including products and customers',
              'code': 'SELECT o.OrderID, c.CustomerName, p.ProductName, od.Quantity, p.Price,\n       (od.Quantity * p.Price) AS TotalPrice\nFROM Orders o\nJOIN Customers c ON o.CustomerID = c.CustomerID\nJOIN OrderDetails od ON o.OrderID = od.OrderID\nJOIN Products p ON od.ProductID = p.ProductID\nORDER BY o.OrderID;',
              'output': 'OrderID | CustomerName   | ProductName | Quantity | Price | TotalPrice\n-------------------------------------------------------------------\n10308   | Ana Trujillo   | Cheese      | 5        | 14.00 | 70.00\n10308   | Ana Trujillo   | Bread       | 2        | 3.50  | 7.00\n10309   | Antonio Moreno | Coffee      | 15       | 7.75  | 116.25\n10310   | Alfreds Futt.  | Chocolate   | 10       | 5.25  | 52.50',
              'explanation': 'This query joins four tables to produce a comprehensive view of orders: Orders, Customers, OrderDetails, and Products. It includes the order ID, customer name, product name, quantity, price per unit, and the calculated total price (quantity * price). This provides a complete picture of what was ordered, by whom, and at what cost.'
            },
            {
              'title': 'Self-Join Example',
              'problem': 'List employees and their managers',
              'code': 'SELECT e1.EmployeeID, e1.FirstName || \' \' || e1.LastName AS Employee,\n       e2.FirstName || \' \' || e2.LastName AS Manager\nFROM Employees e1\nLEFT JOIN Employees e2 ON e1.ManagerID = e2.EmployeeID\nORDER BY e1.EmployeeID;',
              'output': 'EmployeeID | Employee         | Manager\n------------------------------------------------\n1          | Andrew Fuller    | NULL\n2          | Nancy Davolio    | Andrew Fuller\n3          | Janet Leverling  | Andrew Fuller\n4          | Margaret Peacock | Andrew Fuller\n5          | Steven Buchanan  | Andrew Fuller\n6          | Michael Suyama   | Steven Buchanan',
              'explanation': 'This query uses a self-join on the Employees table to show each employee alongside their manager\'s name. The LEFT JOIN ensures all employees are included, even those without managers (like the CEO, who has a NULL ManagerID). Self-joins are powerful for handling hierarchical data within a single table.'
            },
            {
              'title': 'HAVING Clause Example',
              'problem': 'Find products ordered more than 100 times',
              'code': 'SELECT p.ProductName, SUM(od.Quantity) AS TotalOrdered\nFROM Products p\nJOIN OrderDetails od ON p.ProductID = od.ProductID\nGROUP BY p.ProductID, p.ProductName\nHAVING SUM(od.Quantity) > 100\nORDER BY TotalOrdered DESC;',
              'output': 'ProductName     | TotalOrdered\n--------------------------------\nRavioli Angelo | 374\nGorgonzola Telino | 345\nPâté chinois    | 293\nCamembert Pierrot | 234\nGnocchi di nonna Alice | 167',
              'explanation': 'This query finds products that have been ordered more than 100 times in total. It uses JOIN to connect Products and OrderDetails, GROUP BY to group by product, and HAVING to filter based on the aggregate sum of quantities. The WHERE clause filters rows before grouping, while HAVING filters after grouping, allowing filtering based on aggregate results.'
            },
          ]
        };
      case 'stored_procedures':
        return {
          'title': 'Stored Procedures & Triggers',
          'description': 'This lesson explores advanced database programming features that enhance database functionality, enforce business rules, and improve performance. Stored procedures and triggers are essential tools for database developers seeking to build robust, efficient, and maintainable database applications.',
          'keyConcepts': [
            {
              'title': 'What are Stored Procedures?',
              'description': 'A stored procedure is a prepared SQL code that can be saved and reused. Think of it as a function for your database - you can pass parameters to it, it can perform operations, and it can return results. Stored procedures can contain control flow statements (IF/ELSE, WHILE, etc.), variables, error handling, and can call other stored procedures. They are precompiled, which improves performance for frequently executed operations.'
            },
            {
              'title': 'Benefits of Stored Procedures',
              'description': 'Stored procedures offer several advantages:\n\n• Performance: They\'re precompiled and cached, reducing network traffic\n• Security: Can control access to data without giving direct table access\n• Maintenance: Business logic in one place, easier to update\n• Reusability: Same procedure can be called from multiple applications\n• Reduced network traffic: Only the procedure call is sent, not all SQL code'
            },
            {
              'title': 'What are Triggers?',
              'description': 'Triggers are special stored procedures that automatically execute when specific events occur in the database. These events are typically data modification operations (INSERT, UPDATE, DELETE) on a specified table. Triggers can execute before the event (BEFORE triggers) or after the event (AFTER triggers), and can affect the operation itself or perform additional actions.'
            },
            {
              'title': 'Types of Triggers',
              'description': 'Different database systems support different types of triggers:\n\n• DML Triggers: Execute on INSERT, UPDATE, or DELETE operations\n• DDL Triggers: Execute on CREATE, ALTER, or DROP operations\n• INSTEAD OF Triggers: Replace the triggering operation with custom logic\n• Login Triggers: Execute when users log in to the database server\n\nTriggers can also be classified as row-level (fire once for each affected row) or statement-level (fire once for each statement, regardless of how many rows are affected).'
            },
            {
              'title': 'Common Use Cases',
              'description': 'Stored procedures and triggers are commonly used for:\n\n• Enforcing complex business rules and data integrity\n• Implementing auditing and logging\n• Automating database maintenance tasks\n• Creating abstraction layers for applications\n• Implementing complex security models\n• Providing standard interfaces for different applications'
            },
            {
              'title': 'Transactions and Error Handling',
              'description': 'Both stored procedures and triggers often need to ensure data consistency using transactions. A transaction groups multiple operations that should succeed or fail as a unit. Error handling in procedures and triggers is critical to maintain data integrity. Different database systems have different syntax for transactions and error handling, but the concepts are similar.'
            },
          ],
          'syntax': [
            {
              'title': 'Creating a Stored Procedure',
              'code': '-- SQL Server syntax\nCREATE PROCEDURE GetCustomerOrders\n    @CustomerID INT\nAS\nBEGIN\n    SELECT OrderID, OrderDate, TotalAmount\n    FROM Orders\n    WHERE CustomerID = @CustomerID\n    ORDER BY OrderDate DESC;\nEND;\n\n-- MySQL syntax\nDELIMITER //\nCREATE PROCEDURE GetCustomerOrders(IN customerId INT)\nBEGIN\n    SELECT OrderID, OrderDate, TotalAmount\n    FROM Orders\n    WHERE CustomerID = customerId\n    ORDER BY OrderDate DESC;\nEND //\nDELIMITER ;',
              'description': 'This example shows how to create a stored procedure that retrieves orders for a specific customer. The syntax varies between database systems. Key elements include:\n\n• CREATE PROCEDURE statement to define the procedure\n• Parameter declaration (@CustomerID in SQL Server, IN customerId in MySQL)\n• BEGIN and END to enclose the procedure body\n• The SQL statements that make up the procedure logic'
            },
            {
              'title': 'Executing a Stored Procedure',
              'code': '-- SQL Server syntax\nEXEC GetCustomerOrders @CustomerID = 123;\n\n-- Alternative SQL Server syntax\nEXEC GetCustomerOrders 123;\n\n-- MySQL syntax\nCALL GetCustomerOrders(123);',
              'description': 'Executing a stored procedure is straightforward. You use EXEC or EXECUTE in SQL Server, or CALL in MySQL, followed by the procedure name and any required parameters. Parameters can be specified by name or by position, depending on the database system and your preference.'
            },
            {
              'title': 'Stored Procedure with Output Parameter',
              'code': '-- SQL Server\nCREATE PROCEDURE CalculateOrderTotal\n    @OrderID INT,\n    @TotalAmount DECIMAL(10,2) OUTPUT\nAS\nBEGIN\n    SELECT @TotalAmount = SUM(Quantity * UnitPrice)\n    FROM OrderDetails\n    WHERE OrderID = @OrderID;\nEND;\n\n-- Executing with output parameter\nDECLARE @Total DECIMAL(10,2);\nEXEC CalculateOrderTotal @OrderID = 10308, @TotalAmount = @Total OUTPUT;\nSELECT @Total AS OrderTotal;',
              'description': 'Stored procedures can return values through output parameters. This example calculates the total amount for an order and returns it via an output parameter. Output parameters are declared with the OUTPUT keyword in SQL Server (or OUT in MySQL) and must be explicitly marked as output when executing the procedure.'
            },
            {
              'title': 'Creating a Trigger',
              'code': '-- SQL Server trigger on INSERT\nCREATE TRIGGER tr_Orders_Insert\nON Orders\nAFTER INSERT\nAS\nBEGIN\n    -- Get the inserted OrderID(s)\n    DECLARE @OrderID INT;\n    SELECT @OrderID = OrderID FROM inserted;\n    \n    -- Update inventory\n    UPDATE Products\n    SET UnitsInStock = UnitsInStock - od.Quantity\n    FROM Products p\n    JOIN OrderDetails od ON p.ProductID = od.ProductID\n    WHERE od.OrderID = @OrderID;\n    \n    -- Log the order\n    INSERT INTO OrderLog(OrderID, Action, ActionDate)\n    VALUES(@OrderID, \'New Order\', GETDATE());\nEND;',
              'description': 'This trigger fires after an insert operation on the Orders table. It updates the inventory by reducing the units in stock for each product in the order and logs the new order in an audit table. Key elements include:\n\n• CREATE TRIGGER statement to define the trigger\n• ON clause specifying the table the trigger monitors\n• AFTER/BEFORE/INSTEAD OF specifying when the trigger fires\n• FOR/AFTER INSERT/UPDATE/DELETE specifying the operations that activate the trigger\n• The trigger body with the actions to perform'
            },
            {
              'title': 'Using Inserted and Deleted Tables',
              'code': '-- SQL Server UPDATE trigger\nCREATE TRIGGER tr_Employees_UpdateSalary\nON Employees\nAFTER UPDATE\nAS\nBEGIN\n    -- Only proceed if Salary was updated\n    IF UPDATE(Salary)\n    BEGIN\n        INSERT INTO SalaryChangeLog(EmployeeID, OldSalary, NewSalary, ChangeDate)\n        SELECT d.EmployeeID, d.Salary, i.Salary, GETDATE()\n        FROM deleted d\n        JOIN inserted i ON d.EmployeeID = i.EmployeeID\n        WHERE d.Salary <> i.Salary;\n    END\nEND;',
              'description': 'In SQL Server triggers, the inserted and deleted virtual tables provide access to the rows affected by the operation. For an INSERT, only inserted contains rows; for a DELETE, only deleted contains rows; for an UPDATE, both tables contain rows - inserted has the new values, deleted has the old values. This trigger logs salary changes by comparing old and new values.'
            },
            {
              'title': 'Transactions in Stored Procedures',
              'code': '-- SQL Server transaction example\nCREATE PROCEDURE TransferFunds\n    @FromAccount INT,\n    @ToAccount INT,\n    @Amount DECIMAL(10,2)\nAS\nBEGIN\n    -- Start transaction\n    BEGIN TRANSACTION;\n    \n    BEGIN TRY\n        -- Withdraw from source account\n        UPDATE Accounts\n        SET Balance = Balance - @Amount\n        WHERE AccountID = @FromAccount;\n        \n        -- Verify sufficient funds\n        IF @@ROWCOUNT = 0 OR (SELECT Balance FROM Accounts WHERE AccountID = @FromAccount) < 0\n        BEGIN\n            THROW 50000, \'Insufficient funds or invalid account\', 1;\n        END\n        \n        -- Deposit to destination account\n        UPDATE Accounts\n        SET Balance = Balance + @Amount\n        WHERE AccountID = @ToAccount;\n        \n        IF @@ROWCOUNT = 0\n        BEGIN\n            THROW 50001, \'Invalid destination account\', 1;\n        END\n        \n        -- Commit transaction if everything succeeded\n        COMMIT TRANSACTION;\n    END TRY\n    BEGIN CATCH\n        -- Rollback transaction on error\n        ROLLBACK TRANSACTION;\n        \n        -- Re-throw the error\n        THROW;\n    END CATCH\nEND;',
              'description': 'This stored procedure demonstrates how to implement a transaction for a funds transfer between accounts. It ensures that both the withdrawal and deposit succeed or fail together. The TRY/CATCH block provides error handling. If any error occurs, the ROLLBACK undoes all changes. If everything succeeds, the COMMIT makes the changes permanent.'
            },
          ],
          'examples': [
            {
              'title': 'Customer Orders Summary Procedure',
              'problem': 'Create a procedure that summarizes order information for a customer',
              'code': 'CREATE PROCEDURE GetCustomerOrderSummary\n    @CustomerID INT\nAS\nBEGIN\n    -- Customer details\n    SELECT CustomerName, Country, City\n    FROM Customers\n    WHERE CustomerID = @CustomerID;\n    \n    -- Order summary\n    SELECT \n        COUNT(OrderID) AS TotalOrders,\n        SUM(TotalAmount) AS TotalSpent,\n        MIN(OrderDate) AS FirstOrderDate,\n        MAX(OrderDate) AS LastOrderDate\n    FROM Orders\n    WHERE CustomerID = @CustomerID;\n    \n    -- Recent orders (last 5)\n    SELECT TOP 5 OrderID, OrderDate, TotalAmount\n    FROM Orders\n    WHERE CustomerID = @CustomerID\n    ORDER BY OrderDate DESC;\nEND;\n\n-- Execute the procedure\nEXEC GetCustomerOrderSummary @CustomerID = 3;',
              'output': '-- Result Set 1: Customer Details\nCustomerName    | Country | City\n----------------------------------\nAntonio Moreno | Mexico  | México D.F.\n\n-- Result Set 2: Order Summary\nTotalOrders | TotalSpent | FirstOrderDate | LastOrderDate\n--------------------------------------------------------\n7           | 4780.00    | 2022-01-15     | 2022-09-19\n\n-- Result Set 3: Recent Orders\nOrderID | OrderDate  | TotalAmount\n----------------------------------\n10309   | 2022-09-19 | 1450.00\n10287   | 2022-08-22 | 819.00\n10273   | 2022-08-05 | 2142.00\n10254   | 2022-07-11 | 182.00\n10231   | 2022-06-14 | 187.00',
              'explanation': 'This stored procedure returns multiple result sets - customer details, an order summary with aggregated statistics, and a list of recent orders. Multiple result sets allow procedures to return related data sets in a single call, reducing round trips to the database. The client application can process each result set as needed.'
            },
            {
              'title': 'Inventory Update Trigger',
              'problem': 'Create a trigger that automatically updates inventory when an order is placed',
              'code': 'CREATE TRIGGER tr_OrderDetails_UpdateInventory\nON OrderDetails\nAFTER INSERT\nAS\nBEGIN\n    -- Update inventory for each inserted product\n    UPDATE p\n    SET p.UnitsInStock = p.UnitsInStock - i.Quantity\n    FROM Products p\n    JOIN inserted i ON p.ProductID = i.ProductID;\n    \n    -- Check if any product now has negative inventory\n    IF EXISTS (\n        SELECT 1 FROM Products\n        WHERE UnitsInStock < 0\n    )\n    BEGIN\n        -- Revert the update and raise an error\n        UPDATE p\n        SET p.UnitsInStock = p.UnitsInStock + i.Quantity\n        FROM Products p\n        JOIN inserted i ON p.ProductID = i.ProductID;\n        \n        THROW 50010, \'Order cannot be fulfilled due to insufficient inventory\', 1;\n    END\n    \n    -- Log low inventory items\n    INSERT INTO InventoryAlerts (ProductID, ProductName, UnitsInStock, AlertDate)\n    SELECT p.ProductID, p.ProductName, p.UnitsInStock, GETDATE()\n    FROM Products p\n    JOIN inserted i ON p.ProductID = i.ProductID\n    WHERE p.UnitsInStock <= p.ReorderLevel;\nEND;',
              'output': '-- When trying to order more products than available in inventory:\nMsg 50010, Level 16, State 1, Procedure tr_OrderDetails_UpdateInventory\nOrder cannot be fulfilled due to insufficient inventory\n\n-- When successfully placing an order for a product with low inventory:\n-- (No direct output, but an entry is added to the InventoryAlerts table)',
              'explanation': 'This trigger fires when new order details are inserted. It first updates the inventory by reducing the units in stock for each product. It then checks if any product now has negative inventory - if so, it reverts the changes and raises an error to prevent the order. Finally, it adds entries to an alerts table for any products that have fallen below their reorder level, helping inventory managers restock promptly.'
            },
            {
              'title': 'Audit Trail Trigger',
              'problem': 'Create a trigger that maintains an audit trail for employee data changes',
              'code': 'CREATE TRIGGER tr_Employees_AuditChanges\nON Employees\nAFTER UPDATE\nAS\nBEGIN\n    INSERT INTO EmployeeChangesLog (\n        EmployeeID,\n        FieldName,\n        OldValue,\n        NewValue,\n        ChangedBy,\n        ChangedDate\n    )\n    SELECT\n        i.EmployeeID,\n        \'Salary\',\n        CONVERT(VARCHAR(100), d.Salary),\n        CONVERT(VARCHAR(100), i.Salary),\n        SYSTEM_USER,\n        GETDATE()\n    FROM inserted i\n    JOIN deleted d ON i.EmployeeID = d.EmployeeID\n    WHERE i.Salary <> d.Salary;\n    \n    INSERT INTO EmployeeChangesLog (\n        EmployeeID,\n        FieldName,\n        OldValue,\n        NewValue,\n        ChangedBy,\n        ChangedDate\n    )\n    SELECT\n        i.EmployeeID,\n        \'Position\',\n        d.Position,\n        i.Position,\n        SYSTEM_USER,\n        GETDATE()\n    FROM inserted i\n    JOIN deleted d ON i.EmployeeID = d.EmployeeID\n    WHERE i.Position <> d.Position;\n    \n    -- Add similar blocks for other important fields\nEND;',
              'output': '-- No direct output, but after an employee update like:\nUPDATE Employees SET Salary = 65000, Position = \'Senior Manager\' WHERE EmployeeID = 3;\n\n-- The EmployeeChangesLog table would contain:\nLogID | EmployeeID | FieldName | OldValue | NewValue      | ChangedBy   | ChangedDate\n---------------------------------------------------------------------------------------\n1001  | 3          | Salary    | 60000    | 65000        | JohnDoe     | 2022-10-15 14:32:45\n1002  | 3          | Position  | Manager  | Senior Manager| JohnDoe     | 2022-10-15 14:32:45',
              'explanation': 'This trigger creates an audit trail by logging changes to sensitive employee data. When an employee record is updated, the trigger compares old and new values for specific fields (Salary and Position in this example). For each changed field, it creates a separate log entry with details about what changed, who made the change, and when. This type of audit trail is essential for regulatory compliance and security in many organizations.'
            },
            {
              'title': 'Stored Procedure with Dynamic SQL',
              'problem': 'Create a flexible search procedure that can filter on multiple optional criteria',
              'code': 'CREATE PROCEDURE SearchProducts\n    @ProductName VARCHAR(100) = NULL,\n    @CategoryID INT = NULL,\n    @MinPrice DECIMAL(10,2) = NULL,\n    @MaxPrice DECIMAL(10,2) = NULL,\n    @InStock BIT = NULL\nAS\nBEGIN\n    DECLARE @SQL NVARCHAR(1000);\n    \n    SET @SQL = N\'SELECT ProductID, ProductName, CategoryName, Price, UnitsInStock \n               FROM Products p \n               JOIN Categories c ON p.CategoryID = c.CategoryID \n               WHERE 1=1\';\n    \n    -- Add optional filters\n    IF @ProductName IS NOT NULL\n        SET @SQL = @SQL + N\' AND ProductName LIKE \'\'%\' + @ProductName + N\'%\'\'\';\n    \n    IF @CategoryID IS NOT NULL\n        SET @SQL = @SQL + N\' AND p.CategoryID = \' + CAST(@CategoryID AS NVARCHAR(10));\n    \n    IF @MinPrice IS NOT NULL\n        SET @SQL = @SQL + N\' AND Price >= \' + CAST(@MinPrice AS NVARCHAR(20));\n    \n    IF @MaxPrice IS NOT NULL\n        SET @SQL = @SQL + N\' AND Price <= \' + CAST(@MaxPrice AS NVARCHAR(20));\n    \n    IF @InStock IS NOT NULL AND @InStock = 1\n        SET @SQL = @SQL + N\' AND UnitsInStock > 0\';\n    \n    -- Add ordering\n    SET @SQL = @SQL + N\' ORDER BY ProductName\';\n    \n    -- Execute the dynamic SQL\n    EXEC sp_executesql @SQL;\nEND;',
              'output': '-- Example call with category and price range:\nEXEC SearchProducts @CategoryID = 1, @MinPrice = 20, @MaxPrice = 50;\n\nProductID | ProductName     | CategoryName | Price | UnitsInStock\n-----------------------------------------------------------------\n5        | Chef Anton\'s Gumbo Mix | Condiments   | 21.35 | 0\n12       | Chai            | Beverages     | 24.00 | 39\n24       | Guaraná Fantástica | Beverages     | 32.00 | 20\n38       | Queso Cabrales  | Dairy Products | 47.00 | 22',
              'explanation': 'This stored procedure demonstrates dynamic SQL - building a SQL query at runtime based on input parameters. This approach allows creating flexible search functionality where any combination of search criteria can be specified. If a parameter is NULL, that filter is omitted. The procedure safely builds the query string and executes it using sp_executesql. Dynamic SQL is powerful but requires careful handling to prevent SQL injection vulnerabilities.'
            },
          ]
        };
      case 'normalization':
        return {
          'title': 'Database Normalization',
          'description': 'Database normalization is a systematic approach to organizing data in a relational database. It involves dividing large tables into smaller, more manageable ones and defining relationships between them to reduce redundancy and improve data integrity. This lesson explains normalization principles and how to apply them in database design.',
          'keyConcepts': [
            {
              'title': 'What is Normalization?',
              'description': 'Normalization is the process of structuring a database to minimize data redundancy and improve data integrity. It involves organizing fields and tables to ensure that dependencies between them are properly enforced. The normalization process follows a series of steps called "normal forms," each building upon the previous ones. The goal is to isolate data so that additions, deletions, and modifications of a field can be made in just one table and then propagated through the rest of the database via defined relationships.'
            },
            {
              'title': 'Why Normalize Databases?',
              'description': 'Normalization provides several important benefits:\n\n• Eliminating data redundancy (the same data stored in multiple places)\n• Reducing update anomalies (inconsistencies that arise when data is updated)\n• Improving query performance for certain types of queries\n• Making the database schema more flexible for future extensions\n• Ensuring data dependencies make logical sense\n\nHowever, a highly normalized database may require more complex queries and joins, which can affect performance for read-heavy applications.'
            },
            {
              'title': 'First Normal Form (1NF)',
              'description': 'A table is in First Normal Form (1NF) if:\n\n• It has a primary key - a column or set of columns that uniquely identifies each row\n• All attributes (columns) contain only atomic (indivisible) values\n• No repeating groups or arrays\n\nFor example, instead of having multiple phone number columns (Phone1, Phone2, Phone3), you would create a separate PhoneNumbers table with a foreign key reference to the main table. 1NF eliminates repeating groups and ensures each cell contains a single value.'
            },
            {
              'title': 'Second Normal Form (2NF)',
              'description': 'A table is in Second Normal Form (2NF) if:\n\n• It is already in 1NF\n• All non-key attributes are fully functionally dependent on the entire primary key, not just part of it\n\nThis is particularly important for tables with composite primary keys (keys consisting of multiple columns). If some columns depend only on part of the primary key, those columns should be moved to a separate table. 2NF eliminates partial dependencies.'
            },
            {
              'title': 'Third Normal Form (3NF)',
              'description': 'A table is in Third Normal Form (3NF) if:\n\n• It is already in 2NF\n• No non-key attribute depends on another non-key attribute (no transitive dependencies)\n\nFor example, if a table contains CustomerID, CustomerZIP, and CustomerCity, and the city is determined by the ZIP code (not directly by the CustomerID), then CustomerCity should be moved to a separate table with ZIP as the primary key. 3NF eliminates transitive dependencies.'
            },
            {
              'title': 'Other Normal Forms',
              'description': 'There are additional normal forms beyond 3NF, including:\n\n• Boyce-Codd Normal Form (BCNF): A stricter version of 3NF that deals with certain types of anomalies not addressed by 3NF\n• Fourth Normal Form (4NF): Addresses multi-valued dependencies\n• Fifth Normal Form (5NF): Deals with join dependencies\n\nHowever, most database designs aim for 3NF or BCNF as sufficient levels of normalization, as higher normal forms can make the database structure overly complex with diminishing returns in terms of data integrity.'
            },
            {
              'title': 'Denormalization',
              'description': 'Denormalization is the process of intentionally adding redundancy to a normalized database design to improve read performance. This might involve combining tables, adding redundant columns, or pre-calculating values. Denormalization is typically done after normalization, based on specific performance requirements and query patterns. It trades some data integrity and storage efficiency for query speed and simplicity.'
            },
          ],
          'syntax': [
            {
              'title': 'Creating Normalized Tables',
              'code': '-- Unnormalized table (poor design)\nCREATE TABLE Orders_Unnormalized (\n    OrderID INT PRIMARY KEY,\n    CustomerName VARCHAR(100),\n    CustomerEmail VARCHAR(100),\n    CustomerAddress VARCHAR(200),\n    Product1 VARCHAR(100),\n    Product1Quantity INT,\n    Product1Price DECIMAL(10,2),\n    Product2 VARCHAR(100),\n    Product2Quantity INT,\n    Product2Price DECIMAL(10,2),\n    OrderDate DATE\n);\n\n-- Normalized tables (3NF)\nCREATE TABLE Customers (\n    CustomerID INT PRIMARY KEY,\n    Name VARCHAR(100),\n    Email VARCHAR(100),\n    Address VARCHAR(200)\n);\n\nCREATE TABLE Products (\n    ProductID INT PRIMARY KEY,\n    Name VARCHAR(100),\n    Price DECIMAL(10,2)\n);\n\nCREATE TABLE Orders (\n    OrderID INT PRIMARY KEY,\n    CustomerID INT,\n    OrderDate DATE,\n    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)\n);\n\nCREATE TABLE OrderDetails (\n    OrderDetailID INT PRIMARY KEY,\n    OrderID INT,\n    ProductID INT,\n    Quantity INT,\n    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),\n    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)\n);',
              'description': 'This example shows the transformation from an unnormalized table design to a normalized one. The unnormalized design has several problems:\n\n• Repeating groups (Product1, Product2, etc.)\n• No way to add more than two products without changing the schema\n• Customer information is repeated for every order\n\nThe normalized design addresses these issues by creating separate tables for Customers, Products, Orders, and OrderDetails. This structure allows:\n\n• Any number of products per order\n• Customer information to be stored once and referenced by multiple orders\n• Product information to be stored once and referenced by multiple order details'
            },
            {
              'title': 'Querying Normalized Tables',
              'code': '-- Simple query on unnormalized table\nSELECT OrderID, CustomerName, Product1, Product1Quantity\nFROM Orders_Unnormalized\nWHERE CustomerName = \'John Smith\';\n\n-- Equivalent query on normalized tables\nSELECT o.OrderID, c.Name, p.Name AS ProductName, od.Quantity\nFROM Orders o\nJOIN Customers c ON o.CustomerID = c.CustomerID\nJOIN OrderDetails od ON o.OrderID = od.OrderID\nJOIN Products p ON od.ProductID = p.ProductID\nWHERE c.Name = \'John Smith\';',
              'description': 'Querying normalized tables often requires joins to bring related data back together. While the normalized query looks more complex, it offers greater flexibility and maintainability. For example, if you need to find all orders for a specific product, the normalized structure makes this easy, whereas the unnormalized structure would require checking multiple columns (Product1, Product2, etc.) for each order.'
            },
            {
              'title': 'Adding Data to Normalized Tables',
              'code': '-- Insert data into normalized tables\nINSERT INTO Customers (CustomerID, Name, Email, Address)\nVALUES (1, \'John Smith\', \'john@example.com\', \'123 Main St\');\n\nINSERT INTO Products (ProductID, Name, Price)\nVALUES (1, \'Laptop\', 999.99),\n       (2, \'Mouse\', 24.99);\n\nINSERT INTO Orders (OrderID, CustomerID, OrderDate)\nVALUES (1, 1, \'2022-10-15\');\n\nINSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)\nVALUES (1, 1, 1, 1),  -- 1 Laptop\n       (2, 1, 2, 2);  -- 2 Mice',
              'description': 'Adding data to normalized tables requires inserting records into multiple tables and establishing the relationships between them. While this is more complex than inserting into a single unnormalized table, it provides better data integrity. For example, if a customer places multiple orders, their information is stored only once in the Customers table, reducing redundancy and potential inconsistencies.'
            },
            {
              'title': 'Updating Data in Normalized Tables',
              'code': '-- Update customer address\nUPDATE Customers\nSET Address = \'456 Oak Avenue\'\nWHERE CustomerID = 1;\n\n-- Update product price\nUPDATE Products\nSET Price = 899.99\nWHERE ProductID = 1;\n\n-- Update order quantity\nUPDATE OrderDetails\nSET Quantity = 3\nWHERE OrderID = 1 AND ProductID = 2;',
              'description': 'Updating data in normalized tables is much more straightforward and less error-prone. If a customer changes their address, you update it in one place (the Customers table), and the change is automatically reflected for all of their orders. Similarly, if a product\'s price changes, you update it once in the Products table. This eliminates the risk of inconsistent data that would exist in an unnormalized design.'
            },
            {
              'title': 'Denormalization Example',
              'code': '-- Create a denormalized view for reporting\nCREATE VIEW OrderReport AS\nSELECT \n    o.OrderID,\n    o.OrderDate,\n    c.CustomerID,\n    c.Name AS CustomerName,\n    c.Email AS CustomerEmail,\n    p.ProductID,\n    p.Name AS ProductName,\n    p.Price AS UnitPrice,\n    od.Quantity,\n    (p.Price * od.Quantity) AS TotalPrice\nFROM Orders o\nJOIN Customers c ON o.CustomerID = c.CustomerID\nJOIN OrderDetails od ON o.OrderID = od.OrderID\nJOIN Products p ON od.ProductID = p.ProductID;\n\n-- Or create a denormalized table for performance\nCREATE TABLE OrderSummary (\n    OrderID INT,\n    OrderDate DATE,\n    CustomerName VARCHAR(100),\n    TotalItems INT,\n    TotalValue DECIMAL(12,2),\n    PRIMARY KEY (OrderID)\n);\n\n-- Populate/update with a trigger\nCREATE TRIGGER tr_Orders_UpdateSummary\nON OrderDetails\nAFTER INSERT, UPDATE, DELETE\nAS\nBEGIN\n    -- Update order summary for affected orders\n    /* Trigger implementation details */\nEND;',
              'description': 'Denormalization can be implemented using views or materialized tables. A view provides a denormalized perspective while maintaining the normalized underlying structure. A materialized denormalized table can offer better performance for complex reports but requires mechanisms (like triggers) to keep it synchronized with the normalized tables. Denormalization decisions should be based on specific performance requirements and usage patterns.'
            },
          ],
          'examples': [
            {
              'title': 'Converting to First Normal Form (1NF)',
              'problem': 'Convert a table with repeating groups to First Normal Form',
              'code': '-- Original table with repeating groups\nCREATE TABLE StudentCourses (\n    StudentID INT,\n    StudentName VARCHAR(100),\n    Course1 VARCHAR(50),\n    Course2 VARCHAR(50),\n    Course3 VARCHAR(50),\n    PRIMARY KEY (StudentID)\n);\n\n-- Insert sample data\nINSERT INTO StudentCourses VALUES\n(1, \'Alice\', \'Math\', \'Physics\', \'Chemistry\'),\n(2, \'Bob\', \'Biology\', \'Chemistry\', NULL),\n(3, \'Charlie\', \'Physics\', NULL, NULL);\n\n-- 1NF solution: Remove repeating groups\nCREATE TABLE Students (\n    StudentID INT PRIMARY KEY,\n    StudentName VARCHAR(100)\n);\n\nCREATE TABLE StudentCoursesMapping (\n    MappingID INT PRIMARY KEY,\n    StudentID INT,\n    Course VARCHAR(50),\n    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)\n);\n\n-- Insert the same data in 1NF\nINSERT INTO Students VALUES\n(1, \'Alice\'),\n(2, \'Bob\'),\n(3, \'Charlie\');\n\nINSERT INTO StudentCoursesMapping VALUES\n(1, 1, \'Math\'),\n(2, 1, \'Physics\'),\n(3, 1, \'Chemistry\'),\n(4, 2, \'Biology\'),\n(5, 2, \'Chemistry\'),\n(6, 3, \'Physics\');',
              'output': '-- Query on original table\nSELECT * FROM StudentCourses;\n\nStudentID | StudentName | Course1  | Course2  | Course3\n----------------------------------------------------------\n1         | Alice       | Math     | Physics  | Chemistry\n2         | Bob         | Biology  | Chemistry| NULL\n3         | Charlie     | Physics  | NULL     | NULL\n\n-- Query on 1NF tables\nSELECT s.StudentID, s.StudentName, scm.Course\nFROM Students s\nJOIN StudentCoursesMapping scm ON s.StudentID = scm.StudentID\nORDER BY s.StudentID, scm.Course;\n\nStudentID | StudentName | Course\n-----------------------------------\n1         | Alice       | Chemistry\n1         | Alice       | Math\n1         | Alice       | Physics\n2         | Bob         | Biology\n2         | Bob         | Chemistry\n3         | Charlie     | Physics',
              'explanation': 'This example demonstrates converting a table with repeating groups (Course1, Course2, Course3) to First Normal Form. The original design had several problems:\n\n• Limited to a maximum of three courses per student\n• NULL values for students with fewer courses\n• Difficult to query for specific courses\n\nThe 1NF solution creates a separate mapping table that allows:\n\n• Any number of courses per student\n• No NULL values for unused course slots\n• Easy querying for specific courses\n\nThe trade-off is slightly more complex data insertion and the need for joins when querying student courses, but the benefits in flexibility and data integrity outweigh these disadvantages.'
            },
            {
              'title': 'Converting to Second Normal Form (2NF)',
              'problem': 'Convert a table with partial dependencies to Second Normal Form',
              'code': '-- Table in 1NF but not in 2NF\nCREATE TABLE OrderProducts (\n    OrderID INT,\n    ProductID INT,\n    ProductName VARCHAR(100),\n    ProductCategory VARCHAR(50),\n    Quantity INT,\n    OrderDate DATE,\n    CustomerID INT,\n    PRIMARY KEY (OrderID, ProductID)\n);\n\n-- Insert sample data\nINSERT INTO OrderProducts VALUES\n(1, 101, \'Laptop\', \'Electronics\', 1, \'2022-10-15\', 201),\n(1, 102, \'Mouse\', \'Electronics\', 2, \'2022-10-15\', 201),\n(2, 101, \'Laptop\', \'Electronics\', 1, \'2022-10-16\', 202);\n\n-- 2NF solution: Remove partial dependencies\nCREATE TABLE Orders (\n    OrderID INT PRIMARY KEY,\n    OrderDate DATE,\n    CustomerID INT\n);\n\nCREATE TABLE Products (\n    ProductID INT PRIMARY KEY,\n    ProductName VARCHAR(100),\n    ProductCategory VARCHAR(50)\n);\n\nCREATE TABLE OrderDetails (\n    OrderID INT,\n    ProductID INT,\n    Quantity INT,\n    PRIMARY KEY (OrderID, ProductID),\n    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),\n    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)\n);\n\n-- Insert the same data in 2NF\nINSERT INTO Orders VALUES\n(1, \'2022-10-15\', 201),\n(2, \'2022-10-16\', 202);\n\nINSERT INTO Products VALUES\n(101, \'Laptop\', \'Electronics\'),\n(102, \'Mouse\', \'Electronics\');\n\nINSERT INTO OrderDetails VALUES\n(1, 101, 1),\n(1, 102, 2),\n(2, 101, 1);',
              'output': '-- Query on 1NF table\nSELECT * FROM OrderProducts;\n\nOrderID | ProductID | ProductName | ProductCategory | Quantity | OrderDate  | CustomerID\n-----------------------------------------------------------------------------------\n1       | 101       | Laptop      | Electronics     | 1        | 2022-10-15 | 201\n1       | 102       | Mouse       | Electronics     | 2        | 2022-10-15 | 201\n2       | 101       | Laptop      | Electronics     | 1        | 2022-10-16 | 202\n\n-- Query on 2NF tables\nSELECT o.OrderID, p.ProductID, p.ProductName, p.ProductCategory, od.Quantity, o.OrderDate, o.CustomerID\nFROM Orders o\nJOIN OrderDetails od ON o.OrderID = od.OrderID\nJOIN Products p ON od.ProductID = p.ProductID;\n\nOrderID | ProductID | ProductName | ProductCategory | Quantity | OrderDate  | CustomerID\n-----------------------------------------------------------------------------------\n1       | 101       | Laptop      | Electronics     | 1        | 2022-10-15 | 201\n1       | 102       | Mouse       | Electronics     | 2        | 2022-10-15 | 201\n2       | 101       | Laptop      | Electronics     | 1        | 2022-10-16 | 202',
              'explanation': 'This example demonstrates converting a table with partial dependencies to Second Normal Form. In the original table, the primary key is the combination of OrderID and ProductID, but:\n\n• ProductName and ProductCategory depend only on ProductID, not on the full primary key\n• OrderDate and CustomerID depend only on OrderID, not on the full primary key\n\nThese partial dependencies can cause anomalies:\n\n• Update anomalies: If a product name changes, it must be updated in multiple rows\n• Insert anomalies: Can\'t add a new product without an order\n• Delete anomalies: Deleting an order might lose product information\n\nThe 2NF solution creates separate tables for Orders, Products, and OrderDetails, eliminating these partial dependencies and their associated anomalies.'
            },
            {
              'title': 'Converting to Third Normal Form (3NF)',
              'problem': 'Convert a table with transitive dependencies to Third Normal Form',
              'code': '-- Table in 2NF but not in 3NF\nCREATE TABLE Employees (\n    EmployeeID INT PRIMARY KEY,\n    Name VARCHAR(100),\n    DepartmentID INT,\n    DepartmentName VARCHAR(100),\n    DepartmentLocation VARCHAR(100)\n);\n\n-- Insert sample data\nINSERT INTO Employees VALUES\n(1, \'Alice Smith\', 10, \'Engineering\', \'Building A\'),\n(2, \'Bob Johnson\', 10, \'Engineering\', \'Building A\'),\n(3, \'Charlie Brown\', 20, \'Marketing\', \'Building B\');\n\n-- 3NF solution: Remove transitive dependencies\nCREATE TABLE Departments (\n    DepartmentID INT PRIMARY KEY,\n    DepartmentName VARCHAR(100),\n    Location VARCHAR(100)\n);\n\nCREATE TABLE Employees3NF (\n    EmployeeID INT PRIMARY KEY,\n    Name VARCHAR(100),\n    DepartmentID INT,\n    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)\n);\n\n-- Insert the same data in 3NF\nINSERT INTO Departments VALUES\n(10, \'Engineering\', \'Building A\'),\n(20, \'Marketing\', \'Building B\');\n\nINSERT INTO Employees3NF VALUES\n(1, \'Alice Smith\', 10),\n(2, \'Bob Johnson\', 10),\n(3, \'Charlie Brown\', 20);',
              'output': '-- Query on 2NF table\nSELECT * FROM Employees;\n\nEmployeeID | Name          | DepartmentID | DepartmentName | DepartmentLocation\n-------------------------------------------------------------------------------\n1          | Alice Smith   | 10           | Engineering    | Building A\n2          | Bob Johnson   | 10           | Engineering    | Building A\n3          | Charlie Brown | 20           | Marketing      | Building B\n\n-- Query on 3NF tables\nSELECT e.EmployeeID, e.Name, e.DepartmentID, d.DepartmentName, d.Location\nFROM Employees3NF e\nJOIN Departments d ON e.DepartmentID = d.DepartmentID;\n\nEmployeeID | Name          | DepartmentID | DepartmentName | Location\n-----------------------------------------------------------------------\n1          | Alice Smith   | 10           | Engineering    | Building A\n2          | Bob Johnson   | 10           | Engineering    | Building A\n3          | Charlie Brown | 20           | Marketing      | Building B',
              'explanation': 'This example demonstrates converting a table with transitive dependencies to Third Normal Form. In the original table:\n\n• EmployeeID is the primary key\n• DepartmentName and DepartmentLocation depend on DepartmentID, not directly on EmployeeID\n\nThis creates a transitive dependency: EmployeeID → DepartmentID → DepartmentName/Location\n\nThese transitive dependencies can cause problems:\n\n• If a department moves to a new location, multiple employee records must be updated\n• Inconsistencies can arise if one employee\'s department location is updated but others are missed\n\nThe 3NF solution creates a separate Departments table, removing these transitive dependencies and ensuring department information is stored in only one place.'
            },
            {
              'title': 'Denormalization for Performance',
              'problem': 'Create a denormalized data structure for reporting performance',
              'code': '-- Normalized database structure (3NF)\nCREATE TABLE Customers (\n    CustomerID INT PRIMARY KEY,\n    Name VARCHAR(100),\n    Email VARCHAR(100)\n);\n\nCREATE TABLE Products (\n    ProductID INT PRIMARY KEY,\n    Name VARCHAR(100),\n    Category VARCHAR(50),\n    Price DECIMAL(10,2)\n);\n\nCREATE TABLE Orders (\n    OrderID INT PRIMARY KEY,\n    CustomerID INT,\n    OrderDate DATE,\n    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)\n);\n\nCREATE TABLE OrderDetails (\n    OrderDetailID INT PRIMARY KEY,\n    OrderID INT,\n    ProductID INT,\n    Quantity INT,\n    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),\n    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)\n);\n\n-- Denormalized reporting table\nCREATE TABLE SalesReport (\n    ReportID INT PRIMARY KEY,\n    OrderID INT,\n    OrderDate DATE,\n    CustomerID INT,\n    CustomerName VARCHAR(100),\n    ProductID INT,\n    ProductName VARCHAR(100),\n    ProductCategory VARCHAR(50),\n    UnitPrice DECIMAL(10,2),\n    Quantity INT,\n    TotalAmount DECIMAL(12,2),\n    YearMonth VARCHAR(7)  -- e.g., \'2022-10\'\n);\n\n-- Populate the reporting table\nINSERT INTO SalesReport\nSELECT \n    ROW_NUMBER() OVER (ORDER BY o.OrderID, p.ProductID) AS ReportID,\n    o.OrderID,\n    o.OrderDate,\n    c.CustomerID,\n    c.Name AS CustomerName,\n    p.ProductID,\n    p.Name AS ProductName,\n    p.Category AS ProductCategory,\n    p.Price AS UnitPrice,\n    od.Quantity,\n    (p.Price * od.Quantity) AS TotalAmount,\n    FORMAT(o.OrderDate, \'yyyy-MM\') AS YearMonth\nFROM Orders o\nJOIN Customers c ON o.CustomerID = c.CustomerID\nJOIN OrderDetails od ON o.OrderID = od.OrderID\nJOIN Products p ON od.ProductID = p.ProductID;',
              'output': '-- Complex query on normalized tables\nSELECT \n    FORMAT(o.OrderDate, \'yyyy-MM\') AS YearMonth,\n    p.Category,\n    SUM(p.Price * od.Quantity) AS TotalSales\nFROM Orders o\nJOIN OrderDetails od ON o.OrderID = od.OrderID\nJOIN Products p ON od.ProductID = p.ProductID\nWHERE o.OrderDate BETWEEN \'2022-01-01\' AND \'2022-12-31\'\nGROUP BY FORMAT(o.OrderDate, \'yyyy-MM\'), p.Category\nORDER BY YearMonth, TotalSales DESC;\n\n-- Same query on denormalized table (much simpler and faster)\nSELECT \n    YearMonth,\n    ProductCategory,\n    SUM(TotalAmount) AS TotalSales\nFROM SalesReport\nWHERE OrderDate BETWEEN \'2022-01-01\' AND \'2022-12-31\'\nGROUP BY YearMonth, ProductCategory\nORDER BY YearMonth, TotalSales DESC;',
              'explanation': 'This example demonstrates denormalization for reporting performance. While the normalized structure (3NF) is excellent for transactional operations and data integrity, complex analytical queries involving multiple joins can be slow, especially on large datasets.\n\nThe denormalized SalesReport table combines data from multiple normalized tables and pre-calculates common values (TotalAmount, YearMonth). This makes reporting queries simpler and faster, as they require fewer joins and calculations.\n\nThe trade-offs include:\n• Data redundancy (customer and product information is duplicated)\n• More storage space required\n• Need to keep the denormalized table synchronized with the normalized tables\n\nFor a read-heavy reporting system, these trade-offs are often acceptable given the significant performance benefits.'
            },
          ]
        };
      // Add more cases as needed for other lessons
      default:
        // Default content if lesson ID is not recognized
        return {
          'title': widget.lesson.title,
          'description': widget.lesson.description,
          'keyConcepts': [
            {
              'title': 'Coming Soon',
              'description': 'This lesson content is under development. Please check back later for updates.'
            },
          ],
          'syntax': [
            {
              'title': 'Basic Syntax',
              'code': '-- Example code will be provided soon',
              'description': 'Detailed syntax examples will be available shortly.'
            },
          ],
          'examples': [
            {
              'title': 'Example 1',
              'problem': 'Sample problem description',
              'code': '-- Example SQL code',
              'output': '-- Expected output',
              'explanation': 'Detailed explanation will be provided soon.'
            },
          ]
        };
    }
  }
  
  List<Map<String, dynamic>> _getExercises() {
    // Provide exercises based on lesson ID
    switch (widget.lesson.id) {
      case 'basics':
        return [
          {
            'title': 'Basic SELECT Exercise',
            'description': 'Retrieve all employee names and their positions from the Employees table.',
            'hint': 'Use the SELECT statement to specify which columns you want to retrieve.',
            'initialCode': 'SELECT ? FROM Employees;',
            'solutionCode': 'SELECT FirstName, LastName, Position FROM Employees;',
            'testCases': [
              {
                'input': 'Sample Employees table: \nEmployeeID | FirstName | LastName | Position | Salary\n1 | John | Doe | Manager | 60000\n2 | Jane | Smith | Developer | 75000\n3 | Bob | Johnson | Designer | 55000',
                'expectedOutput': 'FirstName | LastName | Position\nJohn | Doe | Manager\nJane | Smith | Developer\nBob | Johnson | Designer'
              }
            ]
          },
          {
            'title': 'Filtered SELECT Exercise',
            'description': 'Retrieve all products with a price greater than \$50.',
            'hint': 'Use the WHERE clause to filter the results based on a condition.',
            'initialCode': 'SELECT ? FROM Products\nWHERE ?;',
            'solutionCode': 'SELECT ProductName, Price FROM Products\nWHERE Price > 50;',
            'testCases': [
              {
                'input': 'Sample Products table: \nProductID | ProductName | Price\n1 | Laptop | 800\n2 | Mouse | 25\n3 | Keyboard | 55\n4 | Monitor | 150\n5 | Headphones | 30',
                'expectedOutput': 'ProductName | Price\nLaptop | 800\nKeyboard | 55\nMonitor | 150'
              }
            ]
          },
          {
            'title': 'INSERT Exercise',
            'description': 'Insert a new product into the Products table.',
            'hint': 'Use the INSERT INTO statement followed by the column names and values.',
            'initialCode': 'INSERT INTO ? \n(?, ?, ?)\nVALUES (?, ?, ?);',
            'solutionCode': 'INSERT INTO Products \n(ProductName, Price, Category)\nVALUES (\'Printer\', 120, \'Electronics\');',
            'testCases': [
              {
                'input': 'Before insertion - Products table: \nProductID | ProductName | Price | Category\n1 | Laptop | 800 | Electronics\n2 | Mouse | 25 | Electronics',
                'expectedOutput': '1 row(s) affected\n\nAfter insertion - Products table: \nProductID | ProductName | Price | Category\n1 | Laptop | 800 | Electronics\n2 | Mouse | 25 | Electronics\n3 | Printer | 120 | Electronics'
              }
            ]
          },
        ];
      case 'queries_joins':
        return [
          {
            'title': 'Basic INNER JOIN Exercise',
            'description': 'Retrieve order information along with customer details.',
            'hint': 'Use INNER JOIN to combine data from Orders and Customers tables based on CustomerID.',
            'initialCode': 'SELECT ?\nFROM Orders\nINNER JOIN Customers\nON ?;',
            'solutionCode': 'SELECT Orders.OrderID, Customers.CustomerName, Orders.OrderDate\nFROM Orders\nINNER JOIN Customers\nON Orders.CustomerID = Customers.CustomerID;',
            'testCases': [
              {
                'input': 'Orders table: \nOrderID | CustomerID | OrderDate\n1 | 3 | 2023-01-15\n2 | 1 | 2023-01-16\n3 | 2 | 2023-01-20\n\nCustomers table: \nCustomerID | CustomerName | Country\n1 | John Smith | USA\n2 | Maria Garcia | Mexico\n3 | Liu Wei | China',
                'expectedOutput': 'OrderID | CustomerName | OrderDate\n-------------------------------------------\n10308   | Ana Trujillo     | 2023-01-15\n10309   | Antonio Moreno   | 2023-01-16\n10310   | Liu Wei          | 2023-01-20'
              }
            ]
          },
          {
            'title': 'Multi-table JOIN Exercise',
            'description': 'Retrieve order details including product names and customer information.',
            'hint': 'Use multiple JOINs to connect Orders, OrderDetails, Products, and Customers tables.',
            'initialCode': 'SELECT ?\nFROM Orders\nINNER JOIN ? ON ?\nINNER JOIN ? ON ?\nINNER JOIN ? ON ?;',
            'solutionCode': 'SELECT Orders.OrderID, Customers.CustomerName, Products.ProductName, OrderDetails.Quantity\nFROM Orders\nINNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID\nINNER JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID\nINNER JOIN Products ON OrderDetails.ProductID = Products.ProductID;',
            'testCases': [
              {
                'input': 'Sample tables structure shown in hint',
                'expectedOutput': 'OrderID | CustomerName | ProductName | Quantity\n1 | Liu Wei | Laptop | 1\n1 | Liu Wei | Mouse | 2\n2 | John Smith | Monitor | 1'
              }
            ]
          },
        ];
      // Add more cases for other lessons
      default:
        return [
          {
            'title': 'Sample Exercise',
            'description': 'This is a placeholder exercise. More exercises will be added soon.',
            'hint': 'No specific hint required for this example.',
            'initialCode': '-- Write your SQL query here',
            'solutionCode': '-- Sample solution',
            'testCases': [
              {
                'input': 'Sample input data',
                'expectedOutput': 'Expected output after running the query'
              }
            ]
          },
        ];
    }
  }
} 

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 0.5;
    final spacing = 20.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}