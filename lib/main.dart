import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hamro_project/presentation/screens/announcement.dart';
import 'package:hamro_project/presentation/screens/class_routine.dart';
import 'package:hamro_project/presentation/screens/home_page.dart';
import 'package:hamro_project/presentation/screens/login_page.dart';
import 'package:hamro_project/presentation/screens/sign_up_page.dart';
import 'core/services/firebase_options.dart';

void main() async {
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
      title: 'Kachhya Kotha',
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginPage()
          : const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
