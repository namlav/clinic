import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_screen.dart';
import '../../../widgets/fade_page_route.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onScheduleTap;

  const HomeScreen({super.key, this.onSearchTap, this.onScheduleTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String _userName = '';

  late Future<Map<String, dynamic>?> _priorityAppointmentFuture;
  late Future<List<Map<String, dynamic>>> _specialtiesFuture;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _priorityAppointmentFuture = _fetchPriorityAppointment();
    _specialtiesFuture = _fetchSpecialties();
  }

  Future<void> _loadUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('fullname')
          .eq('authid', user.id)
          .single();
      if (mounted) setState(() => _userName = data['fullname'] ?? '');
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _fetchPriorityAppointment() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final userResponse = await Supabase.instance.client
          .from('users')
          .select('userid')
          .eq('authid', user.id)
          .single();
      final numericUserId = userResponse['userid'] as int;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await Supabase.instance.client
          .from('appointments')
          .select(
            'appointmentid, appointmentdate, starttime, endtime, doctors(fullname, title, avatarurl)',
          )
          .eq('userid', numericUserId)
          .eq('status', 'Confirmed')
          .gte('appointmentdate', today)
          .order('appointmentdate', ascending: true)
          .order('starttime', ascending: true)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSpecialties() async {
    try {
      final response = await Supabase.instance.client
          .from('specialties')
          .select('*')
          .limit(4); // Giới hạn hiển thị 4 chuyên khoa chính lên trang chủ
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      /// AVATAR
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("assets/images/ava1.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      /// LOGO TEXT
                      const Text(
                        "SereneHealth",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0057C2),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  /// SEARCH
                  IconButton(
                    onPressed: () {
                      if (widget.onSearchTap != null) {
                        widget.onSearchTap!();
                      } else {
                        Navigator.push(
                          context,
                          FadePageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF0057C2),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// WELCOME
              const Text(
                "Chào mừng,",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _userName.isNotEmpty ? _userName : "...",
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
                  color: Color(0xFF0057C2),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: 295,
                child: const Text(
                  "Sức khỏe của bạn là tâm giao. Cùng điểm qua lộ trình chăm sóc hôm nay nhé.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.65,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7D8797),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              /// TITLE
              const Text(
                "Cuộc hẹn ưu tiên",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),

              /// APPOINTMENT CARD
              FutureBuilder<Map<String, dynamic>?>(
                future: _priorityAppointmentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        color: const Color(0xFF004498),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  final appointment = snapshot.data;
                  if (appointment == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEAF2FF)),
                      ),
                      child: const Center(
                        child: Text(
                          "Bạn không có lịch hẹn nào sắp diễn ra",
                          style: TextStyle(
                            color: Color(0xFF7D8797),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  final doctor =
                      appointment['doctors'] as Map<String, dynamic>?;
                  final String doctorName =
                      doctor?['fullname'] ?? "Bác sĩ chuyên khoa";
                  final String specialtyName =
                      doctor?['title'] ?? "Khoa Tổng quát";
                  final String avatarUrl = doctor?['avatarurl'] ?? "";

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 0, 68, 152),
                          Color.fromARGB(255, 17, 89, 185),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x330057C2),
                          blurRadius: 25,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            /// DYNAMIC AVATAR BÁC SĨ
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: avatarUrl.startsWith('http')
                                  ? Image.network(
                                      avatarUrl,
                                      width: 54,
                                      height: 54,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Image.asset(
                                        "assets/images/ava1.jpg",
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      "assets/images/ava1.jpg",
                                      width: 54,
                                      height: 54,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    specialtyName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        /// DATE TIME SHOW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: pickDate,
                              child: Container(
                                width: 125,
                                height: 82,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "NGÀY",
                                          style: TextStyle(
                                            fontSize: 11,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      appointment['appointmentdate'] ??
                                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: pickTime,
                              child: Container(
                                width: 125,
                                height: 82,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "GIỜ",
                                          style: TextStyle(
                                            fontSize: 11,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      appointment['starttime'] != null
                                          ? "${appointment['starttime'].toString().substring(0, 5)} - ${appointment['endtime'].toString().substring(0, 5)}"
                                          : selectedTime.format(context),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        /// BUTTON
                        GestureDetector(
                          onTap: () => widget.onScheduleTap?.call(),
                          child: Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                "Xác nhận tham gia",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0057C2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              /// CATEGORY TITLE
              const Text(
                "Tìm chuyên gia",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),

              /// GRIDVIEW CHUYÊN KHOA
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _specialtiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final specialties = snapshot.data ?? [];
                  if (specialties.isEmpty) {
                    return const Text("Không có dữ liệu chuyên khoa");
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: specialties.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (context, index) {
                      final spec = specialties[index];
                      return _CategoryItem(
                        spec['specialtyname'] ?? "Chuyên khoa",
                        spec['description'] ?? "Bác sĩ chuyên khoa",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SpecialtyDoctorsScreen(specialty: spec),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              /// BLOG TIP
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "MẸO HÀNG NGÀY",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2F6CD3),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Giữ cơ thể đủ nước trong suốt cả ngày",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Uống nước giúp duy trì mức năng lượng trong suốt cả ngày.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A94A6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      /// FLOAT BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.onSearchTap != null) {
            widget.onSearchTap!();
          } else {
            Navigator.push(
              context,
              FadePageRoute(builder: (context) => const SearchScreen()),
            );
          }
        },
        backgroundColor: const Color(0xFF2F6CD3),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  static Widget _infoBox(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _CategoryItem(this.title, this.sub, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Color(0xFF2F6CD3)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A6)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
