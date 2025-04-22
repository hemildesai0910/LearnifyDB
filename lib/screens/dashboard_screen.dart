import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import 'learning_platform_screen.dart';
import 'quiz_level_screen.dart';
import 'ai_bot_screen.dart';
import 'documentation_screen.dart';
import 'ai_quiz_generator_screen.dart';
import 'certification_screen.dart';
import 'profile_screen.dart';
import 'saved_quizzes_screen.dart';
import 'sql_news_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final screenSize = MediaQuery.of(context).size;
    
    // Show loading indicator if user data is not loaded yet
    if (!userProvider.isLoaded) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [Colors.grey.shade900, Colors.black]
                  : [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context, userProvider, themeProvider),
                const SizedBox(height: 30),
                _buildWelcomeCard(context, userProvider, isDarkMode),
                const SizedBox(height: 30),
                _buildProgressCard(context, isDarkMode),
                const SizedBox(height: 30),
                _buildFeatureSections(context, isDarkMode, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context, UserProvider userProvider, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SQL Learning',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.blue.shade900,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.amber : Colors.blueGrey,
              ),
              tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100,
                child: Text(
                  userProvider.email.isNotEmpty 
                      ? userProvider.email[0].toUpperCase() 
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context, UserProvider userProvider, bool isDarkMode) {
    final username = userProvider.username.isNotEmpty 
        ? userProvider.username 
        : userProvider.email.split('@')[0];
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.blue.shade800.withOpacity(0.3) : Colors.blue.shade100,
          width: 1,
        ),
      ),
      color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Continue your SQL learning journey',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isDarkMode) {
    final userProvider = Provider.of<UserProvider>(context);
    final progressPercent = userProvider.progressPercentage.toInt();
    final progressValue = progressPercent / 100;
    
    // Get dynamic stats from UserProvider
    final lessonStats = userProvider.lessonsStats;
    final quizStats = userProvider.quizzesStats;
    final badgeStats = userProvider.badgesStats;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.green.shade800.withOpacity(0.3) : Colors.green.shade100,
          width: 1,
        ),
      ),
      color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.green.shade900 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.green.shade300 : Colors.green.shade500,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.bookmarks_rounded,
                  label: 'Lessons',
                  value: lessonStats,
                  color: Colors.blue,
                  isDarkMode: isDarkMode,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.quiz_rounded,
                  label: 'Quizzes',
                  value: quizStats,
                  color: Colors.orange,
                  isDarkMode: isDarkMode,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.emoji_events_rounded,
                  label: 'Badges',
                  value: badgeStats,
                  color: Colors.purple,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? color.withOpacity(0.3) : color.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDarkMode ? _getLighterColor(color) : _getDarkerColor(color),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSections(BuildContext context, bool isDarkMode, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Path',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        
        // First row of features
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'SQL Learning',
                description: 'Learn SQL fundamentals with interactive lessons',
                icon: Icons.school_rounded,
                color: Colors.blue,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LearningPlatformScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'SQL Quiz',
                description: 'Test your SQL knowledge with quizzes',
                icon: Icons.quiz_rounded,
                color: Colors.green,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizLevelScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Second row of features
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'AI SQL Bot',
                description: 'Get help with SQL queries from AI assistant',
                icon: Icons.smart_toy_rounded,
                color: Colors.amber,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiBotScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'Documentation',
                description: 'Access comprehensive SQL reference materials',
                icon: Icons.menu_book_rounded,
                color: Colors.purple,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Third row of features
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'AI Quiz Generator',
                description: 'Create custom SQL quizzes with AI',
                icon: Icons.auto_awesome_rounded,
                color: Colors.red,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiQuizGeneratorScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'Certification',
                description: 'Earn SQL certificates to showcase your skills',
                icon: Icons.workspace_premium_rounded,
                color: Colors.teal,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        
        // Fourth row with Saved Quizzes and SQL News
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'Saved Quizzes',
                description: 'Access your generated and completed quizzes',
                icon: Icons.save_rounded,
                color: Colors.indigo,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedQuizzesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                context,
                title: 'SQL News',
                description: 'Latest updates from the database world',
                icon: Icons.newspaper_rounded,
                color: Colors.blue,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SqlNewsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _animationController,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? color.withOpacity(0.3) : color.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isDarkMode ? _getLighterColor(color) : _getDarkerColor(color),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for color variations
  Color _getLighterColor(Color color) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness((hslColor.lightness + 0.3).clamp(0.0, 1.0)).toColor();
  }
  
  Color _getDarkerColor(Color color) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }
} 