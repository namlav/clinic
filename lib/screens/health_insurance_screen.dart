import 'package:flutter/material.dart';
import '../models/health_insurance_model.dart';

class HealthInsuranceScreen extends StatefulWidget {
  const HealthInsuranceScreen({super.key});

  @override
  State<HealthInsuranceScreen> createState() => _HealthInsuranceScreenState();
}

class _HealthInsuranceScreenState extends State<HealthInsuranceScreen> {
  late HealthInsurance insurance;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    insurance = HealthInsurance(
      id: '1',
      providerName: 'Bảo Hiểm Y Tế',
      insuranceNumber: 'BHY0007-8905890',
      policyNumber: 'KH001:2025',
      validFrom: DateTime(2025, 1, 1),
      validUntil: DateTime(2025, 12, 31),
      coverage: 2000000,
      monthlyPremium: 500000,
      copay: 500000,
      status: 'ACTIVE',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bảo Hiểm Y Tế',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsuranceCard(),
            const SizedBox(height: 20),
            _buildInsuranceDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCard() {
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
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
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
              Text(
                'Bảo Hiểm Y Tế',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green,
                ),
                child: Text(
                  insurance.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Số Bảo Hiểm',
            style: TextStyle(color: Colors.blue[100], fontSize: 12),
          ),
          Text(
            insurance.insuranceNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hiệu lực từ',
                    style: TextStyle(color: Colors.blue[100], fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${insurance.validFrom.day}/${insurance.validFrom.month}/${insurance.validFrom.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hết hiệu lực',
                    style: TextStyle(color: Colors.blue[100], fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${insurance.validUntil.day}/${insurance.validUntil.month}/${insurance.validUntil.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết bảo hiểm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          'Nhà cung cấp',
          insurance.providerName,
          Icons.business,
        ),
        _buildDetailCard(
          'Số chính sách',
          insurance.policyNumber,
          Icons.description,
        ),
        _buildDetailCard(
          'Bảo hiểm toàn bộ',
          _formatCurrency(insurance.coverage),
          Icons.shield,
        ),
        _buildDetailCard(
          'Phí hàng tháng',
          _formatCurrency(insurance.monthlyPremium),
          Icons.payments,
        ),
        _buildDetailCard(
          'Thanh toán',
          _formatCurrency(insurance.copay),
          Icons.local_hospital,
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
