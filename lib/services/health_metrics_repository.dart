import '../models/health_metrics_model.dart';
import 'supabase_service.dart';

class HealthMetricsRepository {
  final supabaseService = SupabaseService();

  Future<HealthMetrics?> getLatestMetrics(int userId) async {
    try {
      final response = await supabaseService.client
          .from('healthmetrics')
          .select()
          .eq('userid', userId)
          .order('recorddate', ascending: false)
          .limit(1)
          .single();

      return HealthMetrics.fromJson(response);
    } catch (e) {
      print('Error fetching latest metrics: $e');
      return null;
    }
  }

  Future<List<HealthMetrics>> getMetricsHistory(
    int userId, {
    int days = 30,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final response = await supabaseService.client
          .from('healthmetrics')
          .select()
          .eq('userid', userId)
          .gte('recorddate', startDate.toIso8601String())
          .order('recorddate', ascending: false);

      return (response as List)
          .map((item) => HealthMetrics.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching metrics history: $e');
      return [];
    }
  }

  Future<void> recordMetrics(HealthMetrics metrics) async {
    try {
      await supabaseService.client
          .from('healthmetrics')
          .insert(metrics.toJson());
    } catch (e) {
      print('Error recording metrics: $e');
    }
  }
}

extension HealthMetricsJson on HealthMetrics {
  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'recorddate': recordDate?.toIso8601String(),
      'heartrate': heartRate,
      'bloodpressuresys': bloodPressureSys,
      'bloodpressuredia': bloodPressureDia,
      'weightkg': weightKg,
      'weighttrend': weightTrend,
    };
  }
}
