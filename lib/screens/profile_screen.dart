import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../models/health_metrics_model.dart';
import '../services/patient_repository.dart';
import '../services/health_metrics_repository.dart';
import '../services/supabase_service.dart';
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
  final PatientRepository _patientRepository = PatientRepository();
  final HealthMetricsRepository _healthMetricsRepository = HealthMetricsRepository();

  Patient? patient;
  HealthMetrics? latestMetrics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _patientRepository.getCurrentUser();
      final metricsData = userData != null
          ? await _healthMetricsRepository.getLatestMetrics(userData.userId)
          : null;

      setState(() {
        patient = userData;
        latestMetrics = metricsData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (patient == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không thể tải dữ liệu người dùng'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.menu, color: Colors.grey[700], size: 20),
        ),
        title: const Text(
          'Profile bệnh nhân',
          style: TextStyle(
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xFFE8F4F8),
              child: Icon(Icons.person, size: 70, color: Colors.blue[600]),
            ),
            const SizedBox(height: 16),
            Text(
              patient!.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F1F),
              ),
            ),
            Text(
              patient!.membershipTier ?? 'Premium Member',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0066CC),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Thành viên từ ${patient!.joinedDate?.day}/${patient!.joinedDate?.month}/${patient!.joinedDate?.year}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            _buildHealthStats(),
            const SizedBox(height: 24),
            _buildMenuSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStats() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tình Trạng Sức Khỏe',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          if (latestMetrics != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('❤️', '${latestMetrics!.heartRate ?? '--'}', 'lần', 'Nhịp Tim'),
                _buildStatItem(
                  '📊',
                  '${latestMetrics!.bloodPressureSys ?? '--'}/${latestMetrics!.bloodPressureDia ?? '--'}',
                  '',
                  'Huyết Áp',
                ),
                _buildStatItem('⚖️', '${latestMetrics!.weightKg ?? '--'}', 'kg', 'Cân Nặng'),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có dữ liệu',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String unit, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF1F1F1F),
          ),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuItem('🏥 Hồ Sơ Y Tế', 'medical_records'),
        const SizedBox(height: 10),
        _buildMenuItem('🛡️ Bảo Hiểm Y Tế', 'health_insurance'),
        const SizedBox(height: 10),
        _buildMenuItem('💉 Lịch Sử Tiêm Chủng', 'vaccination_history'),
        const SizedBox(height: 10),
        _buildMenuItem('📋 Lịch Sử Khám Bệnh', 'appointment_history'),
      ],
    );
  }

  Widget _buildMenuItem(String title, String route) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () => _navigateToScreen(route),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1F1F1F),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[400],
        ),
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem('🔔 Thông Báo', 'notification_settings'),
        const SizedBox(height: 10),
        _buildSettingItem('❓ Hỗ Trợ', null),
        const SizedBox(height: 10),
        _buildSettingItem('🚪 Đăng xuất', null),
      ],
    );
  }

  Widget _buildSettingItem(String title, String? route) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () {
          if (title == '🚪 Đăng xuất') {
            _logout();
          } else if (route != null) {
            _navigateToScreen(route);
          }
        },
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: title == '🚪 Đăng xuất' ? Colors.red[600] : const Color(0xFF1F1F1F),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await SupabaseService().signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
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
