import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _nameController.text = userProvider.username;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _authService.updateUserProfile(
        fullName: _nameController.text.trim(),
      );
      
      // Update the UserProvider
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateProfile(fullName: _nameController.text.trim());
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      
      if (mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: userProvider.isLoaded
          ? _buildProfile(context, userProvider, isDarkMode)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfile(BuildContext context, UserProvider userProvider, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: isDarkMode ? Colors.indigo.shade700 : Colors.indigo.shade100,
            child: Text(
              userProvider.username.isNotEmpty
                  ? userProvider.username[0].toUpperCase()
                  : userProvider.email.isNotEmpty
                      ? userProvider.email[0].toUpperCase()
                      : '?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.indigo.shade700,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Profile Details
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Display Name
                  _isEditing 
                      ? Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Display Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a display name';
                              }
                              return null;
                            },
                          ),
                        )
                      : _buildInfoRow(
                          label: 'Display Name', 
                          value: userProvider.username.isNotEmpty
                              ? userProvider.username
                              : userProvider.email.split('@')[0],
                          isDarkMode: isDarkMode,
                        ),
                  
                  const SizedBox(height: 10),
                  
                  // Email
                  _buildInfoRow(
                    label: 'Email',
                    value: userProvider.email,
                    isDarkMode: isDarkMode,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Progress
                  _buildInfoRow(
                    label: 'Learning Progress',
                    value: '${userProvider.progressPercentage.toInt()}%',
                    isDarkMode: isDarkMode,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Edit/Save Button
                  if (_isEditing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _isSaving ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                        TextButton(
                          onPressed: _isSaving 
                              ? null 
                              : () => setState(() => _isEditing = false),
                          child: const Text('Cancel'),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Theme Toggle
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            child: ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? Colors.amber : Colors.indigo,
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                activeColor: Colors.indigo,
              ),
              onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Sign Out Button
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
} 