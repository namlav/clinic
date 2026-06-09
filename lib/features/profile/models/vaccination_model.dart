class VaccinationRecord {
  final String id;
  final String vaccineName;
  final String status;
  final String date;
  final String nextDate;
  final String location;
  final String description;
  final bool isDone;

  VaccinationRecord({
    required this.id,
    required this.vaccineName,
    required this.status,
    required this.date,
    required this.nextDate,
    required this.location,
    required this.description,
    required this.isDone,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    final administeredDate = json['administereddate'];
    final isDone = administeredDate != null;

    return VaccinationRecord(
      id: json['vaccinationid']?.toString() ?? '',
      vaccineName: json['vaccinename'] ?? '',
      status: isDone ? 'Đã Hoàn Thành' : 'Sắp Cập Nhật',
      date: administeredDate != null
          ? DateTime.parse(administeredDate).toString().split(' ')[0]
          : '',
      nextDate: json['nextduedate'] != null
          ? DateTime.parse(json['nextduedate']).toString().split(' ')[0]
          : '',
      location: json['providername'] ?? '',
      description: json['dosetype'] ?? '',
      isDone: isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccinationid': id,
      'vaccinename': vaccineName,
      'administereddate': date.isNotEmpty ? date : null,
      'nextduedate': nextDate.isNotEmpty ? nextDate : null,
      'dosetype': description,
    };
  }
}
