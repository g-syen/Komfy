import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String title = args['title'];
    final String type = args['type'];
    final bool isVideo = args['isVideo'];

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('komynfo')
          .where('title', isEqualTo: title)
          .where('type', isEqualTo: type)
          .where('isVideo', isEqualTo: isVideo)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail')),
            body: const Center(child: Text('Data tidak ditemukan')),
          );
        }

        final doc = snapshot.data!.docs.first;
        final imageUrl = doc['imageUrl'];
        final articleTitle = doc['title'];
        final content = doc['content'];

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 30, 20),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkBlue3),
                                const SizedBox(width: 4),
                                Text("Kembali", style: AppTypography.subtitle3.copyWith(color: AppColors.darkBlue3)),
                              ],
                            ),
                          ),
                          Text("Komynfo", style: AppTypography.subtitle3.copyWith(color: AppColors.darkBlue3)),
                        ],
                      ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Text('Gagal memuat konten'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          articleTitle,
                          style: AppTypography.subtitle1.copyWith(color: Colors.black, height: 1.1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          content,
                          textAlign: TextAlign.justify,
                          style: AppTypography.bodyText2.copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}