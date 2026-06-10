import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettings {
  final String id;
  final String title;
  final String description;
  final bool isEnabled;
  final String icon;
  final String? time;

  NotificationSettings({
    required this.id,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.icon,
    this.time,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['settingid']?.toString() ?? '',
      title: _getTitleFromField(json),
      description: _getDescriptionFromField(json),
      isEnabled:
          json['emailsummary'] ??
          json['smsnotification'] ??
          json['appointmentreminder'] ??
          json['medicalrecordupdate'] ??
          json['healthtips'] ??
          json['appupdates'] ??
          json['quietmode'] ??
          false,
      icon: _getIconFromField(json),
      time: json['quietstarttime'] ?? json['quietendtime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settingid': id,
      'emailsummary': isEnabled,
      'smsnotification': isEnabled,
      'appointmentreminder': isEnabled,
      'medicalrecordupdate': isEnabled,
      'healthtips': isEnabled,
      'appupdates': isEnabled,
      'quietmode': isEnabled,
    };
  }

  static String _getTitleFromField(Map<String, dynamic> json) {
    if (json['emailsummary'] != null) return 'Nhận báo cáo lịch biểu Email';
    if (json['smsnotification'] != null) return 'Thông báo qua tin nhắn SMS';
    if (json['medicalrecordupdate'] != null) return 'Cập nhật về sự kiện y tế';
    if (json['appointmentreminder'] != null) return 'Nhắc nhở lịch khám';
    if (json['healthtips'] != null) return 'Bản cập nhật bảo hiểm';
    if (json['appupdates'] != null) return 'Nhắc nhở tiêm vắc xin';
    if (json['quietmode'] != null) return 'Thông báo hệ thống';
    return 'Thông báo';
  }

  static String _getDescriptionFromField(Map<String, dynamic> json) {
    if (json['emailsummary'] != null) {
      return 'Bạn sẽ nhận được email về lịch khám hàng ngày';
    }
    if (json['smsnotification'] != null) {
      return 'Bạn sẽ nhận được lời nhắc nhở qua SMS';
    }
    if (json['medicalrecordupdate'] != null) {
      return 'Nhận thông tin về khám sàng lọc và chương trình sức khỏe';
    }
    if (json['appointmentreminder'] != null) {
      return 'Bạn sẽ nhận lời nhắc trước cuộc hẹn 1 ngày';
    }
    if (json['healthtips'] != null) {
      return 'Thông báo khi thay đổi quyền lợi bảo hiểm';
    }
    if (json['appupdates'] != null) {
      return 'Nhận lời nhắc khi lịch tiêm sắp tới';
    }
    if (json['quietmode'] != null) {
      return 'Nhận cập nhật từ hệ thống SereneHealth';
    }
    return 'Thông báo ứng dụng';
  }

  static String _getIconFromField(Map<String, dynamic> json) {
    if (json['emailsummary'] != null) return 'email';
    if (json['smsnotification'] != null) return 'sms';
    if (json['medicalrecordupdate'] != null) return 'medical';
    if (json['appointmentreminder'] != null) return 'appointment';
    if (json['healthtips'] != null) return 'insurance';
    if (json['appupdates'] != null) return 'vaccine';
    if (json['quietmode'] != null) return 'admin';
    return 'alert';
  }

  static Future<List<NotificationSettings>> fetch() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return _getDefaultSettings();
      }

      final response = await supabase
          .from('notificationsettings')
          .select()
          .eq('userid', userId);

      if ((response as List).isEmpty) {
        return _getDefaultSettings();
      }

      return (response as List).map((item) => NotificationSettings.fromJson(item)).toList();
    } catch (e) {
      return _getDefaultSettings();
    }
  }

  static List<NotificationSettings> _getDefaultSettings() {
    return [
      NotificationSettings(
        id: '1',
        title: 'Nhận báo cáo lịch biểu Email',
        description: 'Bạn sẽ nhận được email về lịch khám hàng ngày',
        isEnabled: true,
        icon: 'email',
      ),
      NotificationSettings(
        id: '2',
        title: 'Thông báo qua tin nhắn SMS',
        description: 'Bạn sẽ nhận được lời nhắc nhở qua SMS',
        isEnabled: true,
        icon: 'sms',
      ),
      NotificationSettings(
        id: '3',
        title: 'Nhắc nhở lịch khám',
        description: 'Bạn sẽ nhận lời nhắc trước cuộc hẹn 1 ngày',
        isEnabled: true,
        icon: 'appointment',
      ),
      NotificationSettings(
        id: '4',
        title: 'Cập nhật về sự kiện y tế',
        description: 'Nhận thông tin về khám sàng lọc và chương trình sức khỏe',
        isEnabled: true,
        icon: 'medical',
      ),
      NotificationSettings(
        id: '5',
        title: 'Bản cập nhật bảo hiểm',
        description: 'Thông báo khi thay đổi quyền lợi bảo hiểm',
        isEnabled: true,
        icon: 'insurance',
      ),
      NotificationSettings(
        id: '6',
        title: 'Nhắc nhở tiêm vắc xin',
        description: 'Nhận lời nhắc khi lịch tiêm sắp tới',
        isEnabled: true,
        icon: 'vaccine',
      ),
      NotificationSettings(
        id: '7',
        title: 'Thông báo hệ thống',
        description: 'Nhận cập nhật từ hệ thống SereneHealth',
        isEnabled: true,
        icon: 'admin',
        time: '22:00 - 07:00',
      ),
    ];
  }

  static Future<void> update(String settingId, Map<String, dynamic> updates) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) throw Exception('User not authenticated');

      // UPSERT: Insert nếu không có, Update nếu có (tối ưu cho user mới)
      await supabase.from('notificationsettings').upsert(
        {
          'settingid': settingId,
          'userid': userId,
          ...updates,
        },
        onConflict: 'settingid',
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật thông báo: $e');
    }
  }
}
