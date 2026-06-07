class HealthInsurance {
  final int insuranceId;
  final int userId;
  final String cardNumber;
  final String? providerName;
  final String? planName;
  final String? status;
  final String? issuePlace;
  final double? deductibleTotal;
  final double? deductibleUsed;
  final double? medicalServiceLimit;
  final double? pharmacyLimit;

  HealthInsurance({
    required this.insuranceId,
    required this.userId,
    required this.cardNumber,
    this.providerName,
    this.planName,
    this.status,
    this.issuePlace,
    this.deductibleTotal,
    this.deductibleUsed,
    this.medicalServiceLimit,
    this.pharmacyLimit,
  });

  factory HealthInsurance.fromJson(Map<String, dynamic> json) {
    return HealthInsurance(
      insuranceId: json['insuranceid'] ?? 0,
      userId: json['userid'] ?? 0,
      cardNumber: json['cardnumber'] ?? '',
      providerName: json['providername'],
      planName: json['planname'],
      status: json['status'],
      issuePlace: json['issueplace'],
      deductibleTotal: json['deductibletotal']?.toDouble(),
      deductibleUsed: json['deductibleused']?.toDouble(),
      medicalServiceLimit: json['medicalservicelimit']?.toDouble(),
      pharmacyLimit: json['pharmacylimit']?.toDouble(),
    );
  }
}
