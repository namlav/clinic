import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';
import 'screens/medical_records_screen.dart';
import 'screens/vaccination_history_screen.dart';
import 'screens/health_insurance_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/appointment_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SereneHealth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeTestScreen(),
    );
  }
}

class HomeTestScreen extends StatelessWidget {
  const HomeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        title: const Text(
          'SereneHealth - Test Screens',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh Sách Các Screens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildScreenButton(
              context,
              'Profile Bệnh Nhân',
              '👤',
              const ProfileScreen(),
            ),
            _buildScreenButton(
              context,
              'Hồ Sơ Y Tế',
              '📋',
              const MedicalRecordsScreen(),
            ),
            _buildScreenButton(
              context,
              'Lịch Sử Tiêm Chủng',
              '💉',
              const VaccinationHistoryScreen(),
            ),
            _buildScreenButton(
              context,
              'Bảo Hiểm Y Tế',
              '🏥',
              const HealthInsuranceScreen(),
            ),
            _buildScreenButton(
              context,
              'Cài Đặt Thông Báo',
              '🔔',
              const NotificationSettingsScreen(),
            ),
            _buildScreenButton(
              context,
              'Lịch Sử Khám Bệnh',
              '📅',
              const AppointmentHistoryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenButton(
    BuildContext context,
    String title,
    String emoji,
    Widget screen,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhấn để xem chi tiết',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.blue[600], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
