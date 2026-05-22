import 'package:flutter/material.dart';
import 'screens/cancel_appointment_screen.dart';
import 'screens/schedule_list_screen.dart';
import 'screens/booking_success_screen.dart';
import 'screens/payment_success_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic App',
      debugShowCheckedModeBanner: false, // Ẩn dải băng "DEBUG" ở góc phải
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003D81)),
      ),
      home: const PaymentSuccessScreen(),
    );
  }
}
