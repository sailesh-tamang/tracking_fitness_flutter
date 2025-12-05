import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is my excerise Screen",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}
