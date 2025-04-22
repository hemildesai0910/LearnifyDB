import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/quiz_questions.dart';
import '../providers/user_provider.dart';
import '../providers/certificate_provider.dart';
import '../models/certificate.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String title;
  final String level;
  final String module;

  const QuizScreen({
    Key? key,
    required this.questions,
    required this.title,
    required this.level,
    required this.module,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  int correctAnswers = 0;
  bool quizCompleted = false;

  void _checkAnswer(int selectedIndex) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswerIndex = selectedIndex;
      hasAnswered = true;
      if (selectedIndex == widget.questions[currentQuestionIndex].correctAnswerIndex) {
        correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        hasAnswered = false;
      });
    } else {
      setState(() {
        quizCompleted = true;
      });
      
      // Calculate score as percentage
      final scorePercentage = ((correctAnswers / widget.questions.length) * 100).round();
      
      // Save completion in UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.completeModule(widget.level, widget.module, scorePercentage);
      
      // Check if all modules in this level are completed
      if (userProvider.checkLevelCompletion(widget.level)) {
        // Generate a certificate for this level
        final certificateProvider = Provider.of<CertificateProvider>(context, listen: false);
        final moduleScores = userProvider.getModuleScores(widget.level);
        
        final certificate = certificateProvider.generateCertificate(
          userName: userProvider.username,
          level: widget.level,
          moduleScores: moduleScores,
        );
        
        certificateProvider.addCertificate(certificate);
        
        // Show a notification about the certificate
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showCertificateEarnedDialog();
          }
        });
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswerIndex = null;
      hasAnswered = false;
      correctAnswers = 0;
      quizCompleted = false;
    });
  }

  void _showCertificateEarnedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              color: Colors.amber,
              size: 28,
            ),
            SizedBox(width: 10),
            Text('Certificate Earned!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve completed all modules in the ${widget.level} level.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'A certificate has been added to your profile. You can view and download it from the Certifications section.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to certificates screen
              Navigator.of(context).pushNamed('/certificates');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('View Certificate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return _buildResultScreen();
    }

    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: Colors.green[100],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1} of ${widget.questions.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              question.question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ...List.generate(
              question.options.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: hasAnswered ? null : () => _checkAnswer(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(index),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: hasAnswered ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
            if (hasAnswered) ...[
              SizedBox(height: 24),
              Text(
                question.explanation,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  currentQuestionIndex < widget.questions.length - 1
                      ? 'Next Question'
                      : 'Finish Quiz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(int index) {
    if (!hasAnswered) {
      return Colors.white;
    }

    if (index == widget.questions[currentQuestionIndex].correctAnswerIndex) {
      return Colors.green;
    }

    if (index == selectedAnswerIndex) {
      return Colors.red;
    }

    return Colors.white;
  }

  Widget _buildResultScreen() {
    final percentage = (correctAnswers / widget.questions.length) * 100;
    final resultMessage = _getResultMessage(percentage);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hasCompletedAllModules = userProvider.checkLevelCompletion(widget.level);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[100],
                ),
                child: Center(
                  child: Text(
                    '${percentage.round()}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'You got $correctAnswers out of ${widget.questions.length} questions correct',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                resultMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      hasCompletedAllModules ? 'View Modules' : 'Next Module',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              if (hasCompletedAllModules) ...[
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to certificates screen
                    Navigator.of(context).pushNamed('/certificates');
                  },
                  icon: Icon(Icons.workspace_premium),
                  label: Text('View My Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getResultMessage(double percentage) {
    if (percentage >= 90) {
      return 'Excellent! You\'re a SQL expert! 🏆';
    } else if (percentage >= 70) {
      return 'Great job! Keep practicing! 👍';
    } else if (percentage >= 50) {
      return 'Good effort! Review and try again! 📚';
    } else {
      return 'Keep learning! You\'ll improve! 💪';
    }
  }
} 