import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE6EAF2),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "SereneHealth",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C2B4A),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.search, size: 20, color: Color(0xFF1C2B4A)),
                ],
              ),

              const SizedBox(height: 20),

              /// WELCOME
              const Text(
                "Welcome back,",
                style: TextStyle(fontSize: 18, color: Color(0xFF1C2B4A)),
              ),

              const SizedBox(height: 4),

              const Text(
                "Alexander",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F6CD3),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Sức khỏe của bạn là tâm giao. Cùng điểm qua lộ trình chăm sóc hôm nay nhé.",
                style: TextStyle(fontSize: 13, color: Color(0xFF8A94A6)),
              ),

              const SizedBox(height: 22),

              /// TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Cuộc hẹn ưu tiên",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF2F6CD3)),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// APPOINTMENT CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E4DA1), Color(0xFF2F6CD3)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [

                    /// DOCTOR INFO
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "TS.BS.Đinh Vĩnh Quang",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Khoa nội thần kinh",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// DATE TIME
                    Row(
                      children: [
                        Expanded(child: _infoBox(Icons.calendar_today, "NGÀY", "24/8/2023")),
                        const SizedBox(width: 10),
                        Expanded(child: _infoBox(Icons.access_time, "GIỜ", "09:30 AM")),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// BUTTON
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          "Xác nhận tham gia",
                          style: TextStyle(
                            color: Color(0xFF2F6CD3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
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
                  _CategoryItem("Tim mạch", "12 Chuyên gia"),
                  _CategoryItem("Nhi khoa", "8 Chuyên gia"),
                  _CategoryItem("Da liễu", "15 Chuyên gia"),
                  _CategoryItem("Tổng quát", "24 Chuyên gia"),
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
                    )
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      /// FLOAT BUTTON
      floatingActionButton: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Color(0xFF2F6CD3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2F6CD3),
        unselectedItemColor: const Color(0xFF8A94A6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "SEARCH"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "SCHEDULE"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "PROFILE"),
        ],
      ),
    );
  }

  static Widget _infoBox(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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

  const _CategoryItem(this.title, this.sub);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A6))),
        ],
      ),
    );
  }
}