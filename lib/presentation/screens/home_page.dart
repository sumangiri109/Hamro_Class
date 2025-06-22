import 'package:flutter/material.dart';
import 'package:hamro_project/presentation/screens/class_routine.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  final List<MenuItem> menuItems = const [
    MenuItem(
      title: "Announcement",
      iconPath: "images/Announcement.png",
      page: AnnouncementPage(),
    ),
    MenuItem(
      title: "Class Routines",
      iconPath: "images/routine.png",
      page: ClassRoutinePage(),
    ),
    MenuItem(
      title: "Assignments",
      iconPath: "images/assignments.png",
      page: AssignmentsPage(),
    ),
    MenuItem(
      title: "Study Materials",
      iconPath: "images/pool.png",
      page: StudyMaterialsPage(),
    ),
    MenuItem(
      title: "Upcoming",
      iconPath: "images/upcomming.png",
      page: UpcomingPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/AppBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              color: Color(0xFFB388EB),
              child: const Text(
                '~ Kachya Kotha ~',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: menuItems
                      .map((item) => _buildMenuCard(context, item))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, MenuItem item) {
    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item.page),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFD1B2FF).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  item.iconPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Georgia',
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MenuItem {
  final String title;
  final String iconPath;
  final Widget page;

  const MenuItem({
    required this.title,
    required this.iconPath,
    required this.page,
  });
}

// Placeholder pages for navigation targets
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Announcement")),
      body: const Center(child: Text("Announcement Page")),
    );
  }
}

class ClassRoutinePage extends StatelessWidget {
  const ClassRoutinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Class Routine")),
      body: const Center(child: Text("Class Routine Page")),
    );
  }
}

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignments")),
      body: const Center(child: Text("Assignments Page")),
    );
  }
}

class StudyMaterialsPage extends StatelessWidget {
  const StudyMaterialsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Materials")),
      body: const Center(child: Text("Study Materials Page")),
    );
  }
}

class UpcomingPage extends StatelessWidget {
  const UpcomingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming")),
      body: const Center(child: Text("Upcoming Page")),
    );
  }
}
