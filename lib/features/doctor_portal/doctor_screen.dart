import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'medical_exam_form.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final supabase = Supabase.instance.client;

  // Bảng màu đồng bộ toàn app
  static const Color kPrimaryDark = Color(0xFF00468C);
  static const Color kPrimary = Color(0xFF0056D2);
  static const Color kBackground = Color(0xFFF8FAFC);

  bool _isLoading = true;
  String _doctorName = "";
  int _navIndex = 0;
  int? _doctorId;
  Map<String, dynamic>? _doctorInfo;
  List<Map<String, dynamic>> _todayAppointments = [];

  // Lịch tuần: map 'yyyy-MM-dd' -> danh sách ca trong ngày đó
  Map<String, List<Map<String, dynamic>>> _weekAppointments = {};
  DateTime _currentWeekStart = _mondayOf(DateTime.now());
  bool _isWeekLoading = false;

  // Các biến thống kê
  int _totalToday = 0;
  int _pendingCount = 0;
  int _completedCount = 0;

  // Lịch làm việc (doctor_availabilities)
  List<Map<String, dynamic>> _availabilities = [];
  bool _isWorkdayLoading = false;

  // Lấy ngày thứ Hai của tuần chứa [date]
  static DateTime _mondayOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 1a. Lấy userid từ bảng users theo authid (auth.uid của Supabase)
      final userRow = await supabase
          .from('users')
          .select('userid')
          .eq('authid', user.id)
          .single();

      // 1b. Lấy thông tin bác sĩ theo userid (bảng doctors không có authid)
      final doctorInfo = await supabase
          .from('doctors')
          .select('*, specialties(specialtyname)')
          .eq('userid', userRow['userid'])
          .single();
      _doctorInfo = doctorInfo;
      _doctorId = doctorInfo['doctorid'] as int?;
      _doctorName = doctorInfo['fullname'] ?? '';

      // 2. Lấy lịch khám TRONG NGÀY HÔM NAY của bác sĩ
      final today = DateTime.now().toIso8601String().split('T')[0];
      final data = await supabase
          .from('appointments')
          .select('*, users:userid(fullname, phone)')
          .eq('doctorid', doctorInfo['doctorid'])
          .eq('appointmentdate', today)
          .order('starttime', ascending: true);

      final list = List<Map<String, dynamic>>.from(data);

      setState(() {
        _todayAppointments = list;
        _totalToday = list.length;
        _pendingCount =
            list.where((a) => a['status'] == 'Pending').length;
        _completedCount =
            list.where((a) => a['status'] == 'Completed').length;
        _isLoading = false;
      });

      // Tải luôn lịch tuần hiện tại
      _loadWeekData();
      // Tải luôn lịch làm việc đã đăng ký
      _loadAvailabilities();
    } catch (e) {
      debugPrint("Lỗi Dashboard: $e");
      setState(() => _isLoading = false);
    }
  }

  // Tải toàn bộ ca khám trong tuần đang xem
  Future<void> _loadWeekData() async {
    if (_doctorId == null) return;
    setState(() => _isWeekLoading = true);
    try {
      final weekEnd = _currentWeekStart.add(const Duration(days: 6));
      final startStr =
          _currentWeekStart.toIso8601String().split('T')[0];
      final endStr = weekEnd.toIso8601String().split('T')[0];

      final data = await supabase
          .from('appointments')
          .select('*, users:userid(fullname, phone)')
          .eq('doctorid', _doctorId!)
          .gte('appointmentdate', startStr)
          .lte('appointmentdate', endStr)
          .order('starttime', ascending: true);

      final list = List<Map<String, dynamic>>.from(data);
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final app in list) {
        final date = (app['appointmentdate'] ?? '').toString();
        grouped.putIfAbsent(date, () => []).add(app);
      }

      setState(() {
        _weekAppointments = grouped;
        _isWeekLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải lịch tuần: $e");
      setState(() => _isWeekLoading = false);
    }
  }

  void _changeWeek(int deltaWeeks) {
    setState(() {
      _currentWeekStart =
          _currentWeekStart.add(Duration(days: 7 * deltaWeeks));
    });
    _loadWeekData();
  }

  // ===================== LỊCH LÀM VIỆC (doctor_availabilities) =====================
  Future<void> _loadAvailabilities() async {
    if (_doctorId == null) return;
    setState(() => _isWorkdayLoading = true);
    try {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final data = await supabase
          .from('doctor_availabilities')
          .select('*')
          .eq('doctorid', _doctorId!)
          .gte('workdate', todayStr)
          .order('workdate', ascending: true)
          .order('starttime', ascending: true);

      setState(() {
        _availabilities = List<Map<String, dynamic>>.from(data);
        _isWorkdayLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải lịch làm việc: $e");
      setState(() => _isWorkdayLoading = false);
    }
  }

  Future<void> _addAvailability(
      DateTime date, TimeOfDay start, TimeOfDay end) async {
    if (_doctorId == null) return;
    String fmtTime(TimeOfDay t) =>
        "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";
    try {
      await supabase.from('doctor_availabilities').insert({
        'doctorid': _doctorId,
        'workdate': date.toIso8601String().split('T')[0],
        'starttime': fmtTime(start),
        'endtime': fmtTime(end),
        'createdat': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã thêm ngày làm việc."),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      _loadAvailabilities();
    } catch (e) {
      debugPrint("Lỗi thêm ngày làm: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi thêm ngày làm: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAvailability(dynamic id) async {
    try {
      await supabase
          .from('doctor_availabilities')
          .delete()
          .eq('availabilityid', id);
      _loadAvailabilities();
    } catch (e) {
      debugPrint("Lỗi xóa ngày làm: $e");
    }
  }

  // Mở dialog chọn ngày + giờ để đăng ký ca làm
  Future<void> _showAddAvailabilityDialog() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: "Chọn giờ bắt đầu",
    );
    if (pickedStart == null || !mounted) return;

    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
      helpText: "Chọn giờ kết thúc",
    );
    if (pickedEnd == null || !mounted) return;

    // Kiểm tra giờ kết thúc phải sau giờ bắt đầu
    final startMin = pickedStart.hour * 60 + pickedStart.minute;
    final endMin = pickedEnd.hour * 60 + pickedEnd.minute;
    if (endMin <= startMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giờ kết thúc phải sau giờ bắt đầu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _addAvailability(pickedDate, pickedStart, pickedEnd);
  }

  // Helper: lấy tên bệnh nhân an toàn (tránh crash khi null)
  void _showSnackBar(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  String _patientName(Map<String, dynamic> app) {
    final users = app['users'];
    if (users is Map) return (users['fullname'] ?? 'Bệnh nhân').toString();
    return 'Bệnh nhân';
  }

  // Helper: lấy giờ bắt đầu dạng HH:mm an toàn
  String _startTime(Map<String, dynamic> app) {
    final raw = (app['starttime'] ?? '').toString();
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw.isEmpty ? '--:--' : raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _navIndex,
              children: [
                _buildDashboardTab(),
                _buildWeeklyScheduleTab(),
                _buildWorkdayTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: _buildDoctorBottomNav(),
      floatingActionButton: (_navIndex == 2 && !_isLoading)
          ? FloatingActionButton.extended(
              onPressed: _showAddAvailabilityDialog,
              backgroundColor: kPrimary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Thêm ngày làm",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // ===================== TAB 0: DASHBOARD HÔM NAY =====================
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: kPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatGrid(),
                    const SizedBox(height: 28),
                    _buildNextPatientSpotlight(),
                    const SizedBox(height: 28),
                    _buildSectionTitle("Lịch khám hôm nay"),
                    const SizedBox(height: 14),
                    _buildTimeline(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== TAB 1: LỊCH TUẦN (thời khóa biểu T2-CN) =====================
  Widget _buildWeeklyScheduleTab() {
    const weekDayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day);

    return SafeArea(
      child: Column(
        children: [
          // Header tuần + nút chuyển tuần
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
              children: [
                const Text(
                  "Lịch làm việc trong tuần",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _weekArrow(Icons.chevron_left, () => _changeWeek(-1)),
                    Text(
                      _weekRangeLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _weekArrow(Icons.chevron_right, () => _changeWeek(1)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isWeekLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 7,
                    itemBuilder: (context, i) {
                      final day = _currentWeekStart.add(Duration(days: i));
                      final dayKey = day.toIso8601String().split('T')[0];
                      final apps = _weekAppointments[dayKey] ?? [];
                      final isToday = DateTime(day.year, day.month, day.day) ==
                          todayStr;
                      return _buildDayRow(
                          weekDayNames[i], day, apps, isToday);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _weekArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  String _weekRangeLabel() {
    final end = _currentWeekStart.add(const Duration(days: 6));
    String fmt(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
    return "${fmt(_currentWeekStart)} - ${fmt(end)}/${end.year}";
  }

  // 1 dòng = 1 ngày trong tuần (kiểu thời khóa biểu)
  Widget _buildDayRow(
    String dayName,
    DateTime day,
    List<Map<String, dynamic>> apps,
    bool isToday,
  ) {
    final hasApps = apps.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isToday
            ? Border.all(color: kPrimary, width: 1.5)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cột ngày
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isToday
                  ? kPrimary
                  : (hasApps
                      ? kPrimary.withValues(alpha: 0.08)
                      : Colors.grey.shade50),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                bottomLeft: Radius.circular(17),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isToday ? Colors.white : kPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isToday ? Colors.white : const Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
          ),
          // Cột ca khám
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: hasApps
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: apps.map((app) {
                        final color = _getStatusColor(
                            app['status']?.toString() ?? '');
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _startTime(app),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _patientName(app),
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Không có ca khám",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TAB 2: NGÀY LÀM (chờ schema từ nhóm trưởng) =====================
  Widget _buildWorkdayTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
            child: const Column(
              children: [
                Text(
                  "Đăng ký ngày làm việc",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Chọn ngày và khung giờ bạn nhận khám",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isWorkdayLoading
                ? const Center(child: CircularProgressIndicator())
                : _availabilities.isEmpty
                    ? _buildEmptyWorkday()
                    : RefreshIndicator(
                        onRefresh: _loadAvailabilities,
                        color: kPrimary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _availabilities.length,
                          itemBuilder: (context, i) =>
                              _buildAvailabilityCard(_availabilities[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkday() {
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
              child: const Icon(Icons.edit_calendar, size: 48, color: kPrimary),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chưa đăng ký ngày làm nào",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bấm nút bên dưới để thêm ngày và khung giờ "
              "bạn nhận khám cho bệnh nhân.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(Map<String, dynamic> item) {
    final workdate = (item['workdate'] ?? '').toString();
    DateTime? date;
    try {
      date = DateTime.parse(workdate);
    } catch (_) {}

    const weekDayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final dayLabel =
        date != null ? weekDayNames[date.weekday - 1] : '';
    final dateLabel = date != null
        ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
        : workdate;
    final start = _startTime(item);
    final end = _endTime(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showAvailabilityOptions(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date?.day.toString() ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "$start - $end",
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDeleteAvailability(item),
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Menu khi bấm vào thẻ ngày làm: Sửa giờ / Xóa
  void _showAvailabilityOptions(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: kPrimary),
              title: const Text("Sửa khung giờ"),
              onTap: () {
                Navigator.pop(context);
                _editAvailabilityTime(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Xóa ngày làm"),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteAvailability(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Sửa giờ bắt đầu / kết thúc của 1 ngày làm
  Future<void> _editAvailabilityTime(Map<String, dynamic> item) async {
    TimeOfDay parseTime(String raw, int fallbackHour) {
      try {
        final parts = raw.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {
        return TimeOfDay(hour: fallbackHour, minute: 0);
      }
    }

    final curStart = parseTime((item['starttime'] ?? '08:00').toString(), 8);
    final curEnd = parseTime((item['endtime'] ?? '17:00').toString(), 17);

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: curStart,
      helpText: "Sửa giờ bắt đầu",
    );
    if (pickedStart == null || !mounted) return;

    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: curEnd,
      helpText: "Sửa giờ kết thúc",
    );
    if (pickedEnd == null || !mounted) return;

    if ((pickedEnd.hour * 60 + pickedEnd.minute) <=
        (pickedStart.hour * 60 + pickedStart.minute)) {
      _showSnackBar("Giờ kết thúc phải sau giờ bắt đầu.", Colors.red);
      return;
    }

    String fmt(TimeOfDay t) =>
        "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

    try {
      await supabase.from('doctor_availabilities').update({
        'starttime': fmt(pickedStart),
        'endtime': fmt(pickedEnd),
      }).eq('availabilityid', item['availabilityid']);
      if (!mounted) return;
      _showSnackBar("Đã cập nhật khung giờ.", const Color(0xFF22C55E));
      _loadAvailabilities();
    } catch (e) {
      debugPrint("Lỗi sửa giờ: $e");
      if (!mounted) return;
      _showSnackBar("Lỗi sửa giờ: $e", Colors.red);
    }
  }

  void _confirmDeleteAvailability(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa ngày làm việc"),
        content: const Text("Bạn có chắc muốn xóa ca làm này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAvailability(item['availabilityid']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  // Helper: lấy giờ kết thúc dạng HH:mm an toàn
  String _endTime(Map<String, dynamic> item) {
    final raw = (item['endtime'] ?? '').toString();
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw.isEmpty ? '--:--' : raw;
  }

  // ===================== TAB 3: CÁ NHÂN =====================
  Widget _buildProfileTab() {
    final specialty =
        _doctorInfo?['specialties']?['specialtyname']?.toString() ??
            'Chuyên khoa';
    final fee = _doctorInfo?['consultationfee']?.toString() ?? '—';
    final avatar = _doctorInfo?['avatarurl']?.toString();
    final title = _doctorInfo?['title']?.toString().trim() ?? '';
    final experience = _doctorInfo?['experienceyears'];
    final rating = _doctorInfo?['rating'];
    final reviewCount = _doctorInfo?['reviewcount'];
    final education = _doctorInfo?['education']?.toString().trim() ?? '';
    final bio = _doctorInfo?['bio']?.toString().trim() ?? '';

    // Tên hiển thị: ghép title (nếu có) + tên, mặc định "BS."
    final displayName =
        title.isNotEmpty ? "$title $_doctorName" : "BS. $_doctorName";

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryDark, kPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: (avatar != null && avatar.isNotEmpty)
                          ? NetworkImage(avatar)
                          : const AssetImage('assets/images/ava1.jpg')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Dải chỉ số: đánh giá + kinh nghiệm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _headerStat(
                        Icons.star_rounded,
                        rating != null ? rating.toString() : '—',
                        "Đánh giá",
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        color: Colors.white24,
                      ),
                      _headerStat(
                        Icons.reviews_outlined,
                        reviewCount != null ? reviewCount.toString() : '0',
                        "Lượt nhận xét",
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        color: Colors.white24,
                      ),
                      _headerStat(
                        Icons.workspace_premium_outlined,
                        experience != null ? "$experience năm" : '—',
                        "Kinh nghiệm",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Giới thiệu (bio) - chỉ hiện khi có dữ liệu
                  if (bio.isNotEmpty) ...[
                    _buildSectionTitle("Giới thiệu"),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        bio,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionTitle("Thông tin"),
                  const SizedBox(height: 10),
                  _profileTile(Icons.medical_information, "Chuyên khoa",
                      specialty),
                  if (education.isNotEmpty)
                    _profileTile(Icons.school_outlined, "Học vấn", education),
                  _profileTile(Icons.payments_outlined, "Phí khám",
                      fee == '—' ? fee : "$fee đ"),
                  _profileTile(Icons.badge_outlined, "Mã bác sĩ",
                      _doctorId?.toString() ?? '—'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Đăng xuất",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ô chỉ số nhỏ trên header tab Cá nhân
  Widget _headerStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _profileTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint("Lỗi đăng xuất: $e");
    }
  }

  // ===================== BOTTOM NAV (style đồng bộ app) =====================
  Widget _buildDoctorBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'TRANG CHỦ'),
          _buildNavItem(1, Icons.calendar_today, 'LỊCH TUẦN'),
          _buildNavItem(2, Icons.edit_calendar, 'NGÀY LÀM'),
          _buildNavItem(3, Icons.person, 'CÁ NHÂN'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _navIndex = index);
        if (index == 0) _loadDashboardData();
        if (index == 1) _loadWeekData();
        if (index == 2) _loadAvailabilities();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[600] : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===================== HERO HEADER (gradient sang trọng) =====================
  Widget _buildHeroHeader() {
    final now = DateTime.now();
    String greeting = "Chào buổi sáng";
    if (now.hour >= 18) {
      greeting = "Chào buổi tối";
    } else if (now.hour >= 12) {
      greeting = "Chào buổi chiều";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryDark, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting,",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "BS. $_doctorName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Hôm nay bạn có $_totalToday ca khám.",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage('assets/images/ava1.jpg'),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== STAT GRID =====================
  Widget _buildStatGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatCell(
            "Tổng ca",
            _totalToday.toString(),
            Icons.event_note,
            kPrimary,
          ),
          _statDivider(),
          _buildStatCell(
            "Chờ duyệt",
            _pendingCount.toString(),
            Icons.hourglass_top,
            const Color(0xFFF59E0B),
          ),
          _statDivider(),
          _buildStatCell(
            "Hoàn tất",
            _completedCount.toString(),
            Icons.check_circle,
            const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.grey.shade200,
      );

  Widget _buildStatCell(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ===================== NEXT PATIENT SPOTLIGHT =====================
  Widget _buildNextPatientSpotlight() {
    final nextApp = _todayAppointments.firstWhere(
      (a) => a['status'] == 'Confirmed',
      orElse: () => {},
    );
    if (nextApp.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Tiêu điểm ca tiếp theo"),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kPrimaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _startTime(nextApp),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _patientName(nextApp),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Sẵn sàng thăm khám",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _navigateToForm(nextApp),
                child: const Text(
                  "BẮT ĐẦU KHÁM NGAY",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== TIMELINE DANH SÁCH CA =====================
  Widget _buildTimeline() {
    if (_todayAppointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "Hôm nay chưa có ca khám nào",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todayAppointments.length,
      itemBuilder: (context, index) {
        final item = _todayAppointments[index];
        final isLast = index == _todayAppointments.length - 1;
        final statusColor = _getStatusColor(item['status']?.toString() ?? '');

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột timeline (giờ + đường nối)
              Column(
                children: [
                  Text(
                    _startTime(item),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Thẻ thông tin ca
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              statusColor.withValues(alpha: 0.12),
                          child: Icon(Icons.person,
                              color: statusColor, size: 22),
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
                              _statusChip(item['status']?.toString() ?? ''),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                          ),
                          onPressed: () => _showQuickAction(item),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    final color = _getStatusColor(status);
    final label = _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  // ===================== ACTIONS =====================
  void _navigateToForm(Map<String, dynamic> app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalExamForm(appointmentData: app),
      ),
    ).then((_) => _loadDashboardData());
  }

  void _showQuickAction(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Ca khám: ${_patientName(item)}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (status == 'Pending') ...[
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Xác nhận nhận ca"),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(item['appointmentid'], 'Confirmed');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text("Từ chối ca này"),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(item['appointmentid'], 'Cancelled');
                },
              ),
            ],
            if (status == 'Confirmed')
              ListTile(
                leading:
                    const Icon(Icons.medical_services, color: kPrimary),
                title: const Text("Tiến hành khám"),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToForm(item);
                },
              ),
            if (status == 'Completed')
              const ListTile(
                leading: Icon(Icons.verified, color: Colors.green),
                title: Text("Ca khám đã hoàn tất"),
              ),
            if (status == 'Cancelled')
              const ListTile(
                leading: Icon(Icons.block, color: Colors.grey),
                title: Text("Ca khám đã bị hủy"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(dynamic id, String status) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': status})
          .eq('appointmentid', id);
    } catch (e) {
      debugPrint("Lỗi cập nhật trạng thái: $e");
    }
    _loadDashboardData();
  }

  Color _getStatusColor(String status) {
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1F36),
      ),
    );
  }
}