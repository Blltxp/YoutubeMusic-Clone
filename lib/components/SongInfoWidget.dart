import 'package:flutter/material.dart';

class SongInfoWidget extends StatelessWidget {
  final String songName;
  final String artistName;

  const SongInfoWidget({
    super.key,
    required this.songName,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(songName,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(artistName,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white70)),
      ],
    );
  }
}
