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

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['recordid']?.toString() ?? '',
      title: json['recordtype'] ?? '',
      icon: _getIconForType(json['recordtype'] ?? ''),
      date: json['recorddate'] != null
          ? DateTime.parse(json['recorddate']).toString().split(' ')[0]
          : '',
      fileSize: _formatFileSize(json['filesize']),
      fileFormat: (json['filetype'] ?? 'PDF').toUpperCase(),
      isDownloadable: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordid': id,
      'recordtype': title,
      'recorddate': date,
      'filetype': fileFormat.toLowerCase(),
    };
  }

  static String _getIconForType(String type) {
    final typeMap = {
      'blood_test': '🔬',
      'xray': '🫁',
      'prescription': '💊',
      'urine_test': '🧪',
    };
    return typeMap[type.toLowerCase()] ?? '📄';
  }

  static String _formatFileSize(dynamic size) {
    if (size == null) return '0 KB';
    int bytes = int.tryParse(size.toString()) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
