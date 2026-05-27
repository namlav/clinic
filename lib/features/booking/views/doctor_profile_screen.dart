import 'package:flutter/material.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() =>
      _DoctorProfilePageState();
}

class _DoctorProfilePageState
    extends State<DoctorProfilePage> {

  int selectedDay = 17;
  int selectedTimeIndex = 1;

  final List<Map<String, dynamic>> timeSlots = [
    {'time': '09:00', 'disabled': false},
    {'time': '10:30', 'disabled': false},
    {'time': '11:15', 'disabled': false},
    {'time': '01:45', 'disabled': false},
    {'time': '03:00', 'disabled': false},
    {'time': '04:30', 'disabled': true},
    {'time': '05:15', 'disabled': false},
  ];

  final List<String> weekDays = [
    'TH\n2',
    'TH\n3',
    'TH\n4',
    'TH\n5',
    'TH\n6',
    'TH\n7',
    'C\nN',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Column(
          children: [

            /// APPBAR
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const SizedBox(height: 18),

                    /// PROFILE CARD
                    _buildProfileCard(),

                    const SizedBox(height: 30),

                    /// INFO
                    _buildInfoSection(),

                    const SizedBox(height: 30),

                    /// CALENDAR
                    _buildCalendarSection(),

                    const SizedBox(height: 28),

                    /// TIME
                    _buildTimeSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            /// BUTTON
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        0,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF0057C2),
          ),

          const Text(
            "SereneHealth",

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,

              color: Color(0xFF0057C2),

              letterSpacing: -0.2,
            ),
          ),

          const Icon(
            Icons.search,
            size: 23,
            color: Color(0xFF0057C2),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 26,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),

            blurRadius: 18,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [

          /// AVATAR
          Stack(
            clipBehavior: Clip.none,

            children: [

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(18),

                child: Image.asset(
                  "assets/images/ava1.jpg",

                  width: 120,
                  height: 120,

                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                right: -4,
                bottom: -4,

                child: Container(
                  width: 32,
                  height: 32,

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF0057C2),

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),

                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),

                  child: const Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// NAME
          const Text(
            "TS. BS\nĐinh Vinh Quang",

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 18,
              height: 1.35,

              fontWeight: FontWeight.w700,

              color: Color(0xFF1A1F36),
            ),
          ),

          const SizedBox(height: 10),

          /// SPECIALTY
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.medical_services_outlined,
                size: 16,
                color: Color(0xFF0057C2),
              ),

              const SizedBox(width: 6),

              const Text(
                "Khoa nội thần kinh",

                style: TextStyle(
                  fontSize: 15,

                  fontWeight:
                      FontWeight.w600,

                  color: Color(0xFF0057C2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// RATING + EXPERIENCE
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFDDEEFF),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: const Row(
                  children: [

                    Icon(
                      Icons.star,
                      size: 15,
                      color: Color(0xFF0057C2),
                    ),

                    SizedBox(width: 4),

                    Text(
                      "4.9 (124 đánh giá)",

                      style: TextStyle(
                        fontSize: 13,

                        fontWeight:
                            FontWeight.w600,

                        color:
                            Color(0xFF4F5B6D),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              const Text(
                "Hơn 20 năm\nkinh nghiệm",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,

                  color: Color(0xFF6E7688),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Thông tin",

          style: TextStyle(
            fontSize: 20,

            fontWeight: FontWeight.w700,

            color: Color(0xFF1A1F36),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.03,
                ),

                blurRadius: 12,

                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: const Text(
            "Tiến sĩ Quang là một chuyên gia thần kinh được công nhận toàn cầu, tập trung vào các thực hành lâm sàng yên bình. Cô kết hợp công nghệ chẩn đoán tiên tiến với phương pháp lấy bệnh nhân làm trung tâm để đảm bảo hành trình chữa lành toàn diện.",

            style: TextStyle(
              fontSize: 14,
              height: 1.8,

              color: Color(0xFF6E7688),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Chọn ngày",

          style: TextStyle(
            fontSize: 20,

            fontWeight: FontWeight.w700,

            color: Color(0xFF1A1F36),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.03,
                ),

                blurRadius: 12,

                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Column(
            children: [

              /// HEADER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(
                    "Tháng 12/2026",

                    style: TextStyle(
                      fontSize: 18,

                      fontWeight:
                          FontWeight.w700,

                      color:
                          Color(0xFF1A1F36),
                    ),
                  ),

                  Row(
                    children: const [

                      Icon(
                        Icons.chevron_left,
                        color:
                            Color(0xFFB0B8C5),
                      ),

                      SizedBox(width: 4),

                      Icon(
                        Icons.chevron_right,
                        color:
                            Color(0xFFB0B8C5),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// WEEK
              Row(
                children:
                    weekDays.map((day) {

                  return Expanded(
                    child: Text(
                      day,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,

                        fontWeight:
                            FontWeight.w600,

                        color:
                            Color(0xFFB0B8C5),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// DAYS
              Wrap(
                spacing: 10,
                runSpacing: 12,

                children: List.generate(
                  17,
                  (index) {

                    int day = index + 8;

                    bool isSelected =
                        day == selectedDay;

                    return GestureDetector(
                      onTap: () {

                        setState(() {
                          selectedDay = day;
                        });
                      },

                      child: Container(
                        width: 36,
                        height: 40,

                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(
                                  0xFF0057C2,
                                )
                              : Colors.transparent,

                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),

                        child: Center(
                          child: Text(
                            "$day",

                            style: TextStyle(
                              fontSize: 15,

                              fontWeight:
                                  isSelected
                                      ? FontWeight
                                          .w700
                                      : FontWeight
                                          .w500,

                              color: isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFF1A1F36,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Chọn giờ",

          style: TextStyle(
            fontSize: 20,

            fontWeight: FontWeight.w700,

            color: Color(0xFF1A1F36),
          ),
        ),

        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: timeSlots.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

            childAspectRatio: 2.7,

            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),

          itemBuilder: (context, index) {

            bool disabled =
                timeSlots[index]['disabled'];

            bool isSelected =
                selectedTimeIndex == index;

            return GestureDetector(
              onTap: disabled
                  ? null
                  : () {

                      setState(() {
                        selectedTimeIndex =
                            index;
                      });
                    },

              child: Container(
                decoration: BoxDecoration(
                  color: disabled
                      ? const Color(
                          0xFFF0F2F5,
                        )
                      : isSelected
                          ? const Color(
                              0xFF0057C2,
                            )
                          : Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  boxShadow: disabled ||
                          isSelected
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                              0.04,
                            ),

                            blurRadius: 8,

                            offset:
                                const Offset(
                              0,
                              2,
                            ),
                          ),
                        ],
                ),

                child: Center(
                  child: Text(
                    timeSlots[index]['time'],

                    style: TextStyle(
                      fontSize: 16,

                      fontWeight:
                          FontWeight.w600,

                      color: disabled
                          ? const Color(
                              0xFFCDD5DF,
                            )
                          : isSelected
                              ? Colors.white
                              : const Color(
                                  0xFF1A1F36,
                                ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        24,
      ),

      child: SizedBox(
        width: double.infinity,
        height: 62,

        child: ElevatedButton(
          onPressed: () {},

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF0057C2),

            elevation: 8,

            shadowColor:
                const Color(0x330057C2),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20),
            ),
          ),

          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                "Xác nhận cuộc hẹn",

                style: TextStyle(
                  fontSize: 18,

                  fontWeight:
                      FontWeight.w700,

                  color: Colors.white,
                ),
              ),

              SizedBox(width: 12),

              Icon(
                Icons.calendar_month_outlined,
                size: 22,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}