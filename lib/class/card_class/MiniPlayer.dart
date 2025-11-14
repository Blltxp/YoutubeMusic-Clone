import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/NowPlayingProvider.dart';
import '../../page/SongPlaying_page.dart';
import '../../mock_database.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  String _getArtistName(int artistId) {
    try {
      return artists.firstWhere((a) => a.id == artistId).name;
    } catch (e) {
      return 'Unknown Artist';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingProvider>(
      builder: (context, nowPlayingProvider, child) {
        if (nowPlayingProvider.currentSong == null ||
            nowPlayingProvider.hideMiniPlayer ||
            nowPlayingProvider.isInReelsPage) {
          return const SizedBox.shrink();
        }

        final song = nowPlayingProvider.currentSong!;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongPlayingPage(song: song),
              ),
            );
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                StreamBuilder<Duration?>(
                  stream: nowPlayingProvider.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration =
                        nowPlayingProvider.duration ?? Duration.zero;

                    // คำนวณค่า progress และป้องกันไม่ให้เกิน 1.0
                    double progress = 0.0;
                    if (duration.inMilliseconds > 0) {
                      progress =
                          position.inMilliseconds / duration.inMilliseconds;
                      // ป้องกันไม่ให้ progress เกิน 1.0
                      if (progress > 1.0) progress = 1.0;
                      if (progress < 0.0) progress = 0.0;
                    }

                    return SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2.0,
                        activeTrackColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[800],
                        thumbShape: SliderComponentShape.noThumb,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: progress,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          if (duration.inMilliseconds > 0) {
                            final newPosition = Duration(
                                milliseconds:
                                    (value * duration.inMilliseconds).toInt());
                            nowPlayingProvider.seek(newPosition);
                          }
                        },
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            song.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note,
                                  color: Colors.white54),
                            ),
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
                              song.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              _getArtistName(song.artistId),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          nowPlayingProvider.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          nowPlayingProvider.togglePlayPause();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          nowPlayingProvider.playNext();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
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
