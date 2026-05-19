import 'package:flutter/material.dart';
import '../data/doctors_data.dart';
import 'doctor_profile_screen.dart';
import 'home_screen.dart';

// import 'schedule_list_screen.dart';
// import 'profile_screen.dart';
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int selectedFilter = 0;
  int selectedBottomNav = 1;

  final List<String> filters = [
    "Tất cả",
    "Tim mạch",
    "Có lịch hôm nay",
    "Đánh giá cao",
    "Da liễu",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 14),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,

                          decoration: BoxDecoration(
                            color: const Color(0xFFECC9AE),

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF6E5B4E),
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          "SereneHealth",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,

                            color: Color(0xFF0057C2),

                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),

                    const Icon(
                      Icons.search,
                      size: 24,
                      color: Color(0xFF0057C2),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// SEARCH BOX
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(18),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),

                        blurRadius: 14,

                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),

                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: Color(0xFFB5BDCA),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "Tìm kiếm bác sĩ chuyên khoa,\nphòng khám hoặc tình trạng bệnh...",

                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF9CA5B5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// FILTERS
                Wrap(
                  spacing: 12,
                  runSpacing: 12,

                  children: List.generate(filters.length, (index) {
                    bool isSelected = selectedFilter == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = index;
                        });
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),

                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0057C2)
                              : const Color(0xFFD9ECFF),

                          borderRadius: BorderRadius.circular(22),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            if (index == 0)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),

                                child: Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),

                            Text(
                              filters[index],

                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,

                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF5B6B81),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 28),

                /// CARD 1
                _doctorCard(
                  image: doctors[0].image,

                  name: doctors[0].name,

                  specialty: doctors[0].specialty,

                  rating: doctors[0].rating.toString(),

                  experience: doctors[0].experience,

                  buttonText: "Đặt lịch",

                  subtitle: doctors[0].subtitle,
                ),

                /// CARD 2
                _doctorCard(
                  image: doctors[1].image,

                  name: doctors[1].name,

                  specialty: doctors[1].specialty,

                  rating: doctors[1].rating.toString(),

                  experience: doctors[1].experience,

                  buttonText: "Đặt lịch",

                  subtitle: doctors[1].subtitle,
                ),

                const SizedBox(height: 18),

                /// CARD 3
                _largeDoctorCard(),

                const SizedBox(height: 18),

                /// CARD 4
                /// CARD 4
                _doctorCard(
                  image: doctors[3].image,

                  name: doctors[3].name,

                  specialty: doctors[3].specialty,

                  rating: doctors[3].rating.toString(),

                  experience: doctors[3].experience,

                  buttonText: "Đặt lịch",

                  subtitle: doctors[3].subtitle,
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),

              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Icon(
                    Icons.home_outlined,

                    size: 22,

                    color: Color(0xFFB1BAC8),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "HOME",

                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,

                      letterSpacing: 0.6,

                      color: Color(0xFFB1BAC8),
                    ),
                  ),
                ],
              ),
            ),

            _selectedBottomItem(1, Icons.search, "SEARCH"),

            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,

            //       MaterialPageRoute(
            //         builder: (context) => const ScheduleListScreen(),
            //       ),
            //     );
            //   },

            //   child: _bottomItem(2, Icons.calendar_today_outlined, "SCHEDULE"),
            // ),

            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,

            //       MaterialPageRoute(
            //         builder: (context) => const ProfileScreen(),
            //       ),
            //     );
            //   },

            //   child: _bottomItem(3, Icons.person_outline, "PROFILE"),
            // ),
          ],
        ),
      ),
    );
  }

  /// NORMAL CARD
  Widget _doctorCard({
    required String image,
    required String name,
    required String specialty,
    required String rating,
    required String experience,
    required String buttonText,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 18,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),

                child: Image.asset(
                  image,

                  width: 96,
                  height: 96,

                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(
                          child: Text(
                            name,

                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w700,

                              color: Color(0xFF1A1F36),
                            ),
                          ),
                        ),

                        _ratingBadge(rating),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      specialty,

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF6E7688),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      experience,

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,

                        letterSpacing: 1,

                        color: Color(0xFFA5ADBA),
                      ),
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
              if (subtitle != null)
                Row(
                  children: [
                    Icon(
                      subtitle == "North Wing"
                          ? Icons.location_on_outlined
                          : Icons.calendar_today_outlined,

                      size: 15,

                      color: const Color(0xFF6E7688),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      subtitle,

                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,

                        color: Color(0xFF4F5B6D),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    _smallAvatar("SJ"),

                    const SizedBox(width: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0FF),

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Text(
                        "+2k",

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,

                          color: Color(0xFF0057C2),
                        ),
                      ),
                    ),
                  ],
                ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => const DoctorProfilePage(),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0057C2),

                  elevation: 8,

                  shadowColor: const Color(0x330057C2),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: Text(
                  buttonText,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,

                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// LARGE CARD
  Widget _largeDoctorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 18,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),

            child: Image.asset(
              "assets/images/ava1.jpg",

              width: double.infinity,
              height: 190,

              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Expanded(
                      child: Text(
                        "Dr. Elena\nRodriguez",

                        style: TextStyle(
                          fontSize: 18,
                          height: 1.45,
                          fontWeight: FontWeight.w700,

                          color: Color(0xFF1A1F36),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 15,
                            color: Color(0xFF0057C2),
                          ),

                          SizedBox(width: 4),

                          Text(
                            "Highly\nRated",

                            style: TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              fontWeight: FontWeight.w700,

                              color: Color(0xFF0057C2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  "Chuyên gia nhi khoa",

                  style: TextStyle(fontSize: 14, color: Color(0xFF6E7688)),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Chuyên về chăm sóc sơ sinh và nhi khoa phát triển, ...",

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF6E7688),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.star_border, size: 16),

                    const SizedBox(width: 4),

                    const Text(
                      "5.0",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Text(
                      "15 năm kinh nghiệm",

                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,

                        letterSpacing: 1,

                        color: Color(0xFFA5ADBA),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => const DoctorProfilePage(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057C2),

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      "Đặt lịch",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,

                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBadge(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),

        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          const Icon(Icons.star, size: 14, color: Color(0xFF0057C2)),

          const SizedBox(width: 3),

          Text(
            rating,

            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0057C2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallAvatar(String text) {
    return Container(
      width: 32,
      height: 32,

      decoration: BoxDecoration(
        color: const Color(0xFFDCE6F9),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Center(
        child: Text(
          text,

          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _bottomItem(int index, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBottomNav = index;
        });
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 22, color: const Color(0xFFB1BAC8)),

          const SizedBox(height: 4),

          Text(
            label,

            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,

              letterSpacing: 0.6,

              color: Color(0xFFB1BAC8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedBottomItem(int index, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBottomNav = index;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),

        decoration: BoxDecoration(
          color: const Color(0xFF0057C2),

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),

              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, size: 20, color: Colors.white),

            const SizedBox(height: 4),

            Text(
              label,

              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,

                letterSpacing: 0.6,

                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
