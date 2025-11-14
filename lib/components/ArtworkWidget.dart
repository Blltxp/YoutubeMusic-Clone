import 'package:flutter/material.dart';

class ArtworkWidget extends StatelessWidget {
  final String imageUrl;
  final bool isAdPlaying;
  final bool isAdInitialized;
  final Widget? adWidget;

  const ArtworkWidget({
    super.key,
    required this.imageUrl,
    required this.isAdPlaying,
    required this.isAdInitialized,
    this.adWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdPlaying && isAdInitialized && adWidget != null) {
      return Center(child: adWidget!);
    } else if (isAdPlaying && !isAdInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey[800]);
        },
      );
    }
  }
}
