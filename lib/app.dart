import 'package:flutter/material.dart';
import 'package:tracking_fitness_flutter/screens/dashboard_screen.dart';
import 'package:tracking_fitness_flutter/screens/login_screen.dart';
import 'package:tracking_fitness_flutter/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
