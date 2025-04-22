import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sql_lesson.dart';
import '../screens/lesson_detail_screen.dart';
import '../providers/user_provider.dart';

class LessonCard extends StatelessWidget {
  final SQLLesson lesson;
  
  const LessonCard({
    Key? key,
    required this.lesson,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final isCompleted = userProvider.completedLessons.contains(lesson.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailScreen(
                lesson: lesson,
              ),
            ),
          ).then((_) {
            // Mark the lesson as completed when user returns from lesson detail
            if (!isCompleted) {
              Provider.of<UserProvider>(context, listen: false)
                .completeLesson(lesson.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getDifficultyColor(lesson.difficulty, isDarkMode).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      color: _getDifficultyColor(lesson.difficulty, isDarkMode),
                      size: 30,
                    ),
                    if (isCompleted)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColorLight(lesson.difficulty, isDarkMode),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lesson.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getDifficultyColor(lesson.difficulty, isDarkMode),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isCompleted)
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty, bool isDarkMode) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return isDarkMode ? Colors.green.shade300 : Colors.green.shade700;
      case 'intermediate':
        return isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700;
      case 'advanced':
        return isDarkMode ? Colors.red.shade300 : Colors.red.shade700;
      default:
        return isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700;
    }
  }
  
  Color _getDifficultyColorLight(String difficulty, bool isDarkMode) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return isDarkMode ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50;
      case 'intermediate':
        return isDarkMode ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50;
      case 'advanced':
        return isDarkMode ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50;
      default:
        return isDarkMode ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50;
    }
  }
} 