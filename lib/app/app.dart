import 'package:flutter/material.dart';
import 'package:tracking_fitness_flutter/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:tracking_fitness_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:tracking_fitness_flutter/features/splash/presentation/pages/splash_screen.dart';

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
