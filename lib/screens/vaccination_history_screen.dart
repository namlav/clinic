import 'package:flutter/material.dart';
import '../models/vaccination_model.dart';
import '../services/vaccination_repository.dart';
import '../services/supabase_service.dart';

class VaccinationHistoryScreen extends StatefulWidget {
  const VaccinationHistoryScreen({super.key});

  @override
  State<VaccinationHistoryScreen> createState() =>
      _VaccinationHistoryScreenState();
}

class _VaccinationHistoryScreenState extends State<VaccinationHistoryScreen> {
  final VaccinationRepository _repository = VaccinationRepository();
  final SupabaseService _supabaseService = SupabaseService();

  List<VaccinationRecord> vaccinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
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

      final fetchedVaccinations = await _repository.getVaccinations(numericUserId);
      setState(() {
        vaccinations = fetchedVaccinations;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading vaccinations: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcomingVaccines = vaccinations.where((v) => !v.isDone).toList();

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
          'Lịch Sử Tiêm Chủng',
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
                  if (upcomingVaccines.isNotEmpty) ...[
                    _buildUpcomingSection(upcomingVaccines.first),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Lịch Trình',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (vaccinations.isEmpty)
                    Center(
                      child: Text(
                        'Không có lịch tiêm chủng',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  else
                    ...vaccinations.map((v) => _buildVaccinationTile(v)),
                ],
              ),
            ),
    );
  }

  Widget _buildUpcomingSection(VaccinationRecord vaccine) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
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
                'Luồng Cập Nhật',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sắp sắp đến hạn',
            style: TextStyle(color: Colors.blue[100], fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          Text(
            vaccine.vaccineName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vaccine.nextDueDate?.toString().split(' ')[0] ?? '--',
            style: TextStyle(color: Colors.blue[100], fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            vaccine.doseType ?? 'Liều tiêm',
            style: TextStyle(color: Colors.blue[100], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationTile(VaccinationRecord vaccine) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: vaccine.isDone
                      ? Colors.green[100]
                      : Colors.orange[100],
                ),
                child: Icon(
                  vaccine.isDone ? Icons.check : Icons.schedule,
                  color: vaccine.isDone ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      vaccine.status,
                      style: TextStyle(
                        fontSize: 11,
                        color: vaccine.isDone ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 11, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                vaccine.administeredDate?.toString().split(' ')[0] ??
                vaccine.nextDueDate?.toString().split(' ')[0] ?? '--',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(width: 14),
              Icon(Icons.location_on, size: 11, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vaccine.providerName ?? 'Không xác định',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            vaccine.doseType ?? 'Liều tiêm',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
