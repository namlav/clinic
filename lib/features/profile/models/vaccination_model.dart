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
}
