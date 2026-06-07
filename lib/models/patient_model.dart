class Patient {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? membershipTier;
  final DateTime? joinedDate;
  final bool? isActive;

  Patient({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.membershipTier,
    this.joinedDate,
    this.isActive,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      userId: json['userid'] ?? 0,
      fullName: json['fullname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatarurl'],
      dateOfBirth: json['dateofbirth'],
      gender: json['gender'],
      membershipTier: json['membershiptier'],
      joinedDate: json['joineddate'] != null
          ? DateTime.parse(json['joineddate'])
          : null,
      isActive: json['isactive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'fullname': fullName,
      'email': email,
      'phone': phone,
      'avatarurl': avatarUrl,
      'dateofbirth': dateOfBirth,
      'gender': gender,
      'membershiptier': membershipTier,
      'joineddate': joinedDate?.toIso8601String(),
      'isactive': isActive,
    };
  }
}
