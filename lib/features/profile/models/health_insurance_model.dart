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
}
