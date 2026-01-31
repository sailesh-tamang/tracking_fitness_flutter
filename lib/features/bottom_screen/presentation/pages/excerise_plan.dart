import 'package:flutter/material.dart';

class ExcerisePlan extends StatelessWidget {
  const ExcerisePlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row (back + centered title like your image)
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.yellow),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Exercise",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40), // keeps title centered
                          ],
                        ),

                        const SizedBox(height: 70),

                        // Header (top)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              "Excerise Tips",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Middle text (stays in top/middle)
                        const Text(
                          "Fitness Goal ,Strength, TrainingCardio",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          "According To This  You Can Do Your Workout By Knowing Your Goal And What Else You Can Do",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),

                        // This pushes the tips section to the bottom of the screen
                        const SizedBox(height: 70), 

                        // Bottom tips section
                        _infoLine(
                          label: "General Health:",
                          value: " 2 Days/Week 150 Mins Moderate Activity",
                        ),

                        const SizedBox(height: 24),

                        _infoLine(
                          label: "Weight Loss:",
                          value: " 3 Days/Week Mix Of HIIT & Steady State",
                        ),

                        const SizedBox(height: 24),

                        _infoLine(
                          label: "Muscle Gain:",
                          value: " 4–5 Days/Week Light Activity (Walking)",
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _infoLine({required String label, required String value}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.25),
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
