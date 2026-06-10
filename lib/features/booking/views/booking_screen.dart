import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'doctor_profile_screen.dart'; 
import 'package:clinic/widgets/bottom_navigation_bar_widget.dart'; 
import 'package:clinic/features/home/views/home_screen.dart';
import 'package:clinic/features/appointment/views/schedule_list_screen.dart';
import 'package:clinic/features/profile/views/profile_screen.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int selectedFilter = 0;
  int selectedBottomNav = 1; 

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  Map<int, String?> _doctorNextAppointments = {}; 
  bool _isLoading = false;

  final List<String> filters = [
    "Tất cả",
    "Tim mạch",
    "Có lịch hôm nay",
    "Đánh giá cao",
    "Da liễu",
  ];

  late Future<List<Map<String, dynamic>>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _fetchDoctors();
  }

  Future<List<Map<String, dynamic>>> _fetchDoctors() async {
    try {
      final client = Supabase.instance.client;

      final response = await client.from('doctors').select('''
        *,
        specialties (
          specialtyname
        )
      ''');
      
      _allDoctors = List<Map<String, dynamic>>.from(response);

      final appointmentResponse = await client
          .from('appointments')
          .select('doctorid, appointmentdate, starttime')
          .eq('status', 'Pending')
          .order('appointmentdate', ascending: true)
          .order('starttime', ascending: true);

      final appointments = List<Map<String, dynamic>>.from(appointmentResponse);
      Map<int, String?> tempNextAppoints = {};

      for (var doc in _allDoctors) {
        int docId = doc['doctorid'];
        final nextApp = appointments.firstWhere(
          (app) => app['doctorid'] == docId,
          orElse: () => {},
        );

        if (nextApp.isNotEmpty) {
          String dateStr = nextApp['appointmentdate'].toString();
          String timeStr = nextApp['starttime'].toString().substring(0, 5);
          
          // Định dạng ngày sang kiểu Việt Nam (DD/MM/YYYY)
          List<String> dateParts = dateStr.split('-');
          String formattedDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";

          tempNextAppoints[docId] = "Lịch tiếp theo: $timeStr ($formattedDate)";
        } else {
          tempNextAppoints[docId] = null;
        }
      }

      _doctorNextAppointments = tempNextAppoints;
      _filteredDoctors = _allDoctors; 

      return _allDoctors;
    } catch (e) {
      return [];
    }
  }

  void _applyFilterAndSearch() {
    String searchWord = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> output = _allDoctors;

    if (selectedFilter == 1) {
      output = output.where((doc) => doc['specialties']?['specialtyname']?.toString().contains("Tim mạch") ?? false).toList();
    } else if (selectedFilter == 2) {
      String todayStr = DateTime.now().toString().substring(0, 10);
      List<String> todayParts = todayStr.split('-');
      String todayFormatted = "${todayParts[2]}/${todayParts[1]}/${todayParts[0]}";
      output = output.where((doc) => _doctorNextAppointments[doc['doctorid']]?.contains(todayFormatted) ?? false).toList();
    } else if (selectedFilter == 3) {
      output = output.where((doc) => (doc['rating'] ?? 0.0) >= 4.8).toList();
    } else if (selectedFilter == 4) {
      output = output.where((doc) => doc['specialties']?['specialtyname']?.toString().contains("Da liễu") ?? false).toList();
    }

    if (searchWord.isNotEmpty) {
      output = output.where((doc) {
        String name = (doc['fullname'] ?? "").toString().toLowerCase();
        String title = (doc['title'] ?? "").toString().toLowerCase();
        // Quét thêm tên chuyên khoa động lấy từ bảng liên kết specialties
        String specialtyMapped = (doc['specialties']?['specialtyname'] ?? "").toString().toLowerCase();
        
        return name.contains(searchWord) || title.contains(searchWord) || specialtyMapped.contains(searchWord);
      }).toList();
    }

    setState(() {
      _filteredDoctors = output;
    });
  }

  void _handleNavigation(int index) {
    if (index == 1) return; 

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ScheduleListScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
            ),
            const SizedBox(height: 24),

            /// SEARCH BOX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFFB5BDCA),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _applyFilterAndSearch(),
                        decoration: const InputDecoration(
                          hintText: "Tìm kiếm bác sĩ, chuyên khoa...",
                          hintStyle: TextStyle(color: Color(0xFF9CA5B5), fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  filters.length,
                  (index) {
                    bool isSelected = selectedFilter == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = index;
                          _applyFilterAndSearch();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0057C2) : const Color(0xFFD9ECFF),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index == 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: isSelected ? Colors.white : const Color(0xFF5B6B81),
                                ),
                              ),
                            Text(
                              filters[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF5B6B81),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0057C2)),
                    );
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData || _allDoctors.isEmpty) {
                    return const Center(
                      child: Text("Không thể tải danh sách bác sĩ", style: TextStyle(color: Color(0xFF6E7688))),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredDoctors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final doc = _filteredDoctors[index];
                      final int docId = doc['doctorid'] ?? 0;
                      
                      final String specialtyName = doc['specialties']?['specialtyname'] ?? (doc['title'] ?? "Chuyên khoa");
                      final String? nextAppointmentStr = _doctorNextAppointments[docId];

                      return index == 2
                          ? _largeDoctorCard(
                              image: doc['avatarurl'] ?? "assets/images/ava1.jpg",
                              name: (doc['fullname'] ?? "Bác sĩ").toString().replaceAll(' ', '\n'),
                              specialty: specialtyName,
                              rating: (doc['rating'] ?? 5.0).toString(),
                              experience: "${doc['experienceyears'] ?? 5} năm kinh nghiệm",
                              bio: doc['bio'] ?? "Chuyên về thăm khám lâm sàng và điều trị nội khoa...",
                              docData: doc, 
                            )
                          : _doctorCard(
                              image: doc['avatarurl'] ?? "assets/images/ava1.jpg",
                              name: (doc['fullname'] ?? "Bác sĩ").toString().replaceAll(' ', '\n'),
                              specialty: specialtyName.replaceAll(' ', '\n'),
                              rating: (doc['rating'] ?? 5.0).toString(),
                              experience: "${doc['experienceyears'] ?? 5} năm kinh nghiệm",
                              buttonText: "Đặt lịch",
                              subtitle: nextAppointmentStr, 
                              docData: doc, 
                            );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBarApp(
        initialIndex: 1, 
        onItemTapped: _handleNavigation, 
      ),
    );
  }

  /// CARD TIÊU CHUẨN
  Widget _doctorCard({
    required String image,
    required String name,
    required String specialty,
    required String rating,
    required String experience,
    required String buttonText,
    required Map<String, dynamic> docData,
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
                    ? Image.asset(image, width: 96, height: 96, fit: BoxFit.cover)
                    : Image.network(
                        image,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/ava1.jpg", width: 96, height: 96, fit: BoxFit.cover),
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
                            style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
                          ),
                        ),
                        _ratingBadge(rating),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(specialty, style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF6E7688))),
                    const SizedBox(height: 12),
                    Text(experience, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: Color(0xFFA5ADBA))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              subtitle != null
                  ? Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF0057C2)),
                        const SizedBox(width: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0057C2)),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(), 
              
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfilePage(doctorData: docData),
                    ),
                  );
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0057C2),
                  elevation: 8,
                  shadowColor: const Color(0x330057C2),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// CARD LỚN
  Widget _largeDoctorCard({
    required String image,
    required String name,
    required String specialty,
    required String rating,
    required String experience,
    required String bio,
    required Map<String, dynamic> docData,
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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            child: image.startsWith('assets/')
                ? Image.asset(image, width: double.infinity, height: 190, fit: BoxFit.cover)
                : Image.network(
                    image,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/ava1.jpg", width: double.infinity, height: 190, fit: BoxFit.cover),
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
                        style: const TextStyle(fontSize: 18, height: 1.45, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 15, color: Color(0xFF0057C2)),
                          SizedBox(width: 4),
                          Text(
                            "Highly\nRated",
                            style: TextStyle(fontSize: 11, height: 1.3, fontWeight: FontWeight.w700, color: Color(0xFF0057C2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(specialty, style: const TextStyle(fontSize: 14, color: Color(0xFF6E7688))),
                const SizedBox(height: 8),
                Text(bio, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6E7688))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.star_border, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    Text(experience, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFA5ADBA))),
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
                          builder: (context) => DoctorProfilePage(doctorData: docData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057C2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "Đặt lịch",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0057C2)),
          ),
        ],
      ),
    );
  }
}