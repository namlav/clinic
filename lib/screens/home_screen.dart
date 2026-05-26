import 'package:flutter/material.dart';
import '../data/doctors_data.dart';
import 'booking_screen.dart';
import 'profile_screen.dart';
import 'doctor_profile_screen.dart';
import 'schedule_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

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
    final doctor = doctors[1];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(doctor.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingPage()),
                      );
                    },
                    icon: const Icon(Icons.search, color: Color(0xFF0057C2), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// WELCOME
              const Text(
                "Chào mừng,",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1, color: Colors.black),
              ),
              const SizedBox(height: 2),
              const Text(
                "Alexander",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1, color: Color(0xFF0057C2)),
              ),
              const SizedBox(height: 14),
              const SizedBox(
                width: 295,
                child: Text(
                  "Sức khỏe của bạn là tâm giao. Cùng điểm qua lộ trình chăm sóc hôm nay nhé.",
                  style: TextStyle(fontSize: 15, height: 1.65, fontWeight: FontWeight.w400, color: Color(0xFF7D8797), letterSpacing: -0.2),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827), letterSpacing: -0.3),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 1),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BookingPage()),
                        );
                      },
                      child: const Text(
                        "Xem tất cả",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0057C2), letterSpacing: -0.2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              /// APPOINTMENT CARD
              Container(
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
                    BoxShadow(color: Color(0x330057C2), blurRadius: 25, offset: Offset(0, 12)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: AssetImage(doctor.image), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, height: 1.35),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.specialty,
                                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: pickDate,
                          child: Container(
                            width: 125,
                            height: 82,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white.withOpacity(0.12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white.withOpacity(0.85)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "NGÀY",
                                      style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.75)),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white.withOpacity(0.12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined, size: 14, color: Colors.white.withOpacity(0.85)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "GIỜ",
                                      style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.75)),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  selectedTime.format(context),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DoctorProfilePage()),
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0057C2)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// CATEGORY
              const Text(
                "Tìm chuyên gia",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: const [
                  _CategoryItem("Tim mạch", "12 Chuyên gia", "Khoa tim mạch"),
                  _CategoryItem("Nhi khoa", "8 Chuyên gia", "Khoa nhi"),
                  _CategoryItem("Da liễu", "15 Chuyên gia", "Khoa da liễu"),
                  _CategoryItem("Tổng quát", "24 Chuyên gia", "Khoa Nội Tổng Quát"),
                ],
              ),
              const SizedBox(height: 24),

              /// BLOG
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
                            style: TextStyle(fontSize: 11, color: Color(0xFF2F6CD3)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Giữ cơ thể đủ nước trong suốt mùa thu",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Uống nước giúp duy trì mức năng lượng trong suốt cả ngày.",
                            style: TextStyle(fontSize: 12, color: Color(0xFF8A94A6)),
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
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFF2F6CD3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 72,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, color: Colors.white, size: 22),
                  SizedBox(height: 2),
                  Text(
                    "HOME",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingPage()),
                );
              },
              child: _navItem(Icons.search, "SEARCH"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScheduleListScreen()),
                );
              },
              child: _navItem(Icons.calendar_today_outlined, "SCHEDULE"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: _navItem(Icons.person_outline, "PROFILE"),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _navItem(IconData icon, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF9AA4B2), size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Color(0xFF9AA4B2), fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final String sub;
  final String specialty;

  const _CategoryItem(this.title, this.sub, this.specialty);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A6)),
            ),
          ],
        ),
      ),
    );
  }
}