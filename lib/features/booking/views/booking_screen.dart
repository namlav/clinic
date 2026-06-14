import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int selectedFilter = 0;
  int selectedBottomNav = 1;

  List<Map<String, dynamic>> filters = [{'id': -1, 'name': 'Tất cả'}];

  late Future<List<Map<String, dynamic>>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _fetchDoctors(-1);
    _fetchSpecialties();
  }

  Future<void> _fetchSpecialties() async {
    try {
      final response = await Supabase.instance.client.from('specialties').select('specialtyid, specialtyname');
      final specs = List<Map<String, dynamic>>.from(response);
      if (mounted) {
        setState(() {
          filters = [{'id': -1, 'name': 'Tất cả'}];
          for (var spec in specs) {
            filters.add({'id': spec['specialtyid'], 'name': spec['specialtyname']});
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải chuyên khoa: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDoctors(int specialtyId) async {
    try {
      var query = Supabase.instance.client
          .from('doctors')
          .select('*, specialties(specialtyname)');
      if (specialtyId != -1) {
        query = query.eq('specialtyid', specialtyId);
      }
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Trả về mảng rỗng nếu xảy ra lỗi kết nối API
      return [];
    }
  }

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
                      const Expanded(
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
                          _doctorsFuture = _fetchDoctors(filters[index]['id']);
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
                              filters[index]['name'],
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

                /// DANH SÁCH BÁC SĨ
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _doctorsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF0057C2),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            "Không thể tải danh sách bác sĩ",
                            style: TextStyle(color: Color(0xFF6E7688)),
                          ),
                        ),
                      );
                    }

                    final doctors = snapshot.data!;

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctors.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final doc = doctors[index];

                        if (index == 2) {
                          return _largeDoctorCard(
                            image: doc['avatarurl'] ?? "assets/images/ava1.jpg",
                            name: (doc['fullname'] ?? "Bác sĩ")
                                .toString()
                                .replaceAll(' ', '\n'),
                            specialty: doc['title'] ?? "Chuyên gia y tế",
                            rating: (doc['rating'] ?? 5.0).toString(),
                            experience:
                                "${doc['experienceyears'] ?? 5}Y EXPERIENCE",
                            bio:
                                doc['bio'] ??
                                "Chuyên về thăm khám lâm sàng và điều trị nội khoa...",
                          );
                        }

                        return _doctorCard(
                          image: doc['avatarurl'] ?? "assets/images/ava1.jpg",
                          name: (doc['fullname'] ?? "Bác sĩ")
                              .toString()
                              .replaceAll(' ', '\n'),
                          specialty: (doc['title'] ?? "Chuyên khoa")
                              .toString()
                              .replaceAll(' ', '\n'),
                          rating: (doc['rating'] ?? 5.0).toString(),
                          experience:
                              "${doc['experienceyears'] ?? 5}Y EXPERIENCE",
                          buttonText: "Đặt lịch",
                          subtitle: index % 2 == 0
                              ? "North Wing"
                              : "Next: Tomorrow",
                        );
                      },
                    );
                  },
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
            _bottomItem(0, Icons.home_outlined, "HOME"),
            _selectedBottomItem(1, Icons.search, "SEARCH"),
            _bottomItem(2, Icons.calendar_today_outlined, "SCHEDULE"),
            _bottomItem(3, Icons.person_outline, "PROFILE"),
          ],
        ),
      ),
    );
  }

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
                child: image.startsWith('assets/')
                    ? Image.asset(
                        image,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        image,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              "assets/images/ava1.jpg",
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
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
                onPressed: () {},
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

  Widget _largeDoctorCard({
    required String image,
    required String name,
    required String specialty,
    required String rating,
    required String experience,
    required String bio,
  }) {
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
            child: image.startsWith('assets/')
                ? Image.asset(
                    image,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    image,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/ava1.jpg",
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
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
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
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
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E7688),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: const TextStyle(
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
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
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
