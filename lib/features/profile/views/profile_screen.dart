import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';
import '../models/health_metrics_model.dart';
import 'medical_records_screen.dart';
import 'vaccination_history_screen.dart';
import 'health_insurance_screen.dart';
import '../../appointment/views/appointment_history_screen.dart';
import '../../notification/views/notification_settings_screen.dart';
import '../../auth/views/welcome_screen.dart';
import '../../../widgets/fade_page_route.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Patient> _patientFuture;

  @override
  void initState() {
    super.initState();
    _patientFuture = Patient.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'SereneHealth',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF4B5563),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final patient = snapshot.data;
          if (patient == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(patient),
                const SizedBox(height: 18),
                _buildHealthOverviewCard(patient, _buildHealthMetricsFromPatient(patient)),
                const SizedBox(height: 18),
                _buildSectionTitle('Quản lý hồ sơ'),
                const SizedBox(height: 12),
                _buildFeatureGrid(),
                const SizedBox(height: 20),
                _buildSectionTitle('Cài đặt'),
                const SizedBox(height: 12),
                _buildSettingsTile('🔔 Thông Báo', 'notification_settings'),
                const SizedBox(height: 10),
                _buildSettingsTile('❓ Hỗ Trợ', null),
                const SizedBox(height: 10),
                _buildSettingsTile('🚪 Đăng xuất', 'logout'),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  HealthMetrics? _buildHealthMetricsFromPatient(Patient patient) {
    if (patient.healthHeartRate != null ||
        patient.healthBloodPressureSys != null ||
        patient.healthWeight != null) {
      return HealthMetrics(
        id: patient.id,
        heartRate: patient.healthHeartRate ?? 0,
        bloodPressureSys: (patient.healthBloodPressureSys ?? 0).toString(),
        bloodPressureDia: (patient.healthBloodPressureDia ?? 0).toString(),
        weightKg: patient.healthWeight ?? 0.0,
        weightTrend: patient.healthWeightTrend ?? '',
      );
    }
    return null;
  }

  Widget _buildProfileCard(Patient patient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFEFF6FF),
            backgroundImage: AssetImage(patient.avatarUrl),
            child: patient.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Color(0xFF2563EB), size: 36)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            patient.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            patient.memberType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thành viên từ ${patient.memberSince.day}/${patient.memberSince.month}/${patient.memberSince.year}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Text(
            'Patient ID: #${patient.id}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBadge(
                patient.isActive ? 'ACTIVE' : 'INACTIVE',
                patient.isActive ? const Color(0xFFEFF6FF) : const Color(0xFFFFEAEA),
                patient.isActive ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color background, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHealthOverviewCard(Patient patient, HealthMetrics? metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tình Trạng Sức Khỏe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 18),
          _buildHealthStat(
            (metrics?.heartRate ?? patient.heartRate).toString(),
            'bpm',
            'Nhịp Tim',
          ),
          const SizedBox(height: 16),
          _buildHealthStat(
            metrics != null
                ? '${metrics.bloodPressureSys}/${metrics.bloodPressureDia}'
                : patient.bloodPressure,
            '',
            'Huyết Áp',
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    (metrics?.weightKg ?? patient.weight).toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (metrics?.weightTrend != null && metrics!.weightTrend.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: metrics.weightTrend.contains('-')
                            ? const Color(0xFFEFF6EE)
                            : const Color(0xFFFFEAEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        metrics.weightTrend,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: metrics.weightTrend.contains('-')
                              ? const Color(0xFF047857)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Cân Nặng',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(String value, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        _buildFeatureTile('Hồ Sơ Y Tế', Icons.folder_shared, 'medical_records'),
        const SizedBox(height: 12),
        _buildFeatureTile('Bảo Hiểm Y Tế', Icons.shield, 'health_insurance'),
        const SizedBox(height: 12),
        _buildFeatureTile(
          'Lịch Sử Tiêm Chủng',
          Icons.vaccines,
          'vaccination_history',
        ),
        const SizedBox(height: 12),
        _buildFeatureTile(
          'Lịch Sử Khám Bệnh',
          Icons.calendar_month,
          'appointment_history',
        ),
      ],
    );
  }

  Widget _buildFeatureTile(String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => _navigateToScreen(route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(15),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          _navigateToScreen(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(15),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
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
      case 'logout':
        _handleLogout();
        return;
      default:
        return;
    }
    Navigator.push(
      context,
      FadePageRoute(builder: (context) => screen),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          FadePageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e')),
        );
      }
    }
  }
}
