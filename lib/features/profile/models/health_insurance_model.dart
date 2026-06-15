import 'package:supabase_flutter/supabase_flutter.dart';

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
  final double deductibleLimit;
  final double insuranceCost;
  final String status;
  final double totalInvoiceAmount;

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
    required this.deductibleLimit,
    required this.insuranceCost,
    required this.status,
    this.totalInvoiceAmount = 0.0,
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
      deductibleLimit: (json['deductiblelimit'] ?? 0).toDouble(),
      insuranceCost: (json['insurancecost'] ?? 0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
      totalInvoiceAmount: (json['total_invoice_amount'] ?? 0).toDouble(),
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
      'deductiblelimit': deductibleLimit,
      'insurancecost': insuranceCost,
      'status': status,
    };
  }

  static Future<HealthInsurance?> fetch() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final insuranceResponse = await supabase
          .from('insurances')
          .select()
          .limit(1)
          .maybeSingle();

      if (insuranceResponse == null) {
        return null;
      }

      final appointmentsResponse = await supabase
          .from('appointments')
          .select('appointmentid')
          .eq('status', 'Completed')
          .limit(1000);

      double totalInvoiceAmount = 0.0;

      if (appointmentsResponse.isNotEmpty) {
        final appointmentIds = (appointmentsResponse as List)
            .map((apt) => apt['appointmentid'])
            .toList();

        if (appointmentIds.isNotEmpty) {
          final paymentsResponse = await supabase
              .from('payments')
              .select('totalamount')
              .inFilter('appointmentid', appointmentIds);

          totalInvoiceAmount = (paymentsResponse as List).fold<double>(
            0.0,
            (sum, payment) =>
                sum + ((payment['totalamount'] ?? 0) as num).toDouble(),
          );
        }
      }

      insuranceResponse['total_invoice_amount'] = totalInvoiceAmount;
      return HealthInsurance.fromJson(insuranceResponse);
    } catch (e) {
      throw Exception('Lỗi lấy bảo hiểm y tế: $e');
    }
  }
}
