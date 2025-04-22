import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final supabase = Supabase.instance.client;
  
  // Get the current user
  User? get currentUser => supabase.auth.currentUser;
  
  // Get the auth state changes stream
  Stream<User?> get authStateChanges => 
      supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  
  // Initialize the auth listener
  void initializeAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.signedIn) {
        // Handle signed in state
        debugPrint('User signed in: ${data.session?.user.email}');
      } else if (event == AuthChangeEvent.signedOut) {
        // Handle signed out state
        debugPrint('User signed out');
      }
    });
  }
  
  // Convert authentication errors to friendly messages
  String getFriendlyErrorMessage(Object error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('ClientID not set')) {
      return 'Google sign-in configuration error: ClientID not set. Please check web/index.html file.';
    } else if (errorMessage.contains('User already registered')) {
      return 'This email is already registered. Please sign in instead.';
    } else if (errorMessage.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorMessage.contains('Email not confirmed')) {
      return 'Please confirm your email address before signing in.';
    } else if (errorMessage.contains('Rate limit exceeded')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorMessage.contains('NetworkError')) {
      return 'Network error. Please check your internet connection.';
    }
    
    return errorMessage;
  }
  
  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      debugPrint('Sign up error: $error');
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // For web platform, use signInWithOAuth instead of GoogleSignIn
      if (kIsWeb) {
        final success = await supabase.auth.signInWithOAuth(
          Provider.google,
          redirectTo: dotenv.env['APP_URL'] ?? 'http://localhost:3000',
        );
        
        if (!success) {
          throw Exception('Google sign in failed');
        }
        
        // Web auth uses redirection so we won't actually reach this point in the code
        // We return a placeholder that won't be used
        return AuthResponse(session: null, user: null);
      }
      
      // For mobile platforms, use GoogleSignIn
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Start the Google sign-in flow
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in canceled by user');
      }
      
      // Get auth details from Google
      final googleAuth = await googleUser.authentication;
      
      // Create credentials for Supabase
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('No ID Token from Google');
      }
      
      // Sign in to Supabase with Google credentials
      final response = await supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return response;
    } catch (error) {
      rethrow;
    }
  }
  
  // Sign in with GitHub
  Future<bool> signInWithGithub() async {
    try {
      final appUrl = dotenv.env['APP_URL'] ?? 'http://localhost:3000';
      
      final success = await supabase.auth.signInWithOAuth(
        Provider.github,
        redirectTo: appUrl,
      );
      
      debugPrint('GitHub OAuth sign-in initiated with redirect to: $appUrl');
      return success;
    } catch (error) {
      debugPrint('GitHub OAuth error: $error');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final redirectUrl = dotenv.env['SUPABASE_REDIRECT_URL'] ?? 'io.supabase.sqlgame://reset-callback/';
      
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      
      debugPrint('Password reset email sent with redirect to: $redirectUrl');
    } catch (error) {
      debugPrint('Password reset error: $error');
      rethrow;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({String? fullName, String? avatarUrl}) async {
    try {
      await supabase.from('profiles').upsert({
        'id': currentUser!.id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      rethrow;
    }
  }
} 