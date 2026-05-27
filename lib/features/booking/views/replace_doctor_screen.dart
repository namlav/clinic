import 'package:flutter/material.dart';

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

      home: const DoctorReplacementPage(),
    );
  }
}

class DoctorReplacementPage extends StatefulWidget {
  const DoctorReplacementPage({super.key});

  @override
  State<DoctorReplacementPage> createState() => _DoctorReplacementPageState();
}

class _DoctorReplacementPageState extends State<DoctorReplacementPage> {
  int selectedNav = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Column(
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

                    /// ALERT
                    _buildAlertBanner(),

                    const SizedBox(height: 28),

                    /// CARD
                    _buildDoctorCard(),

                    const SizedBox(height: 34),

                    /// ACCEPT
                    _buildAcceptButton(),

                    const SizedBox(height: 16),

                    /// CANCEL
                    _buildCancelButton(),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            /// BOTTOM NAV
            _buildBottomNav(),
          ],
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
          const Align(
            alignment: Alignment.centerLeft,

            child: Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: Color(0xFF004B9A),
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

  Widget _buildAlertBanner() {
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
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,

                  color: Color(0xFF4F3729),
                ),

                children: [
                  TextSpan(text: "Bác sĩ "),

                  TextSpan(
                    text: "Đinh Vinh Quang",

                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),

                  TextSpan(
                    text:
                        " hiện bận đột xuất. Để không gián đoạn việc thăm khám, chúng tôi đề xuất bác sĩ thay thế có trình độ tương đương.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(34),

                  topRight: Radius.circular(34),
                ),

                child: Container(
                  width: double.infinity,
                  height: 360,

                  color: const Color(0xFFF1F3F6),

                  child: Image.asset(
                    "assets/images/ava1.jpg",

                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                top: 18,
                left: 18,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),

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
                const Text(
                  "BS. Lê Thanh Hằng",

                  style: TextStyle(
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

                    const Text(
                      "Khoa Nội Tổng Quát",

                      style: TextStyle(
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
                    _statItem("KINH NGHIỆM", "15 năm"),

                    const SizedBox(width: 40),

                    _ratingItem("ĐÁNH GIÁ", "4.9"),
                  ],
                ),

                const SizedBox(height: 22),

                _statItem("HỌC VẤN", "Thạc sĩ Y khoa"),

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

                  child: const Text(
                    '"Tôi cam kết mang lại sự chăm sóc tận tâm và thấu đáo nhất cho mọi bệnh nhân, đảm bảo quá trình điều trị của bạn không bị gián đoạn."',

                    style: TextStyle(
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

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,

      child: ElevatedButton(
        onPressed: () {},

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
        onPressed: () {},

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

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'HOME'},

      {'icon': Icons.search, 'label': 'SEARCH'},

      {'icon': Icons.calendar_today_outlined, 'label': 'SCHEDULE'},

      {'icon': Icons.person_outline, 'label': 'PROFILE'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

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

        children: List.generate(items.length, (index) {
          bool isSelected = selectedNav == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedNav = index;
              });
            },

            child: isSelected
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF0057C2),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          items[index]['icon'] as IconData,

                          size: 20,
                          color: Colors.white,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          items[index]['label'] as String,

                          style: const TextStyle(
                            fontSize: 10,

                            fontWeight: FontWeight.w700,

                            letterSpacing: 0.5,

                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(
                        items[index]['icon'] as IconData,

                        size: 23,

                        color: const Color(0xFFB0B8C5),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        items[index]['label'] as String,

                        style: const TextStyle(
                          fontSize: 10,

                          fontWeight: FontWeight.w600,

                          letterSpacing: 0.5,

                          color: Color(0xFFB0B8C5),
                        ),
                      ),
                    ],
                  ),
          );
        }),
      ),
    );
  }
}
