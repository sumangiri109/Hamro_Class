import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/routine_service.dart';

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  final List<String> times = [
    '9:00–11:00',
    '11:00–12:00',
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
  ];

  late List<List<String>> routine;
  bool? isCR;
  bool isEditing = false;

  //fixed.
  static const double rowHeight = 67.3;

  @override
  void initState() {
    super.initState();
    routine = List.generate(days.length, (_) => List.filled(times.length, ''));
    fetchUserRole();
    loadRoutineFromFirestore();
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

  Future<void> loadRoutineFromFirestore() async {
    final service = RoutineService();
    final loadedRoutine = await service.fetchRoutine(days, times);
    setState(() {
      routine = loadedRoutine;
    });
  }

  Future<void> saveRoutineToFirestore() async {
    final service = RoutineService();
    await service.saveRoutine(routine);
  }

  @override
  Widget build(BuildContext context) {
    if (isCR == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            // Header...
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
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("BACK"),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Class Routine",
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

            // Routine Table (fills width, no horizontal scroll)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      // only vertical scroll if needed
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black26,
                                width: 1,
                              ),
                            ),
                            child: Table(
                              border: TableBorder(
                                verticalInside: const BorderSide(
                                  color: Colors.black26,
                                ),
                                horizontalInside: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              // Distribute each column equally
                              columnWidths: {
                                for (int i = 0; i <= times.length; i++)
                                  i: const FlexColumnWidth(1),
                              },
                              children: [
                                _buildHeaderRow(),
                                ...List.generate(days.length, _buildDataRow),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Edit/Save FAB...
            if (isCR!)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, right: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      if (isEditing) await saveRoutineToFirestore();
                      setState(() => isEditing = !isEditing);
                    },
                    backgroundColor: isEditing
                        ? const Color(0xFFE2B2EA)
                        : const Color(0xFFB28DD0),
                    icon: Icon(isEditing ? Icons.save : Icons.edit),
                    label: Text(isEditing ? 'Save' : 'Edit'),
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
        _buildCell(
          'Day',
          isHeader: true,
          fixedHeight: rowHeight,
          addRightBorder: false,
        ),
        ...times.map(
          (t) => _buildCell(
            t,
            isHeader: true,
            fixedHeight: rowHeight,
            addRightBorder: false,
          ),
        ),
      ],
    );
  }

  TableRow _buildDataRow(int rowIndex) {
    return TableRow(
      decoration: BoxDecoration(
        color: rowIndex.isEven ? const Color(0xFFF1E4FA) : Colors.white,
      ),
      children: [
        _buildCell(
          days[rowIndex],
          isHeader: true,
          fixedHeight: rowHeight,
          addRightBorder: false,
        ),
        ...List.generate(times.length, (colIndex) {
          final text = routine[rowIndex][colIndex];
          return _buildCell(
            text,
            isHeader: false,
            fixedHeight: rowHeight,
            isEditing: isEditing,
            onChanged: (val) => routine[rowIndex][colIndex] = val,
            addRightBorder: false,
          );
        }),
      ],
    );
  }

  Widget _buildCell(
    String text, {
    bool isHeader = false,
    bool isEditing = false,
    ValueChanged<String>? onChanged,
    double? fixedHeight,
    bool addRightBorder = false,
  }) {
    Widget child = isEditing
        ? TextFormField(
            initialValue: text,
            onChanged: onChanged,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            ),
          )
        : Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHeader ? 17 : 20,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,
                fontFamily: 'Georgia',
                color: isHeader ? Colors.black87 : Colors.black54,
              ),
            ),
          );

    if (fixedHeight != null) {
      child = SizedBox(height: fixedHeight, child: child);
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: addRightBorder
          ? const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.black26, width: 1),
              ),
            )
          : null,
      child: child,
    );
  }
}
