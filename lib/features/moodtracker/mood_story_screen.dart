import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komfy/features/moodtracker/model/mood_session_model.dart';
import 'package:komfy/features/moodtracker/model/mood_entry_model.dart';
import 'package:komfy/themes/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
      builder: (context) => AlertDialog(
        title: Text('Masukkan Judul Mood Tracker', style: AppTypography.subtitle2),
        content: TextField(
          controller: _titleController,
          decoration: InputDecoration(hintText: 'Contoh: Hari yang melelahkan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _saveMoodToFirebase();      
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }


  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: RichText(
          text: TextSpan(
            style: AppTypography.subtitle2.copyWith(color: Colors.black),
            children: [
              TextSpan(text: 'Simpan '),
              TextSpan(
                text: 'Mood Tracker',
                style: AppTypography.subtitle2.copyWith(
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
            child: Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _showTitleInputDialog();     
            },
            child: Text('Simpan'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data mood belum lengkap.')),
        );
      }
      if (mounted) setState(() => isSaving = false);
      return;
    }

    final moodEntry = MoodEntry(
      timestamp: DateTime.now(),
      moodType: widget.moodSession.moodType!,
      selectedMoodLabel: widget.moodSession.selectedMoodLabel!,
      reasonIcons: widget.moodSession.reasonIcons,
      reasons: widget.moodSession.reasons,
      feelingIconCodes: widget.moodSession.feelingIcons.map((e) => e.codePoint).toList(),
      feelings: widget.moodSession.feelings,
      story: widget.moodSession.story ?? '', // bisa null
      title: _titleController.text.trim(),
    );

    try {
      await FirebaseFirestore.instance.collection('mood_entries').add(moodEntry.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mood berhasil disimpan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget buildTagBox(String text, {String? svgIconPath, IconData? icon}) {
    return Container(
      margin: EdgeInsets.only(right: 5, bottom: 5),
      width: 90, 
      height: 90,  
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgIconPath != null)
          SvgPicture.asset(
            svgIconPath,
            height: 20,
            width: 20,
          ),
          if (icon != null)
            Icon(
              icon,
              size: 20,
              color: Color(0xFF0B1956),
            ),
          if (svgIconPath != null || icon != null)
            SizedBox(width: 5),
          Text(
            text,
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subtitle4.copyWith(color: Color(0xFF0B1956)),
          ),
        ],
      ),
    );
  }

  Widget buildMoodEmoji() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.moodSession.moodType ?? '', style: TextStyle(fontSize: 32)),
          SizedBox(height: 10),
          Text(
            widget.moodSession.selectedMoodLabel ?? '',
            style: AppTypography.bodyText3.copyWith(color: Color(0xFF142553)),
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
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                        SizedBox(width: 4),
                        Text("Kembali", style: AppTypography.subtitle3),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  Center(child: Text("Mood Tracker", style: AppTypography.title1)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("${widget.currentStep}/4", style: AppTypography.subtitle3),
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: widget.currentStep / 4,
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3E78)),
                                minHeight: 6,
                              ),
                            ),
                            SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                dateFormatted,
                                style: AppTypography.subtitle2.copyWith(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: localeInitialized
                              ? SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Mood :", style: AppTypography.subtitle2.copyWith(color: Colors.black)),
                                      SizedBox(height: 8),
                                      buildMoodEmoji(),
                                      SizedBox(height: 20),

                                      Text(
                                        "Hal yang membuat kamu merasa ${widget.moodSession.selectedMoodLabel?.toLowerCase()} :",
                                        style: AppTypography.subtitle3.copyWith(color: Colors.black),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        children: List.generate(
                                          widget.moodSession.reasons.length,
                                          (index) => buildTagBox(
                                            widget.moodSession.reasons[index],
                                            svgIconPath: index < widget.moodSession.reasonIcons.length
                                                ? widget.moodSession.reasonIcons[index]
                                                : null,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      Text(
                                        "Perasaanmu terhadap hal tersebut :",
                                        style: AppTypography.subtitle3.copyWith(color: Colors.black),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        children: List.generate(
                                          widget.moodSession.feelings.length,
                                          (index) => buildTagBox(
                                            widget.moodSession.feelings[index],
                                            icon: (index < widget.moodSession.feelingIcons.length)
                                                ? widget.moodSession.feelingIcons[index]
                                                : null,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      Text(
                                        "Yuk cerita di sini!",
                                        style: AppTypography.subtitle3.copyWith(color: Colors.black),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF4F9FF),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: TextField(
                                          controller: _storyController,
                                          maxLines: 6,
                                          decoration: InputDecoration(
                                            hintText: 'Tuliskan cerita atau pengalamanmu hari ini...',
                                            hintStyle: AppTypography.bodyText3.copyWith(color: Color(0xFF8F8E8E)),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(16),
                                          ),
                                          style: AppTypography.bodyText2.copyWith(color: Color(0xFF0B1956)),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3E78)),
                                  ),
                                ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Sebelumnya',
                                style: AppTypography.subtitle4.copyWith(color: Color(0xFF0B1956)),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isSaving ? null : _showConfirmationDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: isSaving
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Menyimpan...', style: AppTypography.subtitle4.copyWith(color: Colors.white)),
                                      ],
                                    )
                                  : Text('Simpan', style: AppTypography.subtitle4.copyWith(color: Color(0xFF284082))),
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

