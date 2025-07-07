import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hamro_project/presentation/screens/subject_assignment_page.dart';

import 'announcement.dart';
import 'assignment.dart';
import 'class_routine.dart';
import 'polls.dart';
import 'upcomming.dart';
import 'general_chat.dart';

import 'package:hamro_project/core/services/auth.dart';

void main() {
  runApp(const KachyaKothaApp());
}

class KachyaKothaApp extends StatelessWidget {
  const KachyaKothaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kachya Kotha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: 'Georgia'),
      home: const HomePage(),
      // Make sure to define '/login' route if you want to navigate after logout
      // routes: {
      //   '/login': (context) => LoginPage(),
      // },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String userRole = 'student';

  final List<MenuItem> menuItems = [
    MenuItem(
      title: "Announcement",
      iconPath: "assets/images/Announcement.png",
      page: AnnouncementPage(),
      badgeCount: 3,
    ),
    MenuItem(
      title: "Class Routines",
      iconPath: "assets/images/routine.png",
      page: ClassRoutineScreen(),
      badgeCount: 0,
    ),
    MenuItem(
      title: "Assignments",
      iconPath: "assets/images/assignments.png",
      page: AssignmentPage(),
      badgeCount: 5,
    ),
    MenuItem(
      title: "Polls",
      iconPath: "assets/images/pool.png",
      page: PollsPage(),
      badgeCount: 2,
    ),
    MenuItem(
      title: "General Chat", // new entry
      iconPath: "assets/images/upcomming.png", // same as Upcoming
      page: GeneralChat(),
      badgeCount: 0,
    ),
    MenuItem(
      title: "Upcoming",
      iconPath: "assets/images/commingsoon.jpg",
      page: UpcommingPage(),
      badgeCount: 7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUserRole();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );
    _animationController.forward();
    _headerAnimationController.repeat();
  }

  Future<void> _getCurrentUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() => userRole = doc['role'] ?? 'student');
        }
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? "Good Morning 🌄"
        : (hour < 17 ? "Good Afternoon 🌞" : "Good Evening 🌅");
    final roleTitle =
        (userRole.toLowerCase() == 'cr' || userRole.toLowerCase() == 'teacher')
        ? 'CR'
        : 'Student';
    return "$timeGreeting $roleTitle";
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${now.day} ${months[now.month - 1]}, ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/AppBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAnimatedHeader(),
              Expanded(child: _buildMenuGrid()),
              _buildBottomWave(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAnimatedHeader() => AnimatedBuilder(
    animation: _headerAnimationController,
    builder: (context, child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB388EB).withOpacity(0.9),
            const Color(0xFF8093F1).withOpacity(0.9),
          ],
          transform: GradientRotation(
            _headerAnimationController.value * 2 * math.pi,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Kachya Kotha',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.w600,
              fontFamily: 'lexend',
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMenuGrid() => FadeTransition(
    opacity: _fadeAnimation,
    child: SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final delay = index * 0.1;
                final val = Curves.easeOutBack.transform(
                  math.max(
                    0,
                    (_animationController.value - delay) / (1 - delay),
                  ),
                );
                return Transform.scale(
                  scale: val,
                  child: _buildEnhancedMenuCard(item, index),
                );
              },
            );
          },
        ),
      ),
    ),
  );

  Widget _buildEnhancedMenuCard(MenuItem item, int index) => Hero(
    tag: "menu_${item.title}",
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => item.page,
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  item.iconPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: 4,
                    color: Colors.white,
                    fontFamily: 'Lexend',
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (item.badgeCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      item.badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildBottomWave() => ClipPath(
    clipper: WaveClipper(),
    child: Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB388EB).withOpacity(0.8),
            const Color(0xFF8093F1).withOpacity(0.8),
          ],
        ),
      ),
    ),
  );

  Widget _buildFloatingActionButton() => FloatingActionButton(
    onPressed: _showQuickActionsSheet,
    backgroundColor: const Color(0xFFB388EB),
    child: const Icon(Icons.add, color: Colors.white),
  );

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
                print('logout tapped');
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
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 20);
    final cp1 = Offset(size.width / 4, size.height);
    final ep1 = Offset(size.width / 2, size.height - 10);
    p.quadraticBezierTo(cp1.dx, cp1.dy, ep1.dx, ep1.dy);
    final cp2 = Offset(size.width * 3 / 4, size.height - 20);
    final ep2 = Offset(size.width, size.height - 10);
    p.quadraticBezierTo(cp2.dx, cp2.dy, ep2.dx, ep2.dy);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class MenuItem {
  final String title;
  final String iconPath;
  final Widget page;
  final int badgeCount;
  const MenuItem({
    required this.title,
    required this.iconPath,
    required this.page,
    this.badgeCount = 0,
  });
}
