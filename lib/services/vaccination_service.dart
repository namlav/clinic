import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/models/vaccination_model.dart';

class VaccinationService {
  static Future<List<VaccinationRecord>> fetchVaccinationHistory() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('vaccinationrecords')
          .select();

      return (response as List)
          .map((item) => VaccinationRecord.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử tiêm chủng: $e');
    }
  }
}
