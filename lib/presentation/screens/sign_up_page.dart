import 'package:flutter/material.dart';
import 'package:hamro_project/core/services/auth.dart';
import 'email_verification_waiting_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final _studentEmailRegex = RegExp(r'^[^@]+@student\.ku\.edu\.np$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_studentEmailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use your official student.ku.edu.np email'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      // Verification email sent inside signUpUser(), no need to resend here

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Please check your inbox.'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationWaitingPage(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $res')));
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
            // Branding Text
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

            // Classroom Image
            Expanded(
              flex: 3,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/school-workplace-classroom.jpg',
                    width: 400,
                    height: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Sign Up Form
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
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.black54,
                          letterSpacing: 7.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "KU Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 30),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: signUpUser,
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
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.black54,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                      const SizedBox(height: 20),

                      // Login redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.black54,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Log in",
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
