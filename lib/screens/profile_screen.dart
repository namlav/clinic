import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'medical_records_screen.dart';
import 'vaccination_history_screen.dart';
import 'health_insurance_screen.dart';
import 'appointment_history_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Patient patient;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    patient = Patient(
      id: '1',
      fullName: 'Nguyễn Khôi Khoản',
      email: 'nguyen.khoai@example.com',
      phone: '+84 123 456 789',
      avatarUrl: 'assets/avatar.jpg',
      memberType: 'Premium Member',
      memberSince: DateTime(2023, 4, 21),
      heartRate: 72,
      bloodPressure: '120/80',
      weight: 70,
      height: 175,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.grey[700]),
        title: Text(
          'SereneHealth',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 80, color: Colors.blue),
            ),
            const SizedBox(height: 15),
            Text(
              patient.fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              patient.memberType,
              style: TextStyle(fontSize: 12, color: Colors.blue[600]),
            ),
            Text(
              'Thành viên từ ${patient.memberSince.day}/${patient.memberSince.month}/${patient.memberSince.year}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            _buildHealthStats(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 20),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStats() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tình Trạng Sức Khỏe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('❤️', '${patient.heartRate}', 'Nhịp Tim', 'bpm'),
              _buildStatItem('📊', patient.bloodPressure, 'Huyết Áp', ''),
              _buildStatItem('⚖️', '${patient.weight} kg', 'Cân Nặng', ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label, String unit) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (unit.isNotEmpty)
          Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuItem('Hồ Sơ Y Tế', 'medical_records'),
        _buildMenuItem('Bảo Hiểm Y Tế', 'health_insurance'),
        _buildMenuItem('Lịch Sử Tiêm Chủng', 'vaccination_history'),
        _buildMenuItem('Lịch Sử Khám Bệnh', 'appointment_history'),
      ],
    );
  }

  Widget _buildMenuItem(String title, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () => _navigateToScreen(route),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài Đặt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem('Thông Báo', 'notification_settings'),
        _buildSettingItem('Hỗ Trợ', null),
        _buildSettingItem('Đăng xuất', null),
      ],
    );
  }

  Widget _buildSettingItem(String title, String? route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () {
          if (route != null) _navigateToScreen(route);
        },
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _navigateToScreen(String route) {
    Widget screen;
    switch (route) {
      case 'medical_records':
        screen = const MedicalRecordsScreen();
        break;
      case 'health_insurance':
        screen = const HealthInsuranceScreen();
        break;
      case 'vaccination_history':
        screen = const VaccinationHistoryScreen();
        break;
      case 'appointment_history':
        screen = const AppointmentHistoryScreen();
        break;
      case 'notification_settings':
        screen = const NotificationSettingsScreen();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
