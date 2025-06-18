import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:hamro_project/presentation/screens/login_page.dart';
=======
import 'package:hamro_project/presentation/screens/sign_up_page.dart';
>>>>>>> 2b1807d137f86e9f2924ef3310790bf9f646531a
//import 'package:hamro_project/firebase_options.dart';
import 'core/services/firebase_options.dart';

void main() async {
  // Firebase initilization:
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD

      title: 'Kachhya Kotha',
      home: LoginPage(),
=======
      title: 'Kachhya Kotha',
      home: SignUpPage(),
>>>>>>> 2b1807d137f86e9f2924ef3310790bf9f646531a
    );
  }
}
