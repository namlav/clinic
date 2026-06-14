import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cancel_success_screen.dart';

class CancelAppointmentScreen extends StatefulWidget {
  final int appointmentId;

  const CancelAppointmentScreen({super.key, required this.appointmentId});

  @override
  State<CancelAppointmentScreen> createState() =>
      _CancelAppointmentScreenState();
}

class _CancelAppointmentScreenState extends State<CancelAppointmentScreen> {
  final Color primaryColor = const Color(0xFF003D81);
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  Map<String, dynamic>? appointmentData;

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  Future<void> _loadAppointmentDetails() async {
    setState(() => isLoading = true);
    try {
      print('Loading appointment details for ID: ${widget.appointmentId}');

      final response = await supabase
          .from('appointments')
          .select('*, doctors(fullname, avatarurl, specialties(specialtyname))')
          .eq('appointmentid', widget.appointmentId)
          .single();

      print('Appointment loaded: $response');

      setState(() {
        appointmentData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải chi tiết: $e')));
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleCancelAppointment() async {
    if (appointmentData == null) return;

    setState(() => isLoading = true);
    try {
      print('Attempting to cancel appointment ID: ${widget.appointmentId}');

      final result = await supabase
          .from('appointments')
          .update({'status': 'Cancelled'})
          .eq('appointmentid', widget.appointmentId);

      print('Cancel result: $result');
      print('Appointment cancelled successfully');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CancelSuccessScreen(
              appointmentId: widget.appointmentId,
              doctorName: appointmentData?['doctors']?['fullname'] ?? 'Bác sĩ',
              date: appointmentData?['appointmentdate'] ?? '',
              time:
                  appointmentData?['starttime']?.toString().split('.').first ??
                  '',
              specialty:
                  appointmentData?['doctors']?['specialties']?['specialtyname'] ??
                  'Chuyên khoa',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi hủy lịch: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && appointmentData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final doctor = appointmentData?['doctors'] as Map<String, dynamic>?;
    final doctorName = doctor?['fullname'] ?? 'Bác sĩ';
    final specialty = doctor?['specialties']?['specialtyname'] ?? 'Chuyên khoa';
    final appointmentDate = appointmentData?['appointmentdate'] ?? '';
    final appointmentTime =
        appointmentData?['starttime']?.toString().split('.').first ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003D81)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hủy lịch',
          style: TextStyle(
            color: Color(0xFF003D81),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Xác nhận hủy lịch',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chúng tôi rất tiếc khi bạn không thể tham gia buổi khám này. Vui lòng xác nhận thông tin bên dưới.',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: doctor?['avatarurl'] != null
                        ? NetworkImage(doctor!['avatarurl']!)
                        : null,
                    child: doctor?['avatarurl'] == null
                        ? Text(
                            doctorName.isNotEmpty
                                ? doctorName[0].toUpperCase()
                                : 'B',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    specialty.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.calendar_today, appointmentDate),
                  const SizedBox(height: 8),
                  _infoRow(Icons.access_time, appointmentTime),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.help_outline, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bạn có chắc chắn muốn hủy lịch hẹn này không?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'LÝ DO HỦY LỊCH (KHÔNG BẮT BUỘC)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Vui lòng cho chúng tôi biết lý do để SereneHealth có thể phục vụ bạn tốt hơn...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Giữ lại lịch',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: isLoading ? null : _handleCancelAppointment,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Xác nhận hủy',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
