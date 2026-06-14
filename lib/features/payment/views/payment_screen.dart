import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int doctorId;
  final String bookingDate;
  final String bookingTime;
  final int appointmentId;
  final String? serviceName;
  final double? servicePrice;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.bookingDate,
    required this.bookingTime,
    required this.appointmentId,
    this.serviceName,
    this.servicePrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'MoMo';
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  Map<String, dynamic>? doctorData;
  Timer? _timer;
  int _remainingSeconds = 300; // 5 phút

  @override
  void initState() {
    super.initState();
    _fetchDoctorInfo();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleTimeout() async {
    if (_isLoading) return; // Không hủy nếu đang xử lý thanh toán dở dang
    setState(() => _isLoading = true);
    try {
      await supabase
          .from('appointments')
          .update({'status': 'Cancelled'})
          .eq('appointmentid', widget.appointmentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thời gian giữ chỗ đã hết. Lịch hẹn của bạn đã bị hủy tự động.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Lỗi khi hủy do hết giờ: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _fetchDoctorInfo() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('doctors')
          .select('*, specialties(specialtyname)')
          .eq('doctorid', widget.doctorId)
          .single();

      setState(() {
        doctorData = response;
      });
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePayment() async {
    if (doctorData == null) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thực hiện thanh toán!'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Get numeric userid from users table using authid
      final userResponse = await supabase
          .from('users')
          .select('userid')
          .eq('authid', user.id)
          .single();

      final numericUserId = userResponse['userid'] as int;

      final randomInvoice =
          'SH-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final double consultationFee =
          double.tryParse(doctorData!['consultationfee'].toString()) ?? 500000;
      final double servicePrice = widget.servicePrice ?? 0;
      final double totalFee = consultationFee + servicePrice;

      // Parse starttime: "09:30 AM" -> "09:30:00"
      String startTime = _parseTimeToHHMMSS(widget.bookingTime);
      // Calculate endtime: add 1 hour to starttime
      String endTime = _addHourToTime(startTime);

      // Cập nhật trạng thái lịch hẹn đã tạo ở màn hình trước
      await supabase
          .from('appointments')
          .update({'status': 'Confirmed'})
          .eq('appointmentid', widget.appointmentId);

      // Insert payment — appointmentid để RLS tự verify qua join appointments
      await supabase.from('payments').insert({
        'appointmentid': widget.appointmentId,
        'userid': numericUserId,
        'transactioncode': randomInvoice,
        'baseamount': consultationFee,
        'discountamount': 0,
        'totalamount': totalFee,
        'paymentmethod': selectedMethod,
        'paymentdate': DateTime.now().toIso8601String(),
        'status': 'Success',
      });

      _timer?.cancel(); // Ngắt bộ đếm khi thanh toán thành công

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              transactionCode: randomInvoice,
              totalAmount: '${totalFee.toStringAsFixed(0)}đ',
              date: widget.bookingDate,
              time: widget.bookingTime,
              doctorName: doctorData!['fullname'] ?? 'Bác sĩ',
              appointmentId: widget.appointmentId.toString(),
              doctorAvatar:
                  doctorData!['avatarurl'] ?? 'https://via.placeholder.com/150',
              specialty:
                  doctorData?['specialties']?['specialtyname'] ?? 'Chuyên khoa',
              serviceName: widget.serviceName,
            ),
          ),
        );
      }
    } on PostgrestException catch (e) {
      print("Postgrest Error: ${e.message}");
      if (mounted) {
        // Bắt lỗi 23505: Unique constraint violation (Trùng lịch)
        if (e.code == '23505' ||
            e.message.contains('unique_appointment_slot') ||
            e.message.contains('duplicate key')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Rất tiếc, khung giờ này vừa có người nhanh tay đặt trước. Vui lòng chọn giờ khác!',
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi CSDL: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAndPop() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      // Huỷ lịch hẹn nếu người dùng thoát mà chưa thanh toán
      await supabase
          .from('appointments')
          .update({'status': 'Cancelled'})
          .eq('appointmentid', widget.appointmentId);
    } catch (e) {
      print('Lỗi khi huỷ lịch hẹn do thoát: $e');
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && doctorData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String doctorName = doctorData?['fullname'] ?? 'Chưa rõ bác sĩ';
    final String specialtyName =
        doctorData?['specialties']?['specialtyname'] ?? 'Nội tổng quát';
    final double consultationFee =
        double.tryParse(
          doctorData?['consultationfee'].toString() ?? '500000',
        ) ??
        500000;
    final double servicePrice = widget.servicePrice ?? 0;
    final double totalFee = consultationFee + servicePrice;

    return WillPopScope(
      onWillPop: () async {
        await _cancelAndPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF003D81)),
            onPressed: _cancelAndPop,
          ),
          title: const Text(
            'Thanh toán',
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
              // Thanh hiển thị thời gian đếm ngược
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thời gian thanh toán còn lại: $_formattedTime',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003D81), Color(0xFF0056B3)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cuộc hẹn với',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialtyName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.bookingDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.bookingTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Phí khám
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PHÍ KHÁM',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${consultationFee.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Phí dịch vụ (nếu có)
                    if (widget.serviceName != null) ...[  
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.serviceName!,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '+${servicePrice.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 20),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TỔNG CỘNG',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${totalFee.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildPaymentMethod(
                'Ví MoMo',
                'MoMo',
                'assets/images/momo_logo.png',
              ),
              _buildPaymentMethod(
                'Thẻ ATM / Napas',
                'ATM',
                'assets/images/logo_atm.png',
              ),
              _buildPaymentMethod(
                'ZaloPay',
                'ZaloPay',
                'assets/images/zalopay_logo.png',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${totalFee.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003D81),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003D81),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Thanh toán ngay',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String value, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selectedMethod == value
                ? const Color(0xFF003D81)
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        title: Row(
          children: [
            imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.payment, size: 30, color: Colors.blue),
                  )
                : Image.asset(
                    imagePath,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.payment, size: 30, color: Colors.blue),
                  ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        value: value,
        groupValue: selectedMethod,
        onChanged: (val) => setState(() => selectedMethod = val.toString()),
      ),
    );
  }

  String _parseTimeToHHMMSS(String timeString) {
    try {
      timeString = timeString.trim();
      final parts = timeString.split(':');

      if (parts.isEmpty) return '09:00:00';

      int hour = int.tryParse(parts[0]) ?? 9;
      int minute = 0;

      if (parts.length > 1) {
        final minuteAndPeriod = parts[1].split(' ');
        minute = int.tryParse(minuteAndPeriod[0]) ?? 0;

        // Handle AM/PM
        if (timeString.contains('PM') && hour != 12) {
          hour += 12;
        } else if (timeString.contains('AM') && hour == 12) {
          hour = 0;
        }
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      print('Error parsing time: $e');
      return '09:00:00';
    }
  }

  /// Adds 1 hour to a time string in "HH:MM:SS" format
  String _addHourToTime(String timeString) {
    try {
      final parts = timeString.split(':');
      int hour = int.tryParse(parts[0]) ?? 9;
      int minute = int.tryParse(parts[1]) ?? 0;

      hour += 1;
      if (hour >= 24) hour = 0;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      print('Error adding hour: $e');
      return '10:00:00';
    }
  }
}
