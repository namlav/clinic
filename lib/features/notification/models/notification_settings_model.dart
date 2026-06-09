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
      final response = await supabase.from('notificationsettings').select();
      return (response as List).map((item) => NotificationSettings.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy cài đặt thông báo: $e');
    }
  }

  static Future<void> update(String settingId, Map<String, dynamic> updates) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('notificationsettings').update(updates).eq('id', settingId);
    } catch (e) {
      throw Exception('Lỗi cập nhật cài đặt thông báo: $e');
    }
  }
}
