import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'providers/theme_provider.dart';
import 'providers/certificate_provider.dart';
import 'providers/user_provider.dart';
import 'providers/documentation_provider.dart';
import 'services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/certification_screen.dart';

// Get Supabase client
final supabaseClient = supabase.Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Print configuration values for debugging
  debugPrint('SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}');
  debugPrint('APP_URL: ${dotenv.env['APP_URL']}');
  debugPrint('REDIRECT_URL: ${dotenv.env['SUPABASE_REDIRECT_URL']}');
  
  // Initialize Supabase
  await supabase.Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true,
    authFlowType: _getAuthFlowType(),
  );
  
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error: ${details.exception}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CertificateProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DocumentationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Helper function to determine auth flow type based on platform
supabase.AuthFlowType _getAuthFlowType() {
  if (kIsWeb) {
    return supabase.AuthFlowType.implicit;
  }
  
  try {
    if (Platform.isIOS || Platform.isMacOS) {
      return supabase.AuthFlowType.pkce;
    }
  } catch (e) {
    // Platform is not available, default to implicit
  }
  
  return supabase.AuthFlowType.implicit;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQL Learning Platform',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.indigo,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.indigo,
          secondary: Colors.amber,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.indigo,
          secondary: Colors.amber,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
      routes: {
        '/certificates': (context) => const CertificationScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.initializeAuthListener();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<supabase.User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // If the user is logged in, show the main screen
        if (snapshot.hasData && snapshot.data != null) {
          return const WelcomeScreen();
        }
        
        // Otherwise, show the login screen
        return const LoginScreen();
      },
    );
  }
} 