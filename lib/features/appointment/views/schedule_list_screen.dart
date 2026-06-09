import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cancel_appointment_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> upcomingAppointments = [];
  List<Map<String, dynamic>> completedAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
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

      for (var appointment in response) {
        print('Appointment: $appointment');

        if (appointment['status'] == 'Cancelled') {
          // Skip cancelled appointments
          continue;
        }

        bool isCompleted = false;

        // Nếu trạng thái database đã là hoàn thành
        if (appointment['status'] != 'Upcoming' &&
            appointment['status'] != 'Pending') {
          isCompleted = true;
        } else {
          // Tự động kiểm tra thời gian thực tế
          try {
            final dateStr = appointment['appointmentdate'];
            final endTimeStr =
                appointment['endtime'] ?? appointment['starttime'];

            if (dateStr != null && endTimeStr != null) {
              final appointmentEndTime = DateTime.parse('$dateStr $endTimeStr');
              if (now.isAfter(appointmentEndTime)) {
                isCompleted = true;
              }
            }
          } catch (e) {
            print('Lỗi parse ngày giờ: $e');
          }
        }

        if (isCompleted) {
          completed.add(appointment);
        } else {
          upcoming.add(appointment);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch Trình'),
          actions: [
            IconButton(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Hoàn thành'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildUpcomingTab(), _buildCompletedTab()]),
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
              status: 'Sắp tới',
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
                      'Khoa tim mạch',
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
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003D81),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Chi đường',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    child: const Text(
                      'Nhắc hẹn',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CancelAppointmentScreen(
                            appointmentId: appointmentId,
                          ),
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
            ),
          ],
        ],
      ),
    );
  }
}
