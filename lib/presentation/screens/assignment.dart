import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  bool isEditing = false;
  String? userRole;
  final List<String> assignments = [
    'Submit Physics Lab before Monday.',
    'Group Project report due this Friday.',
    'DSA Assignment 2 deadline extended.',
    'Final-year proposal presentation next week.',
  ];

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          userRole = doc['role'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/AppBackground.png"), // Update this path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header
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
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("BACK"),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Assignments",
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'lexend',
                        color: Colors.white,
                        letterSpacing: 7,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Assignments List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40), // spacing above scroll area
                        Expanded(
                          child: Scrollbar(
                            thickness: 8,
                            radius: const Radius.circular(10),
                            thumbVisibility: true,
                            child: ListView.builder(
                              itemCount: assignments.length,
                              itemBuilder: (context, index) {
                                return AssignmentCard(
                                  initialText: assignments[index],
                                  isEditing: isEditing,
                                  onChanged: (newText) {
                                    setState(() {
                                      assignments[index] = newText;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // CR-only Edit Button
                    if (userRole == 'CR')
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBE90D4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                            });
                          },
                          child: Text(
                            isEditing ? 'Save' : 'Edit',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              color: Colors.white,
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
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final String initialText;
  final bool isEditing;
  final ValueChanged<String> onChanged;

  const AssignmentCard({
    super.key,
    required this.initialText,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5D3F2),
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isEditing
          ? TextFormField(
              initialValue: initialText,
              onChanged: onChanged,
              maxLines: null,
              style: GoogleFonts.roboto(fontSize: 22),
              decoration: const InputDecoration(border: InputBorder.none),
            )
          : Text(initialText, style: GoogleFonts.roboto(fontSize: 24)),
    );
  }
}
