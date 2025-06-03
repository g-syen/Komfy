class KomynfoItem {
  final String title;
  final String type;
  final String imageUrl;
  final bool isVideo;
  final String? content;

  KomynfoItem({
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.isVideo,
    this.content,
  });

  factory KomynfoItem.fromFirestore(Map<String, dynamic> data) {
    return KomynfoItem(
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isVideo: data['isVideo'] ?? false,
      content: data['content'] ?? '',
    );
  }
}
