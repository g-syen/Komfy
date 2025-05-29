import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:komfy/themes/typography.dart';

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final List<String> chatImages = [
    'assets/icons/memoji_kommate.png',
    'assets/icons/memoji_mt.png',
    'assets/icons/memoji_komynfo.png',
    'assets/icons/memoji_komfybadge.png',
  ];

  final List<String> curhatTexts = [
    'Bagaimana kabarmu hari ini?\n',
    'Apa yang sekarang kamu rasakan?\n',
    'Banyak hal-hal menarik soal mental health\n',
    'Kamu bisa naik level dengan rutin pakai Komfy dan isi MoodTracker, lho!\n',
  ];

  final List<String> curhatTexts2 = [
    'Ada yang ingin kamu ceritakan?\nYuk cerita di ',
    'Track Mood kamu di ',
    'Bisa kamu temukan di ',
    'Cek level kamu di ',
  ];

  int currentIndex = 0;

  String _getFeatureName(int index) {
    switch (index) {
      case 0:
        return "Kommate";
      case 1:
        return "Mood Tracker";
      case 2:
        return "Komynfo";
      case 3:
        return "Komfy Badge";
      default:
        return "";
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$featureName belum tersedia.")),
    );
  }

    void _handleTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/navbar', arguments: {'initialIndex': 1});
        break;
      case 1:
        Navigator.pushNamed(context, '/mood_input');
        break;
      case 2:
        _showComingSoon("Halaman Komynfo");
        break;
      case 3:
        _showComingSoon("Halaman Komfy Badge");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: curhatTexts.length,
          itemBuilder: (context, index, realIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => _handleTap(index),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF0F5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.25 * 255).round()),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(top: 0, left: 5, right: 20, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.25 * 255).round()),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                             Image.asset(chatImages[index], width: 100, height: 100),
                            SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    curhatTexts[index],
                                    style: AppTypography.bodyText2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF142553),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: AppTypography.bodyText3.copyWith(
                                        color: const Color(0xFF142553),
                                        height: 1.3,
                                      ),
                                      children: [
                                        TextSpan(text: curhatTexts2[index]),
                                        if (index == currentIndex)
                                          TextSpan(
                                            text: _getFeatureName(currentIndex),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _getFeatureName(index),
                          style: AppTypography.bodyText2.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF142553),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 140,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) => _onPageChanged(index),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            curhatTexts.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? const Color(0xFFF25523)
                    : const Color(0xFFB8B8B8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
