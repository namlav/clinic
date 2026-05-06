import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<String> doctors = [
    "PGS.TS.BS. Nguyễn Tri Thức",
    "TS.BS. Đinh Vinh Quang",
    "PGS.TS.BS Lê Thái Vân Thanh",
    "Dr. Sarah Jenkins",
    "Dr. Elena Rodriguez",
    "Dr. James Wilson",
  ];

  List<String> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  void searchDoctor(String query) {
    final results = doctors.where((doctor) {
      return doctor.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredDoctors = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Search", style: TextStyle(color: Colors.black)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            /// SEARCH INPUT
            TextField(
              controller: _searchController,

              onChanged: searchDoctor,

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

            /// RESULTS
            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,

                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Text(filteredDoctors[index]),
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
