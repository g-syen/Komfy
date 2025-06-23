import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';
import 'package:komfy/shared/icons/my_icons.dart';

class KomynfoCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onCardTap;

  const KomynfoCard({
    super.key, 
    required this.items,
    required this.onCardTap,
  });

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
            item['type'],
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
    String type,
    String imagePath,
    bool isVideo,
    int maxLength,
  ) {
    return GestureDetector(
      onTap: () {
        onCardTap({
          'title': text,
          'type': type,
          'isVideo': isVideo,
        });
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkBlue2,
                      ),
                      child: Icon(
                        isVideo ? MyIcons.videoFill : MyIcons.bacaanFill,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Komynfo",
                      style: AppTypography.bodyText4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF444444)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: AppTypography.bodyText4.copyWith(
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          'assets/icons/play.png',
                          height: 20,
                          width: 20,
                        ),
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
      ),
    );
  }
}

