import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AdWidget extends StatelessWidget {
  final VideoPlayerController? adController;
  final bool showSkipButton;
  final int skipCountdownSeconds;
  final VoidCallback? onSkip;

  const AdWidget({
    super.key,
    required this.adController,
    required this.showSkipButton,
    required this.skipCountdownSeconds,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (adController == null || !adController!.value.isInitialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        AspectRatio(
          aspectRatio: adController!.value.aspectRatio,
          child: VideoPlayer(adController!),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: showSkipButton
              ? ElevatedButton.icon(
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text("ข้ามโฆษณา"),
                  onPressed: onSkip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skipCountdownSeconds > 0
                        ? "ข้ามได้ใน $skipCountdownSeconds"
                        : "ข้ามโฆษณา",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
        ),
      ],
    );
  }
}
