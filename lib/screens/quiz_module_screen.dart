import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_screen.dart';
import '../data/quiz_questions.dart';
import '../providers/user_provider.dart';

class QuizModuleScreen extends StatelessWidget {
  final String level;

  const QuizModuleScreen({Key? key, required this.level}) : super(key: key);

  List<Map<String, dynamic>> getModules() {
    switch (level) {
      case 'beginner':
        return [
          {
            'title': 'SELECT Basics',
            'description': 'Learn basic SELECT queries',
            'icon': Icons.list_alt,
            'questions': beginnerSelectQuestions,
            'id': 'SELECT',
          },
          {
            'title': 'WHERE Clause',
            'description': 'Filtering data with WHERE',
            'icon': Icons.filter_alt,
            'questions': beginnerWhereQuestions,
            'id': 'WHERE',
          },
          {
            'title': 'ORDER BY',
            'description': 'Sorting query results',
            'icon': Icons.sort,
            'questions': beginnerOrderByQuestions,
            'id': 'ORDER BY',
          },
        ];
      case 'intermediate':
        return [
          {
            'title': 'JOINS',
            'description': 'Combining data from multiple tables',
            'icon': Icons.account_tree,
            'questions': intermediateJoinQuestions,
            'id': 'JOIN',
          },
          {
            'title': 'GROUP BY',
            'description': 'Aggregating data',
            'icon': Icons.group_work,
            'questions': intermediateGroupByQuestions,
            'id': 'GROUP BY',
          },
          {
            'title': 'Subqueries',
            'description': 'Nested SQL queries',
            'icon': Icons.layers,
            'questions': intermediateSubqueryQuestions,
            'id': 'Subquery',
          },
        ];
      case 'advanced':
        return [
          {
            'title': 'Complex JOINs',
            'description': 'Advanced table relationships',
            'icon': Icons.hub,
            'questions': advancedJoinQuestions,
            'id': 'Advanced JOIN',
          },
          {
            'title': 'Window Functions',
            'description': 'Advanced data analysis',
            'icon': Icons.analytics,
            'questions': advancedWindowQuestions,
            'id': 'Window Functions',
          },
          {
            'title': 'CTEs',
            'description': 'Common Table Expressions',
            'icon': Icons.table_chart,
            'questions': advancedCTEQuestions,
            'id': 'CTE',
          },
        ];
      case 'expert':
        return [
          {
            'title': 'Query Optimization',
            'description': 'Performance tuning',
            'icon': Icons.speed,
            'questions': expertOptimizationQuestions,
            'id': 'Optimization',
          },
          {
            'title': 'Database Design',
            'description': 'Schema and normalization',
            'icon': Icons.architecture,
            'questions': expertDesignQuestions,
            'id': 'Database Design',
          },
          {
            'title': 'Advanced SQL',
            'description': 'Complex problem solving',
            'icon': Icons.psychology,
            'questions': expertAdvancedQuestions,
            'id': 'Advanced SQL',
          },
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = getModules();
    final levelTitle = level[0].toUpperCase() + level.substring(1);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$levelTitle Modules'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Select a Module',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                final moduleId = module['id'];
                final isCompleted = userProvider.isModuleCompleted(level.capitalize(), moduleId);
                final moduleScore = userProvider.levelProgress[level.capitalize()]?[moduleId] ?? 0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.green[50],
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        module['icon'],
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      module['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      module['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                    trailing: isCompleted 
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$moduleScore%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Icon(Icons.chevron_right, color: Colors.green),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            questions: module['questions'],
                            title: module['title'],
                            level: level.capitalize(),
                            module: moduleId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.isNotEmpty 
        ? '${this[0].toUpperCase()}${this.substring(1)}'
        : this;
  }
} 