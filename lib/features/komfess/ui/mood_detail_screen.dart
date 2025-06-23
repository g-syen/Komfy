import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komfy/themes/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komfy/themes/colors.dart';

import '../../../shared/services/encryption_services.dart';

class MoodDetailScreen extends StatefulWidget {
  final String documentId;

  const MoodDetailScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<MoodDetailScreen> createState() => _MoodDetailScreenState();
}

class _MoodDetailScreenState extends State<MoodDetailScreen> {
  bool localeInitialized = false;
  String dateFormatted = '';
  Map<String, dynamic>? moodData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeLocale();
    _loadMoodData();
  }

  Future<void> initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      localeInitialized = true;
    });
  }

  Future<void> _loadMoodData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mood_entries')
          .doc(widget.documentId)
          .get();

      if (doc.exists) {
        // 1. Get the raw, ENCRYPTED data from Firestore.
        final encryptedData = doc.data()!;

        // 2. Call your helper function and AWAIT the result of the decryption.
        //    This is the new, crucial step.
        final decryptedData = await decryptFirestoreDocument(encryptedData);

        // 3. Extract the timestamp from the DECRYPTED data.
        final timestamp = decryptedData['timestamp'] is Timestamp
            ? (decryptedData['timestamp'] as Timestamp).toDate()
            : DateTime.now();

        // Check if decryption failed by looking for the error flag
        if (decryptedData['decryptionError'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal memproses data mood.')),
            );
            Navigator.pop(context);
          }
          return;
        }

        // 4. Update the state with the DECRYPTED data.
        setState(() {
          moodData = decryptedData; // Use the decrypted data here
          dateFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(timestamp);
          isLoading = false;
        });
      } else {
        // This part remains the same.
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data mood tidak ditemukan.')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // This part remains the same.
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<Map<String, dynamic>> decryptFirestoreDocument(Map<String, dynamic> encryptedData) async {
    try {
      // Decrypt simple strings
      // We can run these in parallel
      final moodTypeFuture = rsaDecryptSingleBlock(encryptedData['moodType']);
      final selectedMoodLabelFuture = rsaDecryptSingleBlock(encryptedData['selectedMoodLabel']);
      final storyFuture = rsaDecryptSingleBlock(encryptedData['story']);
      final titleFuture = rsaDecryptSingleBlock(encryptedData['title']);

      // Decrypt list-based strings
      final reasonIconsStrFuture = rsaDecryptSingleBlock(encryptedData['reasonIcons']);
      final reasonsStrFuture = rsaDecryptSingleBlock(encryptedData['reasons']);
      final feelingIconCodesStrFuture = rsaDecryptSingleBlock(encryptedData['feelingIconCodes']);
      final feelingsStrFuture = rsaDecryptSingleBlock(encryptedData['feelings']);

      // Wait for all text decryptions to finish at the same time
      final results = await Future.wait([
        moodTypeFuture,
        selectedMoodLabelFuture,
        storyFuture,
        titleFuture,
        reasonIconsStrFuture,
        reasonsStrFuture,
        feelingIconCodesStrFuture,
        feelingsStrFuture
      ]);

      // Now that we have all the decrypted strings, we can decode the JSON synchronously.
      return {
        'docId' : encryptedData['docId'],
        'userId': encryptedData['userId'],
        'timestamp': encryptedData['timestamp'],
        'moodType': results[0],
        'selectedMoodLabel': results[1],
        'story': results[2],
        'title': results[3],
        'reasonIcons': List<String>.from(jsonDecode(results[4])),
        'reasons': List<String>.from(jsonDecode(results[5])),
        'feelingIconCodes': List<int>.from(jsonDecode(results[6])),
        'feelings': List<String>.from(jsonDecode(results[7])),
      };
    } catch (e) {
      debugPrint('DECRYPTION FAILED: $e');
      // Return a map with a consistent structure for error handling
      return {
        'docId' : encryptedData['docId'],
        'userId': encryptedData['userId'],
        'timestamp': encryptedData['timestamp'],
        'title': encryptedData['title'],
        'story': encryptedData['story'],
        'moodType': encryptedData['moodType'],
        'selectedMoodLabel': encryptedData['selectedMoodLabel'],
        'reasonIcons': encryptedData['reasonIcons'],
        'reasons': encryptedData['reasons'],
        'feelingIconCodes': encryptedData['feelingIconCodes'],
        'feelings': encryptedData['feelings'],
        'decryptionError': true,
      };
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
          if (svgIconPath != null || icon != null)
          const SizedBox(height: 5),
          Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.subtitle4.copyWith(color: AppColors.darkBlue),
          ),
        ),
        ],
      ),
    );
  }

  Widget buildMoodEmoji() {
    if (moodData == null) return const SizedBox();

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
            moodData!['moodType'] ?? '', style: const TextStyle(fontSize: 30)
          ),
          SizedBox(height: 5),
          Flexible(
            child: Text(
              moodData!['selectedMoodLabel'] ?? '',
              textAlign: TextAlign.center,
              softWrap: true,
              style: AppTypography.subtitle4.copyWith(color: AppColors.darkBlue),
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
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                        const SizedBox(width: 4),
                        Text("Kembali", style: AppTypography.subtitle3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Center(child: Text("Komfess", style: AppTypography.title1)),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD5E6FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3E78)),
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              children: [
                                if (moodData != null && moodData!['title'] != null && moodData!['title'].toString().isNotEmpty)
                                  Column(
                                    children: [
                                      Text(
                                        moodData!['title'],
                                        textAlign: TextAlign.center,
                                        style: AppTypography.title2.copyWith(color: Colors.black),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
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
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(25, 0, 25, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mood:", style: AppTypography.subtitle2.copyWith(color: Colors.black)),
                                  const SizedBox(height: 5),
                                  buildMoodEmoji(),
                                  const SizedBox(height: 15),
                                  if (moodData!['reasons'] != null && (moodData!['reasons'] as List).isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Hal yang membuat kamu merasa ${moodData!['selectedMoodLabel']?.toLowerCase()}:",
                                          style: AppTypography.subtitle3.copyWith(color: Colors.black),
                                        ),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          spacing: 5,
                                          runSpacing: 5,
                                          children: List.generate(
                                            (moodData!['reasons'] as List).length,
                                            (index) {
                                              final reasons = moodData!['reasons'] as List;
                                              final reasonIcons = moodData!['reasonIcons'] as List? ?? [];
                                              return buildTagBox(
                                                reasons[index],
                                                svgIconPath: index < reasonIcons.length ? reasonIcons[index] : null,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  if (moodData!['feelings'] != null && (moodData!['feelings'] as List).isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Perasaanmu terhadap hal tersebut:",
                                            style: AppTypography.subtitle3.copyWith(color: Colors.black)),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          spacing: 5,
                                          runSpacing: 5,
                                          children: List.generate(
                                            (moodData!['feelings'] as List).length,
                                            (index) {
                                              final feelings = moodData!['feelings'] as List;
                                              final feelingIconCodes = moodData!['feelingIconCodes'] as List? ?? [];
                                              return buildTagBox(
                                                feelings[index],
                                                icon: index < feelingIconCodes.length
                                                    ? IconData(feelingIconCodes[index], fontFamily: 'MyIcons')
                                                    : null,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  if (moodData!['story'] != null && moodData!['story'].toString().isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Ceritanya:", style: AppTypography.subtitle3.copyWith(color: Colors.black)),
                                        const SizedBox(height: 5),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F9FF),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: Colors.black),
                                          ),
                                          child: Text(
                                            moodData!['story'],
                                            style: AppTypography.bodyText2.copyWith(color: const Color(0xFF0B1956)),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
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