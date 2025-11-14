import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../mock_database.dart';
import '../../provider/NowPlayingProvider.dart';
import '../../page/SongPlaying_page.dart';

class SongCard extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongCard({Key? key, required this.song, this.onTap}) : super(key: key);

  @override
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      try {
        final nowPlayingProvider = context.read<NowPlayingProvider>();
        nowPlayingProvider.playSong(widget.song);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongPlayingPage(song: widget.song),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถเล่นเพลงได้'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getArtistName() {
    try {
      return artists.firstWhere((a) => a.id == widget.song.artistId).name;
    } catch (e) {
      return 'Unknown Artist';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  widget.song.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.song.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    _getArtistName(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // TODO: Implement song options menu
              },
            ),
          ],
        ),
      ),
    );
  }
}
