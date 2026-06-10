import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_screen.dart';
import '../../../widgets/fade_page_route.dart';
import 'package:clinic/features/appointment/views/schedule_list_screen.dart';
import 'package:clinic/features/booking/views/booking_screen.dart';
 
class HomeScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
 
  const HomeScreen({super.key, this.onSearchTap});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

 
class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
 
  late Future<Map<String, dynamic>?> _userProfileFuture;
  late Future<Map<String, dynamic>?> _priorityAppointmentFuture;
  late Future<List<Map<String, dynamic>>> _specialtiesFuture;
 
  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
    _priorityAppointmentFuture = _fetchPriorityAppointment();
    _specialtiesFuture = _fetchSpecialties();
  }
 
  //Lấy thông tin cá nhân của User hiện tại từ Supabase
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;
 
      if (authUser == null) return null;
 
      final response = await Supabase.instance.client
          .from('users')
          .select('fullname, avatarurl')
          .eq('authid', authUser.id)
          .maybeSingle();
 
      return response;
    } catch (e) {
      return null;
    }
  }
 
  //  Lấy cuộc hẹn ưu tiên sắp diễn ra
  Future<Map<String, dynamic>?> _fetchPriorityAppointment() async {
    try {
      // FIX 1: Thêm filter theo user hiện tại
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) return null;
 
      final response = await Supabase.instance.client
          .from('appointments')
          .select(
            'appointmentid, appointmentdate, starttime, endtime, doctors(fullname, title, avatarurl)',
          )
          .eq('userid', authUser.id)
          .neq('status', 'Cancelled')
          .order('appointmentdate', ascending: true)
          .limit(1)
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
 
  // Lấy danh sách chuyên khoa
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
 
  // FIX 2: Bỏ pickDate và pickTime vì không liên kết với appointment thật,
  // tránh gây hiểu lầm cho người dùng
 
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
 
              FutureBuilder<Map<String, dynamic>?>(
                future: _userProfileFuture,
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data;
                  final String userAvatar = userData?['avatarurl'] ?? "";
                  final String userFullname = userData?['fullname'] ?? "User";
 
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              /// AVATAR USER DYNAMIC
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: userAvatar.startsWith('http')
                                        ? NetworkImage(userAvatar)
                                              as ImageProvider
                                        : const AssetImage(
                                            "assets/images/ava1.jpg",
                                          ),
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
                                    builder: (context) => const BookingPage(),
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
 
                      /// WELCOME SECTION
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
                        userFullname,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1,
                          color: Color(0xFF0057C2),
                        ),
                      ),
                    ],
                  );
                },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Cuộc hẹn ưu tiên",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScheduleListScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 4, bottom: 1),
                      child: Text(
                        "Xem tất cả",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0057C2),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
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
                                    // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(209),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
 
                        /// DATE TIME SHOW — FIX 2: Bỏ GestureDetector, chỉ hiển thị thông tin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 125,
                              height: 82,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                color: Colors.white.withAlpha(31),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                        color: Colors.white.withAlpha(217),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "NGÀY",
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w500,
                                          // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                          color: Colors.white.withAlpha(191),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    appointment['appointmentdate'] ?? "—",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 125,
                              height: 82,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                color: Colors.white.withAlpha(31),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_outlined,
                                        size: 14,
                                        // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                        color: Colors.white.withAlpha(217),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "GIỜ",
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w500,
                                          // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
                                          color: Colors.white.withAlpha(191),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    appointment['starttime'] != null
                                        ? "${appointment['starttime'].toString().substring(0, 5)} - ${appointment['endtime'].toString().substring(0, 5)}"
                                        : "—",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
 
                        /// BUTTON — FIX 3: TODO hoàn thiện logic xác nhận tham gia
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement xác nhận tham gia lịch hẹn
                            // Cần gọi API cập nhật trạng thái appointment
                            print(
                              "Xác nhận tham gia lịch hẹn ID: ${appointment['appointmentid']}",
                            );
                          },
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
                            "Giữ cơ thể đủ nước trong suốt mùa thu",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Uông nước giúp duy trì mức năng lượng trong suốt cả ngày.",
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
        backgroundColor: const Color(0xFF2F6CD3),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
 
  // FIX 4: Xóa _infoBox vì là dead code (không được gọi ở đâu)
}
 
class _CategoryItem extends StatelessWidget {
  final String title;
  final String sub;
 
  const _CategoryItem(this.title, this.sub);
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // FIX 5: Thay withOpacity (deprecated) bằng withAlpha
            color: Colors.black.withAlpha(5),
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