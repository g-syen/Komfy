import 'package:flutter/material.dart';

class MoodSession {
  String? moodType;               // Emoji atau jenis mood 
  String? selectedMoodLabel;     // Label mood seperti 
  List<String> reasonIcons = []; // emoji alasan
  List<String> reasons = [];     // Alasan (Step 2)
  List<IconData> feelingIcons = []; // emoji feelings
  List<String> feelings = [];  // Aktivitas (Step 3)
  String? story;                 // Cerita (Step 4)

  MoodSession({
    this.moodType,
    this.selectedMoodLabel,
    this.reasonIcons = const [],
    this.reasons = const [],
    this.feelingIcons = const [],
    this.feelings = const [],
    this.story,
  });

  bool get isComplete =>
      moodType != null &&
      selectedMoodLabel != null &&
      reasonIcons.isNotEmpty &&
      reasons.isNotEmpty &&
      feelingIcons.isNotEmpty &&
      feelings.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'moodType': moodType,
      'selectedMoodLabel': selectedMoodLabel,
      'reasonIcons': reasonIcons,
      'reasons': reasons,
      'feelingIcons': feelingIcons.map((icon) => icon.codePoint).toList(),
      'feelings': feelings,
      'story': story,
    };
  }
}