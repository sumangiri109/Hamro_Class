import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  final List<String> times = [
    '9:00–11:00',
    '11:00–12:00', // Break
    '12:00–2:00',
    '2:00–4:00',
  ];

  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  late List<List<String>> routine;
  bool? isCR;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    routine = List.generate(days.length, (_) => List.filled(times.length, ''));
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isCR = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      isCR = doc.exists && doc['role'].toString().toLowerCase() == 'cr';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCR == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3EAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB28DD0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Class Routine',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "BACK",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isCR!
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing ? 'Edit mode enabled' : 'Edit mode disabled',
                    ),
                  ),
                );
              },
              backgroundColor: isEditing
                  ? Colors.redAccent
                  : const Color(0xFFB28DD0),
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              label: Text(isEditing ? 'Save' : 'Edit'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Class Routine Table',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Table(
                    border: TableBorder.all(color: Colors.black26),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      0: const FixedColumnWidth(100),
                      for (int i = 1; i <= times.length; i++)
                        i: const FixedColumnWidth(140),
                    },
                    children: [
                      _buildHeaderRow(),
                      ...List.generate(days.length, _buildDataRow),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFE4C6F1)),
      children: [
        _buildCell('Day', isHeader: true),
        ...times.map((t) => _buildCell(t, isHeader: true)).toList(),
      ],
    );
  }

  TableRow _buildDataRow(int rowIndex) {
    return TableRow(
      decoration: BoxDecoration(
        color: rowIndex % 2 == 0 ? const Color(0xFFF1E4FA) : Colors.white,
      ),
      children: [
        _buildCell(days[rowIndex], isHeader: true),
        ...List.generate(times.length, (colIndex) {
          final isBreak = times[colIndex] == '11:00–12:00';
          final text = routine[rowIndex][colIndex].isEmpty && isBreak
              ? 'Break'
              : routine[rowIndex][colIndex];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: isEditing && !isBreak
                ? TextFormField(
                    initialValue: text,
                    onChanged: (value) {
                      routine[rowIndex][colIndex] = value;
                    },
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                  )
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 16 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
}
