class HealthRecord {
  final String id;
  final String title;
  final String icon;
  final String date;
  final String fileSize;
  final String fileFormat;
  final bool isDownloadable;

  HealthRecord({
    required this.id,
    required this.title,
    required this.icon,
    required this.date,
    required this.fileSize,
    required this.fileFormat,
    required this.isDownloadable,
  });
}
