import 'package:flutter/material.dart';
import '../models/health_insurance_model.dart';
import '../services/insurance_repository.dart';
import '../services/supabase_service.dart';

class HealthInsuranceScreen extends StatefulWidget {
  const HealthInsuranceScreen({super.key});

  @override
  State<HealthInsuranceScreen> createState() => _HealthInsuranceScreenState();
}

class _HealthInsuranceScreenState extends State<HealthInsuranceScreen> {
  final InsuranceRepository _repository = InsuranceRepository();
  final SupabaseService _supabaseService = SupabaseService();

  List<HealthInsurance> insurances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsurances();
  }

  Future<void> _loadInsurances() async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      final userResponse = await _supabaseService.client
          .from('users')
          .select()
          .eq('authid', userId)
          .single();

      final numericUserId = userResponse['userid'] as int;

      final fetchedInsurances = await _repository.getInsurances(numericUserId);
      setState(() {
        insurances = fetchedInsurances;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading insurances: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Báo Hiểm Y Tế',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (insurances.isEmpty)
                    Center(
                      child: Text(
                        'Không có bảo hiểm',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  else ...[
                    ...insurances.map((insurance) => Column(
                      children: [
                        _buildInsuranceCard(insurance),
                        const SizedBox(height: 24),
                      ],
                    )),
                    _buildInsuranceDetails(insurances.first),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInsuranceCard(HealthInsurance insurance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bảo Hiểm Y Tế',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green,
                ),
                child: Text(
                  insurance.status?.toUpperCase() ?? 'ACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Số Bảo Hiểm',
            style: TextStyle(
              color: Colors.blue[100],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insurance.cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceDetails(HealthInsurance insurance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết bảo hiểm',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          'Nhà cung cấp',
          insurance.providerName ?? 'N/A',
          Icons.business,
        ),
        _buildDetailCard(
          'Kế hoạch',
          insurance.planName ?? 'N/A',
          Icons.description,
        ),
        _buildDetailCard(
          'Tổng bảo hiểm',
          _formatCurrency(insurance.deductibleTotal ?? 0),
          Icons.shield,
        ),
        _buildDetailCard(
          'Đã sử dụng',
          _formatCurrency(insurance.deductibleUsed ?? 0),
          Icons.payments,
        ),
        _buildDetailCard(
          'Giới hạn dụng cụ y tế',
          _formatCurrency(insurance.medicalServiceLimit ?? 0),
          Icons.local_hospital,
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₫'.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
