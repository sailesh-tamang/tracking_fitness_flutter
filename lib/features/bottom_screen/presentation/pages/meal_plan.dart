import 'package:flutter/material.dart';

class MealPlan extends StatelessWidget {
  const MealPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.yellow),
        title: const Text(
          "Meal Plan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // -------- TEXT SECTION --------
            const Text(
              "Physical Fitness Is A State Of Health And Well-Being That Gives You "
                  "The Ability To Perform Daily Activities, Work, And Leisure With "
                  "Vigor And Efficiency, Without Experiencing Undue Fatigue, And "
                  "With Enough Energy To Handle Unexpected Demands.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            // -------- BUTTONS SECTION --------
            _buildButton("Suggestion For Body"),
            const SizedBox(height: 15),
            _buildButton("Weight Loss"),
            const SizedBox(height: 15),
            _buildButton("Weight Gain"),
          ],
        ),
      ),
    );
  }

  // Reusable Elevated Button
  static Widget _buildButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // TODO: Add navigation logic
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
