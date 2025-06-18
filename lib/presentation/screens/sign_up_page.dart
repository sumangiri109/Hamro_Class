import 'package:flutter/material.dart';
import 'package:hamro_project/constant/const.dart';
import 'package:hamro_project/presentation/screens/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "images/AppBackground.png",
            ), // Your background image
            fit: BoxFit.cover, // Make it cover full screen
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Text Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Kacchya\nKotha~",
                      style: TextStyle(
                        fontSize: 60,

                        // fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontFamily: 'lexendPeta',
                        fontWeight: FontWeight.w200,
                        letterSpacing: 7.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "A Classroom\nBeyond the\nwalls",
                      style: TextStyle(
                        fontSize: 50,
                        height: 1.3,
                        color: Colors.black54,
                        letterSpacing: 7.0,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle: Image
            Expanded(
              flex: 3,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'images/school-workplace-classroom.jpg', // The classroom image
                    width: 400,
                    height: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Right: Login Form
            Expanded(
              flex: 5,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  margin: EdgeInsets.only(top: 50, right: 50, bottom: 50),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 220, 220),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD2B7F5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.black),
                        ),
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
}
