import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komfy/features/komfess/model/mood_session_model.dart';
import 'package:komfy/features/komfess/model/mood_entry_model.dart';
import 'package:komfy/themes/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komfy/themes/colors.dart';

class MoodStoryScreen extends StatefulWidget {
  final MoodSession moodSession;
  final int currentStep;

  const MoodStoryScreen({
    super.key,
    required this.moodSession,
    required this.currentStep,
  });

  @override
  State<MoodStoryScreen> createState() => _MoodStoryScreenState();
}

class _MoodStoryScreenState extends State<MoodStoryScreen> {
  final TextEditingController _storyController = TextEditingController();
  late TextEditingController _titleController;

  bool isSaving = false;
  bool localeInitialized = false;
  String dateFormatted = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    initializeLocale();
  }

  Future<void> initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    final now = DateTime.now();
    setState(() {
      localeInitialized = true;
      dateFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    });
  }

  @override
  void dispose() {
    _storyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showTitleInputDialog() {
    _titleController.clear();

    showDialog(
      context: context,
      builder:
          (context) =>
          AlertDialog(
            title: Text(
              'Masukkan Judul Mood Tracker',
              style: AppTypography.subtitle2,
            ),
            content: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Contoh: Hari yang melelahkan',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Batal',
                  style: AppTypography.subtitle4.copyWith(
                    color: AppColors.red,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveMoodToFirebase();
                },
                child: Text(
                  'Simpan',
                  style: AppTypography.subtitle4.copyWith(
                    color: AppColors.blue2,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
          AlertDialog(
            title: RichText(
              text: TextSpan(
                style: AppTypography.subtitle4.copyWith(color: Colors.black),
                children: [
                  TextSpan(text: 'Simpan '),
                  TextSpan(
                    text: 'Mood Tracker',
                    style: AppTypography.subtitle3.copyWith(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(text: ' hari ini?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Edit',
                  style: AppTypography.subtitle3.copyWith(
                    color: AppColors.red,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showTitleInputDialog();
                },
                child: Text(
                  'Simpan',
                  style: AppTypography.subtitle4.copyWith(
                    color: AppColors.blue2,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveMoodToFirebase() async {
    setState(() => isSaving = true);

    final storyText = _storyController.text.trim();
    if (storyText.isNotEmpty) {
      widget.moodSession.story = storyText;
    }

    if (!widget.moodSession.isComplete) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Data mood belum lengkap.')));
      }
      if (mounted) setState(() => isSaving = false);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User belum login.')));
        setState(() => isSaving = false);
      }
      return;
    }

    final userId = currentUser.uid;

    final moodEntry = MoodEntry(
      timestamp: DateTime.now(),
      moodType: widget.moodSession.moodType!,
      selectedMoodLabel: widget.moodSession.selectedMoodLabel!,
      reasonIcons: widget.moodSession.reasonIcons,
      reasons: widget.moodSession.reasons,
      feelingIconCodes:
      widget.moodSession.feelingIcons.map((e) => e.codePoint).toList(),
      feelings: widget.moodSession.feelings,
      story: widget.moodSession.story ?? '',
      title: _titleController.text.trim(),
      userId: userId,
    );

    final moodData = moodEntry.toMap()
      ..addAll({'userId': userId});

    try {
      await FirebaseFirestore.instance.collection('mood_entries').add(moodData);
      final docRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int moodTracker = data?['jumlahMoodTracker'] ?? 0;
        int journaling = data?['jumlahJournal'] ?? 0;
        if(moodData['story'] != '') {
          journaling = journaling + 1;
        }
        int hariPemakaian = data?['hariPemakaian'] ?? 0;
        Timestamp lastCheckedIn = data?['lastCheckedIn'] ?? Timestamp.now();
        DateTime checkIn = lastCheckedIn.toDate();
        String formattedDate = DateFormat('dd/MM/yyyy').format(checkIn);
        DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
        DateTime twoDaysAgo = DateTime.now().subtract(Duration(days: 2));
        String formattedNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
        String formattedYesterday = DateFormat('dd/MM/yyyy').format(yesterday);
        String formattedTwoDaysAgo = DateFormat('dd/MM/yyyy').format(twoDaysAgo);
        bool isYesterday = formattedDate == formattedYesterday;
        bool isTwoDaysAgo = formattedDate == formattedTwoDaysAgo;
        bool isToday = formattedDate == formattedNow;
        Map<String, dynamic> dataBaru = {};
        if(isYesterday || isTwoDaysAgo) {
          dataBaru = {
            'jumlahMoodTracker': moodTracker+1,
            'jumlahJournal': journaling,
            'hariPemakaian': hariPemakaian+1,
            'lastCheckedIn': Timestamp.now(),
          };
        } else if (isToday){
          dataBaru = {
            'jumlahMoodTracker': moodTracker+1,
            'jumlahJournal': journaling,
            'hariPemakaian': hariPemakaian,
            'lastCheckedIn': Timestamp.now(),
          };
        } else {
          dataBaru = {
            'jumlahMoodTracker': moodTracker++,
            'jumlahJournal': journaling,
            'hariPemakaian': 1,
            'lastCheckedIn': Timestamp.now(),
          };
        }
        docRef.update(dataBaru);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mood berhasil disimpan!')));
        Navigator.pushNamed(context, '/komfess');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget buildTagBox(String text, {String? svgIconPath, IconData? icon}) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (svgIconPath != null)
            SvgPicture.asset(svgIconPath, height: 30, width: 30),
          if (icon != null)
            Icon(icon, size: 30, color: const Color(0xFF0B1956)),
          if (svgIconPath != null || icon != null) const SizedBox(height: 5),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle4.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoodEmoji() {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.moodSession.moodType ?? '',
            style: const TextStyle(fontSize: 30),
          ),
          SizedBox(height: 5),
          Flexible(
            child: Text(
              widget.moodSession.selectedMoodLabel ?? '',
              textAlign: TextAlign.center,
              softWrap: true,
              style: AppTypography.subtitle4.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
                bottom: 15,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4),
                        Text("Kembali", style: AppTypography.subtitle3),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
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
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${widget.currentStep}/4",
                                style: AppTypography.subtitle3,
                              ),
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: widget.currentStep / 4,
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1A3E78),
                                ),
                                minHeight: 6,
                              ),
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                dateFormatted,
                                style: AppTypography.subtitle2.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child:
                          localeInitialized
                              ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mood :",
                                  style: AppTypography.subtitle2
                                      .copyWith(color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                buildMoodEmoji(),
                                SizedBox(height: 15),
                                Text(
                                  "Hal yang membuat kamu merasa ${widget
                                      .moodSession.selectedMoodLabel
                                      ?.toLowerCase()} :",
                                  style: AppTypography.subtitle3
                                      .copyWith(color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: List.generate(
                                    widget.moodSession.reasons.length,
                                        (index) =>
                                        buildTagBox(
                                          widget.moodSession.reasons[index],
                                          svgIconPath:
                                          index <
                                              widget
                                                  .moodSession
                                                  .reasonIcons
                                                  .length
                                              ? widget
                                              .moodSession
                                              .reasonIcons[index]
                                              : null,
                                        ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  "Perasaanmu terhadap hal tersebut :",
                                  style: AppTypography.subtitle3
                                      .copyWith(color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: List.generate(
                                    widget.moodSession.feelings.length,
                                        (index) =>
                                        buildTagBox(
                                          widget
                                              .moodSession
                                              .feelings[index],
                                          icon:
                                          (index <
                                              widget
                                                  .moodSession
                                                  .feelingIcons
                                                  .length)
                                              ? widget
                                              .moodSession
                                              .feelingIcons[index]
                                              : null,
                                        ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  "Yuk cerita di sini!",
                                  style: AppTypography.subtitle3
                                      .copyWith(color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF4F9FF),
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _storyController,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      hintText:
                                      'Tuliskan cerita atau pengalamanmu hari ini...',
                                      hintStyle: AppTypography.bodyText3
                                          .copyWith(
                                        color: Color(0xFF8F8E8E),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(
                                        16,
                                      ),
                                    ),
                                    style: AppTypography.bodyText2
                                        .copyWith(
                                      color: Color(0xFF0B1956),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          )
                              : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1A3E78),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 32,
                        ),
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
                                style: AppTypography.subtitle4.copyWith(
                                  color: Color(0xFF0B1956),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                              isSaving ? null : _showConfirmationDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.blue2,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child:
                              isSaving
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Menyimpan...',
                                    style: AppTypography.subtitle4
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              )
                                  : Text(
                                'Simpan',
                                style: AppTypography.subtitle4.copyWith(
                                  color: Color(0xFF284082),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
