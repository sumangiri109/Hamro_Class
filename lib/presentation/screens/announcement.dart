import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 Import Google Fonts

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Announcement Page',
      theme: ThemeData(useMaterial3: true),
      home: const AnnouncementPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBDDF7),
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFBE90D4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "BACK",
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "~Announcements~",
                    style: GoogleFonts.roboto(
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Posts
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // Add a gap above the posts
                  Column(
                    children: [
                      const SizedBox(height: 40), // Gap for Edit button
                      Expanded(
                        child: Scrollbar(
                          thickness: 10,
                          radius: const Radius.circular(10),
                          thumbVisibility: true,
                          child: ListView(
                            children: const [
                              AnnouncementCard(text: 'Post 1'),
                              AnnouncementCard(text: 'Post 2'),
                              AnnouncementCard(text: 'Post 3'),
                              AnnouncementCard(text: 'Post 4'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE90D4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Edit',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String text;
  const AnnouncementCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5D3F2),
        border: Border.all(color: Colors.black54, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 26,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
