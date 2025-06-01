import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool showFullContent = false;
  YoutubePlayerController? _controller;
  bool _isControllerInitialized = false;

  late String videoTitle;
  late String content;
  late String title;
  late String type;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      title = args['title'];
      type = args['type'];

      FirebaseFirestore.instance
          .collection('komynfo')
          .where('title', isEqualTo: title)
          .where('type', isEqualTo: type)
          .where('isVideo', isEqualTo: true)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final videoUrl = doc['imageUrl'];
          final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';
          setState(() {
            videoTitle = doc['title'];
            content = doc['content'];
            _controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                enableCaption: true,
                isLive: false,
                controlsVisibleAtStart: true,
                useHybridComposition: true,
              ),
            );
            _isControllerInitialized = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller!),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppColors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        player,
                        const SizedBox(height: 16),
                        Text(videoTitle, style: AppTypography.subtitle1.copyWith(color: Colors.black, height: 1.1)),
                        const SizedBox(height: 12),
                        Text(
                          showFullContent || content.length < 150
                            ? content
                            : "${content.substring(0, 200)}...",
                            textAlign: TextAlign.justify,
                            style: AppTypography.bodyText2.copyWith(color: Colors.black),
                        ),
                        if (content.length >= 150)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showFullContent = !showFullContent;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                showFullContent ? "Lihat lebih sedikit" : "Lihat lebih banyak",
                                style: AppTypography.subtitle4.copyWith(color: Colors.grey),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
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
