import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/shared/icons/my_icons.dart';
import 'package:komfy/features/moodtracker/model/mood_session_model.dart';

class MoodInputScreen3 extends StatefulWidget {
  final MoodSession moodSession;
  final int currentStep;

  const MoodInputScreen3({
    super.key,
    required this.moodSession,
    required this.currentStep,
  });

  @override
  State<MoodInputScreen3> createState() => _MoodInputScreen3State();
}

class _MoodInputScreen3State extends State<MoodInputScreen3> {
  final List<String> feelings = [];
  final List<IconData> feelingIcons = [];

  final List<Map<String, dynamic>> reflectionOptions = [
    {'icon': MyIcons.senang, 'label': 'senang'},
    {'icon': MyIcons.bersyukur, 'label': 'bersyukur'},
    {'icon': MyIcons.biasaAja, 'label': 'biasa saja'},
    {'icon': MyIcons.bingung, 'label': 'bingung'},
    {'icon': MyIcons.membosankan, 'label': 'membosankan'},
    {'icon': MyIcons.canggung, 'label': 'canggung'},
    {'icon': MyIcons.marah, 'label': 'marah'},
    {'icon': MyIcons.cemas, 'label': 'cemas'},
    {'icon': MyIcons.sedih, 'label': 'sedih'},
    {'icon': MyIcons.kecewa, 'label': 'kecewa'},
    {'icon': MyIcons.kaget, 'label': 'kaget'},
    {'icon': MyIcons.malu, 'label': 'malu'},
  ];

  void toggleSelection(String label, IconData icon) {
    setState(() {
      if (feelings.contains(label)) {
        int index = feelings.indexOf(label);
        feelings.removeAt(index);
        feelingIcons.removeAt(index);
      } else {
        if (feelings.length < 5) {
          feelings.add(label);
          feelingIcons.add(icon);
        }
      }
    });
  }

  void nextStep() {
    final updatedSession = widget.moodSession;
    updatedSession.feelings = List.from(feelings);
    updatedSession.feelingIcons = List.from(feelingIcons);

    Navigator.pushNamed(
      context,
      '/mood_story',
      arguments: {
        'moodSession': updatedSession,
        'currentStep': widget.currentStep + 1,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 15),
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
                      Center(child: Text("Mood Tracker", style: AppTypography.title1)),
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
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${widget.currentStep}/4",
                                            style: AppTypography.subtitle3,
                                          ),
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
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Gimana perasaan kamu tentang hal itu?',
                                          style: AppTypography.subtitle3,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Kamu dapat memilih hingga 5 pilihan',
                                          style: AppTypography.bodyText3.copyWith(color: Colors.black.withAlpha(102)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = (constraints.maxWidth / 100).floor();
                                      crossAxisCount = crossAxisCount.clamp(2, 4);

                                      return GridView.count(
                                        crossAxisCount: crossAxisCount,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        childAspectRatio: 1.0,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                        children: reflectionOptions.map((item) {
                                          final isSelected = feelings.contains(item['label']);
                                          return GestureDetector(
                                            onTap: () => toggleSelection(item['label'], item['icon']),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: isSelected ? const Color(0xFF6F96D1) : Colors.transparent,
                                                border: Border.all(color: const Color(0xFF0B1956)),
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(item['icon'], size: 30, color: const Color(0xFF0B1956)),
                                                  const SizedBox(height: 4),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          left: 20,
                          right: 20,
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
                              if (feelings.isNotEmpty)
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
            );
          },
        ),
      ),
    );
  }
}
