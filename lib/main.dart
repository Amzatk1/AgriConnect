import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // ✅ Ensure this exists
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Properly initialize Firebase with FirebaseOptions
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AgriConnectApp()); // ✅ Used const
}

class AgriConnectApp extends StatelessWidget {
  const AgriConnectApp({super.key}); // ✅ Used super.key for cleaner code

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashScreen(), // ✅ New splash screen for better user experience
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

// ✅ Added a simple splash screen to handle Firebase initialization
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
      User? user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => user != null ? const DashboardScreen() : const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Firebase Initialization Error: $e");
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
      body: Center(child: CircularProgressIndicator()), // ✅ Loading indicator
    );
  }
}
