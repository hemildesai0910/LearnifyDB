import 'package:flutter/material.dart';
import '../models/certificate.dart';

class CertificateProvider extends ChangeNotifier {
  final List<Certificate> _certificates = [];
  
  List<Certificate> get certificates => [..._certificates];

  // Get certificates based on level
  List<Certificate> getCertificatesForLevel(String level) {
    return _certificates.where((cert) => cert.level == level).toList();
  }

  // Check if a user has completed a specific level
  bool hasCompletedLevel(String level) {
    return _certificates.any((cert) => cert.level == level && cert.isCompleted);
  }

  // Add a new certificate
  void addCertificate(Certificate certificate) {
    // Check if a certificate for this level already exists
    final existingIndex = _certificates.indexWhere(
      (cert) => cert.level == certificate.level
    );
    
    if (existingIndex >= 0) {
      // Replace the existing certificate with the new one
      _certificates[existingIndex] = certificate;
    } else {
      // Add the new certificate
      _certificates.add(certificate);
    }
    
    notifyListeners();
  }

  // Helper method to create a certificate from module scores
  Certificate generateCertificate({
    required String userName,
    required String level,
    required List<int> moduleScores,
  }) {
    // Calculate average score
    final totalScore = moduleScores.reduce((a, b) => a + b);
    final averageScore = (totalScore / moduleScores.length).round();
    
    // Generate certificate ID
    final id = 'CERT-${level.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Create certificate title
    final title = '$level SQL Certification';
    
    return Certificate(
      id: id,
      title: title,
      userName: userName,
      level: level,
      score: averageScore,
      dateIssued: DateTime.now(),
    );
  }
} 