import 'package:supabase_flutter/supabase_flutter.dart';

class Patient {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String memberType;
  final DateTime memberSince;
  final int heartRate;
  final String bloodPressure;
  final double weight;
  final double height;
  final bool isActive;
  final int? healthHeartRate;
  final int? healthBloodPressureSys;
  final int? healthBloodPressureDia;
  final double? healthWeight;
  final String? healthWeightTrend;

  Patient({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.memberType,
    required this.memberSince,
    required this.heartRate,
    required this.bloodPressure,
    required this.weight,
    required this.height,
    required this.isActive,
    this.healthHeartRate,
    this.healthBloodPressureSys,
    this.healthBloodPressureDia,
    this.healthWeight,
    this.healthWeightTrend,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['userid']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullname'] ?? json['full_name'] ?? json['name'] ?? 'Người dùng',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarurl'] ?? json['avatar_url'] ?? '',
      memberType: json['membershiptier'] ?? json['membership_tier'] ?? 'Standard',
      memberSince: json['joineddate'] != null
          ? DateTime.parse(json['joineddate'])
          : (json['joined_date'] != null ? DateTime.parse(json['joined_date']) : DateTime.now()),
      heartRate: json['heartrate'] ?? json['heart_rate'] ?? 0,
      bloodPressure: json['bloodpressure'] ?? json['blood_pressure'] ?? '0/0',
      weight: (json['weightkg'] ?? json['weight_kg'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      isActive: json['isactive'] ?? true,
      healthHeartRate: json['health_heartrate'],
      healthBloodPressureSys: json['health_bloodpressuresys'],
      healthBloodPressureDia: json['health_bloodpressuredia'],
      healthWeight: json['health_weightkg'] != null ? (json['health_weightkg'] as num).toDouble() : null,
      healthWeightTrend: json['health_weighttrend'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': id,
      'fullname': fullName,
      'email': email,
      'phone': phone,
      'avatarurl': avatarUrl,
      'membershiptier': memberType,
      'joineddate': memberSince.toIso8601String(),
      'heartrate': heartRate,
      'bloodpressure': bloodPressure,
      'weightkg': weight,
      'height': height,
      'isactive': isActive,
    };
  }

  static Future<Patient> fetch() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user data with healthmetrics join
      var response = await supabase
          .from('users')
          .select('*, healthmetrics(*)')
          .eq('authid', userId)
          .maybeSingle();

      response ??= await supabase
            .from('users')
            .select('*, healthmetrics(*)')
            .eq('userid', userId)
            .maybeSingle();

      if (response == null) {
        throw Exception('User not found');
      }

      // Extract healthmetrics from response if available
      var healthMetricsData = response['healthmetrics'];

      // Fallback: if join didn't return healthmetrics, fetch directly
      if (healthMetricsData == null || (healthMetricsData is List && healthMetricsData.isEmpty)) {
        try {
          final userIdInt = int.tryParse(userId);
          if (userIdInt != null) {
            final metricsResponse = await supabase
                .from('healthmetrics')
                .select()
                .eq('userid', userIdInt)
                .maybeSingle();
            if (metricsResponse != null) {
              healthMetricsData = [metricsResponse];
            }
          }
        } catch (_) {
          // Silent fallback
        }
      }

      if (healthMetricsData is List && healthMetricsData.isNotEmpty) {
        final metrics = healthMetricsData[0];
        response['health_heartrate'] = metrics['heartrate'];
        response['health_bloodpressuresys'] = metrics['bloodpressuresys'];
        response['health_bloodpressuredia'] = metrics['bloodpressuredia'];
        response['health_weightkg'] = metrics['weightkg'];
        response['health_weighttrend'] = metrics['weighttrend'];
      }

      return Patient.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy thông tin bệnh nhân: $e');
    }
  }
}
