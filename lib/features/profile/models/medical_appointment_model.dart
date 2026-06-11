import 'package:supabase_flutter/supabase_flutter.dart';

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

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) {
    final appointmentDate = json['appointmentdate'] != null
        ? DateTime.parse(json['appointmentdate'])
        : DateTime.now();
    final isUpcoming = appointmentDate.isAfter(DateTime.now());

    return MedicalAppointment(
      id: json['appointmentid']?.toString() ?? '',
      doctorName: json['doctors']?['fullname'] ?? 'Bác sĩ',
      specialization:
          json['doctors']?['specialties']?['specialtyname'] ?? 'Khoa',
      hospital: 'Phòng Khám',
      avatarUrl: json['doctors']?['avatarurl'] ?? 'assets/avatar.jpg',
      appointmentDate: appointmentDate,
      status: json['status'] ?? 'Đang chờ',
      notes: json['notes'] ?? '',
      isUpcoming: isUpcoming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentid': id,
      'appointmentdate': appointmentDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  static Future<List<MedicalAppointment>> fetch() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('appointments').select('*, doctors(fullname, avatarurl, specialties(specialtyname))');
      return (response as List).map((item) => MedicalAppointment.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử khám bệnh: $e');
    }
  }
}
