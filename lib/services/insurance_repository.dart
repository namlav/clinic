import '../models/health_insurance_model.dart';
import 'supabase_service.dart';

class InsuranceRepository {
  final supabaseService = SupabaseService();

  Future<List<HealthInsurance>> getInsurances(int userId) async {
    try {
      final response = await supabaseService.client
          .from('insurances')
          .select()
          .eq('userid', userId)
          .order('insuranceid', ascending: false);

      return (response as List)
          .map((item) => HealthInsurance.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching insurances: $e');
      return [];
    }
  }

  Future<HealthInsurance?> getActiveInsurance(int userId) async {
    try {
      final response = await supabaseService.client
          .from('insurances')
          .select()
          .eq('userid', userId)
          .eq('status', 'active')
          .single();

      return HealthInsurance.fromJson(response);
    } catch (e) {
      print('Error fetching active insurance: $e');
      return null;
    }
  }
}
