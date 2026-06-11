import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clinic/features/booking/views/doctor_profile_screen.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> filteredDoctors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    searchDoctor("");
  }

  Future<void> searchDoctor(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      var supabaseQuery = Supabase.instance.client.from('doctors').select('*');

      if (query.isNotEmpty) {
        supabaseQuery = supabaseQuery.ilike('fullname', '%$query%');
      }

      final response = await supabaseQuery;
      
      setState(() {
        filteredDoctors = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Search", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                searchDoctor(value);
              },
              decoration: InputDecoration(
                hintText: "Tìm bác sĩ...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0057C2)),
                    )
                  : filteredDoctors.isEmpty
                      ? const Center(
                          child: Text(
                            "Không tìm thấy bác sĩ nào phù hợp",
                            style: TextStyle(color: Color(0xFF6E7688)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDoctors[index];
                            final String fullname = doc['fullname'] ?? "Bác sĩ";
                            final String title = doc['title'] ?? "Chuyên khoa";
                            final String avatarUrl = doc['avatarurl'] ?? "";

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorProfilePage(doctorData: doc),
                                  ),
                                );
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: avatarUrl.startsWith('http')
                                          ? Image.network(
                                              avatarUrl,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Image.asset("assets/images/ava1.jpg", width: 44, height: 44, fit: BoxFit.cover),
                                            )
                                          : Image.asset("assets/images/ava1.jpg", width: 44, height: 44, fit: BoxFit.cover),
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
            ),
          ],
        ),
      ),
    );
  }
}