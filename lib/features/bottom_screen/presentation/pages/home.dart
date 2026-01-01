import 'package:flutter/material.dart';
import 'package:tracking_fitness_flutter/app/app.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Center(
        child: Text("Dashboard",style: TextStyle(color: Colors.white),
        ),
      ),
        backgroundColor: Colors.black,
      ),

    );
  }
}
