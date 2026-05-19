class DoctorModel {

  final String name;
  final String specialty;
  final String image;
  final double rating;
  final String experience;
  final String? subtitle;

  DoctorModel({
    required this.name,
    required this.specialty,
    required this.image,
    required this.rating,
    required this.experience,
    this.subtitle,
  });
}