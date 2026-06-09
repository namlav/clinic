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
    };
  }

  static Future<Patient> fetch() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('users').select('*').limit(1);
      final data = (response as List).first as Map<String, dynamic>;
      return Patient.fromJson(data);
    } catch (e) {
      throw Exception('Lỗi lấy thông tin bệnh nhân: $e');
    }
  }
}
