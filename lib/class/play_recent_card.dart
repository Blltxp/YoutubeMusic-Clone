import 'package:flutter/material.dart';
import 'package:youtubemusic_clone/page/SongPlaying_page.dart';
import 'package:provider/provider.dart';
import '../provider/NowPlayingProvider.dart';

import '../mock_database.dart';

class PlayRecentCard extends StatelessWidget {
  final Song song;
  final Artist artist;

  const PlayRecentCard({
    super.key,
    required this.song,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nowPlayingProvider = context.read<NowPlayingProvider>();
        nowPlayingProvider.setPlaylistAndPlay([song], 0, shuffle: true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongPlayingPage(song: song),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.asset(
                song.imageUrl,
                width: 120,
                height: 110,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 0.0),
                child: Text(
                  song.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
