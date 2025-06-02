import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';

class MoodRecapScreen extends StatelessWidget {
  const MoodRecapScreen({super.key});

  int _getMoodScore(String? selectedMoodLabel) {
    switch (selectedMoodLabel) {
      case 'Sangat Buruk':
        return 1;
      case 'Buruk':
        return 2;
      case 'Netral':
        return 3;
      case 'Baik':
        return 4;
      case 'Sangat Baik':
        return 5;
      default:
        return 0;
    }
  }

  void _deleteMoodEntry(BuildContext context, String docId) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Mood'),
      content: const Text('Apakah kamu yakin ingin menghapus mood ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    await FirebaseFirestore.instance.collection('mood_entries').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood berhasil dihapus')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Kamu belum login')),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mood_entries')
              .where('userId', isEqualTo: user.uid)
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('Firestore error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            final hasData = docs.isNotEmpty;

            List<Map<String, dynamic>> moodData = [];
            if (hasData) {
              moodData = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final label = data['selectedMoodLabel'] ?? '';
                return {
                  'docId': doc.id,
                  'moodScore': _getMoodScore(label),
                  'selectedMoodLabel': label,
                  'moodType': data['moodType'] ?? '',
                  'title': data['title'] ?? '',
                  'timestamp': data['timestamp'] is Timestamp
                      ? (data['timestamp'] as Timestamp).toDate()
                      : DateTime.now(),
                };
              }).toList();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        'Komfess',
                        style: AppTypography.title1.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  
                  // Mood Legendary Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkBlue,
                          AppColors.darkBlue2,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood Legendary',
                          style: AppTypography.subtitle3.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Perubahan Mood seiring waktu',
                          style: AppTypography.bodyText1.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        
                        // Chart or No Data Message
                        SizedBox(
                          height: 150,
                          child: hasData
                            ? LineChart(
                                LineChartData(
                                  backgroundColor: Colors.transparent,
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index >= 0 && index < moodData.length) {
                                            final date = moodData[index]['timestamp'] as DateTime;
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                DateFormat('dd').format(date),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFFB0B0B0),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 48,
                                        getTitlesWidget: (value, meta) {
                                          Widget moodIcon;
                                          switch (value.toInt()) {
                                            case 1:
                                              moodIcon = const Text('😓', style: TextStyle(fontSize: 16));
                                              break;
                                            case 2:
                                              moodIcon = const Text('🙁', style: TextStyle(fontSize: 16));
                                              break;
                                            case 3:
                                              moodIcon = const Text('😐', style: TextStyle(fontSize: 16));
                                              break;
                                            case 4:
                                              moodIcon = const Text('🙂', style: TextStyle(fontSize: 16));
                                              break;
                                            case 5:
                                              moodIcon = const Text('😊', style: TextStyle(fontSize: 16));
                                              break;
                                            default:
                                              return const SizedBox();
                                          }
                                          return SizedBox(width: 32, height: 32, child: Center(child: moodIcon));
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: true),
                                  minY: 0,
                                  maxY: 5,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(moodData.length, (i) {
                                        return FlSpot(i.toDouble(), moodData[i]['moodScore'].toDouble());
                                      }),
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      barWidth: 3,
                                      color: Colors.white,
                                      belowBarData: BarAreaData(show: true),
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: AppColors.blue2,
                                            strokeColor: Colors.white,
                                            strokeWidth: 2,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Kamu belum mengisi mood',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Button to Mood Input
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        side: BorderSide(color: AppColors.blue2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/mood_input');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Apa yang sedang kamu rasakan? ',
                          style: AppTypography.bodyText3.copyWith(
                            color: AppColors.blue2, fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Isi MoodTracker, yuk!',
                              style: AppTypography.bodyText3.copyWith(
                                color: AppColors.blue2,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Section Title
                  Text(
                    'Perasaanku belakangan ini',
                    style: AppTypography.subtitle3.copyWith(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Mood List or No Data Message
                  Expanded(
                    child: hasData
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 55),
                          child: Column(
                            children: List.generate(moodData.length, (index) {
                              final selectedMoodLabel = moodData[index]['selectedMoodLabel'];
                              final moodType = moodData[index]['moodType'];
                              final title = moodData[index]['title'];
                              final timestamp = moodData[index]['timestamp'] as DateTime;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/mood_detail',
                                    arguments: moodData[index]['docId'],
                                  );
                                },
                                child: Card(
                                  elevation: 2,
                                  color: const Color(0xFFF4F9FF),
                                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: const Color(0xFF6F8BBD)),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    moodType,
                                                    style: const TextStyle(fontSize: 28),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    selectedMoodLabel,
                                                    style: AppTypography.subtitle3.copyWith(
                                                      color: const Color(0xFF142553),
                                                      fontSize: 18,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: AppTypography.subtitle3.copyWith(
                                                    color: const Color(0xFF142553),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  DateFormat('dd MMM yyyy').format(timestamp),
                                                  style: AppTypography.subtitle4.copyWith(color: const Color(0xFF838383)),
                                                ),
                                                Text(
                                                  DateFormat('HH:mm').format(timestamp),
                                                  style: AppTypography.subtitle4.copyWith(color: const Color(0xFF838383)),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                                    tooltip: 'Hapus mood',
                                                    constraints: const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () => _deleteMoodEntry(context, moodData[index]['docId']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              );
                            }),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Kamu belum mengisi mood',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}