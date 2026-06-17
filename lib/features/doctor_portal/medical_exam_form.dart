import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalExamForm extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  const MedicalExamForm({super.key, required this.appointmentData});

  @override
  State<MedicalExamForm> createState() => _MedicalExamFormState();
}

class _MedicalExamFormState extends State<MedicalExamForm> {
  // Bảng màu đồng bộ toàn app
  static const Color kPrimaryDark = Color(0xFF00468C);
  static const Color kPrimary = Color(0xFF0056D2);
  static const Color kBackground = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  bool get _isCompleted => widget.appointmentData['status'] == 'Completed';

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _patientName() {
    final users = widget.appointmentData['users'];
    if (users is Map) return (users['fullname'] ?? 'Bệnh nhân').toString();
    return 'Bệnh nhân';
  }

  String _startTime() {
    final raw = (widget.appointmentData['starttime'] ?? '').toString();
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw.isEmpty ? '--:--' : raw;
  }

  Future<void> _submitExamResult() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      final notes = _notesController.text.trim();
      var prescription = _prescriptionController.text.trim();
      if (notes.isNotEmpty) {
        prescription = "$prescription\n\nLời dặn: $notes";
      }

      // 1. Lưu vào bảng medicalrecords
      final inserted = await supabase.from('medicalrecords').insert({
        'userid': widget.appointmentData['userid'], // ID Bệnh nhân
        'appointmentid': widget.appointmentData['appointmentid'], // ID Cuộc hẹn
        'doctorid': widget.appointmentData['doctorid'], // ID Bác sĩ
        'diagnosis': _diagnosisController.text.trim(), // Chẩn đoán
        'prescription': prescription, // Đơn thuốc + lời dặn
        'recordtype': 'KhamLamSang', // Loại hồ sơ (mặc định)
        'recorddate': DateTime.now().toIso8601String(), // Ngày ghi hồ sơ
      }).select('recordid').single();

      // 2. Cập nhật trạng thái cuộc hẹn
      try {
        await supabase
            .from('appointments')
            .update({'status': 'Completed'})
            .eq('appointmentid', widget.appointmentData['appointmentid']);
      } catch (e) {
        // Rollback hồ sơ vừa tạo để tránh trạng thái không nhất quán
        await supabase
            .from('medicalrecords')
            .delete()
            .eq('recordid', inserted['recordid']);
        rethrow;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lưu hồ sơ bệnh án thành công!"),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi lưu hồ sơ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientCard(),
                      const SizedBox(height: 24),
                      _buildFieldLabel(
                          Icons.medical_information, "Chẩn đoán bệnh lý"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _diagnosisController,
                        maxLines: 3,
                        hint: "Nhập kết quả chẩn đoán...",
                        enabled: !_isCompleted,
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? "Không được để trống"
                            : null,
                      ),
                      const SizedBox(height: 22),
                      _buildFieldLabel(
                          Icons.medication_outlined, "Đơn thuốc & Dịch vụ"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _prescriptionController,
                        maxLines: 5,
                        hint: "Nhập đơn thuốc và các xét nghiệm phát sinh...",
                        enabled: !_isCompleted,
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? "Không được để trống"
                            : null,
                      ),
                      const SizedBox(height: 22),
                      _buildFieldLabel(
                          Icons.sticky_note_2_outlined, "Ghi chú / Lời dặn"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _notesController,
                        maxLines: 2,
                        enabled: !_isCompleted,
                        hint: "Lời dặn dành cho bệnh nhân...",
                      ),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryDark, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Phiếu khám bệnh",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 2),
            child: Text(
              "Nhập kết quả chẩn đoán và đơn thuốc",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: kPrimary.withValues(alpha: 0.12),
            child: const Icon(Icons.person, color: kPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patientName(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Giờ khám: ${_startTime()}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isCompleted ? Colors.green.withValues(alpha: 0.1) : kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _isCompleted ? "Đã hoàn thành" : "Đang khám",
              style: TextStyle(
                color: _isCompleted ? Colors.green : kPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1A1F36),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required int maxLines,
    required String hint,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // nút lưu
  Widget _buildSubmitButton() {
    if (_isCompleted) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isSaving ? null : _submitExamResult,
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "HOÀN TẤT CA KHÁM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}