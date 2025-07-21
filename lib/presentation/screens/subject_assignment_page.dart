import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();

  // map of postId -> comment controller
  final Map<String, TextEditingController> _commentControllers = {};

  String _fmt(Timestamp? ts) =>
      ts == null ? 'Unknown time' : _dateFormat.format(ts.toDate());

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  @override
  void dispose() {
    _postController.dispose();
    _commentControllers.values.forEach((c) => c.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()?.containsKey('role') == true) {
        setState(() {
          _role = doc['role'] as String;
        });
      }
    }
  }

  Future<String?> _showNewPostDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Assignment'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Details'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final txt = controller.text.trim();
              Navigator.pop(ctx, txt.isEmpty ? null : txt);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _addNewPost() async {
    final text = await _showNewPostDialog();
    if (text != null) {
      await _svc.addPost(widget.subject, text);
    }
  }

  void _startEditing(String postId, String currentText) {
    setState(() {
      _postController.text = currentText;
    });
  }

  Future<void> _saveEdit(String postId) async {
    final newText = _postController.text.trim();
    if (newText.isNotEmpty) {
      await _svc.updatePost(widget.subject, postId, newText);
      setState(() {
        _postController.clear();
      });
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
            image: AssetImage('assets/images/AppBackground.png'),
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
                      child: const Text('BACK'),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Assignments – ${widget.subject}',
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

            // Posts + Comments
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
                              if (docs.isEmpty)
                                return const Center(
                                  child: Text(
                                    'No posts yet.',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                );

                              return Scrollbar(
                                controller: _scrollController,
                                thickness: 8,
                                radius: const Radius.circular(10),
                                thumbVisibility: true,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: docs.length,
                                  itemBuilder: (context, i) {
                                    final doc = docs[i];
                                    final data =
                                        doc.data()! as Map<String, dynamic>;
                                    final txt = data['text'] as String? ?? '';
                                    final ts = data['timestamp'] as Timestamp?;
                                    final isEdited =
                                        data['isEdited'] as bool? ?? false;
                                    final authorEmail =
                                        data['userEmail'] as String? ??
                                        'unknown';

                                    // ensure controller for this post
                                    final commentCtrl = _commentControllers
                                        .putIfAbsent(
                                          doc.id,
                                          () => TextEditingController(),
                                        );

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
                                          Text(
                                            txt,
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${_fmt(ts)}${isEdited ? ' (edited)' : ''}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const Divider(height: 24),

                                          // Comment input
                                          TextField(
                                            controller: commentCtrl,
                                            decoration: InputDecoration(
                                              hintText: 'Add a comment...',
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.send),
                                                onPressed: () async {
                                                  final commentText =
                                                      commentCtrl.text.trim();
                                                  if (commentText.isNotEmpty) {
                                                    await _svc.addComment(
                                                      subject: widget.subject,
                                                      postId: doc.id,
                                                      commentText: commentText,
                                                    );
                                                    commentCtrl.clear();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Comment list
                                          StreamBuilder<QuerySnapshot>(
                                            stream: _svc.getCommentsStream(
                                              widget.subject,
                                              doc.id,
                                            ),
                                            builder: (c, csnap) {
                                              if (!csnap.hasData)
                                                return const SizedBox();
                                              final comments = csnap.data!.docs;
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: comments.length,
                                                itemBuilder: (context, idx) {
                                                  final cd = comments[idx];
                                                  final cdata =
                                                      cd.data()!
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >;
                                                  final email =
                                                      cdata['userEmail']
                                                          as String? ??
                                                      'unknown';
                                                  final text =
                                                      cdata['text']
                                                          as String? ??
                                                      '';
                                                  final cts =
                                                      cdata['timestamp']
                                                          as Timestamp?;

                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 12,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          email,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          text,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          _fmt(cts),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black45,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
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

                    if (_role == 'CR')
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          onPressed: _addNewPost,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
