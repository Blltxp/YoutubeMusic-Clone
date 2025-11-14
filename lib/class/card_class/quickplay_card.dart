// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../mock_database.dart';
import '../../page/SongPlaying_page.dart';
import '../../page/SongInfo_page.dart';
import '../../provider/NowPlayingProvider.dart';

Widget QuickPlayCards(BuildContext context, Song song, Artist artist) {
  return GestureDetector(
    onTap: () {
      final nowPlayingProvider = context.read<NowPlayingProvider>();
      nowPlayingProvider.playSong(song);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SongPlayingPage(song: song),
        ),
      );
    },
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
              image: DecorationImage(
                image: AssetImage(song.imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  artist.name,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showSongOptions(context, song, artist);
            },
          ),
        ],
      ),
    ),
  );
}

// แก้ไขให้รับค่าจาก QuickPlayCards()
void _showSongOptions(BuildContext context, Song song, Artist artist) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayingPage(song: song),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add to Playlist'),
              onTap: () {
                // ฟังก์ชันเพิ่มไปยัง Playlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Song Info'),
              onTap: () {
                // เปลี่ยนการนำทางไปที่หน้า SongInfoPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongInfoPage(
                      song: song,
                      artist: artist,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
