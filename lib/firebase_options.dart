import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform; // Import platform for native checks
import 'package:flutter/foundation.dart' show kIsWeb; // Import web check

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // ✅ Web Configuration
      return const FirebaseOptions(
        apiKey: "AIzaSyCRSd1Jo9W58ZYQzM_a0teBbBovUtlMKxM", // ✅ Web API Key
        appId: "1:673744286535:web:your-web-app-id", // ✅ Replace with correct Web App ID
        messagingSenderId: "673744286535",
        projectId: "agriconnect-b8729",
        authDomain: "agriconnect-b8729.firebaseapp.com",
        storageBucket: "agriconnect-b8729.appspot.com",
      );
    } else if (Platform.isAndroid) {
      // ✅ Android Configuration
      return const FirebaseOptions(
        apiKey: "AIzaSyDcv6ZQXDwdxDuUBs5thPKdUp2XpcBQfT0", // ✅ Android API Key
        appId: "1:673744286535:android:5b5d49a35198d98ca75262",
        messagingSenderId: "673744286535",
        projectId: "agriconnect-b8729",
        storageBucket: "agriconnect-b8729.appspot.com",
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // ✅ iOS/macOS Configuration
      return const FirebaseOptions(
        apiKey: "AIzaSyCTDDhA1HPf2vkqLwKPuSHpDdg89wF3dnw", // ✅ iOS API Key
        appId: "1:673744286535:ios:5551830452079922a75262",
        messagingSenderId: "673744286535",
        projectId: "agriconnect-b8729",
        storageBucket: "agriconnect-b8729.appspot.com",
        iosBundleId: "com.example.agriconnect",
      );
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
