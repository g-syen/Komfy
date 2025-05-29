import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:komfy/themes/typography.dart';

class MoodRecapScreen extends StatefulWidget {
  const MoodRecapScreen({super.key});

  @override
  State<MoodRecapScreen> createState() => _MoodRecapScreenState();
}

class _MoodRecapScreenState extends State<MoodRecapScreen> {
  int selectedDays = 7;

  // Dummy mood data (isi 2 atau 3 data untuk tes blur)
  final List<FlSpot> moodSpots = [
    FlSpot(1, 2),
    FlSpot(2, 3),
    FlSpot(3, 1),
    FlSpot(4, 5),
    FlSpot(5, 3),
  ];

  final List<Map<String, dynamic>> moodHistory = [
    {
      "emoji": "😐",
      "label": "Netral",
      "title": "Judul Mood Tracker",
      "date": "19 April 2025",
      "time": "12.09 WIB",
    },
    {
      "emoji": "😐",
      "label": "Netral",
      "title": "Judul Mood Tracker",
      "date": "22 April 2025",
      "time": "06.34 WIB",
    },
  ];

  bool get hasMinimumMoodEntries => moodSpots.length >= 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "Komfess",
                    style: AppTypography.title1.copyWith(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Mood Legendary!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildChart(),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/mood_input');
                    },
                    child: const Text(
                      "Apa yang kamu rasakan saat ini?",
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Divider(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Perasaanku belakangan ini",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...moodHistory.map(_buildMoodCard).toList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildChart() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1E5B),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: hasMinimumMoodEntries
              ? SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      backgroundColor: const Color(0xFF0B1E5B),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const emojis = ['🥲', '😟', '😐', '🙂', '🥰'];
                              if (value >= 1 && value <= 5) {
                                return Text(emojis[value.toInt() - 1]);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) =>
                                Text(value.toInt().toString()),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: false,
                          color: Colors.white,
                          dotData: FlDotData(show: true),
                          spots: moodSpots,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      Container(color: const Color(0xFF0B1E5B)),
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.black.withAlpha((0.3 * 255).toInt()),
                              child: const Text(
                                "Isi Mood Tracker minimal 3 hari untuk menampilkan chart!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (hasMinimumMoodEntries)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 7, 30].map((e) {
                final isSelected = selectedDays == e;
                return GestureDetector(
                  onTap: () => setState(() => selectedDays = e),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      '$e',
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> mood) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigasi ke detail mood
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(mood["emoji"], style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(mood["label"]),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                mood["title"],
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mood["date"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(mood["time"]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
