import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../core/services/notice_service.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final NoticeService noticeService = NoticeService();
  bool isEditing = false;
  String? userRole;

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
      if (doc.exists && doc.data()?.containsKey('role') == true) {
        setState(() {
          userRole = doc['role'] as String?;
        });
      }
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    final date = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(date);
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
            image: AssetImage("assets/images/AppBackground.png"),
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
                      "Announcements",
                      style: TextStyle(
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

            // Announcements List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: noticeService.getNoticesStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No announcements yet.',
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;

                              return Scrollbar(
                                thickness: 8,
                                radius: const Radius.circular(10),
                                thumbVisibility: true,
                                child: ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = docs[index];
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final text = data['text'] ?? '';
                                    final timestamp =
                                        data['timestamp'] as Timestamp?;

                                    return AnnouncementCard(
                                      id: doc.id,
                                      text: text,
                                      timestamp: timestamp,
                                      isEditing: isEditing,
                                      canEdit: userRole == 'CR',
                                      onChanged: (newText) {
                                        noticeService.updateNotice(
                                          doc.id,
                                          newText,
                                        );
                                      },
                                      onDelete: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Delete Announcement',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this announcement?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await noticeService.deleteNotice(
                                            doc.id,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // CR-only buttons
                    if (userRole == 'CR') ...[
                      Positioned(
                        bottom: 70,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBE90D4),
                            side: BorderSide(color: Colors.black26, width: 1.5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final newNotice = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                final TextEditingController controller =
                                    TextEditingController();
                                return AlertDialog(
                                  title: const Text('Add Announcement'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your announcement',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        controller.text,
                                      ),
                                      child: const Text('Post'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (newNotice != null &&
                                newNotice.trim().isNotEmpty) {
                              await noticeService.addNotice(newNotice.trim());
                            }
                          },
                          child: Text(
                            'New Post',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBE90D4),
                            side: BorderSide(color: Colors.black26, width: 1.5),
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
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class AnnouncementCard extends StatefulWidget {
  final String id;
  final String text;
  final Timestamp? timestamp;
  final bool isEditing;
  final bool canEdit;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const AnnouncementCard({
    super.key,
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isEditing,
    required this.canEdit,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant AnnouncementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    final date = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E4FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100.withOpacity(0.6),
            offset: const Offset(0, 6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 145, 145, 146),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editable text or plain text
          widget.isEditing
              ? TextFormField(
                  controller: _controller,
                  maxLines: null,
                  style: GoogleFonts.roboto(fontSize: 20),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onChanged: widget.onChanged,
                )
              : Text(
                  widget.text,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    letterSpacing: 1,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTimestamp(widget.timestamp),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),

              // Delete button only if canEdit (CR role)
              if (widget.canEdit)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.black45, size: 28),
                  tooltip: 'Delete announcement',
                  onPressed: widget.onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
