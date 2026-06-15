import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clinic/features/booking/views/doctor_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialSearchType;

  const SearchScreen({super.key, this.initialQuery, this.initialSearchType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> filteredDoctors = [];
  List<Map<String, dynamic>> filteredSpecialties = [];
  List<Map<String, dynamic>> filteredServices = [];
  bool isLoading = false;

  String searchType = 'Bác sĩ';
  final List<String> searchTypes = ['Bác sĩ', 'Chuyên khoa', 'Dịch vụ'];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchType != null) {
      searchType = widget.initialSearchType!;
    }
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    searchData(_searchController.text);
  }

  Future<void> searchData(String query) async {
    setState(() => isLoading = true);

    try {
      if (searchType == 'Bác sĩ') {
        // Tìm bác sĩ theo tên
        var q = Supabase.instance.client
            .from('doctors')
            .select('*, specialties(specialtyname)');
        if (query.isNotEmpty) {
          q = q.ilike('fullname', '%$query%');
        }
        final response = await q;
        setState(() {
          filteredDoctors = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else if (searchType == 'Chuyên khoa') {
        // Tìm chuyên khoa theo tên HOẶC triệu chứng/từ khóa trong description
        var q = Supabase.instance.client.from('specialties').select('*');
        if (query.isNotEmpty) {
          q = q.or('specialtyname.ilike.%$query%,description.ilike.%$query%');
        }
        final response = await q;
        setState(() {
          filteredSpecialties = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else if (searchType == 'Dịch vụ') {
        // Tìm dịch vụ theo tên, lấy đầy đủ thông tin chuyên khoa để điều hướng
        var q = Supabase.instance.client
            .from('services')
            .select('*, specialties(*)')
            .eq('isactive', true);
        if (query.isNotEmpty) {
          q = q.ilike('servicename', '%$query%');
        }
        final response = await q;
        setState(() {
          filteredServices = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Search Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Khám phá",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (value) => searchData(value),
              decoration: InputDecoration(
                hintText: _hintText(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: searchTypes.map((type) {
                  final isSelected = searchType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => searchType = type);
                          searchData(_searchController.text);
                        }
                      },
                      selectedColor: const Color(0xFF0057C2),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF0057C2)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0057C2),
                      ),
                    )
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  String _hintText() {
    if (searchType == 'Bác sĩ') return 'Tìm tên bác sĩ...';
    if (searchType == 'Chuyên khoa') return 'Nhập tên hoặc triệu chứng...';
    return 'Tìm dịch vụ...';
  }

  Widget _buildContent() {
    if (searchType == 'Bác sĩ') return _buildDoctorsList();
    if (searchType == 'Chuyên khoa') return _buildSpecialtiesList();
    return _buildServicesList();
  }

  Widget _buildDoctorsList() {
    if (filteredDoctors.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy bác sĩ nào phù hợp",
          style: TextStyle(color: Color(0xFF6E7688)),
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doc = filteredDoctors[index];
        final String fullname = doc['fullname'] ?? "Bác sĩ";
        final String title =
            doc['specialties']?['specialtyname'] ??
            doc['title'] ??
            "Chuyên khoa";
        final String avatarUrl = doc['avatarurl'] ?? "";

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorProfilePage(doctorData: doc),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: avatarUrl.startsWith('http')
                      ? Image.network(
                          avatarUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Image.asset(
                            "assets/images/ava1.jpg",
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "assets/images/ava1.jpg",
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E7688),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFFB5BDCA),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialtiesList() {
    if (filteredSpecialties.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy chuyên khoa nào phù hợp",
          style: TextStyle(color: Color(0xFF6E7688)),
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredSpecialties.length,
      itemBuilder: (context, index) {
        final spec = filteredSpecialties[index];
        final String name = spec['specialtyname'] ?? "Chuyên khoa";

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialtyDoctorsScreen(specialty: spec),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF0057C2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFFB5BDCA),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesList() {
    if (filteredServices.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy dịch vụ nào phù hợp",
          style: TextStyle(color: Color(0xFF6E7688)),
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final serv = filteredServices[index];
        final String name = serv['servicename'] ?? "Dịch vụ";
        final String priceStr = (serv['price'] ?? 0).toString().replaceAll(
          RegExp(r'\.0*$'),
          '',
        );
        final Map<String, dynamic>? specialty = serv['specialties'];

        return GestureDetector(
          onTap: () {
            if (specialty != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SpecialtyDoctorsScreen(specialty: specialty),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Color(0xFF0057C2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty?['specialtyname'] ?? 'Chuyên khoa',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E7688),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${priceStr}đ",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0057C2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Màn hình danh sách bác sĩ theo chuyên khoa ───────────────────────────────
class SpecialtyDoctorsScreen extends StatefulWidget {
  final Map<String, dynamic> specialty;
  const SpecialtyDoctorsScreen({super.key, required this.specialty});

  @override
  State<SpecialtyDoctorsScreen> createState() => _SpecialtyDoctorsScreenState();
}

class _SpecialtyDoctorsScreenState extends State<SpecialtyDoctorsScreen> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await Supabase.instance.client
          .from('doctors')
          .select('*, specialties(specialtyname)')
          .eq('specialtyid', widget.specialty['specialtyid']);
      setState(() {
        doctors = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.specialty['specialtyname'] ?? 'Bác sĩ',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0057C2)),
            )
          : doctors.isEmpty
          ? const Center(
              child: Text(
                "Không có bác sĩ nào trong chuyên khoa này",
                style: TextStyle(color: Color(0xFF6E7688)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doc = doctors[index];
                final String fullname = doc['fullname'] ?? "Bác sĩ";
                final String title =
                    doc['specialties']?['specialtyname'] ??
                    doc['title'] ??
                    "Chuyên khoa";
                final String avatarUrl = doc['avatarurl'] ?? "";

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfilePage(doctorData: doc),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: avatarUrl.startsWith('http')
                              ? Image.network(
                                  avatarUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Image.asset(
                                    "assets/images/ava1.jpg",
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  "assets/images/ava1.jpg",
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullname,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1F36),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6E7688),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFFB5BDCA),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
