import '../models/health_record_model.dart';
import 'supabase_service.dart';

class HealthRecordRepository {
  final supabaseService = SupabaseService();

  Future<List<HealthRecord>> getRecords(int userId) async {
    try {
      final response = await supabaseService.client
          .from('medicalrecords')
          .select()
          .eq('userid', userId)
          .order('recorddate', ascending: false);

      return (response as List)
          .map((item) => HealthRecord.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching health records: $e');
      return [];
    }
  }

  Future<void> downloadFile(String fileUrl, String fileName) async {
    try {
      // Implementation for downloading files
      print('Downloading $fileName from $fileUrl');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }
}
