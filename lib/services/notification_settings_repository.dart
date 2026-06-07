import '../models/notification_settings_model.dart';
import 'supabase_service.dart';

class NotificationSettingsRepository {
  final supabaseService = SupabaseService();

  Future<NotificationSettings?> getSettings(int userId) async {
    try {
      final response = await supabaseService.client
          .from('notificationsettings')
          .select()
          .eq('userid', userId)
          .single();

      return NotificationSettings.fromJson(response);
    } catch (e) {
      print('Error fetching notification settings: $e');
      // Create default settings if they don't exist
      return _createDefaultSettings(userId);
    }
  }

  Future<NotificationSettings?> _createDefaultSettings(int userId) async {
    try {
      final defaultSettings = {
        'userid': userId,
        'emailsummary': true,
        'smsnotification': true,
        'appointmentreminder': true,
        'medicalrecordupdate': true,
        'healthtips': true,
        'appupdates': false,
        'quietmode': false,
      };

      await supabaseService.client
          .from('notificationsettings')
          .insert(defaultSettings);

      return NotificationSettings.fromJson(defaultSettings..['settingid'] = 0);
    } catch (e) {
      print('Error creating default settings: $e');
      return null;
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await supabaseService.client
          .from('notificationsettings')
          .update(settings.toJson())
          .eq('userid', settings.userId);
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }
}
