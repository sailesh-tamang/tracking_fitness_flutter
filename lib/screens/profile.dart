import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is my Profile Screen",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}
