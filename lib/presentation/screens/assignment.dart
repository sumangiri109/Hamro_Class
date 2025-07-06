// assignment_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'subject_assignment_page.dart';

class AssignmentPage extends StatelessWidget {
  const AssignmentPage({Key? key}) : super(key: key);

  // Hard‑coded list of subjects
  final List<String> subjects = const [
    'DSA',
    'Math 208',
    'MCSC 201',
    'Digital Logic',
    'Circuit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/AppBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header (same as AnnouncementPage)
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          228,
                          208,
                          239,
                        ),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        textStyle: GoogleFonts.roboto(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("BACK"),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Assignments and Internals",
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'lexend',
                        color: Colors.white,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Subject List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, i) {
                    final name = subjects[i];
                    return Card(
                      color: const Color(0xFFF1E4FA),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(
                          name,
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            letterSpacing: 1,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SubjectAssignmentPage(subject: name),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
