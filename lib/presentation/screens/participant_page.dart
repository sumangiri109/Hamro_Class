import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ParticipantPage extends StatefulWidget {
  const ParticipantPage({Key? key}) : super(key: key);

  @override
  State<ParticipantPage> createState() => _ParticipantPageState();
}

class _ParticipantPageState extends State<ParticipantPage> {
  final DateFormat _dateFormat = DateFormat.yMMMMd().add_jm();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() => userRole = doc['role'] as String?);
      }
    }
  }

  Future<void> _toggleRole(String uid, String currentRole) async {
    final newRole = currentRole == 'CR' ? 'Student' : 'CR';
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': newRole,
    });
  }

  Future<void> _toggleAccept(String uid, bool isAccepted) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isAccepted': !isAccepted,
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
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('BACK'),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Participants',
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
            // Participants Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No participants found.',
                          style: TextStyle(color: Colors.black38, fontSize: 18),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 12,
                          columns: const [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Joined At')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final email = data['email'] as String? ?? '';
                            final role = data['role'] as String? ?? 'Student';
                            final createdTs = data['createdAt'] as Timestamp?;
                            final createdAtStr = createdTs != null
                                ? _dateFormat.format(createdTs.toDate())
                                : 'Unknown';
                            final isAccepted =
                                data['isAccepted'] as bool? ?? false;

                            return DataRow(
                              cells: [
                                DataCell(Text(email)),
                                DataCell(Text(role)),
                                DataCell(Text(createdAtStr)),
                                DataCell(
                                  Text(isAccepted ? 'Accepted' : 'Pending'),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      if (userRole == 'CR')
                                        ElevatedButton(
                                          onPressed: () =>
                                              _toggleAccept(doc.id, isAccepted),
                                          child: Text(
                                            isAccepted ? 'Revoke' : 'Accept',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFBE90D4,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      if (userRole == 'CR' && isAccepted)
                                        ElevatedButton(
                                          onPressed: () =>
                                              _toggleRole(doc.id, role),
                                          child: Text(
                                            role == 'CR'
                                                ? 'Make Student'
                                                : 'Make CR',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFBE90D4,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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
