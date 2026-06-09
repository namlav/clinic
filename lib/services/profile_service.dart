import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/models/patient_model.dart';

class ProfileService {
  static Future<Patient> fetchPatient() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('users')
          .select('*')
          .limit(1);

      final data = (response as List).first as Map<String, dynamic>;

      // Debug: in tất cả dữ liệu
      print('🔍 Database response: $data');

      return Patient.fromJson(data);
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Lỗi: $e');
    }
  }
}
