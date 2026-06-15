import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  final int doctorId;
  const AppointmentHistoryScreen({super.key, required this.doctorId});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  final supabase = Supabase.instance.client;

  static const Color kPrimaryDark = Color(0xFF00468C);
  static const Color kPrimary = Color(0xFF0056D2);
  static const Color kBackground = Color(0xFFF8FAFC);

  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];

  // Mặc định: 3 tháng gần nhất tính tới hôm nay
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    // 3 tháng gần nhất (DateTime tự chuẩn hóa khi month <= 0)
    _fromDate = DateTime(now.year, now.month - 3, now.day);
    _loadHistory();
  }

  String _dateKey(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // Chuẩn hoá khoá ngày 'yyyy-MM-dd' từ chuỗi DB (date / timestamp / có 'T' hoặc khoảng trắng)
  String _dateKeyFromRaw(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    if (s.isEmpty) return '';
    final parsed = DateTime.tryParse(s.replaceFirst(' ', 'T'));
    if (parsed != null) return _dateKey(parsed);
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final fromStr = _dateKey(_fromDate);
      final toStr = _dateKey(_toDate);
      // Chặn trên nới thêm 1 ngày để không loại nhầm bản ghi ngày cuối
      // khi cột appointmentdate là kiểu timestamp/timestamptz.
      final endExclusive =
          _dateKey(_toDate.add(const Duration(days: 1)));

      final data = await supabase
          .from('appointments')
          .select('*, users:userid(fullname, phone)')
          .eq('doctorid', widget.doctorId)
          .gte('appointmentdate', fromStr)
          .lt('appointmentdate', endExclusive)
          .order('appointmentdate', ascending: false)
          .order('starttime', ascending: false);

      final raw = List<Map<String, dynamic>>.from(data);
      // Lọc lại phía client theo khoá ngày đã chuẩn hoá [fromStr..toStr].
      final filtered = raw.where((a) {
        final key = _dateKeyFromRaw(a['appointmentdate']);
        return key.compareTo(fromStr) >= 0 && key.compareTo(toStr) <= 0;
      }).toList();

      debugPrint("Lịch sử khám: doctorId=${widget.doctorId} "
          "$fromStr..$toStr | raw=${raw.length} | filtered=${filtered.length}");

      setState(() {
        _results = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải lịch sử khám: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
    _loadHistory();
  }

  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  String _patientName(Map<String, dynamic> app) {
    final users = app['users'];
    if (users is Map) return (users['fullname'] ?? 'Bệnh nhân').toString();
    return 'Bệnh nhân';
  }

  String _time(dynamic raw) {
    final s = (raw ?? '').toString();
    if (s.length >= 5) return s.substring(0, 5);
    return s.isEmpty ? '--:--' : s;
  }

  String _dateLabel(Map<String, dynamic> app) {
    final raw = (app['appointmentdate'] ?? '').toString();
    final d = DateTime.tryParse(raw);
    return d != null ? _fmtDate(d) : raw;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Confirmed':
        return kPrimary;
      case 'Completed':
        return const Color(0xFF22C55E);
      default:
        return Colors.red;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ duyệt';
      case 'Confirmed':
        return 'Đã nhận ca';
      case 'Completed':
        return 'Hoàn tất';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
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
            _buildFilterBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: kPrimary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _results.length,
                            itemBuilder: (context, i) =>
                                _buildHistoryCard(_results[i]),
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
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Lịch sử khám",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(child: _dateButton("Từ ngày", _fromDate, () => _pickDate(true))),
          const SizedBox(width: 10),
          Expanded(child: _dateButton("Đến ngày", _toDate, () => _pickDate(false))),
        ],
      ),
    );
  }

  Widget _dateButton(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 13, color: kPrimary),
                const SizedBox(width: 6),
                Text(
                  _fmtDate(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, size: 48, color: kPrimary),
            ),
            const SizedBox(height: 20),
            const Text(
              "Không có ca khám nào",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Không tìm thấy ca khám trong khoảng thời gian đã chọn.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? '';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.person, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patientName(item),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _dateLabel(item),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _time(item['starttime']),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}