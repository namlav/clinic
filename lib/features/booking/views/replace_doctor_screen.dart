import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clinic/features/home/views/search_screen.dart';
import 'package:clinic/features/home/views/home_screen.dart';
import 'package:clinic/features/appointment/views/schedule_list_screen.dart';
import 'package:clinic/features/profile/views/profile_screen.dart';
import 'package:clinic/widgets/bottom_navigation_bar_widget.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SereneHealth',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const DoctorReplacementPage(appointmentId: 1),
    );
  }
}

class DoctorReplacementPage extends StatefulWidget {
  final int appointmentId;

  const DoctorReplacementPage({
    super.key,
    required this.appointmentId,
  });

  @override
  State<DoctorReplacementPage> createState() => _DoctorReplacementPageState();
}

class _DoctorReplacementPageState extends State<DoctorReplacementPage> {
  int selectedBottomNav = 2; // Màn hình thông báo lịch hẹn thuộc phạm vi Tab SCHEDULE (Index số 2)
  
  late Future<Map<String, dynamic>?> _replacementDataFuture;

  @override
  void initState() {
    super.initState();
    _replacementDataFuture = _loadReplacementDoctorAndAppointment();
  }

  Future<Map<String, dynamic>?> _loadReplacementDoctorAndAppointment() async {
    try {
      final client = Supabase.instance.client;

      final appointmentResponse = await client
          .from('appointments')
          .select('doctorid, doctors(fullname, specialtyid)')
          .eq('appointmentid', widget.appointmentId)
          .maybeSingle();

      if (appointmentResponse == null) return null;

      final originalDoctor = appointmentResponse['doctors'] as Map<String, dynamic>?;
      if (originalDoctor == null) return null;

      final int originalDoctorId = appointmentResponse['doctorid'];
      final int specialtyId = originalDoctor['specialtyid'];
      final String originalDoctorName = originalDoctor['fullname'] ?? "Bác sĩ";

      final replacementResponse = await client
          .from('doctors')
          .select('*, specialties(specialtyname)')
          .eq('specialtyid', specialtyId)
          .neq('doctorid', originalDoctorId)
          .order('rating', ascending: false)
          .limit(1);

      if (replacementResponse != null && (replacementResponse as List).isNotEmpty) {
        final replacementDoctor = replacementResponse.first as Map<String, dynamic>;
        
        return {
          'original_doctor_name': originalDoctorName,
          'replacement_doctor': replacementDoctor,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _handleNavigation(int index) {
    if (index == 2) return; 

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _replacementDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF004B9A)),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  "Không tìm thấy thông tin đề xuất bác sĩ thay thế phù hợp.",
                  style: TextStyle(color: Color(0xFF6E7688), fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final data = snapshot.data!;
            final String originalName = data['original_doctor_name'];
            final Map<String, dynamic> replacementDoc = data['replacement_doctor'];
            final Map<String, dynamic>? specialtyInfo = replacementDoc['specialties'] as Map<String, dynamic>?;

            return Column(
              children: [
                /// APPBAR
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),

                        _buildAlertBanner(originalName),
                        const SizedBox(height: 28),

                        /// CARD 
                        _buildDoctorCard(replacementDoc, specialtyInfo),
                        const SizedBox(height: 34),

                        /// ACCEPT
                        _buildAcceptButton(replacementDoc['doctorid']),
                        const SizedBox(height: 16),

                        /// CANCEL
                        _buildCancelButton(),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                BottomNavigationBarApp(
                  initialIndex: 2, 
                  onItemTapped: _handleNavigation, 
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 22,
                color: Color(0xFF004B9A),
              ),
            ),
          ),
          const Text(
            "Thông báo",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF004B9A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(String originalDoctorName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 177, 147),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline, size: 22, color: Color(0xFF9A4F1D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Color(0xFF4F3729),
                ),
                children: [
                  const TextSpan(text: "Bác sĩ "),
                  TextSpan(
                    text: originalDoctorName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text: " hiện bận đột xuất. Để không gián đoạn việc thăm khám, chúng tôi đề xuất bác sĩ thay thế có trình độ tương đương.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, Map<String, dynamic>? specialty) {
    final String avatarUrl = doctor['avatarurl'] ?? "";
    final String fullname = doctor['fullname'] ?? "Bác sĩ thay thế";
    final String specialtyName = specialty != null ? specialty['specialtyname'] : (doctor['title'] ?? "Khoa Nội Tổng Quát");
    final String experienceYears = "${doctor['experienceyears'] ?? 10} năm";
    final String rating = (doctor['rating'] ?? 5.0).toString();
    final String education = doctor['education'] ?? "Thạc sĩ Y khoa";
    final String bio = doctor['bio'] ?? '"Tôi cam kết mang lại sự chăm sóc tận tâm và thấu đáo nhất cho mọi bệnh nhân, đảm bảo quá trình điều trị của bạn không bị gián đoạn."';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Stack(
            children: [
              CustomClipRRect(avatarUrl: avatarUrl),
              Positioned(
                top: 18,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B9A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "ĐỀ XUẤT TỐT NHẤT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  fullname,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 10),

                /// SPECIALTY
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      size: 17,
                      color: Color(0xFF0057C2),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      specialtyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0057C2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 18),

                /// STATS
                Row(
                  children: [
                    _statItem("KINH NGHIỆM", experienceYears),
                    const SizedBox(width: 40),
                    _ratingItem("ĐÁNH GIÁ", rating),
                  ],
                ),
                const SizedBox(height: 22),
                _statItem("HỌC VẤN", education),
                const SizedBox(height: 24),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 22),

                /// QUOTE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    bio.startsWith('"') ? bio : '"$bio"',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6E7688),
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

  Widget _statItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFFB0B8C5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0057C2)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF7D8797))),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _ratingItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFFB0B8C5),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 17, color: Color(0xFFFFB800)),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptButton(int replacementDoctorId) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await Supabase.instance.client
                .from('appointments')
                .update({'doctorid': replacementDoctorId})
                .eq('appointmentid', widget.appointmentId);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xác nhận thay đổi bác sĩ thành công!")),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Có lỗi xảy ra khi xác nhận: $e")),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: const Color(0x33004B9A),
          backgroundColor: const Color(0xFF004B9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: const Text(
          "Đồng ý và tiếp tục",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton(
        onPressed: () async {
          try {
            await Supabase.instance.client
                .from('appointments')
                .update({'status': 'Cancelled'})
                .eq('appointmentid', widget.appointmentId);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã hủy lịch hẹn và tiến hành hoàn tiền.")),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Không thể hủy lịch. Lỗi: $e")),
              );
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE6B7B7), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, size: 20, color: Color(0xFFD93434)),
            SizedBox(width: 8),
            Text(
              "Hủy lịch và hoàn tiền",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD93434),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipRRect extends StatelessWidget {
  const CustomClipRRect({
    super.key,
    required this.avatarUrl,
  });

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
      ),
      child: Container(
        width: double.infinity,
        height: 360,
        color: const Color(0xFFF1F3F6),
        child: avatarUrl.startsWith('http')
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/images/ava1.jpg",
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                "assets/images/ava1.jpg",
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}