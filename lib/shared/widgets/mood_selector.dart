import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/shared/constants/mood_data.dart';

class MoodSelector extends StatelessWidget {
  final double screenWidth;
  final int selectedMoodIndex;
  final Function(int) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.screenWidth,
    required this.selectedMoodIndex,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final double cardSize = screenWidth * 0.15;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(moodEmojis.length, (index) {
          final isSelected = selectedMoodIndex == index;
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                onMoodSelected(-1);
              } else {
                onMoodSelected(index);
              }
            },
            child: Container(
              width: cardSize,
              height: cardSize + 6,
              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5885FF)
                    : const Color(0xFF091F5B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(moodEmojis[index], style: const TextStyle(fontSize: 24)),
                  Text(
                    moodLabels[index],
                    style: AppTypography.bodyText4.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}