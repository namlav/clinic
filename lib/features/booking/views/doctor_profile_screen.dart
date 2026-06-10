import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfilePage({
    super.key,
    required this.doctorData,
  });

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  // Quản lý ngày động
  late DateTime _currentMonthView;
  late DateTime _today;
  late DateTime _selectedDate;
  late DateTime _maxDate; // #1 Thêm biến quản lý ngày tối đa
  
  // Quản lý giờ động
  int selectedTimeIndex = 0;
  List<Map<String, dynamic>> dynamicTimeSlots = [];

  final List<String> weekDays = [
    'TH\n2', 'TH\n3', 'TH\n4', 'TH\n5', 'TH\n6', 'TH\n7', 'C\nN',
  ];

  @override
  void initState() {
    super.initState();
    
    // #2 Cấu hình thời gian khởi tạo trong initState()
    _today = DateTime.now();
    _maxDate = DateTime(
      _today.year,
      _today.month + 3,
      _today.day,
    );
    _currentMonthView = DateTime(
      _today.year,
      _today.month,
      1,
    );
    _selectedDate = _today; 
    
    _generateMedicalTimeSlots();
  }

  // Tự động sinh khung giờ khám: Sáng (7h-10h30), Chiều (13h-16h30) cách nhau 30 phút
  void _generateMedicalTimeSlots() {
    dynamicTimeSlots.clear();
    
    // Ca Sáng: 07:00 -> 10:30
    double morningStart = 7.0;
    double morningEnd = 10.5; 
    for (double time = morningStart; time <= morningEnd; time += 0.5) {
      dynamicTimeSlots.add({
        'time': _formatDoubleToTime(time),
        'disabled': false,
      });
    }

    // Ca Chiều: 13:00 -> 16:30
    double afternoonStart = 13.0;
    double afternoonEnd = 16.5; 
    for (double time = afternoonStart; time <= afternoonEnd; time += 0.5) {
      dynamicTimeSlots.add({
        'time': _formatDoubleToTime(time),
        'disabled': false,
      });
    }
  }

  String _formatDoubleToTime(double value) {
    int hours = value.toInt();
    int minutes = ((value - hours) * 60).toInt();
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  // Logic chuyển tháng trên lịch (Giới hạn trong khoảng maxDate đã tính)
  void _changeMonth(int increment) {
    setState(() {
      DateTime newMonth = DateTime(_currentMonthView.year, _currentMonthView.month + increment, 1);
      DateTime maxLimitMonth = DateTime(_maxDate.year, _maxDate.month, 1);
      DateTime minLimitMonth = DateTime(_today.year, _today.month, 1);

      if ((newMonth.isBefore(maxLimitMonth) || newMonth.isAtSameMomentAs(maxLimitMonth)) &&
          (newMonth.isAfter(minLimitMonth) || newMonth.isAtSameMomentAs(minLimitMonth))) {
        _currentMonthView = newMonth;
      }
    });
  }

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

                    /// PROFILE CARD (Nơi chứa thông tin chuyên khoa bác sĩ)
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
          const Icon(
            Icons.search,
            size: 23,
            color: Color(0xFF0057C2),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final String fullname = widget.doctorData['fullname'] ?? "Bác sĩ";
    final String specialty =widget.doctorData['specialties']?['specialtyname']?? "Chuyên khoa";
    final String rating = (widget.doctorData['rating'] ?? 5.0).toString();
    final int reviewCount = widget.doctorData['reviewcount'] ?? 0;
    final int experienceYears = widget.doctorData['experienceyears'] ?? 5;
    final String avatarUrl = widget.doctorData['avatarurl'] ?? "assets/images/ava1.jpg";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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
                        errorBuilder: (context, error, stackTrace) => Image.asset(
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
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
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
          
          /// ĐÃ ĐỔ CHUYÊN KHOA ĐỘNG TẠI ĐÂY
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
                (specialty),// 
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0057C2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEEFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 15,
                      color: Color(0xFF0057C2),
                    ),
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
    final String bio = widget.doctorData['bio'] ?? 
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
                color: Colors.black.withOpacity(0.03),
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
    int daysInMonth = DateUtils.getDaysInMonth(_currentMonthView.year, _currentMonthView.month);
    List<DateTime> validDays = [];
    
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime day = DateTime(_currentMonthView.year, _currentMonthView.month, i);
      
      // #3 Kiểm tra ràng buộc: Ngày phải từ hôm nay trở đi và trước ngày tối đa (3 tháng sau)
      if (
        day.isAfter(_today.subtract(const Duration(days: 1))) &&
        day.isBefore(_maxDate.add(const Duration(days: 1)))
      ) {
        validDays.add(day);
      }
    }

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
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tháng ${_currentMonthView.month}/${_currentMonthView.year}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _changeMonth(-1),
                        child: const Icon(Icons.chevron_left, color: Color(0xFFB0B8C5)),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () => _changeMonth(1),
                        child: const Icon(Icons.chevron_right, color: Color(0xFFB0B8C5)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

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

              validDays.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Không có lịch trống trong tháng này", style: TextStyle(color: Colors.grey)),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: validDays.map((dateTime) {
                        bool isSelected = dateTime.year == _selectedDate.year &&
                            dateTime.month == _selectedDate.month &&
                            dateTime.day == _selectedDate.day;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = dateTime;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0057C2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "${dateTime.day}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF1A1F36),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
          itemCount: dynamicTimeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.7,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            bool disabled = dynamicTimeSlots[index]['disabled'];
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
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    dynamicTimeSlots[index]['time'],
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
          onPressed: () async {
            if (dynamicTimeSlots.isEmpty) return;

            final String selectedTime = dynamicTimeSlots[selectedTimeIndex]['time'];
            
            // #4 Sửa và tính toán kết thúc thời gian biểu tự động (+30 phút)
            final parts = selectedTime.split(':');
            DateTime startDateTime = DateTime(
              2026,
              1,
              1,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
            DateTime endDateTime = startDateTime.add(const Duration(minutes: 30));
            final String endTime =
                "${endDateTime.hour.toString().padLeft(2, '0')}:"
                "${endDateTime.minute.toString().padLeft(2, '0')}:00";

            final String appointmentDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
            final int doctorId = widget.doctorData['doctorid'] ?? 0;

            try {
              // #5 Lưu trữ bản ghi lên hệ thống Supabase với starttime và endtime động
              await Supabase.instance.client.from('appointments').insert({
                'doctorid': doctorId,
                'appointmentdate': appointmentDate,
                'starttime': "$selectedTime:00", 
                'endtime': endTime,
                'status': 'Pending',           
                'createdat': DateTime.now().toIso8601String(),
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đặt lịch hẹn khám thành công!")),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi hệ thống: Không thể đặt lịch lịch hẹn ($e)")),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0057C2),
            elevation: 8,
            shadowColor: const Color(0x330057C2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Row(
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