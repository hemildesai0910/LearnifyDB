import 'package:flutter/material.dart';

class SQLQueryEditor extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final String lessonTitle;

  const SQLQueryEditor({
    Key? key,
    required this.exercises,
    required this.lessonTitle,
  }) : super(key: key);

  @override
  State<SQLQueryEditor> createState() => _SQLQueryEditorState();
}

class _SQLQueryEditorState extends State<SQLQueryEditor> {
  final TextEditingController _queryController = TextEditingController();
  String _resultOutput = '';
  String _errorOutput = '';
  bool _isExecuting = false;
  int _currentExerciseIndex = 0;
  bool _showSolution = false;
  bool _exerciseCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercises.isNotEmpty) {
      _queryController.text = widget.exercises[_currentExerciseIndex]['initialCode'];
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _executeQuery() {
    setState(() {
      _isExecuting = true;
      _errorOutput = '';
    });

    // Simulate query execution with a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _processQueryResult();
    });
  }

  void _processQueryResult() {
    // Get current exercise
    final exercise = widget.exercises[_currentExerciseIndex];
    final userQuery = _queryController.text.trim();
    
    // Very simple SQL validator - this could be expanded with a real SQL parser
    if (userQuery.isEmpty) {
      setState(() {
        _isExecuting = false;
        _errorOutput = 'Query cannot be empty';
        _resultOutput = '';
      });
      return;
    }

    // Compare with test cases
    final testCase = exercise['testCases'][0];
    final solutionQuery = exercise['solutionCode'];
    
    // Check if the query seems correct (simple string comparison)
    // In a real app, you'd want to use a proper SQL parser to check semantics, not just syntax
    bool isCorrect = _checkQueryCorrectness(userQuery, solutionQuery);
    
    if (isCorrect) {
      setState(() {
        _isExecuting = false;
        _resultOutput = testCase['expectedOutput'];
        _exerciseCompleted = true;
        _errorOutput = '';
      });
    } else {
      setState(() {
        _isExecuting = false;
        // Show a helpful error message
        _errorOutput = 'Your query didn\'t produce the expected output. Try again!';
        _resultOutput = 'Expected:\n${testCase['expectedOutput']}\n\nYour query produced different results.';
      });
    }
  }

  bool _checkQueryCorrectness(String userQuery, String solutionQuery) {
    // Remove comments, extra spaces, and make case-insensitive for comparison
    String normalizedUserQuery = _normalizeQuery(userQuery);
    String normalizedSolutionQuery = _normalizeQuery(solutionQuery);
    
    // Very simple check - in a real app, this would be much more sophisticated
    // using actual SQL parsing and execution
    
    // If the queries are exactly the same after normalization
    if (normalizedUserQuery == normalizedSolutionQuery) {
      return true;
    }
    
    // If the user's query is close enough to the solution
    // For example, if the only difference is in the column order
    // or similar non-functional aspects
    
    // For simplicity, we'll check if the query contains the main keywords
    // from the solution (very basic approach)
    List<String> solutionKeywords = _extractKeywords(normalizedSolutionQuery);
    List<String> userKeywords = _extractKeywords(normalizedUserQuery);
    
    // Check if user query contains all important keywords from solution
    if (solutionKeywords.every((keyword) => userKeywords.contains(keyword))) {
      // Additional check: if query has placeholders, it's not correct yet
      if (userQuery.contains('?')) {
        return false;
      }
      return true;
    }
    
    return false;
  }
  
  String _normalizeQuery(String query) {
    // Remove comments
    query = query.replaceAll(RegExp(r'--.*$', multiLine: true), '');
    // Remove extra whitespace
    query = query.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Make case-insensitive
    return query.toLowerCase();
  }
  
  List<String> _extractKeywords(String query) {
    // Extract important SQL keywords and table/column names
    // This is a very simplified approach
    final importantKeywords = [
      'select', 'from', 'where', 'join', 'group by', 'order by',
      'insert into', 'values', 'update', 'delete from'
    ];
    
    List<String> foundKeywords = [];
    for (var keyword in importantKeywords) {
      if (query.contains(keyword)) {
        foundKeywords.add(keyword);
      }
    }
    
    // Extract table names (very simple approach)
    final tableMatches = RegExp(r'from\s+([a-z0-9_]+)', caseSensitive: false).allMatches(query);
    for (var match in tableMatches) {
      if (match.groupCount >= 1) {
        foundKeywords.add(match.group(1)!.toLowerCase());
      }
    }
    
    return foundKeywords;
  }

  void _resetExercise() {
    setState(() {
      _queryController.text = widget.exercises[_currentExerciseIndex]['initialCode'];
      _resultOutput = '';
      _errorOutput = '';
      _exerciseCompleted = false;
      _showSolution = false;
    });
  }

  void _showHint() {
    final hint = widget.exercises[_currentExerciseIndex]['hint'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hint),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'CLOSE',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _revealSolution() {
    setState(() {
      _showSolution = true;
      _queryController.text = widget.exercises[_currentExerciseIndex]['solutionCode'];
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _queryController.text = widget.exercises[_currentExerciseIndex]['initialCode'];
        _resultOutput = '';
        _errorOutput = '';
        _exerciseCompleted = false;
        _showSolution = false;
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _queryController.text = widget.exercises[_currentExerciseIndex]['initialCode'];
        _resultOutput = '';
        _errorOutput = '';
        _exerciseCompleted = false;
        _showSolution = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises.isEmpty ? null : widget.exercises[_currentExerciseIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (exercise == null) {
      return const Center(
        child: Text('No exercises available for this lesson yet.'),
      );
    }
    
    return Column(
      children: [
        // Exercise navigation header
        Container(
          padding: const EdgeInsets.all(16),
          color: isDarkMode ? Colors.blueGrey.shade800 : Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Exercise ${_currentExerciseIndex + 1}/${widget.exercises.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentExerciseIndex > 0)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                          ),
                          onPressed: _previousExercise,
                          tooltip: 'Previous Exercise',
                        ),
                      if (_currentExerciseIndex < widget.exercises.length - 1)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                          ),
                          onPressed: _exerciseCompleted ? _nextExercise : null,
                          tooltip: 'Next Exercise',
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Hint'),
                        onPressed: _showHint,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Solution'),
                        onPressed: _showSolution ? null : _revealSolution,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exercise['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exercise['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Display sample data for the exercise
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  exercise['testCases'][0]['input'],
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 14,
                    color: isDarkMode ? Colors.green.shade200 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Query editor
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SQL Query Editor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode 
                              ? _errorOutput.isNotEmpty ? Colors.red.shade300 : Colors.grey.shade700 
                              : _errorOutput.isNotEmpty ? Colors.red.shade300 : Colors.grey.shade300,
                        ),
                      ),
                      child: TextField(
                        controller: _queryController,
                        maxLines: 6,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 15,
                          color: isDarkMode ? Colors.greenAccent : Colors.blue.shade900,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your SQL query here...',
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    if (_errorOutput.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorOutput,
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _resetExercise,
                          child: const Text('Reset'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isExecuting ? null : _executeQuery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isExecuting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Run Query'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 16,
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
                            color: isDarkMode ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                            ),
                          ),
                          child: _resultOutput.isEmpty
                              ? Center(
                                  child: Text(
                                    'Results will appear here after you run your query',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_exerciseCompleted)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.green.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green.shade400,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Exercise completed successfully!',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        _resultOutput,
                                        style: TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 14,
                                          color: isDarkMode ? Colors.greenAccent : Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 