import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;
import '../models/certificate.dart';
import '../providers/certificate_provider.dart';
import '../providers/user_provider.dart';
import '../services/email_service.dart';
import 'package:flutter/foundation.dart';

class CertificationScreen extends StatefulWidget {
  const CertificationScreen({Key? key}) : super(key: key);

  @override
  _CertificationScreenState createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final certificateProvider = Provider.of<CertificateProvider>(context);
    final certificates = certificateProvider.certificates;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certifications'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          userProvider.username.isEmpty
              ? _buildLoginPrompt(context)
              : certificates.isEmpty
                  ? _buildNoCertificatesMessage(context)
                  : _buildCertificatesList(context, certificates),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Login Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please login to view your certifications',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCertificatesMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Certificates Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Complete all modules in a quiz level to earn your certificate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesList(BuildContext context, List<Certificate> certificates) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      itemBuilder: (ctx, index) {
        final certificate = certificates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Certificate header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: certificate.getBadgeColor().withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: certificate.getBadgeColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        certificate.getBadgeIcon(),
                        color: certificate.getBadgeColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Issued on ${certificate.formattedDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: certificate.getBadgeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: certificate.getBadgeColor().withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${certificate.score}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: certificate.getBadgeColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Certificate preview
              InkWell(
                onTap: () {
                  _showCertificateDialog(context, certificate);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildCertificatePreview(certificate),
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.visibility,
                      label: 'View',
                      onTap: () => _showCertificateDialog(context, certificate),
                    ),
                    _buildActionButton(
                      icon: Icons.download,
                      label: 'Download',
                      onTap: () => _downloadCertificate(certificate),
                    ),
                    _buildActionButton(
                      icon: Icons.email,
                      label: 'Email',
                      onTap: () => _showEmailDialog(context, certificate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertificatePreview(Certificate certificate) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Certificate background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Certificate border
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CertificateBorderPainter(
                          color: certificate.getBadgeColor().withOpacity(0.3),
                        ),
                      ),
                    ),
                    
                    // Watermark icon
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Opacity(
                        opacity: 0.07,
                        child: Icon(
                          Icons.code,
                          size: 100,
                          color: certificate.getBadgeColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Certificate content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CERTIFICATE OF ACHIEVEMENT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  certificate.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: certificate.getBadgeColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This certifies that',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  certificate.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'has successfully completed the SQL ${certificate.level} level',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      certificate.getBadgeIcon(),
                      size: 14,
                      color: certificate.getBadgeColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      certificate.getGrade(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: certificate.getBadgeColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertificateDialog(BuildContext context, Certificate certificate) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(certificate.title),
              backgroundColor: certificate.getBadgeColor(),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.email),
                  tooltip: 'Email Certificate',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showEmailDialog(context, certificate);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download Certificate',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _downloadCertificate(certificate);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RepaintBoundary(
                key: _certificateKey,
                child: _buildFullCertificate(certificate),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCertificate(Certificate certificate) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: certificate.getBadgeColor().withOpacity(0.5), width: 2),
      ),
      child: Stack(
        children: [
          // Certificate background
          Positioned.fill(
            child: CustomPaint(
              painter: CertificateBorderPainter(
                color: certificate.getBadgeColor().withOpacity(0.2),
              ),
            ),
          ),
          
          // Watermark
          Positioned(
            right: 20,
            bottom: 20,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.code,
                size: 150,
                color: certificate.getBadgeColor(),
              ),
            ),
          ),
          
          // Certificate content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top header
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: certificate.getBadgeColor(),
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'SQL MASTER ACADEMY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      'ID: ${certificate.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Certificate title
                const Text(
                  'CERTIFICATE OF ACHIEVEMENT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Divider
                Container(
                  height: 2,
                  width: 100,
                  color: certificate.getBadgeColor().withOpacity(0.5),
                ),
                
                const SizedBox(height: 24),
                
                // Certificate body
                Text(
                  'This certifies that',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // User name
                Text(
                  certificate.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Certificate description
                Text(
                  'has successfully completed the ${certificate.level} level of SQL mastery,\n'
                  'demonstrating proficiency in all required modules.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Score and grade
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildScoreBadge(certificate),
                    const SizedBox(width: 24),
                    _buildGradeBadge(certificate),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Date and signature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Issued',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          certificate.formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.gesture,
                          size: 36,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 120,
                          height: 1,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SQL Master Academy',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(Certificate certificate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: certificate.getBadgeColor().withOpacity(0.1),
        border: Border.all(
          color: certificate.getBadgeColor().withOpacity(0.3),
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${certificate.score}%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: certificate.getBadgeColor(),
        ),
      ),
    );
  }

  Widget _buildGradeBadge(Certificate certificate) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: certificate.getBadgeColor().withOpacity(0.1),
        border: Border.all(
          color: certificate.getBadgeColor().withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            certificate.getBadgeIcon(),
            size: 20,
            color: certificate.getBadgeColor(),
          ),
          const SizedBox(width: 8),
          Text(
            certificate.getGrade(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: certificate.getBadgeColor(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadCertificate(Certificate certificate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First show the dialog to ensure certificate is rendered
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('Preparing Download...'),
                backgroundColor: certificate.getBadgeColor(),
                automaticallyImplyLeading: false,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key: _certificateKey,
                  child: _buildFullCertificate(certificate),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
      
      // Wait for the certificate to be rendered
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get the rendered certificate
      final RenderRepaintBoundary boundary = _certificateKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Could not generate certificate image');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final base64String = base64Encode(pngBytes);
      final dataUrl = 'data:image/png;base64,$base64String';
      
      // Close the dialog
      Navigator.of(context).pop();
      
      // For web, use an anchor element to download
      final anchorElement = html.AnchorElement(href: dataUrl);
      anchorElement.download = 'SQL_${certificate.level}_Certificate.png';
      anchorElement.target = '_blank';
      
      // Programmatically click the anchor to trigger download
      anchorElement.click();
      
      _showSuccessSnackBar('Certificate downloaded successfully');
    } catch (e) {
      // Close the dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Failed to download certificate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEmailDialog(BuildContext context, Certificate certificate) {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Email Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address to receive your certificate',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                Navigator.of(ctx).pop();
                _emailCertificate(certificate, emailController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _emailCertificate(Certificate certificate, String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First show the dialog to ensure certificate is rendered
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('Sending Certificate...'),
                backgroundColor: certificate.getBadgeColor(),
                automaticallyImplyLeading: false,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key: _certificateKey,
                  child: _buildFullCertificate(certificate),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Sending email...', 
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
      
      // Wait for the certificate to be rendered
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get the rendered certificate
      final RenderRepaintBoundary boundary = _certificateKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Could not generate certificate image');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Use email service to send the certificate
      final emailService = EmailService();
      final subject = 'Your SQL ${certificate.level} Certificate';
      final body = 'Congratulations on completing the SQL ${certificate.level} level!\n\n'
          'Your certificate is attached to this email.\n\n'
          'SQL Master Academy Team';
      
      final success = await emailService.sendCertificateEmail(
        email: email,
        subject: subject,
        body: body,
        certificateImage: pngBytes,
        certificateName: 'SQL_${certificate.level}_Certificate.png',
      );
      
      // Close the dialog
      Navigator.of(context).pop();
      
      if (success) {
        // Show certificate sent confirmation dialog
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Certificate Sent!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_read,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your certificate has been sent to:\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please check your inbox or spam folder.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        _showSuccessSnackBar('Certificate sent to $email');
      } else {
        throw Exception('Email sending failed');
      }
    } catch (e) {
      // Close the dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Failed to email certificate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class CertificateBorderPainter extends CustomPainter {
  final Color color;

  CertificateBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final borderPath = Path();
    
    // Outer border
    borderPath.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Corner decorations
    final cornerSize = size.width * 0.1;
    
    // Top left corner
    borderPath.moveTo(0, cornerSize);
    borderPath.lineTo(0, 0);
    borderPath.lineTo(cornerSize, 0);
    
    // Top right corner
    borderPath.moveTo(size.width - cornerSize, 0);
    borderPath.lineTo(size.width, 0);
    borderPath.lineTo(size.width, cornerSize);
    
    // Bottom right corner
    borderPath.moveTo(size.width, size.height - cornerSize);
    borderPath.lineTo(size.width, size.height);
    borderPath.lineTo(size.width - cornerSize, size.height);
    
    // Bottom left corner
    borderPath.moveTo(cornerSize, size.height);
    borderPath.lineTo(0, size.height);
    borderPath.lineTo(0, size.height - cornerSize);
    
    canvas.drawPath(borderPath, paint);
    
    // Draw decorative pattern
    final patternPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Border pattern
    final patternPath = Path();
    final spacing = size.width * 0.03;
    
    for (var i = 0; i < 8; i++) {
      final offset = spacing * (i + 1);
      
      // Top left corner pattern
      patternPath.moveTo(0, offset);
      patternPath.lineTo(offset, 0);
      
      // Bottom right corner pattern
      patternPath.moveTo(size.width, size.height - offset);
      patternPath.lineTo(size.width - offset, size.height);
    }
    
    canvas.drawPath(patternPath, patternPaint);
  }

  @override
  bool shouldRepaint(CertificateBorderPainter oldDelegate) => 
      color != oldDelegate.color;
} 