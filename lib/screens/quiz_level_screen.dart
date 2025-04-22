import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_module_screen.dart';
import '../providers/user_provider.dart';

class QuizLevelScreen extends StatelessWidget {
  const QuizLevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Quiz Levels'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Choose Your Level',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildLevelCard(
                  context,
                  'Beginner',
                  'Basic SQL Queries',
                  Icons.star_border,
                  userProvider,
                ),
                _buildLevelCard(
                  context,
                  'Intermediate',
                  'Joins & Subqueries',
                  Icons.star_half,
                  userProvider,
                ),
                _buildLevelCard(
                  context,
                  'Advanced',
                  'Complex Queries',
                  Icons.star,
                  userProvider,
                ),
                _buildLevelCard(
                  context,
                  'Expert',
                  'Optimization & Design',
                  Icons.workspace_premium,
                  userProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    String level,
    String description,
    IconData icon,
    UserProvider userProvider,
  ) {
    // Check if this level has a certificate
    final hasCertificate = userProvider.earnedCertificates.contains('$level-Certificate');
    final moduleScores = userProvider.getModuleScores(level);
    final completedModules = moduleScores.where((score) => score > 0).length;
    
    return Card(
      elevation: 2,
      color: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizModuleScreen(
                level: level.toLowerCase(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasCertificate ? Icons.verified : icon,
                  color: hasCertificate ? Colors.amber : Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                level,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 