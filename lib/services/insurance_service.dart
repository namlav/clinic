import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/models/health_insurance_model.dart';

class InsuranceService {
  static Future<HealthInsurance?> fetchInsurance() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('insurances')
          .select()
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return HealthInsurance.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi lấy bảo hiểm y tế: $e');
    }
  }
}
