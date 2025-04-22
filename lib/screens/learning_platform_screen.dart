import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/sql_lesson.dart';
import '../widgets/lesson_card.dart';

class LearningPlatformScreen extends StatefulWidget {
  const LearningPlatformScreen({Key? key}) : super(key: key);

  @override
  State<LearningPlatformScreen> createState() => _LearningPlatformScreenState();
}

class _LearningPlatformScreenState extends State<LearningPlatformScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _queryResult = '';
  bool _isExecuting = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sample SQL lessons
    final List<SQLLesson> lessons = [
      SQLLesson(
        id: 'basics',
        title: 'SQL Basics',
        description: 'Learn the fundamentals of SQL including SELECT, INSERT, UPDATE, and DELETE statements.',
        animationAsset: 'assets/animations/sql_animation.json',
        difficulty: 'Beginner',
      ),
      SQLLesson(
        id: 'queries_joins',
        title: 'Queries & Joins',
        description: 'Master complex queries and different types of JOINs in SQL.',
        animationAsset: 'assets/animations/sql_animation.json',
        difficulty: 'Intermediate',
      ),
      SQLLesson(
        id: 'stored_procedures',
        title: 'Stored Procedures & Triggers',
        description: 'Learn how to create and use stored procedures and triggers in SQL.',
        animationAsset: 'assets/animations/sql_animation.json',
        difficulty: 'Advanced',
      ),
      SQLLesson(
        id: 'normalization',
        title: 'Database Normalization',
        description: 'Understand the principles of database normalization and how to implement them.',
        animationAsset: 'assets/animations/sql_animation.json',
        difficulty: 'Intermediate',
      ),
      SQLLesson(
        id: 'transactions',
        title: 'Transactions & Indexing',
        description: 'Learn about transactions, concurrency control, and indexing in SQL databases.',
        animationAsset: 'assets/animations/sql_animation.json',
        difficulty: 'Advanced',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Learning Platform'),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.blue.shade100,
            child: Stack(
              children: [
                Lottie.asset(
                  'assets/animations/sql_animation.json',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interactive SQL Learning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Master SQL with animated lessons, examples, and hands-on coding challenges.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                return LessonCard(lesson: lessons[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showPracticeDialog(context);
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.code),
        label: const Text('SQL Practice'),
        tooltip: 'Open SQL Practice Environment',
      ),
    );
  }

  void _showPracticeDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.code,
              color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            const Text('SQL Practice Environment'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write and execute SQL queries to practice your skills:',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _queryController,
                  maxLines: 5,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 15,
                    color: isDarkMode ? Colors.greenAccent : Colors.blue.shade900,
                  ),
                  decoration: InputDecoration(
                    hintText: 'SELECT * FROM Customers WHERE Country = "USA";',
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isExecuting ? null : () {
                    setState(() {
                      _isExecuting = true;
                    });
                    
                    // Simulate SQL execution
                    Future.delayed(const Duration(milliseconds: 800), () {
                      final query = _queryController.text.trim().toLowerCase();
                      
                      String result = '';
                      if (query.contains('select') && query.contains('from')) {
                        if (query.contains('customers')) {
                          result = 'CustomerID | CustomerName | Country\n----------------------------------\n1 | John Smith | USA\n2 | Maria Garcia | Mexico\n3 | Liu Wei | China';
                        } else if (query.contains('products')) {
                          result = 'ProductID | ProductName | Price\n--------------------------------\n1 | Laptop | 800\n2 | Mouse | 25\n3 | Keyboard | 55';
                        } else if (query.contains('orders')) {
                          result = 'OrderID | CustomerID | OrderDate\n----------------------------------\n1 | 3 | 2023-01-15\n2 | 1 | 2023-01-16\n3 | 2 | 2023-01-20';
                        } else {
                          result = 'Table not found. Available tables: Customers, Products, Orders';
                        }
                      } else if (query.contains('insert') && query.contains('into')) {
                        result = '1 row(s) affected';
                      } else if (query.contains('update') && query.contains('set')) {
                        result = '2 row(s) affected';
                      } else if (query.contains('delete') && query.contains('from')) {
                        result = '1 row(s) affected';
                      } else {
                        result = 'Invalid SQL query. Try using SELECT, INSERT, UPDATE, or DELETE statements.';
                      }
                      
                      setState(() {
                        _queryResult = result;
                        _isExecuting = false;
                      });
                      
                      // Rebuild the dialog with the updated result
                      Navigator.of(context).pop();
                      _showPracticeDialog(context);
                    });
                  },
                  icon: _isExecuting 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('EXECUTE QUERY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Results:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                  child: _queryResult.isEmpty
                      ? Center(
                          child: Text(
                            'Results will appear here after execution',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _queryResult,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 14,
                              color: isDarkMode ? Colors.greenAccent : Colors.blue.shade900,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available tables: Customers, Products, Orders, OrderDetails',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
} 