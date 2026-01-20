


import 'package:fitness_tracker/features/bottom_screen/presentation/pages/excerise_plan.dart';
import 'package:fitness_tracker/features/bottom_screen/presentation/pages/home.dart';
import 'package:fitness_tracker/features/bottom_screen/presentation/pages/meal_plan.dart';
import 'package:fitness_tracker/features/bottom_screen/presentation/pages/profile.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;


  List<Widget> lstBottomScreen = [
    const Home(),
    const MealPlan(),
    const ExcerisePlan(),
    const Profile(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'meal plan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_handball),
              label: 'excerises'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'profile'),
        ],
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
