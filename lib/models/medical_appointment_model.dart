class MedicalAppointment {
  final int appointmentId;
  final int userId;
  final int doctorId;
  final DateTime appointmentDate;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? roomName;
  final String? cancellationReason;
  final DateTime? createdAt;

  // Doctor info (from joins)
  final String? doctorName;
  final String? specialization;
  final String? hospital;
  final String? avatarUrl;

  MedicalAppointment({
    required this.appointmentId,
    required this.userId,
    required this.doctorId,
    required this.appointmentDate,
    this.startTime,
    this.endTime,
    this.status,
    this.roomName,
    this.cancellationReason,
    this.createdAt,
    this.doctorName,
    this.specialization,
    this.hospital,
    this.avatarUrl,
  });

  bool get isUpcoming {
    return appointmentDate.isAfter(DateTime.now()) && status != 'cancelled';
  }

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) {
    return MedicalAppointment(
      appointmentId: json['appointmentid'] ?? 0,
      userId: json['userid'] ?? 0,
      doctorId: json['doctorid'] ?? 0,
      appointmentDate: json['appointmentdate'] != null
          ? DateTime.parse(json['appointmentdate'])
          : DateTime.now(),
      startTime: json['starttime'],
      endTime: json['endtime'],
      status: json['status'],
      roomName: json['roomname'],
      cancellationReason: json['cancellationreason'],
      createdAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : null,
      doctorName: json['doctors']?['fullname'] ?? json['doctorname'],
      specialization: json['doctors']?['title'],
      hospital: json['hospital'],
      avatarUrl: json['doctors']?['avatarurl'],
    );
  }
}
