import 'package:flutter/material.dart';
import '../models/medical_appointment_model.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  late List<MedicalAppointment> appointments;
  late List<MedicalAppointment> filteredAppointments;
  String selectedFilter = 'Tất cả';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    searchController.addListener(_filterAppointments);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    appointments = [
      MedicalAppointment(
        id: '1',
        doctorName: 'PGS.TS.BS. Nguyễn Trí Thoại',
        specialization: '🩺 Khoa tim mạch',
        hospital: 'Bệnh viện Anh',
        avatarUrl: 'assets/doctor1.jpg',
        appointmentDate: DateTime(2025, 4, 24),
        status: 'Hoàn thành',
        notes: 'Khám sức khỏe định kỳ',
        isUpcoming: false,
      ),
      MedicalAppointment(
        id: '2',
        doctorName: 'TS.BS. Đặng Vinh Quang',
        specialization: '🏥 Khoa nội tiết',
        hospital: 'Bệnh viện Nhân Sâm',
        avatarUrl: 'assets/doctor2.jpg',
        appointmentDate: DateTime(2025, 5, 12),
        status: 'Hoàn thành',
        notes: 'Khám tiểu đường',
        isUpcoming: false,
      ),
      MedicalAppointment(
        id: '3',
        doctorName: 'PGS.TS.BS. Lê Thái Văn Thạnh',
        specialization: '👨‍⚕️ Khoa nội khoa',
        hospital: 'Bệnh viện Sài Gòn',
        avatarUrl: 'assets/doctor3.jpg',
        appointmentDate: DateTime(2025, 6, 15),
        status: 'Sắp tới',
        notes: 'Tái khám',
        isUpcoming: true,
      ),
      MedicalAppointment(
        id: '4',
        doctorName: 'BS. Phòng Khám Ngành Đảng',
        specialization: '👩‍⚕️ Khoa nha khoa',
        hospital: 'Bệnh viện Miễn Quy',
        avatarUrl: 'assets/doctor4.jpg',
        appointmentDate: DateTime(2025, 6, 25),
        status: 'Nhắc nhở',
        notes: 'Lịch khám gần nhất',
        isUpcoming: true,
      ),
    ];
    filteredAppointments = appointments;
  }

  void _filterAppointments() {
    setState(() {
      filteredAppointments = appointments.where((apt) {
        bool matchesSearch = searchController.text.isEmpty ||
            apt.doctorName.toLowerCase().contains(searchController.text.toLowerCase()) ||
            apt.hospital.toLowerCase().contains(searchController.text.toLowerCase());

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch Sử Khám Bệnh',
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
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            _buildUpcomingAppointment(),
            const SizedBox(height: 20),
            Text(
              'Lịch Khám Gần Đây',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: Icon(Icons.tune, color: Colors.blue[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildUpcomingAppointment() {
    final upcoming = appointments.where((a) => a.isUpcoming).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final apt = upcoming.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue[50],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch Khám Sắp Tới',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${apt.appointmentDate.day}/${apt.appointmentDate.month}/${apt.appointmentDate.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.blue[600]),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(MedicalAppointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      appointment.specialization,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      appointment.hospital,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: appointment.isUpcoming
                  ? Colors.orange[100]
                  : Colors.green[100],
            ),
            child: Text(
              appointment.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: appointment.isUpcoming
                    ? Colors.orange[700]
                    : Colors.green[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
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
