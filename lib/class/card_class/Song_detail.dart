// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'package:flutter/material.dart';
import '../../mock_database.dart';
import '../../page/SongPlaying_page.dart';
import 'package:provider/provider.dart';
import '../../provider/NowPlayingProvider.dart';

class SongDetailsTabs extends StatelessWidget {
  final String currentSongTitle;
  final int artistId;

  const SongDetailsTabs({
    super.key,
    required this.currentSongTitle,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context) {
    final currentSong =
        songs.firstWhere((song) => song.name == currentSongTitle);
    final relatedSongs =
        songs.where((song) => song.artistId == artistId).toList();
    final queueSongs = songs
        .where((song) => song.name != currentSongTitle)
        .toList(); // คิวเพลง

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 11 / 12,
          child: TabBarView(
            children: [
              // แสดงคิวเพลง
              QueueTab(queueSongs: queueSongs),
              // แสดงเนื้อเพลง
              LyricsTab(lyrics: currentSong.lyrics),
              // แสดงเพลงที่เกี่ยวข้อง
              RelatedSongsTab(relatedSongs: relatedSongs),
            ],
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          child: const TabBar(
            tabs: [
              Tab(text: "ถัดไป"),
              Tab(
                text: "เนื้อเพลง",
              ),
              Tab(text: "เกี่ยวข้อง"),
            ],
          ),
        ),
      ],
    );
  }
}

class QueueTab extends StatelessWidget {
  final List<Song> queueSongs;

  const QueueTab({super.key, required this.queueSongs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // เพิ่ม SingleChildScrollView ให้ ListView
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: queueSongs.length,
        itemBuilder: (context, index) {
          final song = queueSongs[index];
          final artist =
              artists.firstWhere((artist) => artist.id == song.artistId);
          return ListTile(
            leading: Image.asset(song.imageUrl),
            title: Text(song.name),
            trailing: Text('${song.duration} วินาที'),
            onTap: () {
              // เปลี่ยนไปเพลงที่กด
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongPlayingPage(
                    song: song,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LyricsTab extends StatelessWidget {
  final String? lyrics;

  const LyricsTab({super.key, required this.lyrics});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: lyrics != null
          ? Text(lyrics!)
          : const Text('ยังไม่มีข้อมูลเนื้อเพลง'),
    );
  }
}

class RelatedSongsTab extends StatelessWidget {
  final List<Song> relatedSongs;

  const RelatedSongsTab({super.key, required this.relatedSongs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: relatedSongs.length,
      itemBuilder: (context, index) {
        final song = relatedSongs[index];
        final artist =
            artists.firstWhere((artist) => artist.id == song.artistId);
        return ListTile(
          leading: Image.asset(song.imageUrl),
          title: Text(song.name),
          trailing: Text('${song.duration} วินาที'),
          onTap: () {
            final nowPlayingProvider = context.read<NowPlayingProvider>();
            nowPlayingProvider.playSong(song);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongPlayingPage(
                  song: song,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
