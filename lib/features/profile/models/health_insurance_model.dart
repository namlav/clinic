class HealthInsurance {
  final String id;
  final String providerName;
  final String insuranceNumber;
  final String policyNumber;
  final DateTime validFrom;
  final DateTime validUntil;
  final double coverage;
  final double monthlyPremium;
  final double copay;
  final String status;

  HealthInsurance({
    required this.id,
    required this.providerName,
    required this.insuranceNumber,
    required this.policyNumber,
    required this.validFrom,
    required this.validUntil,
    required this.coverage,
    required this.monthlyPremium,
    required this.copay,
    required this.status,
  });

  factory HealthInsurance.fromJson(Map<String, dynamic> json) {
    return HealthInsurance(
      id: json['insuranceid']?.toString() ?? '',
      providerName: json['providername'] ?? '',
      insuranceNumber: json['cardnumber'] ?? '',
      policyNumber: json['planname'] ?? '',
      validFrom: json['validfrom'] != null
          ? DateTime.parse(json['validfrom'])
          : DateTime.now(),
      validUntil: json['validuntil'] != null
          ? DateTime.parse(json['validuntil'])
          : DateTime.now().add(Duration(days: 365)),
      coverage: (json['medicalserviceslimit'] ?? 0).toDouble(),
      monthlyPremium: (json['monthlypremium'] ?? 0).toDouble(),
      copay: (json['deductibletotal'] ?? 0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insuranceid': id,
      'providername': providerName,
      'cardnumber': insuranceNumber,
      'planname': policyNumber,
      'validfrom': validFrom.toIso8601String(),
      'validuntil': validUntil.toIso8601String(),
      'medicalserviceslimit': coverage,
      'monthlypremium': monthlyPremium,
      'deductibletotal': copay,
      'status': status,
    };
  }
}
