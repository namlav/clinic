import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../payment/views/payment_screen.dart';
import 'service_selection_screen.dart';

class DoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfilePage({super.key, required this.doctorData});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  DateTime currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime selectedDate = DateTime.now();
  int selectedTimeIndex = -1; // Đổi thành -1 để bắt buộc người dùng tự chọn giờ
  bool _isConfirming = false; // Biến trạng thái để khóa nút khi đang xử lý
  bool _isActive = true; // Mặc định là cho phép

  List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    try {
      final doctorId = widget.doctorData['doctorid'];
      if (doctorId == null) return;



      final dateStr =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      final response = await Supabase.instance.client
          .from('appointments')
          .select('starttime')
          .eq('doctorid', doctorId)
          .eq('appointmentdate', dateStr)
          .neq('status', 'Cancelled');

      final List<String> slots = (response as List).map((e) {
        final timeStr = e['starttime'].toString();
        return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
      }).toList();

      if (mounted) {
        setState(() {
          _bookedSlots = slots;
        });
      }
    } catch (e) {
      debugPrint("Lỗi fetch booked slots: $e");
    }
  }

  String _to24HourFormat(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    if (hour < 8) hour += 12; // 01:45 -> 13:45
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  String _addOneHour(String time24) {
    final parts = time24.split(':');
    if (parts.length >= 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      hour += 1;
      if (hour >= 24) hour = hour % 24;
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00";
    }
    return "$time24:00";
  }

  Future<void> _checkUserStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('users')
            .select('isactive')
            .eq('authid', user.id)
            .single();

        if (mounted) {
          setState(() {
            _isActive = data['isactive'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi kiểm tra trạng thái user: $e");
    }
  }

  void _showRestrictedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_person, color: Colors.red),
            SizedBox(width: 10),
            Text("Tài khoản bị hạn chế"),
          ],
        ),
        content: const Text(
          "Tài khoản của bạn đã bị hạn chế chức năng đặt lịch khám do vi phạm quy định hoặc chưa hoàn thiện hồ sơ. Vui lòng liên hệ hỗ trợ để biết thêm chi tiết.",
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "ĐÃ HIỂU",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0057C2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> timeSlots = [
    {'time': '09:00', 'disabled': false},
    {'time': '10:30', 'disabled': false},
    {'time': '11:15', 'disabled': false},
    {'time': '01:45', 'disabled': false},
    {'time': '03:00', 'disabled': false},
    {'time': '04:30', 'disabled': false},
    {'time': '05:15', 'disabled': false},
  ];

  final List<String> weekDays = [
    'TH\n2',
    'TH\n3',
    'TH\n4',
    'TH\n5',
    'TH\n6',
    'TH\n7',
    'C\nN',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            /// APPBAR
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    /// PROFILE CARD
                    _buildProfileCard(),

                    const SizedBox(height: 30),

                    /// INFO
                    _buildInfoSection(),

                    const SizedBox(height: 30),

                    /// CALENDAR
                    _buildCalendarSection(),

                    const SizedBox(height: 28),

                    /// TIME
                    _buildTimeSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            /// BUTTON XÁC NHẬN
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF0057C2),
            ),
          ),
          const Text(
            "SereneHealth",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0057C2),
              letterSpacing: -0.2,
            ),
          ),
          const Icon(Icons.search, size: 23, color: Color(0xFF0057C2)),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final String fullname = widget.doctorData['fullname'] ?? "Bác sĩ";
    final String title = widget.doctorData['title'] ?? "Chuyên gia y tế";
    final String rating = (widget.doctorData['rating'] ?? 5.0).toString();
    final int reviewCount = widget.doctorData['reviewcount'] ?? 0;
    final int experienceYears = widget.doctorData['experienceyears'] ?? 5;
    final String avatarUrl =
        widget.doctorData['avatarurl'] ?? "assets/images/ava1.jpg";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// AVATAR
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: avatarUrl.startsWith('http')
                    ? Image.network(
                        avatarUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              "assets/images/ava1.jpg",
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                      )
                    : Image.asset(
                        "assets/images/ava1.jpg",
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0057C2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// NAME
          Text(
            fullname,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F36),
            ),
          ),

          const SizedBox(height: 10),

          /// SPECIALTY
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 16,
                color: Color(0xFF0057C2),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0057C2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// RATING + EXPERIENCE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEEFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 15, color: Color(0xFF0057C2)),
                    const SizedBox(width: 4),
                    Text(
                      "$rating ($reviewCount đánh giá)",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F5B6D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Text(
                "Hơn $experienceYears năm\nkinh nghiệm",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF6E7688),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final String bio =
        widget.doctorData['bio'] ??
        "Thông tin chi tiết về thực hành lâm sàng và lộ trình chẩn đoán điều trị y tế toàn diện của bác sĩ đang được cập nhật...";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thông tin",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: Color(0xFF6E7688),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    final int daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final int firstWeekday = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    ).weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chọn ngày",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tháng ${currentMonth.month}/${currentMonth.year}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap:
                            (currentMonth.year == DateTime.now().year &&
                                currentMonth.month == DateTime.now().month)
                            ? null
                            : () {
                                setState(() {
                                  currentMonth = DateTime(
                                    currentMonth.year,
                                    currentMonth.month - 1,
                                    1,
                                  );
                                });
                              },
                        child: Icon(
                          Icons.chevron_left,
                          color:
                              (currentMonth.year == DateTime.now().year &&
                                  currentMonth.month == DateTime.now().month)
                              ? Colors.grey[300]
                              : const Color(0xFFB0B8C5),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                              1,
                            );
                          });
                        },
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFB0B8C5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// WEEK
              Row(
                children: weekDays.map((day) {
                  return Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB0B8C5),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// DAYS
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: daysInMonth + firstWeekday - 1,
                itemBuilder: (context, index) {
                  if (index < firstWeekday - 1) {
                    return const SizedBox.shrink();
                  }
                  int day = index - (firstWeekday - 1) + 1;

                  DateTime currentDay = DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    day,
                  );
                  DateTime today = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );
                  bool isPastDay = currentDay.isBefore(today);

                  bool isSelected =
                      selectedDate.year == currentMonth.year &&
                      selectedDate.month == currentMonth.month &&
                      selectedDate.day == day;

                  return GestureDetector(
                    onTap: isPastDay
                        ? null
                        : () {
                            setState(() {
                              selectedDate = currentDay;
                              selectedTimeIndex = -1; // Reset giờ khi đổi ngày
                            });
                            _fetchBookedSlots();
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0057C2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "$day",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isPastDay
                                ? Colors.grey[400]
                                : isSelected
                                ? Colors.white
                                : const Color(0xFF1A1F36),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chọn giờ",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.7,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            bool disabled = timeSlots[index]['disabled'];
            final timeStr = timeSlots[index]['time'];
            final time24 = _to24HourFormat(timeStr);

            // Nếu giờ này nằm trong danh sách đã đặt thì disable
            if (_bookedSlots.contains(timeStr) ||
                _bookedSlots.contains(time24)) {
              disabled = true;
            }

            // Vô hiệu hóa các khung giờ trong ngày hôm nay đã trôi qua
            DateTime now = DateTime.now();
            if (selectedDate.year == now.year &&
                selectedDate.month == now.month &&
                selectedDate.day == now.day) {
              final parts = time24.split(':');
              int hour = int.parse(parts[0]);
              int minute = int.parse(parts[1]);

              DateTime slotTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                hour,
                minute,
              );
              if (slotTime.isBefore(now)) {
                disabled = true;
              }
            }

            bool isSelected = selectedTimeIndex == index;

            return GestureDetector(
              onTap: disabled
                  ? null
                  : () {
                      setState(() {
                        selectedTimeIndex = index;
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: disabled
                      ? const Color(0xFFF0F2F5)
                      : isSelected
                      ? const Color(0xFF0057C2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: disabled || isSelected
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    timeSlots[index]['time'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: disabled
                          ? const Color(0xFFCDD5DF)
                          : isSelected
                          ? Colors.white
                          : const Color(0xFF1A1F36),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: ElevatedButton(
          onPressed: (selectedTimeIndex == -1 || _isConfirming)
              ? null
              : () async {
                  setState(() {
                    _isConfirming = true;
                  });
                  final String selectedTime =
                      timeSlots[selectedTimeIndex]['time'];
                  final String appointmentDate =
                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                  final int doctorId = widget.doctorData['doctorid'] ?? 0;
                  try {
                    // 1. Lấy AuthId (UUID) của phiên đăng nhập hiện tại từ hệ thống Auth
                    final currentUser =
                        Supabase.instance.client.auth.currentUser;
                    if (currentUser == null) {
                      throw Exception("Vui lòng đăng nhập lại để tiếp tục!");
                    }
                    final String authId = currentUser.id;

                    // 2. Truy vấn vào bảng users để lấy ra UserId (số nguyên) tương ứng

                    final userData = await Supabase.instance.client
                        .from('users')
                        .select('userid')
                        .eq('authid', authId)
                        .single();

                    final int userId = userData['userid'];

                    // 3. Thực hiện lệnh Insert kèm theo đúng trường userid
                    final newAppointment = await Supabase.instance.client
                        .from('appointments')
                        .insert({
                          'userid':
                              userId, // 👉 Dòng quan trọng nhất để vượt qua RLS
                          'doctorid': doctorId,
                          'appointmentdate': appointmentDate,
                          'starttime': "${_to24HourFormat(selectedTime)}:00",
                          'endtime': _addOneHour(_to24HourFormat(selectedTime)),
                          'status': 'Pending',
                          'createdat': DateTime.now().toIso8601String(),
                        })
                        .select()
                        .single();

                    final int newAppointmentId =
                        newAppointment['appointmentid'];
                    final int? specialtyId =
                        widget.doctorData['specialtyid'] as int?;
                    final double consultationFee =
                        double.tryParse(
                          widget.doctorData['consultationfee']?.toString() ??
                              '0',
                        ) ??
                        0;

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceSelectionScreen(
                            appointmentId: newAppointmentId,
                            doctorId: doctorId,
                            specialtyId: specialtyId,
                            bookingDate: appointmentDate,
                            bookingTime: selectedTime,
                            consultationFee: consultationFee,
                          ),
                        ),
                      ).then((_) {
                        // Mở khóa nút lại nếu người dùng bấm "Back"
                        if (mounted) {
                          setState(() => _isConfirming = false);
                        }
                      });
                    }
                  } on PostgrestException catch (e) {
                    if (mounted) {
                      // Bắt lỗi 23505: Trùng lịch từ Supabase
                      if (e.code == '23505' ||
                          e.message.contains('unique_appointment_slot') ||
                          e.message.contains('duplicate key')) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Khung giờ đã đầy',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'Rất tiếc, khung giờ này vừa có người nhanh tay đặt trước. Vui lòng chọn giờ khác!',
                              style: TextStyle(fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF003D81),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Đã hiểu'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi CSDL: ${e.message}")),
                        );
                      }
                      setState(() => _isConfirming = false);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi hệ thống: $e")),
                      );
                      setState(() => _isConfirming = false);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedTimeIndex == -1
                ? Colors.grey[400]
                : const Color(0xFF0057C2),
            elevation: selectedTimeIndex == -1 ? 0 : 8,
            shadowColor: selectedTimeIndex == -1
                ? Colors.transparent
                : const Color(0x330057C2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isConfirming
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Xác nhận cuộc hẹn",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
