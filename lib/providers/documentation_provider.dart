import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentationProvider extends ChangeNotifier {
  final Set<String> _bookmarks = {};
  String _currentSection = 'SQL Basics';
  final String _bookmarksKey = 'sql_documentation_bookmarks';
  bool _isLoaded = false;

  // Getters
  Set<String> get bookmarks => Set.unmodifiable(_bookmarks);
  String get currentSection => _currentSection;
  bool get isLoaded => _isLoaded;

  DocumentationProvider() {
    _initializeBookmarks();
  }

  // Initialize bookmarks
  Future<void> _initializeBookmarks() async {
    await _loadBookmarks();
    _isLoaded = true;
    notifyListeners();
  }

  // Load bookmarks from SharedPreferences
  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksList = prefs.getStringList(_bookmarksKey);
      if (bookmarksList != null) {
        _bookmarks.clear();
        _bookmarks.addAll(bookmarksList);
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  // Save bookmarks to SharedPreferences
  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_bookmarksKey, _bookmarks.toList());
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  // Toggle bookmark for a topic
  Future<void> toggleBookmark(String topic) async {
    if (_bookmarks.contains(topic)) {
      _bookmarks.remove(topic);
    } else {
      _bookmarks.add(topic);
    }
    await _saveBookmarks();
    notifyListeners();
  }

  // Check if a topic is bookmarked
  bool isBookmarked(String topic) {
    return _bookmarks.contains(topic);
  }

  // Set current section
  void setCurrentSection(String section) {
    if (sections.containsKey(section)) {
      _currentSection = section;
      notifyListeners();
    }
  }

  // Get topics for a specific section
  List<String> getTopicsForSection(String section) {
    return sections[section] ?? [];
  }

  // Search topics across all sections
  List<String> searchTopics(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    final results = <String>[];
    
    for (final sectionTopics in sections.values) {
      results.addAll(
        sectionTopics.where(
          (topic) => topic.toLowerCase().contains(lowercaseQuery),
        ),
      );
    }
    
    return results;
  }

  // Get documentation sections
  Map<String, List<String>> get sections => {
    'SQL Basics': [
      'SELECT Statement',
      'WHERE Clause',
      'ORDER BY Clause',
      'GROUP BY Clause',
    ],
    'Joins & Relations': [
      'INNER JOIN',
      'LEFT JOIN',
      'RIGHT JOIN',
      'FULL OUTER JOIN',
    ],
    'Functions': [
      'Aggregate Functions',
      'String Functions',
      'Date Functions',
      'Numeric Functions',
    ],
    'Database Design': [
      'Tables & Relationships',
      'Primary Keys',
      'Foreign Keys',
      'Normalization',
    ],
  };
} 