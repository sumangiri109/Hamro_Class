import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/notice_service.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final NoticeService noticeService = NoticeService();
  String? userRole;
  String? _editingPostId;

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
                          backgroundColor: const Color.fromARGB(255, 228, 208, 239),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          textStyle: GoogleFonts.roboto(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
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

            // Announcement List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: noticeService.getNoticesStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No announcements yet.',
                          style: TextStyle(color: Colors.black38, fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final id = doc.id;
                        final text = data['text'] ?? '';
                        final timestamp = data['timestamp'] as Timestamp?;
                        final isEdited = data['isEdited'] ?? false;

                        return AnnouncementCard(
                          id: id,
                          text: text,
                          timestamp: timestamp,
                          isEdited: isEdited,
                          isEditing: _editingPostId == id,
                          canEdit: userRole == 'CR',
                          onEdit: () {
                            setState(() {
                              _editingPostId = id;
                            });
                          },
                          onCancelEdit: () {
                            setState(() {
                              _editingPostId = null;
                            });
                          },
                          onSave: (newText) async {
                            await noticeService.updateNotice(id, newText);
                            setState(() {
                              _editingPostId = null;
                            });
                          },
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Announcement'),
                                content: const Text('Are you sure you want to delete this announcement?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await noticeService.deleteNotice(id);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Add New Button for CRs
            if (userRole == 'CR')
              Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final newNotice = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final TextEditingController controller = TextEditingController();
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
                                  onPressed: () => Navigator.pop(context, controller.text),
                                  child: const Text('Post'),
                                ),
                              ],
                            );
                          },
                        );

                        if (newNotice != null && newNotice.trim().isNotEmpty) {
                          await noticeService.addNotice(newNotice.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE90D4),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'New Post',
                        style: GoogleFonts.roboto(fontSize: 20, color: Colors.white, letterSpacing: 3),
                      ),
                    ),
                  ],
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
  final bool isEdited;
  final bool isEditing;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onCancelEdit;
  final ValueChanged<String> onSave;
  final VoidCallback onDelete;

  const AnnouncementCard({
    super.key,
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isEdited,
    required this.isEditing,
    required this.canEdit,
    required this.onEdit,
    required this.onCancelEdit,
    required this.onSave,
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
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.isEditing
              ? Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: widget.onCancelEdit,
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final updatedText = _controller.text.trim();
                            if (updatedText.isNotEmpty) {
                              widget.onSave(updatedText);
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    )
                  ],
                )
              : Text(
                  widget.text,
                  style: const TextStyle(fontSize: 18),
                ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${formatTimestamp(widget.timestamp)} ${widget.isEdited ? '(edited)' : ''}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              if (widget.canEdit && !widget.isEditing)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black45),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black45),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }
}
