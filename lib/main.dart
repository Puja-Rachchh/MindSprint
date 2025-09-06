

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCswf_pFS4ZxKavsMGEK-4olojhuTNo5TU",
        authDomain: "mindsprint-2aa78.firebaseapp.com",
        projectId: "mindsprint-2aa78",
        storageBucket: "http://mindsprint-2aa78.firebasestorage.app",
        messagingSenderId: "603568524649",
        appId: "1:603568524649:web:5e4161e9c4ac5e468881f8",
        measurementId: "G-L1447H1ESJ",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindSprint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A5ACD)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ...existing code...
