class VaccinationRecord {
  final int vaccinationId;
  final int userId;
  final String vaccineName;
  final String? vaccineType;
  final String? manufacturer;
  final String? doseType;
  final DateTime? administeredDate;
  final DateTime? nextDueDate;
  final String? providerName;

  VaccinationRecord({
    required this.vaccinationId,
    required this.userId,
    required this.vaccineName,
    this.vaccineType,
    this.manufacturer,
    this.doseType,
    this.administeredDate,
    this.nextDueDate,
    this.providerName,
  });

  bool get isDone => administeredDate != null;

  String get status {
    if (isDone) {
      return 'Đã Hoàn Thành';
    } else if (nextDueDate != null &&
        nextDueDate!.isBefore(DateTime.now().add(Duration(days: 30)))) {
      return 'Sắp Đến Hạn';
    }
    return 'Chưa Tiêm';
  }

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      vaccinationId: json['vaccinationid'] ?? 0,
      userId: json['userid'] ?? 0,
      vaccineName: json['vaccinename'] ?? '',
      vaccineType: json['vaccinetype'],
      manufacturer: json['manufacturer'],
      doseType: json['dosetype'],
      administeredDate: json['administereddate'] != null
          ? DateTime.parse(json['administereddate'])
          : null,
      nextDueDate: json['nextduedate'] != null
          ? DateTime.parse(json['nextduedate'])
          : null,
      providerName: json['providername'],
    );
  }
}
