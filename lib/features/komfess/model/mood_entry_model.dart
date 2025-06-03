import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final DateTime timestamp;
  final String moodType;
  final String selectedMoodLabel;
  final List<String> reasonIcons;
  final List<String> reasons;
  final List<int> feelingIconCodes;
  final List<String> feelings;
  final String? story;
  final String title;
  final String? userId;

  MoodEntry({
    required this.timestamp,
    required this.moodType,
    required this.selectedMoodLabel,
    required this.reasonIcons,
    required this.reasons,
    required this.feelingIconCodes,
    required this.feelings,
    this.story,
    required this.title,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'moodType': moodType,
      'selectedMoodLabel': selectedMoodLabel,
      'reasonIcons': reasonIcons,
      'reasons': reasons,
      'feelingIconCodes': feelingIconCodes,
      'feelings': feelings,
      'story': story,
      'timestamp': Timestamp.fromDate(timestamp),
      'title': title,
      'userId': userId,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      moodType: map['moodType'],
      selectedMoodLabel: map['selectedMoodLabel'],
      reasonIcons: List<String>.from(map['reasonIcons']),
      reasons: List<String>.from(map['reasons']),
      feelingIconCodes: List<int>.from(map['feelingIconCodes']),
      feelings: List<String>.from(map['feelings']),
      story: map['story'],
      title: map['title'],
      userId: map['userId'],
    );
  }

}