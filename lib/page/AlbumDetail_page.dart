// ignore_for_file: file_names, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import '../mock_database.dart'; // Import Album class
import 'package:provider/provider.dart'; // Import Provider
import '../provider/NowPlayingProvider.dart'; // Import NowPlayingProvider
import '../page/SongPlaying_page.dart'; // Import SongPlayingPage

class AlbumDetailPage extends StatelessWidget {
  final Album album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    // หาเพลงทั้งหมดที่อยู่ในอัลบั้มนี้
    // แก้ไขการเปรียบเทียบให้ใช้ int โดยตรง
    final albumSongs =
        songs.where((song) => song.albumIds.contains(album.id)).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(album.name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          // เพิ่มปุ่ม back
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              album.imageUrl,
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
          ),
          // แสดงชื่ออัลบั้มและศิลปิน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.name,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  'Album by ${album.artistName}', // แสดงชื่อศิลปิน
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.black),
              label: const Text('Play', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              onPressed: () {
                if (albumSongs.isNotEmpty) {
                  final nowPlayingProvider =
                      Provider.of<NowPlayingProvider>(context, listen: false);
                  List<Song> playlistToPlay = List.from(albumSongs);
                  int playIndex = 0;
                  Song songToPlay = playlistToPlay[playIndex];

                  nowPlayingProvider.setPlaylistAndPlay(
                      playlistToPlay, playIndex);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongPlayingPage(
                        song: songToPlay,
                        initialPlaylist: playlistToPlay,
                        initialIndex: playIndex,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ไม่มีเพลงในอัลบั้มนี้')),
                  );
                }
              },
            ),
          ),
          // --- สิ้นสุด ปุ่ม Play ใหม่ ---

          // แสดงรายการเพลงในอัลบั้ม
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: albumSongs.asMap().entries.map((entry) {
                int originalIndex = entry.key;
                Song tappedSong = entry.value;
                final artist = artists.firstWhere(
                    (a) => a.id == tappedSong.artistId,
                    orElse: () => Artist(
                        id: 0,
                        name: 'Unknown Artist',
                        followers: 0,
                        imageUrl: '',
                        profileBackgroundUrl: ''));
                return ListTile(
                  leading: Image.asset(tappedSong.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(tappedSong.name,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(artist.name,
                      style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.more_vert, color: Colors.white),
                  onTap: () {
                    if (albumSongs.isNotEmpty) {
                      List<Song> reorderedPlaylist = [];
                      if (originalIndex < albumSongs.length) {
                        reorderedPlaylist
                            .addAll(albumSongs.sublist(originalIndex));
                        reorderedPlaylist
                            .addAll(albumSongs.sublist(0, originalIndex));
                      } else {
                        // Fallback if index is out of bounds, though should not happen with asMap
                        reorderedPlaylist = List.from(albumSongs);
                      }

                      final nowPlayingProvider =
                          Provider.of<NowPlayingProvider>(context,
                              listen: false);
                      nowPlayingProvider.setPlaylistAndPlay(
                          reorderedPlaylist, 0);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongPlayingPage(
                            song: tappedSong,
                            initialPlaylist: reorderedPlaylist,
                            initialIndex:
                                0, // Index เริ่มต้นคือ 0 เสมอสำหรับ Playlist ที่จัดเรียงใหม่
                          ),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
