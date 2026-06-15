import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorName = "Alexander";
    final Map<String, dynamic> nextPatient = {
      "name": "Nguyễn Văn An",
      "symptom": "Đau thắt ngực trái",
      "date": "24/08/2023",
      "time": "09:30 AM",
      "image": "https://i.pravatar.cc/150?u=a1"
    };

    final List<Map<String, dynamic>> managementTools = [
      {"title": "Lịch hẹn", "count": "12 Ca", "icon": Icons.calendar_today, "color": const Color(0xFFEAF2FF)},
      {"title": "Bệnh nhân", "count": "450 Người", "icon": Icons.people_outline, "color": const Color(0xFFFFF4E5)},
      {"title": "Hồ sơ y tế", "count": "8 File mới", "icon": Icons.folder_open, "color": const Color(0xFFF3E8FF)},
      {"title": "Doanh thu", "count": "25.5 Tr", "icon": Icons.account_balance_wallet_outlined, "color": const Color(0xFFE4F8F1)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Text("DR", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "SereneHealth",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0057C2),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0057C2)),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              /// GREETING
              const Text(
                "Chào Bác sĩ,",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1),
              ),
              Text(
                doctorName,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF0057C2), height: 1.1),
              ),
              const SizedBox(height: 12),
              const Text(
                "Hôm nay bạn có 12 cuộc hẹn đã xác nhận. Hãy kiểm tra lộ trình làm việc nhé.",
                style: TextStyle(fontSize: 15, color: Color(0xFF7D8797), height: 1.5),
              ),

              const SizedBox(height: 25),

              const Text(
                "Bệnh nhân tiếp theo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 14),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004498), Color(0xFF0067E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(nextPatient['image'], width: 55, height: 55, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nextPatient['name'], style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              Text("Triệu chứng: ${nextPatient['symptom']}", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildInfoTag(Icons.calendar_today, "NGÀY", nextPatient['date'])),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInfoTag(Icons.access_time, "GIỜ", nextPatient['time'])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0057C2),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text("Bắt đầu thăm khám", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Công cụ quản lý",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: managementTools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final tool = managementTools[index];
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: tool['color'], borderRadius: BorderRadius.circular(10)),
                          child: Icon(tool['icon'], color: const Color(0xFF0057C2), size: 22),
                        ),
                        const SizedBox(height: 12),
                        Text(tool['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(tool['count'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CẬP NHẬT Y KHOA", style: TextStyle(fontSize: 10, color: Color(0xFF0057C2), fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("Phác đồ điều trị nội thần kinh 2024", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 4),
                          Text("Những thay đổi quan trọng trong việc chẩn đoán sớm...", style: TextStyle(color: Color(0xFF8A94A6), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 65, height: 65,
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.menu_book, color: Colors.white),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0057C2),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0057C2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Lịch trực"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Tin nhắn"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Cá nhân"),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}