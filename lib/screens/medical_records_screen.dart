import 'package:flutter/material.dart';
import '../models/health_record_model.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late List<HealthRecord> records;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    records = [
      HealthRecord(
        id: '1',
        title: 'Xét nghiệm máu',
        icon: '🔬',
        date: '12/02/2025',
        fileSize: '1.2 MB',
        fileFormat: 'PDF',
        isDownloadable: true,
      ),
      HealthRecord(
        id: '2',
        title: 'Chụp X quang vùng ngực',
        icon: '🫁',
        date: '21/01/2025',
        fileSize: '0.8 MB',
        fileFormat: 'PDF',
        isDownloadable: true,
      ),
      HealthRecord(
        id: '3',
        title: 'Toa thuốc',
        icon: '💊',
        date: '11/01/2025',
        fileSize: '450 KB',
        fileFormat: 'PDF',
        isDownloadable: true,
      ),
      HealthRecord(
        id: '4',
        title: 'Xét nghiệm nước tiểu',
        icon: '🧪',
        date: '01/01/2025',
        fileSize: '680 KB',
        fileFormat: 'PDF',
        isDownloadable: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hồ Sơ Y Tế',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 20),
            const Text(
              'Hồ Sơ Y Tế',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            ...records.map(_buildRecordTile),
            const SizedBox(height: 14),
            _buildMissingRecordCard(),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage: const AssetImage('assets/avatar.jpg'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nguyễn Khỏe Khoắn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Patient ID: #564774',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Tìm kiếm hồ sơ y tế của bạn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tìm kiếm hồ sơ...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(HealthRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.description,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.fileFormat,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      record.fileSize,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (record.isDownloadable)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Color(0xFF2563EB),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMissingRecordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF2563EB),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Thiếu hồ sơ?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tài trực tiếp hồ sơ còn thiếu hoặc gửi hồ sơ từ nhà cung cấp.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Tải lên'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tìm kiếm hồ sơ y tế...',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}
