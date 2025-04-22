import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  // Default values
  String _username = '';
  String _email = '';
  int _score = 0;
  List<String> _completedQuizzes = [];
  List<String> _earnedCertificates = [];
  List<String> _completedLessons = [];
  Map<String, Map<String, int>> _levelProgress = {
    'Beginner': {'SELECT': 0, 'WHERE': 0, 'ORDER BY': 0},
    'Intermediate': {'JOIN': 0, 'GROUP BY': 0, 'Subquery': 0},
    'Advanced': {'Advanced JOIN': 0, 'Window Functions': 0, 'CTE': 0},
    'Expert': {'Optimization': 0, 'Database Design': 0, 'Advanced SQL': 0},
  };
  double _progressPercentage = 0.0;
  bool _isLoaded = false;
  final _supabase = Supabase.instance.client;
  
  // Getters
  String get username => _username;
  String get email => _email;
  int get score => _score;
  List<String> get completedQuizzes => List.unmodifiable(_completedQuizzes);
  List<String> get earnedCertificates => List.unmodifiable(_earnedCertificates);
  List<String> get completedLessons => List.unmodifiable(_completedLessons);
  Map<String, Map<String, int>> get levelProgress => Map.unmodifiable(_levelProgress);
  double get progressPercentage => _progressPercentage;
  bool get isLoaded => _isLoaded;
  
  // Calculate overall progress as percentage
  double calculateProgress() {
    if (_completedLessons.isEmpty && _completedQuizzes.isEmpty && _earnedCertificates.isEmpty) {
      return 0.0;
    }
    
    // Calculate weights for different components
    final lessonWeight = 0.4; // 40% weight for lessons
    final quizWeight = 0.4;   // 40% weight for quizzes
    final badgeWeight = 0.2;  // 20% weight for badges/certificates
    
    // Calculate progress for each component
    final lessonProgress = _completedLessons.length / 10.0; // Total 10 lessons
    final quizProgress = _completedQuizzes.length / 5.0;    // Total 5 quizzes
    final badgeProgress = _earnedCertificates.length / 8.0; // Total 8 badges
    
    // Calculate weighted progress
    final totalProgress = (lessonProgress * lessonWeight) +
                         (quizProgress * quizWeight) +
                         (badgeProgress * badgeWeight);
    
    return totalProgress * 100; // Convert to percentage
  }
  
  // Statistics for the dashboard
  String get lessonsStats => '${_completedLessons.length}/10';
  String get quizzesStats => '${_completedQuizzes.length}/8';
  String get badgesStats => '${_earnedCertificates.length}/5';
  
  UserProvider() {
    // Initialize with current user data if available
    _initializeUser();
    
    // Listen for auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _initializeUser();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _clearUser();
      }
    });
  }

  // Initialize user data from Supabase
  Future<void> _initializeUser() async {
    final user = _supabase.auth.currentUser;
    
    if (user != null) {
      _email = user.email ?? '';
      
      // Extract username from email (temporary)
      if (_email.isNotEmpty) {
        _username = _email.split('@')[0];
      }
      
      try {
        // Fetch user profile from database
        final profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
            
        if (profileData != null && profileData['full_name'] != null) {
          _username = profileData['full_name'].toString();
        }

        // Fetch user progress data
        final progressData = await _supabase
            .from('user_progress')
            .select()
            .eq('user_id', user.id)
            .order('updated_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (progressData != null) {
          _progressPercentage = (progressData['progress_percentage'] as num?)?.toDouble() ?? 0.0;
          
          // Load completed items with proper type conversion
          final completedItems = await _supabase
              .from('user_progress')
              .select()
              .eq('user_id', user.id)
              .eq('completed', true);

          if (completedItems != null) {
            // Convert dynamic lists to List<String> with proper type checking
            _completedLessons = (completedItems as List)
                .where((item) => item['topic_id'] != null && item['topic_id'].toString().startsWith('lesson_'))
                .map((item) => item['topic_id'].toString())
                .toList();

            _completedQuizzes = (completedItems as List)
                .where((item) => item['topic_id'] != null && item['topic_id'].toString().startsWith('quiz_'))
                .map((item) => item['topic_id'].toString())
                .toList();

            _earnedCertificates = (completedItems as List)
                .where((item) => item['topic_id'] != null && item['topic_id'].toString().startsWith('certificate_'))
                .map((item) => item['topic_id'].toString())
                .toList();
          }
        } else {
          _progressPercentage = 0.0;
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        _progressPercentage = 0.0;
        _completedLessons = [];
        _completedQuizzes = [];
        _earnedCertificates = [];
      }
      
      _isLoaded = true;
      notifyListeners();
    }
  }

  // Clear user data on sign out
  void _clearUser() {
    _username = '';
    _email = '';
    _progressPercentage = 0.0;
    _isLoaded = false;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({String? fullName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (fullName != null) {
        _username = fullName;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Add setUsername method
  Future<bool> setUsername(String username) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': username,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _username = username;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting username: $e');
      return false;
    }
  }

  // Update progress in Supabase
  Future<void> _updateProgressInSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final newProgress = calculateProgress();
      
      await _supabase.from('user_progress').upsert({
        'user_id': user.id,
        'topic_id': 'overall_progress',
        'progress_percentage': newProgress,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _progressPercentage = newProgress;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  // Override existing methods to update progress
  @override
  void completeLesson(String lessonId) {
    if (!_completedLessons.contains(lessonId)) {
      _completedLessons.add(lessonId);
      _saveUserToPrefs();
      _updateProgressInSupabase();
      notifyListeners();
    }
  }

  @override
  void completeQuiz(String quizId) {
    if (!_completedQuizzes.contains(quizId)) {
      _completedQuizzes.add(quizId);
      _saveUserToPrefs();
      _updateProgressInSupabase();
      notifyListeners();
    }
  }

  @override
  void addCertificate(String certificateId) {
    if (!_earnedCertificates.contains(certificateId)) {
      _earnedCertificates.add(certificateId);
      _saveUserToPrefs();
      _updateProgressInSupabase();
      notifyListeners();
    }
  }

  // New methods for tracking module completion
  void completeModule(String level, String module, int score) {
    if (_levelProgress.containsKey(level) && _levelProgress[level]!.containsKey(module)) {
      _levelProgress[level]![module] = score;
      _saveUserToPrefs();
      
      // Check if all modules in the level are completed
      checkLevelCompletion(level);
      
      notifyListeners();
    }
  }
  
  // Check if all modules in a level are completed
  bool checkLevelCompletion(String level) {
    if (!_levelProgress.containsKey(level)) {
      return false;
    }
    
    final modules = _levelProgress[level]!;
    final allCompleted = modules.values.every((score) => score > 0);
    
    // If all modules are completed, add a certificate ID for this level
    if (allCompleted) {
      final certId = '$level-Certificate';
      addCertificate(certId);
      return true;
    }
    
    return false;
  }
  
  // Get module scores for a level
  List<int> getModuleScores(String level) {
    if (!_levelProgress.containsKey(level)) {
      return [];
    }
    
    return _levelProgress[level]!.values.toList();
  }
  
  // Check if a specific module is completed
  bool isModuleCompleted(String level, String module) {
    if (!_levelProgress.containsKey(level) || !_levelProgress[level]!.containsKey(module)) {
      return false;
    }
    
    return _levelProgress[level]![module]! > 0;
  }
  
  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString('username') ?? '';
      _score = prefs.getInt('score') ?? 0;
      
      // Properly cast the lists with explicit type conversion
      _completedQuizzes = (prefs.getStringList('completedQuizzes') ?? [])
          .map((item) => item.toString())
          .toList();
          
      _earnedCertificates = (prefs.getStringList('earnedCertificates') ?? [])
          .map((item) => item.toString())
          .toList();
          
      _completedLessons = (prefs.getStringList('completedLessons') ?? [])
          .map((item) => item.toString())
          .toList();
      
      // Load level progress
      for (final level in _levelProgress.keys) {
        for (final module in _levelProgress[level]!.keys) {
          final key = 'progress_${level}_$module'.replaceAll(' ', '_');
          _levelProgress[level]![module] = prefs.getInt(key) ?? 0;
        }
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Fallback to default values in case of error
      _username = '';
      _score = 0;
      _completedQuizzes = [];
      _earnedCertificates = [];
      _completedLessons = [];
      _levelProgress = {
        'Beginner': {'SELECT': 0, 'WHERE': 0, 'ORDER BY': 0},
        'Intermediate': {'JOIN': 0, 'GROUP BY': 0, 'Subquery': 0},
        'Advanced': {'Advanced JOIN': 0, 'Window Functions': 0, 'CTE': 0},
        'Expert': {'Optimization': 0, 'Database Design': 0, 'Advanced SQL': 0},
      };
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  Future<void> _saveUserToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username);
      await prefs.setInt('score', _score);
      await prefs.setStringList('completedQuizzes', _completedQuizzes);
      await prefs.setStringList('earnedCertificates', _earnedCertificates);
      await prefs.setStringList('completedLessons', _completedLessons);
      
      // Save level progress
      for (final level in _levelProgress.keys) {
        for (final module in _levelProgress[level]!.keys) {
          final key = 'progress_${level}_$module'.replaceAll(' ', '_');
          await prefs.setInt(key, _levelProgress[level]![module]!);
        }
      }
    } catch (e) {
      // Silent error handling
      print('Error saving user data: $e');
    }
  }
} 