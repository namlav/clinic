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
}
