class Patient {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String memberType;
  final DateTime memberSince;
  final int heartRate;
  final String bloodPressure;
  final double weight;
  final double height;

  Patient({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.memberType,
    required this.memberSince,
    required this.heartRate,
    required this.bloodPressure,
    required this.weight,
    required this.height,
  });
}
