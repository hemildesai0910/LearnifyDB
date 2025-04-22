import 'package:flutter/material.dart';

class Certificate {
  final String id;
  final String title;
  final String userName;
  final String level;
  final int score;
  final DateTime dateIssued;
  final bool isCompleted;

  Certificate({
    required this.id,
    required this.title,
    required this.userName,
    required this.level,
    required this.score,
    required this.dateIssued,
    this.isCompleted = true,
  });

  String get formattedDate {
    return '${dateIssued.day.toString().padLeft(2, '0')}-${dateIssued.month.toString().padLeft(2, '0')}-${dateIssued.year}';
  }

  Color getBadgeColor() {
    if (level == 'Beginner') {
      return Colors.green;
    } else if (level == 'Intermediate') {
      return Colors.blue;
    } else if (level == 'Advanced') {
      return Colors.orange;
    } else {
      return Colors.purple;
    }
  }

  IconData getBadgeIcon() {
    if (score >= 90) {
      return Icons.workspace_premium;
    } else if (score >= 75) {
      return Icons.military_tech;
    } else {
      return Icons.stars;
    }
  }

  String getGrade() {
    if (score >= 90) {
      return 'Excellent';
    } else if (score >= 80) {
      return 'Very Good';
    } else if (score >= 70) {
      return 'Good';
    } else if (score >= 60) {
      return 'Satisfactory';
    } else {
      return 'Needs Improvement';
    }
  }
} 