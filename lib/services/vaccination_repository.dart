import '../models/vaccination_model.dart';
import 'supabase_service.dart';

class VaccinationRepository {
  final supabaseService = SupabaseService();

  Future<List<VaccinationRecord>> getVaccinations(int userId) async {
    try {
      final response = await supabaseService.client
          .from('vaccinationrecords')
          .select()
          .eq('userid', userId)
          .order('administereddate', ascending: false);

      return (response as List)
          .map((item) => VaccinationRecord.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching vaccinations: $e');
      return [];
    }
  }

  Future<List<VaccinationRecord>> getUpcomingVaccinations(int userId) async {
    try {
      final response = await supabaseService.client
          .from('vaccinationrecords')
          .select()
          .eq('userid', userId)
          .filter('administereddate', 'is', null)
          .order('nextduedate', ascending: true);

      return (response as List)
          .map((item) => VaccinationRecord.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching upcoming vaccinations: $e');
      return [];
    }
  }
}
