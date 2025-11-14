import 'package:flutter/material.dart';

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class NowPlayingBar extends StatelessWidget {
  final String songName;
  final String imagePath;
  final String artistName;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSkipNext;

  const NowPlayingBar({
    super.key,
    required this.songName,
    required this.imagePath,
    required this.artistName,
    required this.isPlaying,
    this.onPlayPause,
    this.onSkipNext,
  });

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87, // Or your preferred mini-player background color
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.asset(
              imagePath,
              width: 48, // Adjusted size
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 48,
                height: 48,
                color: Colors.grey[700],
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  songName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artistName,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white),
            iconSize: 30,
            onPressed: onPlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            iconSize: 30,
            onPressed: onSkipNext,
          ),
        ],
      ),
    );
  }
}
