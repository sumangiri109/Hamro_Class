import 'package:flutter/material.dart';
import 'package:hamro_project/core/services/auth.dart'; // for signOutUser

class WaitingApprovalPage extends StatefulWidget {
  const WaitingApprovalPage({Key? key}) : super(key: key);

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage> {
  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Color(0xFFB388EB)),
              title: const Text('Logout'),
              onTap: () async {
                await AuthMethods().signOutUser();
                if (!mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() => FloatingActionButton(
    onPressed: _showQuickActionsSheet,
    backgroundColor: const Color(0xFFB388EB),
    child: const Icon(Icons.more_horiz, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background image same as other pages
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/AppBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Top bar like Announcement page
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Color(0xFFBE90D4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Access Pending",
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'lexend',
                  color: Colors.white,
                  letterSpacing: 5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Expanded(child: SizedBox()),

            // Center message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: const Text(
                "Your access is pending approval by the admin.\nPlease wait until you are accepted.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Expanded(child: SizedBox()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
