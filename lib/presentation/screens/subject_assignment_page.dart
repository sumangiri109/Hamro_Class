import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/assignment_service.dart';

class SubjectAssignmentPage extends StatefulWidget {
  final String subject;
  const SubjectAssignmentPage({Key? key, required this.subject})
    : super(key: key);

  @override
  State<SubjectAssignmentPage> createState() => _SubjectAssignmentPageState();
}

class _SubjectAssignmentPageState extends State<SubjectAssignmentPage> {
  final AssignmentService _svc = AssignmentService();
  String? _role;

  // Track which post is being edited (null if none)
  String? _editingPostId;

  // Controller for the editable TextField (only one at a time)
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()!.containsKey('role')) {
        setState(() => _role = doc['role'] as String);
      }
    }
  }

  String _fmt(Timestamp? ts) {
    if (ts == null) return 'Unknown time';
    return DateFormat.yMMMd().add_jm().format(ts.toDate());
  }

  Future<void> _showNewPostDialog() async {
    final textCtrl = TextEditingController();

    final shouldPost = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add Assignment'),
        content: TextField(
          controller: textCtrl,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Details'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (shouldPost == true && textCtrl.text.trim().isNotEmpty) {
      final txt = textCtrl.text.trim();
      try {
        await _svc.addPost(widget.subject, txt);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding post: $e')));
      }
    }
  }

  void _startEditing(String postId, String currentText) {
    setState(() {
      _editingPostId = postId;
      _editingController.text = currentText;
    });
  }

  Future<void> _saveEdit(String postId) async {
    final newText = _editingController.text.trim();
    if (newText.isNotEmpty) {
      await _svc.updatePost(widget.subject, postId, newText);
      setState(() {
        _editingPostId = null;
        _editingController.clear();
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingPostId = null;
      _editingController.clear();
    });
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text("BACK"),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Assignments and Internals - ${widget.subject}",
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

            // Posts List
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
                            stream: _svc.streamPosts(widget.subject),
                            builder: (ctx, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final docs = snap.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No assignment posts yet.',
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }
                              return Scrollbar(
                                thickness: 8,
                                radius: const Radius.circular(10),
                                thumbVisibility: true,
                                child: ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (_, i) {
                                    final doc = docs[i];
                                    final data =
                                        doc.data()! as Map<String, dynamic>;
                                    final txt = data['text'] as String? ?? '';
                                    final ts = data['timestamp'] as Timestamp?;
                                    final isEdited =
                                        data['isEdited'] as bool? ?? false;

                                    final isEditingThisPost =
                                        _editingPostId == doc.id;

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1E4FA),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purple.shade100
                                                .withOpacity(0.6),
                                            offset: const Offset(0, 6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                            255,
                                            145,
                                            145,
                                            146,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (isEditingThisPost &&
                                              _role == 'CR')
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  controller:
                                                      _editingController,
                                                  maxLines: null,
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 20,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        contentPadding:
                                                            EdgeInsets.all(12),
                                                      ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          _saveEdit(doc.id),
                                                      child: const Text('Save'),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    ElevatedButton(
                                                      onPressed: _cancelEdit,
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.grey,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          else
                                            Text(
                                              txt,
                                              style: GoogleFonts.roboto(
                                                fontSize: 20,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${_fmt(ts)}${isEdited ? ' (edited)' : ''}",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.black45,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              if (_role == 'CR' &&
                                                  !isEditingThisPost)
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.black54,
                                                        size: 28,
                                                      ),
                                                      tooltip: 'Edit post',
                                                      onPressed: () =>
                                                          _startEditing(
                                                            doc.id,
                                                            txt,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.black45,
                                                        size: 28,
                                                      ),
                                                      tooltip: 'Delete post',
                                                      onPressed: () async {
                                                        final del = await showDialog<bool>(
                                                          context: context,
                                                          builder: (_) => AlertDialog(
                                                            title: const Text(
                                                              'Delete this post?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'No',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Yes',
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        if (del == true) {
                                                          _svc.deletePost(
                                                            widget.subject,
                                                            doc.id,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Only "New Post" button for CR
                    if (_role == 'CR') ...[
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBE90D4),
                            side: const BorderSide(
                              color: Colors.black26,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showNewPostDialog,
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
