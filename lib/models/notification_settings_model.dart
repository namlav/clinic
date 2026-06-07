class NotificationSettings {
  final int settingId;
  final int userId;
  final bool? emailSummary;
  final bool? smsNotification;
  final bool? appointmentReminder;
  final bool? medicalRecordUpdate;
  final bool? healthTips;
  final bool? appUpdates;
  final bool? quietMode;
  final String? quietStartTime;
  final String? quietEndTime;

  NotificationSettings({
    required this.settingId,
    required this.userId,
    this.emailSummary,
    this.smsNotification,
    this.appointmentReminder,
    this.medicalRecordUpdate,
    this.healthTips,
    this.appUpdates,
    this.quietMode,
    this.quietStartTime,
    this.quietEndTime,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      settingId: json['settingid'] ?? 0,
      userId: json['userid'] ?? 0,
      emailSummary: json['emailsummary'],
      smsNotification: json['smsnotification'],
      appointmentReminder: json['appointmentreminder'],
      medicalRecordUpdate: json['medicalrecordupdate'],
      healthTips: json['healthtips'],
      appUpdates: json['appupdates'],
      quietMode: json['quietmode'],
      quietStartTime: json['quietstarttime'],
      quietEndTime: json['quietendtime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'emailsummary': emailSummary,
      'smsnotification': smsNotification,
      'appointmentreminder': appointmentReminder,
      'medicalrecordupdate': medicalRecordUpdate,
      'healthtips': healthTips,
      'appupdates': appUpdates,
      'quietmode': quietMode,
      'quietstarttime': quietStartTime,
      'quietendtime': quietEndTime,
    };
  }
}
