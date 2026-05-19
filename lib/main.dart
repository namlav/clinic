import 'package:flutter/material.dart';
//import 'screens/home_screen.dart'; 
//import 'screens/booking_screen.dart';
import 'screens/doctor_profile_screen.dart';
//import 'screens/replace_doctor_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clinic App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Inter',
      ),
      //home: const HomeScreen(), 
      //home: const BookingPage(),
       home: const DoctorProfilePage(),
     // home: const DoctorReplacementPage(),
    );
  }
}

