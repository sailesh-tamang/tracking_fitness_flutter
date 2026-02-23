import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MealPlan extends StatefulWidget {
  const MealPlan({super.key});

  @override
  State<MealPlan> createState() => _MealPlanState();
}

class _MealPlanState extends State<MealPlan> {
  YoutubePlayerController? _youtubeController;

  final List<Map<String, String>> mealPlans = const [
    {
      'title': 'Weight Loss',
      'description': 'High protein, lower sugar, and portion control',
      'videoId': 'LCyECbA3pUw',
    },
    {
      'title': 'Maintenance',
      'description': 'Balanced calories with whole foods',
      'videoId': '81G22t2UHxA',
    },
    {
      'title': 'Muscle Gain',
      'description': 'Calorie surplus with protein each meal',
      'videoId': '6y-R3dNx4vA',
    },
  ];

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _showVideoPlayer(String videoId, String title) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _youtubeController?.dispose();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (_youtubeController != null)
              YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: const Color(0xFF9CFF00),
              ),
          ],
        ),
      ),
    );
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- TAGS SECTION --------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _TagChip("NUTRITION"),
                    SizedBox(width: 10),
                    _TagChip("BALANCE"),
                    SizedBox(width: 10),
                    _TagChip("HYDRATION"),
                    SizedBox(width: 10),
                    _TagChip("RECOVERY"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------- TEXT SECTION --------
              const Text(
                "Build a plan that fuels your day: steady energy, clean ingredients, and consistent habits that support your fitness goal.",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // -------- MEAL PLAN CARDS --------
              ...mealPlans.map((plan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildMealCard(
                    title: plan['title']!,
                    description: plan['description']!,
                    videoId: plan['videoId']!,
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Build meal plan card
  Widget _buildMealCard({
    required String title,
    required String description,
    required String videoId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              _showVideoPlayer(videoId, title);
            },
            child: Row(
              children: const [
                Icon(Icons.play_arrow, color: Color(0xFF9CFF00), size: 16),
                SizedBox(width: 6),
                Text(
                  'Watch Video',
                  style: TextStyle(
                    color: Color(0xFF9CFF00),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tag/Chip widget for categories
class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
