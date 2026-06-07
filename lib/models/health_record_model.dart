class HealthRecord {
  final int recordId;
  final int userId;
  final int? appointmentId;
  final String? recordType;
  final DateTime? recordDate;
  final String? fileType;
  final String? fileSize;
  final String? fileUrl;

  HealthRecord({
    required this.recordId,
    required this.userId,
    this.appointmentId,
    this.recordType,
    this.recordDate,
    this.fileType,
    this.fileSize,
    this.fileUrl,
  });

  String get title => recordType ?? 'Hồ sơ y tế';

  String get icon {
    final type = recordType?.toLowerCase() ?? '';
    if (type.contains('xét nghiệm') || type.contains('test')) return '🔬';
    if (type.contains('x-quang') || type.contains('xray')) return '🫁';
    if (type.contains('toa') || type.contains('prescription')) return '💊';
    if (type.contains('nước tiểu')) return '🧪';
    return '📄';
  }

  String get date {
    if (recordDate == null) return '';
    return '${recordDate!.day}/${recordDate!.month}/${recordDate!.year}';
  }

  String get fileFormat => fileType?.toUpperCase() ?? 'PDF';

  bool get isDownloadable => fileUrl != null && fileUrl!.isNotEmpty;

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      recordId: json['recordid'] ?? 0,
      userId: json['userid'] ?? 0,
      appointmentId: json['appointmentid'],
      recordType: json['recordtype'],
      recordDate: json['recorddate'] != null
          ? DateTime.parse(json['recorddate'])
          : null,
      fileType: json['filetype'],
      fileSize: json['filesize'],
      fileUrl: json['fileurl'],
    );
  }
}
