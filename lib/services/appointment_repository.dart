import '../models/medical_appointment_model.dart';
import 'supabase_service.dart';

class AppointmentRepository {
  final supabaseService = SupabaseService();

  Future<List<MedicalAppointment>> getAppointments(int userId) async {
    try {
      final response = await supabaseService.client
          .from('appointments')
          .select('*, doctors(*)')
          .eq('userid', userId)
          .order('appointmentdate', ascending: false);

      return (response as List)
          .map((item) => MedicalAppointment.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  Future<List<MedicalAppointment>> getUpcomingAppointments(int userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseService.client
          .from('appointments')
          .select('*, doctors(*)')
          .eq('userid', userId)
          .gt('appointmentdate', now)
          .neq('status', 'cancelled')
          .order('appointmentdate', ascending: true);

      return (response as List)
          .map((item) => MedicalAppointment.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching upcoming appointments: $e');
      return [];
    }
  }

  Future<void> bookAppointment(MedicalAppointment appointment) async {
    try {
      await supabaseService.client.from('appointments').insert({
        'userid': appointment.userId,
        'doctorid': appointment.doctorId,
        'appointmentdate': appointment.appointmentDate.toIso8601String(),
        'starttime': appointment.startTime,
        'endtime': appointment.endTime,
        'roomname': appointment.roomName,
        'status': 'scheduled',
      });
    } catch (e) {
      print('Error booking appointment: $e');
    }
  }

  Future<void> cancelAppointment(int appointmentId, String reason) async {
    try {
      await supabaseService.client
          .from('appointments')
          .update({'status': 'cancelled', 'cancellationreason': reason})
          .eq('appointmentid', appointmentId);
    } catch (e) {
      print('Error cancelling appointment: $e');
    }
  }
}
