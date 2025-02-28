import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: const HomeScreen(), // Default HomeScreen
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
