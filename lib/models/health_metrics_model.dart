class HealthMetrics {
  final int metricId;
  final int userId;
  final DateTime? recordDate;
  final int? heartRate;
  final int? bloodPressureSys;
  final int? bloodPressureDia;
  final double? weightKg;
  final String? weightTrend;

  HealthMetrics({
    required this.metricId,
    required this.userId,
    this.recordDate,
    this.heartRate,
    this.bloodPressureSys,
    this.bloodPressureDia,
    this.weightKg,
    this.weightTrend,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      metricId: json['metricid'] ?? 0,
      userId: json['userid'] ?? 0,
      recordDate: json['recorddate'] != null
          ? DateTime.parse(json['recorddate'])
          : null,
      heartRate: json['heartrate'],
      bloodPressureSys: json['bloodpressuresys'],
      bloodPressureDia: json['bloodpressuredia'],
      weightKg: json['weightkg']?.toDouble(),
      weightTrend: json['weighttrend'],
    );
  }
}
