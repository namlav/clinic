class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialty;
  final String image;
  final String date;
  final String time;
  final String location;
  final double price;
  final String status;
  final String? transactionId;

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.image,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.status,
    this.transactionId,
  });
}
