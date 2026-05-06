import 'package:flutter/material.dart';
import '../models/health_record_model.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({Key? key}) : super(key: key);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hồ Sơ Y Tế',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[50],
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghi chú về tài liệu của bạn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tất cả hồ sơ y tế được mã hóa và an toàn',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hồ Sơ Y Tế',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...records.map((record) => _buildRecordTile(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(HealthRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Text(record.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.date,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.description, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      record.fileFormat,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      record.fileSize,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (record.isDownloadable)
            IconButton(
              icon: Icon(Icons.download, color: Colors.blue[600], size: 20),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
