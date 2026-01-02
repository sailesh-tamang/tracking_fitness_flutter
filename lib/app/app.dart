import 'package:flutter/material.dart';
import 'package:lost_n_found/features/splash/presentation/pages/splash_screen.dart';



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
