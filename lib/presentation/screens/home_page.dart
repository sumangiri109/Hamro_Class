import 'package:flutter/material.dart';
import 'package:hamro_project/presentation/screens/class_routine.dart';

// Import each page from its own file
import 'announcement.dart';
import 'assignment.dart';
import 'polls.dart';
import 'upcomming.dart';
import 'class_routine.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${_getMonthName(now.month)} ${now.day}, ${now.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  final List<MenuItem> menuItems = [
    MenuItem(
      title: "Announcement",
      iconPath: "images/Announcement.png",
      page: AnnouncementPage(),
    ),
    MenuItem(
      title: "Class Routines",
      iconPath: "images/routine.png",
      page: ClassRoutineScreen(),
    ),
    MenuItem(
      title: "Assignments",
      iconPath: "images/assignments.png",
      page: AssignmentPage(),
    ),
    MenuItem(title: "Polls", iconPath: "images/pool.png", page: PollsPage()),
    MenuItem(
      title: "Upcomming",
      iconPath: "images/upcomming.png",
      page: UpcommingPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Logged out")));
        },
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
      ),
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
              color: const Color(0xFFB388EB),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "👋 Greetings & Welcome Back",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "~ Kachya Kotha ~",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getCurrentDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Courier',
                      color: Colors.white,
                    ),
                  ),
                ],
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
                color: const Color.fromRGBO(209, 178, 255, 0.9),
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
