import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cancel_appointment_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> upcomingAppointments = [];
  List<Map<String, dynamic>> completedAppointments = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập!')));
        setState(() => isLoading = false);
        return;
      }

      print('Loading appointments for user: ${user.id}');

      // Get numeric userid from users table using authid
      final userResponse = await supabase
          .from('users')
          .select('userid')
          .eq('authid', user.id)
          .single();

      final numericUserId = userResponse['userid'] as int;
      print('Numeric userid: $numericUserId');

      final response = await supabase
          .from('appointments')
          .select('*, doctors(fullname, avatarurl, specialties(specialtyname))')
          .eq('userid', numericUserId);

      print('Appointments response: $response');
      print('Response count: ${response.length}');

      final upcoming = <Map<String, dynamic>>[];
      final completed = <Map<String, dynamic>>[];
      final now = DateTime.now();
      // Ngày hôm nay (chỉ lấy phần ngày, không tính giờ)
      final today = DateTime(now.year, now.month, now.day);

      // Danh sách id cần tự động cập nhật Completed trên DB
      final List<int> autoCompleteIds = [];

      for (var appointment in response) {
        print('Appointment: $appointment');

        final status = appointment['status'] as String? ?? '';

        // Bỏ qua các lịch đã hủy
        if (status == 'Cancelled') continue;

        if (status == 'Completed') {
          completed.add(appointment);
        } else if (status == 'Confirmed' || status == 'Pending') {
          // Kiểm tra ngày hẹn đã qua ngày hôm nay chưa
          bool pastDay = false;
          try {
            final dateStr = appointment['appointmentdate'] as String?;
            if (dateStr != null) {
              final appointmentDay = DateTime.parse(dateStr);
              // Ngày hẹn < hôm nay → đã qua ngày
              if (appointmentDay.isBefore(today)) {
                pastDay = true;
              }
            }
          } catch (e) {
            print('Lỗi parse ngày: $e');
          }

          if (pastDay) {
            // Ghi nhớ để batch update lên DB
            autoCompleteIds.add(appointment['appointmentid'] as int);
            // Cập nhật status cục bộ để hiển thị đúng ngay
            appointment['status'] = 'Completed';
            completed.add(appointment);
          } else {
            upcoming.add(appointment);
          }
        } else {
          // Trường hợp khác: kiểm tra theo thời gian thực tế
          try {
            final dateStr = appointment['appointmentdate'];
            final endTimeStr =
                appointment['endtime'] ?? appointment['starttime'];

            if (dateStr != null && endTimeStr != null) {
              final appointmentEndTime = DateTime.parse('$dateStr $endTimeStr');
              if (now.isAfter(appointmentEndTime)) {
                completed.add(appointment);
              } else {
                upcoming.add(appointment);
              }
            }
          } catch (e) {
            print('Lỗi parse ngày giờ: $e');
          }
        }
      }

      // Batch update các lịch quá hạn lên DB (không block UI)
      if (autoCompleteIds.isNotEmpty) {
        for (final id in autoCompleteIds) {
          supabase
              .from('appointments')
              .update({'status': 'Completed'})
              .eq('appointmentid', id)
              .then((_) => print('Auto-completed appointmentid: $id'))
              .catchError((e) => print('Lỗi auto-complete $id: $e'));
        }
      }

      print(
        'Upcoming count: ${upcoming.length}, Completed count: ${completed.length}',
      );

      setState(() {
        upcomingAppointments = upcoming;
        completedAppointments = completed;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải lịch: $e')));
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Trình'),
        actions: [
          IconButton(
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUpcomingTab(), _buildCompletedTab()],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcomingAppointments.isEmpty) {
      return Center(
        child: Text(
          'Không có lịch hẹn sắp tới',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        final doctor = appointment['doctors'] as Map<String, dynamic>?;
        final doctorName = doctor?['fullname'] ?? 'Bác sĩ';
        final avatarUrl =
            doctor?['avatarurl'] ?? 'https://via.placeholder.com/150';
        final specialty =
            doctor?['specialties']?['specialtyname'] ?? 'Chuyên khoa';

        // Tính xem đã đến giờ hẹn chưa
        final rawDate = appointment['appointmentdate'] as String? ?? '';
        final rawStart =
            appointment['starttime']?.toString().split('.').first ?? '';
        bool canComplete = false;
        try {
          final appointmentStart = DateTime.parse('$rawDate $rawStart');
          canComplete = DateTime.now().isAfter(appointmentStart);
        } catch (_) {}

        return Column(
          children: [
            _buildAppointmentCard(
              appointmentId: appointment['appointmentid'],
              doctorName: doctorName,
              specialty: specialty,
              date: rawDate,
              time: rawStart,
              location: appointment['roomname'] ?? 'Phòng Khám',
              imageUrl: avatarUrl,
              status: 'Sắp tới',
              canComplete: canComplete,
            ),
            if (index < upcomingAppointments.length - 1)
              const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (completedAppointments.isEmpty) {
      return Center(
        child: Text(
          'Không có lịch hẹn hoàn thành',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = completedAppointments[index];
        final doctor = appointment['doctors'] as Map<String, dynamic>?;
        final doctorName = doctor?['fullname'] ?? 'Bác sĩ';
        final avatarUrl =
            doctor?['avatarurl'] ?? 'https://via.placeholder.com/150';
        final specialty =
            doctor?['specialties']?['specialtyname'] ?? 'Chuyên khoa';

        return Column(
          children: [
            _buildAppointmentCard(
              appointmentId: appointment['appointmentid'],
              doctorName: doctorName,
              specialty: specialty,
              date: appointment['appointmentdate'] ?? '',
              time:
                  '${appointment['starttime']?.toString().split('.').first ?? ''}',
              location: appointment['roomname'] ?? 'Phòng Khám',
              imageUrl: avatarUrl,
              status: 'Hoàn thành',
              isCompleted: true,
            ),
            if (index < completedAppointments.length - 1)
              const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Future<void> _markAsCompleted(int appointmentId) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': 'Completed'})
          .eq('appointmentid', appointmentId);
      if (mounted) {
        // Hiển thị dialog hoàn thành
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Hoàn tất lịch hẹn!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003D81),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cảm ơn bạn đã sử dụng dịch vụ. Chúc bạn nhiều sức khỏe!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _tabController.animateTo(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D81),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        _loadAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildAppointmentCard({
    required int appointmentId,
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String location,
    required String imageUrl,
    required String status,
    bool isCompleted = false,
    bool canComplete = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(imageUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                location,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isCompleted) ...[
            // Nút Hoàn thành — chỉ bật khi đã đến giờ hẹn
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: canComplete
                    ? () => _markAsCompleted(appointmentId)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canComplete
                      ? const Color(0xFF003D81)
                      : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  canComplete ? 'Hoàn thành' : 'Chưa đến giờ khám',
                  style: TextStyle(
                    color: canComplete ? Colors.white : Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Nút Hủy lịch
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CancelAppointmentScreen(appointmentId: appointmentId),
                    ),
                  ).then((_) => _loadAppointments());
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(color: Colors.red, width: 1),
                ),
                child: const Text(
                  'Hủy lịch',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
