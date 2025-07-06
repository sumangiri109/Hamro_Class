import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/poll_service.dart';

class PollsPage extends StatefulWidget {
  const PollsPage({super.key});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  final PollService pollService = PollService();
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
                      "Polls",
                      style: TextStyle(
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
                            stream: pollService.getPollsStream(),
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
                                    'No polls yet.',
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
                                    final question = data['question'] ?? '';
                                    final options = List<String>.from(
                                      data['options'] ?? [],
                                    );
                                    final votes = Map<String, dynamic>.from(
                                      data['votes'] ?? {},
                                    );
                                    final timestamp =
                                        data['timestamp'] as Timestamp?;

                                    return PollCard(
                                      pollId: doc.id,
                                      question: question,
                                      options: options,
                                      votes: votes,
                                      timestamp: timestamp,
                                      userRole: userRole,
                                      isEditing: isEditing,
                                      onChanged: (newText) => pollService
                                          .updatePoll(doc.id, newText),
                                      onOptionsChanged: (newOptions) =>
                                          pollService.updateOptions(
                                            doc.id,
                                            newOptions,
                                          ),
                                      onVote: (index) =>
                                          pollService.vote(doc.id, index),
                                      onDeVote: () =>
                                          pollService.removeVote(doc.id),
                                      onDelete: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Poll'),
                                            content: const Text(
                                              'Are you sure you want to delete this poll?',
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
                                          await pollService.deletePoll(doc.id);
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

                    if (userRole == 'CR') ...[
                      Positioned(
                        bottom: 70,
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
                          onPressed: () async {
                            final questionController = TextEditingController();
                            final List<TextEditingController>
                            optionControllers = [
                              TextEditingController(),
                              TextEditingController(),
                            ];

                            final result =
                                await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('New Poll'),
                                    content: StatefulBuilder(
                                      builder: (context, setState) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: questionController,
                                            decoration: const InputDecoration(
                                              hintText: 'Poll question',
                                            ),
                                          ),
                                          ...optionControllers.map(
                                            (controller) => TextField(
                                              controller: controller,
                                              decoration: const InputDecoration(
                                                hintText: 'Option',
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () => setState(
                                              () => optionControllers.add(
                                                TextEditingController(),
                                              ),
                                            ),
                                            icon: const Icon(Icons.add),
                                            label: const Text("Add Option"),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, {
                                              'question':
                                                  questionController.text,
                                              'options': optionControllers
                                                  .map((ctrl) => ctrl.text)
                                                  .toList(),
                                            }),
                                        child: const Text('Post'),
                                      ),
                                    ],
                                  ),
                                );

                            if (result != null &&
                                result['question'] != null &&
                                (result['options'] as List).isNotEmpty) {
                              await pollService.addPoll(
                                result['question'],
                                List<String>.from(result['options']),
                              );
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

class PollCard extends StatefulWidget {
  final String pollId;
  final String question;
  final List<String> options;
  final Map<String, dynamic> votes; // userId -> selectedOptionIndex
  final Timestamp? timestamp;
  final String? userRole;
  final bool isEditing;
  final ValueChanged<String> onChanged;
  final ValueChanged<List<String>> onOptionsChanged;
  final Function(int) onVote;
  final VoidCallback onDeVote;
  final VoidCallback onDelete;

  const PollCard({
    super.key,
    required this.pollId,
    required this.question,
    required this.options,
    required this.votes,
    required this.timestamp,
    required this.userRole,
    required this.isEditing,
    required this.onChanged,
    required this.onOptionsChanged,
    required this.onVote,
    required this.onDeVote,
    required this.onDelete,
  });

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  late TextEditingController _controller;
  late List<TextEditingController> _optionControllers;
  String? userId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question);
    _optionControllers = widget.options
        .map((opt) => TextEditingController(text: opt))
        .toList();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void didUpdateWidget(covariant PollCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _controller.text = widget.question;
    }
    if (oldWidget.options != widget.options) {
      _optionControllers = widget.options
          .map((opt) => TextEditingController(text: opt))
          .toList();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var ctrl in _optionControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    final date = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(date);
  }

  int? getUserVoteIndex() {
    if (userId == null) return null;
    return widget.votes[userId]?.toInt();
  }

  int getVoteCount(int optionIndex) {
    return widget.votes.values
        .where((v) => v.toString() == optionIndex.toString())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final userVoteIndex = getUserVoteIndex();
    final userHasVoted = userVoteIndex != null;

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
          widget.isEditing && widget.userRole == 'CR'
              ? TextFormField(
                  controller: _controller,
                  maxLines: null,
                  style: GoogleFonts.roboto(fontSize: 20),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Edit Question',
                  ),
                  onFieldSubmitted: (val) {
                    widget.onChanged(val.trim());
                  },
                )
              : Text(
                  widget.question,
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    letterSpacing: 2,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
          const SizedBox(height: 10),

          // Options with vertical padding between them
          ...List.generate(widget.options.length, (index) {
            final optionText = widget.options[index];
            final voteCount = getVoteCount(index);

            if (widget.isEditing && widget.userRole == 'CR') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (val) {
                          final newOptions = List<String>.from(widget.options);
                          newOptions[index] = val.trim();
                          widget.onOptionsChanged(newOptions);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black38),
                      onPressed: () {
                        final newOptions = List<String>.from(widget.options);
                        if (newOptions.length > 1) {
                          newOptions.removeAt(index);
                          widget.onOptionsChanged(newOptions);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('At least one option is required.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }

            // Voting buttons with vertical spacing between
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: userVoteIndex == index
                      ? const Color.fromARGB(255, 211, 181, 232)
                      : Colors.white,
                  foregroundColor: userVoteIndex == index
                      ? Colors.white
                      : Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: userVoteIndex == index
                          ? const Color.fromARGB(255, 209, 208, 208)
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                ),
                onPressed: () {
                  if (userVoteIndex == index) {
                    widget.onDeVote();
                  } else {
                    widget.onVote(index);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        optionText,
                        style: GoogleFonts.roboto(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        voteCount.toString(),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color.fromARGB(255, 195, 116, 226),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (widget.isEditing && widget.userRole == 'CR') ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
              ),
              onPressed: () {
                final newOptions = List<String>.from(widget.options);
                newOptions.add('');
                widget.onOptionsChanged(newOptions);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
          ],

          const SizedBox(height: 12),

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
              if (widget.userRole == 'CR' && widget.isEditing)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black38),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
