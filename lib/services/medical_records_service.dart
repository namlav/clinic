import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/models/health_record_model.dart';

class MedicalRecordsService {
  static Future<List<HealthRecord>> fetchMedicalRecords() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('medicalrecords')
          .select();

      return (response as List)
          .map((item) => HealthRecord.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy hồ sơ y tế: $e');
    }
  }
}
