import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,//this is the background color to main
      appBar: AppBar(title: Center(child: Text("profile", style: TextStyle(color: Colors.white),)),backgroundColor: Colors.black,
      ),
    );
  }
}
