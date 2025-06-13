import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hamro_project/core/services/firebase_options.dart';
import 'package:hamro_project/presentation/screens/widgets/widgets_tests.dart';

void main() async {
  // Firebase initilization:
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamro Project',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WidgetTest(),
    );
  }
}
