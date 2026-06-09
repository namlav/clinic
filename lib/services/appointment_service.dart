import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/models/medical_appointment_model.dart';

class AppointmentService {
  static Future<List<MedicalAppointment>> fetchAppointmentHistory() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('appointments')
          .select('*, doctors(fullname, avatarurl, specialties(specialtyname))');

      return (response as List)
          .map((item) => MedicalAppointment.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử khám bệnh: $e');
    }
  }
}
