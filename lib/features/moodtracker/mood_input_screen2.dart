import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/features/moodtracker/model/mood_session_model.dart';

class MoodInputScreen2 extends StatefulWidget {
  final MoodSession moodSession;
  final int currentStep;

  const MoodInputScreen2({
    super.key,
    required this.moodSession,
    required this.currentStep,
  });

  @override
  State<MoodInputScreen2> createState() => _MoodInputScreen2State();
}

class _MoodInputScreen2State extends State<MoodInputScreen2> {
  final List<String> reasons = [];
  final List<String> reasonIcons = [];

  final List<Map<String, dynamic>> moodFactors = [
    {'icon': 'assets/icons/users_three.svg', 'label': 'keluarga'},
    {'icon': 'assets/icons/building.svg', 'label': 'pekerjaan'},
    {'icon': 'assets/icons/graduation_cap.svg', 'label': 'kuliah'},
    {'icon': 'assets/icons/friends.svg', 'label': 'teman'},
    {'icon': 'assets/icons/playing_cards.svg', 'label': 'hubungan'},
    {'icon': 'assets/icons/ship.svg', 'label': 'perjalanan'},
    {'icon': 'assets/icons/pizza_slice.svg', 'label': 'makanan'},
    {'icon': 'assets/icons/gym.svg', 'label': 'aktivitas fisik'},
    {'icon': 'assets/icons/confetti.svg', 'label': 'kesehatan'},
    {'icon': 'assets/icons/headset.svg', 'label': 'musik'},
    {'icon': 'assets/icons/film.svg', 'label': 'film/series'},
    {'icon': 'assets/icons/sunrise.svg', 'label': 'cuaca'},
    {'icon': 'assets/icons/paw.svg', 'label': 'hewan peliharaan'},
    {'icon': 'assets/icons/bowling.svg', 'label': 'hobi'},
    {'icon': 'assets/icons/terrace.svg', 'label': 'lingkungan'},
  ];

  void toggleSelection(String label, String icon) {
    setState(() {
      if (reasons.contains(label)) {
        int index = reasons.indexOf(label);
        reasons.removeAt(index);
        reasonIcons.removeAt(index);
      } else {
        if (reasons.length < 5) {
          reasons.add(label);
          reasonIcons.add(icon);
        }
      }
    });
  }

  void nextStep() {
    final updatedSession = widget.moodSession;
    updatedSession.reasons = List.from(reasons);
    updatedSession.reasonIcons = List.from(reasonIcons);

    Navigator.pushNamed(
      context,
      '/mood_input3',
      arguments: {
        'moodSession': updatedSession,
        'currentStep': widget.currentStep + 1,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isTablet = screenWidth > 600;

    final iconSize = screenWidth * 0.08;
    final paddingHorizontal = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                paddingHorizontal,
                screenHeight * 0.03,
                paddingHorizontal,
                screenHeight * 0.015,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: iconSize),
                        const SizedBox(width: 4),
                        Text("Kembali", style: AppTypography.subtitle3),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: Text("Mood Tracker", style: AppTypography.title1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD5E6FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: paddingHorizontal,
                          vertical: screenHeight * 0.015,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.015,
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("${widget.currentStep}/4", style: AppTypography.subtitle3),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: widget.currentStep / 4,
                                      backgroundColor: Colors.white,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A3E78)),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Apa yang membuat kamu merasa ${widget.moodSession.selectedMoodLabel?.toLowerCase()}?',
                                style: AppTypography.subtitle3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Kamu dapat memilih hingga 5 pilihan',
                                style: AppTypography.bodyText3.copyWith(
                                  color: Colors.black.withAlpha(102),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount = isTablet ? 5 : 3;
                                  return GridView.count(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 1,
                                    physics: const BouncingScrollPhysics(),
                                    children: moodFactors.map((item) {
                                      final isSelected = reasons.contains(item['label']);
                                      return GestureDetector(
                                        onTap: () => toggleSelection(item['label'], item['icon']),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: isSelected
                                                ? const Color(0xFF6F96D1)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: const Color(0xFF0B1956),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(3),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                item['icon'],
                                                height: iconSize,
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                item['label'],
                                                textAlign: TextAlign.center,
                                                style: AppTypography.subtitle4.copyWith(color: const Color(0xFF0B1956)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 32,
                      left: paddingHorizontal,
                      right: paddingHorizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sebelumnya',
                              style: AppTypography.subtitle4.copyWith(color: const Color(0xFF0B1956)),
                            ),
                          ),
                          if (reasons.isNotEmpty)
                            ElevatedButton(
                              onPressed: nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF284082),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Selanjutnya',
                                style: AppTypography.subtitle4.copyWith(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
