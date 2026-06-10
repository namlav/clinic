import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../booking/views/doctor_profile_screen.dart'; 
import '../../../widgets/bottom_navigation_bar_widget.dart'; 
import '../views/home_screen.dart';
import '../../appointment/views/schedule_list_screen.dart';
import '../../profile/views/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  Map<int, String?> _doctorNextAppointments = {}; 
  bool _isLoading = false;
  String _selectedSpecialty = "Tất cả";

  final List<Map<String, dynamic>> _categories = [
    {"name": "Tất cả", "icon": Icons.grid_view_rounded},
    {"name": "Tim mạch", "icon": Icons.favorite_rounded},
    {"name": "Nha khoa", "icon": Icons.clean_hands_rounded},
    {"name": "Da liễu", "icon": Icons.face_rounded},
    {"name": "Mắt", "icon": Icons.visibility_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorsAndSchedules();
  }

  Future<void> _fetchDoctorsAndSchedules() async {
    setState(() {
      _isLoading = true;
    });

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
          
          List<String> dateParts = dateStr.split('-');
          String formattedDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";

          tempNextAppoints[docId] = "Lịch tiếp theo: $timeStr ($formattedDate)";
        } else {
          tempNextAppoints[docId] = null;
        }
      }

      setState(() {
        _doctorNextAppointments = tempNextAppoints;
        _filteredDoctors = _allDoctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilterAndSearch() {
    String query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> results = _allDoctors;

    if (_selectedSpecialty != "Tất cả") {
      results = results.where((doc) {
        final specName = doc['specialties']?['specialtyname']?.toString() ?? "";
        return specName.contains(_selectedSpecialty);
      }).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((doc) {
        final fullname = (doc['fullname'] ?? "").toString().toLowerCase();
        return fullname.contains(query);
      }).toList();
    }

    setState(() {
      _filteredDoctors = results;
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE2E8F0),
                    backgroundImage: AssetImage("assets/images/ava1.jpg"), 
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tìm kiếm",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B), size: 26),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// SEARCH BAR & FILTER BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _applyFilterAndSearch(),
                        decoration: const InputDecoration(
                          hintText: "Tìm bác sĩ, phòng khám...",
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0057C2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// CATEGORIES ROW
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Chuyên khoa chính",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  bool isSelected = _selectedSpecialty == cat['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpecialty = cat['name'];
                        _applyFilterAndSearch();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 85,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'],
                            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                            size: 26,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            /// DOCTORS LIST
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Bác sĩ phù hợp",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0057C2)))
                  : _filteredDoctors.isEmpty
                      ? const Center(child: Text("Không tìm thấy bác sĩ nào phù hợp"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doc = _filteredDoctors[index];
                            final int docId = doc['doctorid'] ?? 0;
                            final String specialtyName = doc['specialties']?['specialtyname'] ?? (doc['title'] ?? "Chuyên khoa");
                            final String? nextAppointmentStr = _doctorNextAppointments[docId];

                            return _buildDoctorCard(
                              doc: doc,
                              specialtyName: specialtyName,
                              subtitle: nextAppointmentStr,
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

  Widget _buildDoctorCard({
    required Map<String, dynamic> doc,
    required String specialtyName,
    String? subtitle,
  }) {
    final String fullname = doc['fullname'] ?? "Bác sĩ"; 
    final double rating = (doc['rating'] ?? 5.0).toDouble();
    final String avatarUrl = doc['avatarurl'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// AVATAR IMAGE (Size 74x74)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: avatarUrl.startsWith('http')
                ? Image.network(
                    avatarUrl, 
                    width: 74, 
                    height: 74, 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.asset("assets/images/ava1.jpg", width: 74, height: 74, fit: BoxFit.cover),
                  )
                : Image.asset(
                    "assets/images/ava1.jpg", 
                    width: 74, 
                    height: 74, 
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 14),
          
          /// INFO CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullname,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  specialtyName.toUpperCase(), 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0057C2), letterSpacing: 0.3),
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      "$rating (120 đánh giá)", 
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, color: Colors.green, size: 8),
                    const SizedBox(width: 4),
                    // ĐÃ FIX: Đổi FontWeight sang cấu trúc hằng số chuẩn w500, bóc tách từ khóa const cha để sạch lỗi
                    Text(
                      "Sẵn sàng",
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorProfilePage(doctorData: doc),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057C2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Đặt lịch",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
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
}