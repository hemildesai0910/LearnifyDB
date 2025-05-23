import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client configuration and initialization
class SupabaseConfig {
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authFlowType: AuthFlowType.pkce,
    );
  }

  // Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  // Get current user
  static User? get currentUser => client.auth.currentUser;
  
  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
