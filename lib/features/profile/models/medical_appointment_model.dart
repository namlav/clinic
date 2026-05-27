class MedicalAppointment {
  final String id;
  final String doctorName;
  final String specialization;
  final String hospital;
  final String avatarUrl;
  final DateTime appointmentDate;
  final String status;
  final String notes;
  final bool isUpcoming;

  MedicalAppointment({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    required this.avatarUrl,
    required this.appointmentDate,
    required this.status,
    required this.notes,
    required this.isUpcoming,
  });
}
