import 'package:flutter/material.dart';

class PlaybackControlsWidget extends StatelessWidget {
  final bool isAdPlaying;
  final bool isShuffle;
  final int repeatMode;
  final bool isPlaying;
  final VoidCallback? onShuffle;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onRepeat;

  const PlaybackControlsWidget({
    super.key,
    required this.isAdPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.isPlaying,
    this.onShuffle,
    this.onPrevious,
    this.onPlayPause,
    this.onNext,
    this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.shuffle,
              color: isAdPlaying
                  ? Colors.grey[700]
                  : (isShuffle ? Colors.white : Colors.white70)),
          onPressed: isAdPlaying ? null : onShuffle,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 40),
          color: isAdPlaying ? Colors.grey[700] : Colors.white,
          onPressed: isAdPlaying ? null : onPrevious,
        ),
        GestureDetector(
          onTap: onPlayPause,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 40,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 40),
          color: isAdPlaying ? Colors.grey[700] : Colors.white,
          onPressed: isAdPlaying ? null : onNext,
        ),
        IconButton(
          icon: Icon(
            repeatMode == 0
                ? Icons.repeat
                : (repeatMode == 1 ? Icons.repeat : Icons.repeat_one),
            color: isAdPlaying
                ? Colors.grey[700]
                : (repeatMode > 0 ? Colors.white : Colors.white70),
          ),
          onPressed: isAdPlaying ? null : onRepeat,
        ),
      ],
    );
  }
}
