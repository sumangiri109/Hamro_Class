import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineService {
  final _firestore = FirebaseFirestore.instance;
  final String _docId = 'current';

  /// Save routine by converting 2D list into map of maps (row -> col -> value)
  Future<void> saveRoutine(List<List<String>> routine) async {
    try {
      Map<String, Map<String, String>> routineMap = {};

      for (int i = 0; i < routine.length; i++) {
        Map<String, String> rowMap = {};
        for (int j = 0; j < routine[i].length; j++) {
          rowMap[j.toString()] = routine[i][j];
        }
        routineMap[i.toString()] = rowMap;
      }

      await _firestore.collection('routine_table').doc(_docId).set({
        'data': routineMap,
        'lastUpdated': Timestamp.now(),
      });

      print('Routine saved to Firestore successfully.');
    } catch (e) {
      print('Error saving routine to Firestore: $e');
    }
  }

  /// Load routine and convert map of maps back to 2D list
  Future<List<List<String>>> fetchRoutine(
    List<String> days,
    List<String> times,
  ) async {
    try {
      final doc = await _firestore
          .collection('routine_table')
          .doc(_docId)
          .get();

      if (doc.exists && doc.data()?['data'] != null) {
        final data = Map<String, dynamic>.from(doc['data']);
        List<List<String>> routine = [];

        for (int i = 0; i < days.length; i++) {
          final rowMap = Map<String, dynamic>.from(data[i.toString()] ?? {});
          List<String> row = [];
          for (int j = 0; j < times.length; j++) {
            row.add(rowMap[j.toString()]?.toString() ?? '');
          }
          routine.add(row);
        }

        print('Routine fetched from Firestore.');
        return routine;
      } else {
        print('Routine document not found. Returning empty routine.');
        return List.generate(days.length, (_) => List.filled(times.length, ''));
      }
    } catch (e) {
      print('Error fetching routine: $e');
      return List.generate(days.length, (_) => List.filled(times.length, ''));
    }
  }
}
