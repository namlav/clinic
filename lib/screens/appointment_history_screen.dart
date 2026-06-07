import 'package:flutter/material.dart';
import '../models/medical_appointment_model.dart';
import '../services/appointment_repository.dart';
import '../services/supabase_service.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  final AppointmentRepository _repository = AppointmentRepository();
  final SupabaseService _supabaseService = SupabaseService();

  List<MedicalAppointment> appointments = [];
  List<MedicalAppointment> filteredAppointments = [];
  String selectedFilter = 'Tất cả';
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterAppointments);
    _loadAppointments();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
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

      final fetchedAppointments = await _repository.getAppointments(numericUserId);
      setState(() {
        appointments = fetchedAppointments;
        filteredAppointments = appointments;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterAppointments() {
    setState(() {
      filteredAppointments = appointments.where((apt) {
        bool matchesSearch = searchController.text.isEmpty ||
            (apt.doctorName?.toLowerCase().contains(searchController.text.toLowerCase()) ?? false);

        bool matchesFilter = true;
        if (selectedFilter == 'Hoàn thành') {
          matchesFilter = !apt.isUpcoming;
        } else if (selectedFilter == 'Sắp tới') {
          matchesFilter = apt.isUpcoming;
        }

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    _filterAppointments();
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
          'Lịch Sử Khám Bệnh',
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
                  _buildSearchAndFilter(),
                  const SizedBox(height: 20),
                  _buildUpcomingAppointment(),
                  const SizedBox(height: 20),
                  Text(
                    'Lịch Khám Gần Đây',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredAppointments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Không tìm thấy lịch khám',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ...filteredAppointments.map((apt) => _buildAppointmentTile(apt)),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 18),
            suffixIcon: Icon(Icons.tune, color: Colors.blue[600], size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[600]!, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tất cả'),
              _buildFilterChip('Hoàn thành'),
              _buildFilterChip('Sắp tới'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        onSelected: (selected) {
          _onFilterChanged(label);
        },
        backgroundColor: isSelected ? Colors.blue[600] : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildUpcomingAppointment() {
    final upcoming = appointments.where((a) => a.isUpcoming).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final apt = upcoming.first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFE8F4F8),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch Khám Sắp Tới',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${apt.appointmentDate.day}/${apt.appointmentDate.month}/${apt.appointmentDate.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.blue[600], size: 18),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(MedicalAppointment appointment) {
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
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue[600], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName ?? 'Bác sĩ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      appointment.specialization ?? 'Chuyên khoa',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    Text(
                      appointment.roomName ?? 'Phòng khám',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: appointment.isUpcoming
                  ? Colors.orange[100]
                  : Colors.green[100],
            ),
            child: Text(
              appointment.status ?? 'Chưa xác định',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: appointment.isUpcoming
                    ? Colors.orange[700]
                    : Colors.green[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 11, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
