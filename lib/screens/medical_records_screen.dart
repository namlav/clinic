import 'package:flutter/material.dart';
import '../models/health_record_model.dart';
import '../services/health_record_repository.dart';
import '../services/supabase_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final HealthRecordRepository _repository = HealthRecordRepository();
  final SupabaseService _supabaseService = SupabaseService();

  List<HealthRecord> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      // Get the user record from the users table to get the numeric userid
      final userResponse = await _supabaseService.client
          .from('users')
          .select()
          .eq('authid', userId)
          .single();

      final numericUserId = userResponse['userid'] as int;

      final fetchedRecords = await _repository.getRecords(numericUserId);
      setState(() {
        records = fetchedRecords;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading records: $e');
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
          'Hồ Sơ Y Tế',
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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFE8F4F8),
                      border: Border.all(color: Colors.blue[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ghi chú về tài liệu của bạn',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[600],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                  const SizedBox(height: 24),
                  Text(
                    'Hồ Sơ Y Tế',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Center(
                      child: Text(
                        'Không có hồ sơ y tế',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  else
                    ...records.map((record) => _buildRecordTile(record)),
                ],
              ),
            ),
    );
  }

  Widget _buildRecordTile(HealthRecord record) {
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
          Text(record.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 11,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.date,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.description, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      record.fileFormat,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      record.fileSize ?? '--',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (record.isDownloadable)
            IconButton(
              icon: Icon(Icons.download, color: Colors.blue[600], size: 18),
              onPressed: () {
                if (record.fileUrl != null) {
                  _repository.downloadFile(record.fileUrl!, record.title);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
