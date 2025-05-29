import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KomynfoCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const KomynfoCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final longestTitleLength = items
        .map((e) => e['title'].toString().length)
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return _buildSingleCard(
            item['title'],
            item['image'],
            item['isVideo'],
            longestTitleLength,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleCard(
    String text,
    String imagePath,
    bool isVideo,
    int maxLength,
  ) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Header Komynfo ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/layers_icon.svg',
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Komynfo",
                    style: AppTypography.bodyText4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF091F5B),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF444444)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isVideo ? "Tontonan" : "Bacaan",
                  style: AppTypography.bodyText5.copyWith(
                    color: const Color(0xFF444444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // === Gambar ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isVideo)
                    Image.asset(
                      'assets/icons/play.png',
                      height: 30,
                      width: 30,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // === Judul/Teks ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 40,
                maxHeight: 60,
              ),
              child: Text(
                text,
                style:
                    AppTypography.bodyText4.copyWith(color: const Color(0xFF091F5B)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
