import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/notification/models/notification_settings_model.dart';

class NotificationService {
  static Future<List<NotificationSettings>> fetchNotificationSettings() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.from('notificationsettings').select();

      return (response as List)
          .map((item) => NotificationSettings.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy cài đặt thông báo: $e');
    }
  }

  static Future<void> updateNotificationSetting(
    String settingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('notificationsettings')
          .update(updates)
          .eq('id', settingId);
    } catch (e) {
      throw Exception('Lỗi cập nhật cài đặt thông báo: $e');
    }
  }
}
