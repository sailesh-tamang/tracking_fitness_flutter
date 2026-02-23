import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExcerisePlan extends StatefulWidget {
  const ExcerisePlan({super.key});

  @override
  State<ExcerisePlan> createState() => _ExcerisePlanState();
}

class _ExcerisePlanState extends State<ExcerisePlan> {
  YoutubePlayerController? _youtubeController;

  final List<Map<String, String>> exerciseTips = const [
    {
      'title': 'General Health',
      'description': '2 days/week, 150 mins moderate activity',
      'videoId': '8ef7FhmMcLU',
    },
    {
      'title': 'Weight Loss',
      'description': '3 days/week, mix of HIIT & steady state',
      'videoId': 'Ammb_7sv_KA',
    },
    {
      'title': 'Muscle Gain',
      'description': '4–5 days/week, light activity (walking)',
      'videoId': 'UIPvIYsjfpo',
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

                        const SizedBox(height: 30),

                        // Tags Section
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: const [
                              _TagChip("FITNESS GOAL"),
                              SizedBox(width: 10),
                              _TagChip("STRENGTH"),
                              SizedBox(width: 10),
                              _TagChip("TRAINING"),
                              SizedBox(width: 10),
                              _TagChip("CARDIO"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Middle text (stays in top/middle)
                        const Text(
                          "According to this, you can plan your workout by knowing your goal and what else you can do.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),

                        // This pushes the tips section to the bottom of the screen
                        const SizedBox(height: 50), 

                        // Bottom tips section
                        ...exerciseTips.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 22.0),
                            child: _buildTipCard(
                              title: tip['title']!,
                              description: tip['description']!,
                              videoId: tip['videoId']!,
                            ),
                          );
                        }).toList(),

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

  Widget _buildTipCard({
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
