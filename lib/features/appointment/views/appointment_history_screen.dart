import 'package:flutter/material.dart';
import '../../profile/models/medical_appointment_model.dart';
import '../../../widgets/fade_page_route.dart';
import 'appointment_detail_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  late TextEditingController searchController;
  String selectedFilter = 'Tất cả';
  late Future<List<MedicalAppointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _appointmentsFuture = MedicalAppointment.fetch();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3B4754)),
        title: const Text(
          'Lịch Sử Khám Bệnh',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<MedicalAppointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final appointments = snapshot.data ?? [];
          final query = searchController.text.toLowerCase();
          final filteredAppointments = appointments.where((apt) {
            final matchesSearch =
                query.isEmpty ||
                apt.doctorName.toLowerCase().contains(query) ||
                apt.hospital.toLowerCase().contains(query);

            var matchesFilter = true;
            if (selectedFilter == 'Hoàn thành') {
              matchesFilter = !apt.isUpcoming;
            } else if (selectedFilter == 'Sắp tới') {
              matchesFilter = apt.isUpcoming;
            }

            return matchesSearch && matchesFilter;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(appointments),
                const SizedBox(height: 16),
                _buildSearchSection(filteredAppointments.length),
                const SizedBox(height: 18),
                _buildSectionHeading(filteredAppointments.length),
                const SizedBox(height: 12),
                if (filteredAppointments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Không tìm thấy lịch khám',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ),
                  )
                else
                  ...filteredAppointments.map(_buildAppointmentTile),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<MedicalAppointment> appointments) {
    final nextAppointment = appointments.isNotEmpty
        ? (appointments.firstWhere(
            (a) => a.isUpcoming,
            orElse: () => appointments.first,
          ))
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(31),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Lịch khám gần đây',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Giữ lịch khám của bạn luôn cập nhật',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (nextAppointment != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(nextAppointment.appointmentDate),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextAppointment.doctorName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Lần khám',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${appointments.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Chưa có lịch khám',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBadge(
                  icon: Icons.check_circle,
                  label: 'Hoàn thành',
                  value:
                      '${appointments.where((a) => !a.isUpcoming).length} lần',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryBadge(
                  icon: Icons.schedule,
                  label: 'Sắp tới',
                  value:
                      '${appointments.where((a) => a.isUpcoming).length} lần',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm bác sĩ, bệnh viện...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.filter_alt_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSelectionChip('Tất cả'),
              _buildSelectionChip('Hoàn thành'),
              _buildSelectionChip('Sắp tới'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withAlpha(31),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('cancel')) {
      return const Color(0xFFFFEAEA);
    } else if (lowerStatus.contains('pending') || lowerStatus.contains('chờ')) {
      return const Color(0xFFFFF7ED);
    } else if (lowerStatus.contains('confirm') || lowerStatus.contains('xác')) {
      return const Color(0xFFEFF6FF);
    } else if (lowerStatus.contains('complete') ||
        lowerStatus.contains('hoàn')) {
      return const Color(0xFFEFF6EE);
    }
    return const Color(0xFFF3F4F6);
  }

  Color _getStatusTextColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('cancel')) {
      return const Color(0xFFDC2626);
    } else if (lowerStatus.contains('pending') || lowerStatus.contains('chờ')) {
      return const Color(0xFFB45309);
    } else if (lowerStatus.contains('confirm') || lowerStatus.contains('xác')) {
      return const Color(0xFF2563EB);
    } else if (lowerStatus.contains('complete') ||
        lowerStatus.contains('hoàn')) {
      return const Color(0xFF047857);
    }
    return const Color(0xFF6B7280);
  }

  Widget _buildSectionHeading(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch Khám Gần Đây',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count mục',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            foregroundColor: const Color(0xFF2563EB),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Xem thêm'),
        ),
      ],
    );
  }

  Widget _buildAppointmentTile(MedicalAppointment appointment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadePageRoute(
            builder: (context) =>
                AppointmentDetailScreen(appointmentId: int.parse(appointment.id)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(20),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    appointment.doctorName
                        .split(' ')
                        .take(2)
                        .map((word) => word[0])
                        .join(),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.specialization,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.hospital,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(appointment.status),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _getStatusTextColor(appointment.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatDate(appointment.appointmentDate),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
                Text(
                  appointment.notes,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
