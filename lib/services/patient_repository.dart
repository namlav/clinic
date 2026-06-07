import '../models/patient_model.dart';
import 'supabase_service.dart';

class PatientRepository {
  final supabaseService = SupabaseService();

  Future<Patient?> getCurrentUser() async {
    try {
      final userId = supabaseService.getCurrentUserId();
      if (userId == null) return null;

      final response = await supabaseService.client
          .from('users')
          .select()
          .eq('authid', userId)
          .single();

      return Patient.fromJson(response);
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  Future<Patient?> getUserById(int userId) async {
    try {
      final response = await supabaseService.client
          .from('users')
          .select()
          .eq('userid', userId)
          .single();

      return Patient.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<void> updateProfile(Patient patient) async {
    try {
      await supabaseService.client
          .from('users')
          .update(patient.toJson())
          .eq('userid', patient.userId);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}
