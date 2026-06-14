import 'package:supabase_flutter/supabase_flutter.dart';

class HealthMetrics {
  final String id;
  final int heartRate;
  final String bloodPressureSys;
  final String bloodPressureDia;
  final double weightKg;
  final String weightTrend;

  HealthMetrics({
    required this.id,
    required this.heartRate,
    required this.bloodPressureSys,
    required this.bloodPressureDia,
    required this.weightKg,
    required this.weightTrend,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      id: json['metricsid']?.toString() ?? '',
      heartRate: json['heartrate'] ?? 0,
      bloodPressureSys: json['bloodpressuresys']?.toString() ?? '0',
      bloodPressureDia: json['bloodpressuredia']?.toString() ?? '0',
      weightKg: (json['weightkg'] ?? 0).toDouble(),
      weightTrend: json['weighttrend'] ?? '',
    );
  }

  static Future<HealthMetrics?> fetch(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      // Try as integer first (most common)
      final userIdInt = int.tryParse(userId);
      if (userIdInt != null) {
        final response = await supabase
            .from('healthmetrics')
            .select()
            .eq('userid', userIdInt)
            .maybeSingle();

        if (response != null) {
          return HealthMetrics.fromJson(response);
        }
      }

      // Try as string if integer didn't work
      final response = await supabase
          .from('healthmetrics')
          .select()
          .eq('userid', userId)
          .maybeSingle();

      return response != null ? HealthMetrics.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }
}
