import 'package:flutter/material.dart';
import '../models/vaccination_model.dart';

class VaccinationHistoryScreen extends StatefulWidget {
  const VaccinationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationHistoryScreen> createState() =>
      _VaccinationHistoryScreenState();
}

class _VaccinationHistoryScreenState extends State<VaccinationHistoryScreen> {
  late List<VaccinationRecord> vaccinations;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    vaccinations = [
      VaccinationRecord(
        id: '1',
        vaccineName: 'COVID-19 (Booster)',
        status: 'Tiếp Cộng',
        date: '',
        nextDate: '15/03/2025',
        location: 'Phòng khám Nguyễn Khôi Khoản',
        description: 'Liều tăng cường sau 6 tháng',
        isDone: false,
      ),
      VaccinationRecord(
        id: '2',
        vaccineName: 'COVID-19 (Modernized)',
        status: 'Đã Hoàn Thành',
        date: '12/10/2023',
        nextDate: '',
        location: 'Phòng Khám Thành Công',
        description: 'Liều 2',
        isDone: true,
      ),
      VaccinationRecord(
        id: '3',
        vaccineName: 'Influenza (Quadrivalent)',
        status: 'Đã Hoàn Thành',
        date: '08/09/2023',
        nextDate: '',
        location: 'Bệnh viện Quân Y',
        description: 'Liều 1',
        isDone: true,
      ),
      VaccinationRecord(
        id: '4',
        vaccineName: 'Viêm Gan B',
        status: 'Đã Hoàn Thành',
        date: '15/08/2023',
        nextDate: '',
        location: 'Bệnh viện Đại Anh',
        description: 'Liều 3',
        isDone: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final upcomingVaccines = vaccinations.where((v) => !v.isDone).toList();

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
          'Lịch Sử Tiêm Chủng',
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
            if (upcomingVaccines.isNotEmpty) ...[
              _buildUpcomingSection(upcomingVaccines.first),
              const SizedBox(height: 20),
            ],
            Text(
              'Lịch Trình',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...vaccinations.map((v) => _buildVaccinationTile(v)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(VaccinationRecord vaccine) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Luồng Cập Nhật',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sắp sắp đến hạn',
            style: TextStyle(color: Colors.blue[100], fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text(
            vaccine.vaccineName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vaccine.nextDate,
            style: TextStyle(color: Colors.blue[100], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            vaccine.description,
            style: TextStyle(color: Colors.blue[100], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationTile(VaccinationRecord vaccine) {
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      vaccine.status,
                      style: TextStyle(
                        fontSize: 11,
                        color: vaccine.isDone ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                vaccine.isDone ? vaccine.date : vaccine.nextDate,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vaccine.location,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            vaccine.description,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
