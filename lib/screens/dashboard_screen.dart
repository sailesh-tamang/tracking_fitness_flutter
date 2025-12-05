import 'package:flutter/material.dart';

// adjust these imports to your actual paths
import 'package:tracking_fitness_flutter/screens/excerise.dart' show ExerciseScreen;
import 'meal_plans.dart';
import 'profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // <-- must NOT be final

  // All tab screens in a list
  final List<Widget> _screens = const [
    Center(
      child: Text(
        "This is my home page",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    ),
    MealPlansScreen(),
    ExerciseScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        title: Text(
          _getTitleForIndex(_currentIndex),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),

      // BODY changes based on selected tab
      body: _screens[_currentIndex],

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFD0FF00),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // <-- just switch tab, no Navigator.push
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meal Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Meal Plans";
      case 2:
        return "Exercise";
      case 3:
        return "Profile";
      default:
        return "Dashboard";
    }
  }
}
