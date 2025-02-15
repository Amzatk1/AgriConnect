import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/plant_identification_screen.dart'; // ✅ Ensure this file exists
import 'services/plant_ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool isDarkMode = await getThemePreference();
  runApp(AgriConnectApp(isDarkMode: isDarkMode));
}

class AgriConnectApp extends StatefulWidget {
  final bool isDarkMode;
  const AgriConnectApp({super.key, required this.isDarkMode});

  @override
  AgriConnectAppState createState() => AgriConnectAppState();
}

class AgriConnectAppState extends State<AgriConnectApp> {
  late bool _isDarkMode;
  final PlantAIService _aiService = PlantAIService();

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _initializeAIModel();
  }

  /// ✅ **Load AI Model**
  Future<void> _initializeAIModel() async {
    await _aiService.loadModel();
  }

  /// ✅ **Toggle Theme**
  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
      saveThemePreference(isDark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: AuthWrapper(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => DashboardScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
        '/profile': (context) => const ProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/plant-identification': (context) => const PlantIdentificationScreen(), // ✅ Route Fixed
      },
    );
  }
}

/// ✅ **Handles User Persistence: Checks if a User is Logged In**
class AuthWrapper extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const AuthWrapper({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return DashboardScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode);
        }
        return const HomeScreen();
      },
    );
  }
}

/// ✅ **Splash Screen for Firebase Initialization**
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("🔥 Firebase Initialization Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error initializing Firebase: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// ✅ **Store Theme Preference**
Future<void> saveThemePreference(bool isDark) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', isDark);
}

/// ✅ **Get Theme Preference**
Future<bool> getThemePreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false;
}
