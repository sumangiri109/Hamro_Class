import 'package:flutter/material.dart';
import 'package:hamro_project/core/services/auth.dart' show AuthMethods;
import 'package:hamro_project/presentation/screens/home_page.dart';
import 'package:hamro_project/presentation/screens/sign_up_page.dart';
import 'waiting_approval.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      await AuthMethods().getCurrentUserRole();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (res == "not_accepted") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WaitingApprovalPage()),
      );
    } else if (res == "email_not_verified") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email not verified. Your account has been deleted. Please sign up again.",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/AppBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text Section
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

            // Image
            Expanded(
              flex: 3,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/school-workplace-classroom.jpg",
                    width: 400,
                    height: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Login Form box
            Expanded(
              flex: 5,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  margin: const EdgeInsets.only(top: 50, right: 50, bottom: 50),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 232, 234),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.black54,
                            letterSpacing: 7.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "KU Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD2B7F5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.black54,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDBDBDB),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Color(0xFF8E8E8E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDBDBDB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.black54,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                color: Color(0xFF0095F6),
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
