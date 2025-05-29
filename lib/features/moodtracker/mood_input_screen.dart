import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/shared/constants/mood_data.dart';
import 'package:komfy/shared/widgets/mood_selector.dart';
import 'package:komfy/features/moodtracker/model/mood_session_model.dart';

class MoodInputScreen extends StatefulWidget {
  const MoodInputScreen({super.key});

  @override
  State<MoodInputScreen> createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends State<MoodInputScreen> {
  MoodSession moodSession = MoodSession();
  int currentStep = 1;
  int selectedMoodIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0) {
      setState(() {
        selectedMoodIndex = args;
        moodSession.moodType = moodEmojis[selectedMoodIndex];
        moodSession.selectedMoodLabel = moodLabels[selectedMoodIndex];
      });
    }
  }

  void nextStep() {
    if (selectedMoodIndex != -1) {
      moodSession.moodType = moodEmojis[selectedMoodIndex];
      moodSession.selectedMoodLabel = moodLabels[selectedMoodIndex];
      
      Navigator.pushNamed(
        context,
        '/mood_input2',
        arguments: {
          'moodSession': moodSession,
          'currentStep': currentStep + 1,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
                decoration: BoxDecoration(
                  color: Color(0xFFD5E6FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 100),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenHeight * 0.01),
                                child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "$currentStep/4",
                                      style: AppTypography.subtitle3,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: currentStep / 4,
                                      backgroundColor: Colors.white,
                                      valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Color(0xFF1A3E78)),
                                          minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Gimana perasaan kamu saat ini?',
                                style: AppTypography.subtitle3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 5),
                            MoodSelector(
                              screenWidth: screenWidth,
                              selectedMoodIndex: selectedMoodIndex,
                              onMoodSelected: (index) {
                                setState(() {
                                  selectedMoodIndex = index;
                                  if (index >= 0) {
                                    moodSession.moodType = moodEmojis[index];
                                    moodSession.selectedMoodLabel = moodLabels[index];
                                  } else {
                                    moodSession.moodType = null;
                                    moodSession.selectedMoodLabel = null;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedMoodIndex != -1)
                      Positioned(
                        bottom: 32,
                        right: 20,
                        child: ElevatedButton(
                          onPressed: nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF284082),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                          ),
                          child: Text("Selanjutnya",
                            style: AppTypography.subtitle4.copyWith(color: Colors.white)),
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