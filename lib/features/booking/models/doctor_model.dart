class DoctorModel {
  final int? doctorId;
  final int? specialtyId;
  final String? title;
  final String fullName;
  final int? experienceYears;
  final double? rating;
  final int? reviewCount;
  final String? education;
  final String? bio;
  final String? avatarUrl;
  final double consultationFee;

  DoctorModel({
    this.doctorId,
    this.specialtyId,
    this.title,
    required this.fullName,
    this.experienceYears,
    this.rating,
    this.reviewCount,
    this.education,
    this.bio,
    this.avatarUrl,
    required this.consultationFee,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctorId: json['doctorid'] as int?,
      specialtyId: json['specialtyid'] as int?,
      title: json['title'] as String?,
      fullName: json['fullname'] ?? 'Bác sĩ',
      experienceYears: json['experienceyears'] as int?,
      // Ép kiểu num sang double an toàn tránh lỗi bất đồng bộ dữ liệu số thực
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 5.0,
      reviewCount: json['reviewcount'] as int?,
      education: json['education'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarurl'] as String?,
      consultationFee: json['consultationfee'] != null 
          ? (json['consultationfee'] as num).toDouble() 
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (doctorId != null) 'doctorid': doctorId,
      'specialtyid': specialtyId,
      'title': title,
      'fullname': fullName,
      'experienceyears': experienceYears,
      'rating': rating,
      'reviewcount': reviewCount,
      'education': education,
      'bio': bio,
      'avatarurl': avatarUrl,
      'consultationfee': consultationFee,
    };
  }
}