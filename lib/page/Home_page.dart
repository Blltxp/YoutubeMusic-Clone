// ignore_for_file: file_names, unused_import, unused_catch_stack

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:youtubemusic_clone/page/user_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtubemusic_clone/page/SongPlaying_page.dart';
import 'package:provider/provider.dart';
import '../provider/NowPlayingProvider.dart';

import '../class/button/playAll_bt.dart';
import '../class/card_class/Core_Appbar.dart';
import '../class/card_class/HotSongCards.dart';
import '../class/card_class/genre_card.dart';
import '../class/card_class/playlist_card.dart';
import '../class/card_class/quickplay_card.dart';
import '../class/music_categories_card.dart';
import '../class/play_recent_card.dart';
import '../class/sliver_app_bar_delegate.dart';
import '../mock_database.dart';

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

final PageController _pageController = PageController(); // สร้าง PageController

class HomePage extends StatefulWidget {
  final ScrollController controller;
  final User user;

  const HomePage({super.key, required this.controller, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ตัวแปรเก็บข้อมูลเพลงที่กำลังเล่น - อาจจะไม่จำเป็นแล้วถ้า MiniPlayer จัดการ
  late List<Song> shuffledSongs;
  late List<Song> shuffledQuickPlaySongs;
  late List<Song> shuffledHotSongs;

  @override
  void initState() {
    super.initState();
    refreshAllSongs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refreshAllSongs() {
    setState(() {
      shuffledSongs = List.from(songs)..shuffle();
      shuffledQuickPlaySongs = List.from(songs)..shuffle();
      shuffledHotSongs = List.from(songs)..shuffle();
    });
  }

  Future<void> playAllSongs(List<Song> songsToPlay) async {
    try {
      if (!mounted || songsToPlay.isEmpty) {
        return;
      }

      // Update NowPlayingProvider
      await context
          .read<NowPlayingProvider>()
          .setPlaylistAndPlay(songsToPlay, 0);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongPlayingPage(
              song: songsToPlay[0],
              initialPlaylist: songsToPlay,
              initialIndex: 0,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in playAllSongs: $e');
    }
  }

  Future<void> playSingleSong(Song song) async {
    try {
      if (!mounted) return;

      final nowPlayingProvider = context.read<NowPlayingProvider>();
      await nowPlayingProvider.playSong(song);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongPlayingPage(
              song: song,
              initialPlaylist: [song],
              initialIndex: 0,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in playSingleSong: $e');
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // กำหนดสีพื้นหลังของหน้า HomePage จากการเลือกเพลง
    final currentUser = widget.user;
    Color backgroundColor = Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: widget.controller,
        slivers: [
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          CoreAppbar(
            onAlertTap: () {
              // ฟังก์ชันแจ้งเตือน
            },
            onProfileTap: () {
              // ฟังก์ชันโปรไฟล์
            },
            user: currentUser,
            currentPage: 'HomePage',
          ),

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

          SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(14.0, 20.0, 9.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          MusicCategoryCard(title: "ผ่อนคลาย"),
                          MusicCategoryCard(title: "กระปรี้กระเปร่า"),
                          MusicCategoryCard(title: "ปาร์ตี้"),
                          MusicCategoryCard(title: "ออกกำลังกาย"),
                          MusicCategoryCard(title: "รู้สึกดี"),
                          MusicCategoryCard(title: "เดินทาง"),
                          MusicCategoryCard(title: "โรแมนติก"),
                          MusicCategoryCard(title: "เศร้า"),
                          MusicCategoryCard(title: "จดจ่อ"),
                          MusicCategoryCard(title: "การนอนหลับ"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

          // ส่วนเล่นอย่างรวดเร็ว
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // รายการล่าสุด
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (users.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPage(
                                  userId: currentUser
                                      .id, // ส่ง userId ไป // ส่งข้อมูล user ไป
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: AssetImage(currentUser.imageUrl),
                            radius: 20,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            "เล่นล่าสุด",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Iconify(
                        MaterialSymbols.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent.withOpacity(0.7),
                        Colors.black
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: (shuffledSongs.length / 9).ceil(),
                          itemBuilder: (context, pageIndex) {
                            // คำนวณจำนวนเพลงในแต่ละหน้า
                            int songsOnThisPage = (pageIndex ==
                                    (shuffledSongs.length / 9).ceil() - 1)
                                ? shuffledSongs.length - pageIndex * 9
                                : 9;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20, top: 20),
                              child: Wrap(
                                spacing: 5.0,
                                runSpacing: 5.0,
                                children:
                                    List.generate(songsOnThisPage, (index) {
                                  int songIndex = pageIndex * 9 + index;
                                  final song = shuffledSongs[songIndex];
                                  final artist = artists.firstWhere(
                                      (artist) => artist.id == song.artistId);
                                  return GestureDetector(
                                    onTap: () {
                                      context
                                          .read<NowPlayingProvider>()
                                          .setPlaylistAndPlay(
                                              shuffledSongs, songIndex);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SongPlayingPage(
                                            song: song,
                                            initialPlaylist: shuffledSongs,
                                            initialIndex: songIndex,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                                  64) /
                                              3,
                                      child: Column(
                                        children: [
                                          PlayRecentCard(
                                            song: song,
                                            artist: artist,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: (shuffledSongs.length / 9).ceil(),
                          effect: const ExpandingDotsEffect(
                            activeDotColor: Colors.white,
                            dotColor: Colors.grey,
                            dotHeight: 8.0,
                            dotWidth: 8.0,
                            spacing: 5.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                // เลือกอย่างรวดเร็ว
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "เลือกอย่างรวดเร็ว",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (shuffledQuickPlaySongs.isEmpty) {
                            return;
                          }
                          playAllSongs(shuffledQuickPlaySongs);
                        },
                        child: const PlayAllButton(),
                      ),
                    ],
                  ),
                ),
                // เพลงในส่วนของเลือกอย่างรวดเร็ว
                Container(
                  height: 400,
                  padding:
                      const EdgeInsets.only(top: 18.0, left: 18, bottom: 10),
                  child: PageView.builder(
                    itemCount: (shuffledQuickPlaySongs.length / 4).ceil(),
                    itemBuilder: (context, pageIndex) {
                      return SingleChildScrollView(
                        child: Column(
                          children: List.generate(4, (index) {
                            int songIndex = pageIndex * 4 + index;
                            if (songIndex < shuffledQuickPlaySongs.length) {
                              final song = shuffledQuickPlaySongs[songIndex];
                              final artist = artists.firstWhere(
                                  (a) => a.id == song.artistId,
                                  orElse: () => Artist(
                                      id: 0,
                                      name: 'Unknown',
                                      followers: 0,
                                      imageUrl: '',
                                      profileBackgroundUrl: ''));

                              // Wrap with GestureDetector
                              return GestureDetector(
                                onTap: () {
                                  context
                                      .read<NowPlayingProvider>()
                                      .setPlaylistAndPlay(
                                          shuffledQuickPlaySongs, songIndex);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SongPlayingPage(
                                        song: song,
                                        initialPlaylist: shuffledQuickPlaySongs,
                                        initialIndex: songIndex,
                                      ),
                                    ),
                                  );
                                },
                                child: QuickPlayCards(
                                  context,
                                  song,
                                  artist,
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }),
                        ),
                      );
                    },
                  ),
                ),

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                // มาแรง
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "เพลงมาแรงสำหรับคุณ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => playAllSongs(shuffledHotSongs),
                        child: const PlayAllButton(),
                      ),
                    ],
                  ),
                ),
                // เพลงในส่วนของมาแรง
                Container(
                  height: 400,
                  padding:
                      const EdgeInsets.only(top: 18.0, left: 18, bottom: 10),
                  child: PageView.builder(
                    itemCount: (shuffledHotSongs.length / 4).ceil(),
                    itemBuilder: (context, pageIndex) {
                      return SingleChildScrollView(
                        child: Column(
                          children: List.generate(4, (index) {
                            int songIndex = pageIndex * 4 + index;
                            if (songIndex < shuffledHotSongs.length) {
                              final song = shuffledHotSongs[songIndex];
                              final artist = artists.firstWhere(
                                  (artist) => artist.id == song.artistId);
                              // Wrap with GestureDetector
                              return GestureDetector(
                                onTap: () {
                                  context
                                      .read<NowPlayingProvider>()
                                      .setPlaylistAndPlay(
                                          shuffledHotSongs, songIndex);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SongPlayingPage(
                                        song: song,
                                        initialPlaylist: shuffledHotSongs,
                                        initialIndex: songIndex,
                                      ),
                                    ),
                                  );
                                },
                                child: HotSongCards(
                                  context,
                                  song,
                                  artist,
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }),
                        ),
                      );
                    },
                  ),
                ),

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                // เพลย์ลิสต์แนะนำ
                const Padding(
                  padding: EdgeInsets.only(left: 18.0, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "เพลย์ลิสต์แนะนำ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 18),
                  height: 205,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      PlaylistCard(
                        title: "Daily Mix 1",
                        imageUrl: 'assets/images/Playlist/DailyMix1.jpg',
                      ),
                      PlaylistCard(
                        title: "Chill Vibes",
                        imageUrl: 'assets/images/Playlist/ChillVibe.jpg',
                      ),
                      PlaylistCard(
                        title: "Top Hits",
                        imageUrl: 'assets/images/Playlist/TopHits.jpg',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                // แนวเพลงหรืออารมณ์
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Genres & Moods",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      SizedBox(
                        width: 10,
                      ),
                      GenreCard(
                        title: 'Pop',
                        imageUrl: 'assets/images/Genre/pop.jpg',
                      ),
                      GenreCard(
                        title: 'Hip-Hop',
                        imageUrl: 'assets/images/Genre/hiphop.jpg',
                      ),
                      GenreCard(
                        title: 'Rock',
                        imageUrl: 'assets/images/Genre/rock.jpg',
                      ),
                      GenreCard(
                        title: 'Jazz',
                        imageUrl: 'assets/images/Genre/jazz.jpg',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
