import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassRoutinePage extends StatefulWidget {
  const ClassRoutinePage({Key? key}) : super(key: key);

  @override
  State<ClassRoutinePage> createState() => _ClassRoutinePageState();
}

class _ClassRoutinePageState extends State<ClassRoutinePage> {
  bool? isCR; // null = loading, true = CR, false = student

  final List<String> times = ['9–11', '11–12', '12–2', '2–4'];
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

  @override
  void initState() {
    super.initState();
    routine = List.generate(days.length, (_) => List.filled(times.length, ''));
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isCR = false); // Not signed in
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc['role'];
        setState(() {
          isCR = role == 'cr';
        });
      } else {
        setState(() => isCR = false); // Default to student
      }
    } catch (e) {
      print("Error checking role: $e");
      setState(() => isCR = false);
    }
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
        title: const Text(
          'Class Routine',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              isCR!
                  ? "You are CR - tap any cell to edit."
                  : "You are Student - read-only mode.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCR! ? Colors.green : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder.all(color: Colors.black12),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {0: FixedColumnWidth(90)},
                    children: [
                      _buildHeaderRow(),
                      ...List.generate(
                        days.length,
                        (row) => _buildDataRow(row),
                      ),
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
        _buildCell("Day", isHeader: true),
        ...times.map((t) => _buildCell(t, isHeader: true)).toList(),
      ],
    );
  }

  TableRow _buildDataRow(int row) {
    return TableRow(
      decoration: BoxDecoration(
        color: row % 2 == 0 ? const Color(0xFFF6ECFF) : Colors.white,
      ),
      children: [
        _buildCell(days[row], isHeader: true),
        ...List.generate(times.length, (col) {
          return GestureDetector(
            onTap: () {
              if (isCR!) {
                _editCell(row, col);
              }
            },
            child: _buildCell(routine[row][col]),
          );
        }),
      ],
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text.isEmpty ? "-" : text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 16 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }

  void _editCell(int row, int col) async {
    final controller = TextEditingController(text: routine[row][col]);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit ${days[row]} ${times[col]}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter subject/class"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                routine[row][col] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
