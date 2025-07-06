import 'package:flutter/material.dart';

class UpcommingPage extends StatefulWidget {
  const UpcommingPage({super.key});

  @override
  State<UpcommingPage> createState() => _UpcommingPageState();
}

class _UpcommingPageState extends State<UpcommingPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'images/AppBackground.png', // Replace with your image
            fit: BoxFit.cover,
          ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.5)),

          // Main content
          Column(
            children: [
              // Header with back and centered title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFBA94D1),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xFFEED7FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('BACK'),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Upcomings',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'lexend',
                          color: Colors.white,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Feature list with animation
              Expanded(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        children: [
                          buildFeatureCard(
                            "🎨Dark Mode & Theme",
                            "Switch between light and dark themes.",
                          ),
                          buildFeatureCard(
                            "📁Resource Sharing",
                            "Share notes, PDFs, and links with your class.",
                          ),
                          buildFeatureCard(
                            "📅Attendance System",
                            "View and manage attendance records.",
                          ),
                          buildFeatureCard(
                            "🔔Push Notifications",
                            "Receive real-time updates and alerts.",
                          ),
                          buildFeatureCard(
                            "💬Communication Tools",
                            "Chat between students and class reps.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Clean feature card
  Widget buildFeatureCard(String title, String subtitle) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
