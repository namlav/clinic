import 'package:demo1/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // 1. Đảm bảo các widget được khởi tạo trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(const SereneHealthApp());
}

class SereneHealthApp extends StatelessWidget {
  const SereneHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SereneHealth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0056A7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0056A7)),
      ),
      // Màn hình bắt đầu là LoginScreen nằm trong thư mục screens
      home: const WelcomeScreen(),
    );
  }
}
