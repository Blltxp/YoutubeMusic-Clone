// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:provider/provider.dart';
import '../page/SongPlaying_page.dart';
import '../provider/NowPlayingProvider.dart';
import '../provider/UserProvider.dart';

import '../class/card_class/Core_Appbar.dart';
import '../class/explore_class.dart';
import '../mock_database.dart';
import '../page/AlbumDetail_page.dart';

class ExplorePage extends StatelessWidget {
  final ScrollController controller;

  const ExplorePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = context.watch<UserProvider>().currentUser;
    final User userForAppbar;
    if (currentUser != null) {
      userForAppbar = currentUser;
    } else {
      userForAppbar = users[0];
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: controller,
        slivers: [
          // AppBar ที่สามารถเลื่อนหายไปได้
          CoreAppbar(
            onAlertTap: () {
              // Alert action
            },
            onProfileTap: () {
              // Profile action
            },
            user: userForAppbar,
            currentPage: 'ExplorePage',
            isExplorePage: true,
          ),

          // ปุ่ม "มาใหม่," "อันดับ," และ "อารมณ์และแนวเพลง"
          const SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 18, right: 20.0, top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FilterButton(
                        title: 'มาใหม่',
                        icon: Icons.new_releases,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: FilterButton(
                        title: 'อันดับ',
                        icon: Icons.trending_up,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: FilterButton(
                        title: 'อารมณ์และแนวเพลง',
                        icon: Icons.mood,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ),

          // ส่วนของอัลบั้มและซิงเกิลใหม่
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 18, right: 20.0, top: 20, bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'อัลบั้มและซิงเกิลใหม่',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Iconify(
                        MaterialSymbols.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: albums.map((album) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AlbumDetailPage(album: album),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: AlbumCard(
                              imagePath: album.imageUrl,
                              albumTitle: album.name,
                              albumType: album.albumType,
                              artistName: album.artistName,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

// ส่วนของเพลงยอดนิยม
          const SectionTitle('เพลงยอดนิยม'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                final artist = artists.firstWhere((a) => a.id == song.artistId);
                return ListTile(
                  leading: Image.asset(song.imageUrl),
                  title: Text(song.name,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(artist.name,
                      style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.more_vert, color: Colors.white),
                  onTap: () {
                    final nowPlayingProvider =
                        Provider.of<NowPlayingProvider>(context, listen: false);
                    nowPlayingProvider.setPlaylistAndPlay(
                        List<Song>.from(songs), index);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SongPlayingPage(song: song)),
                    );
                  },
                );
              },
              childCount: songs.length,
            ),
          ),

          // ส่วนของหมวดหมู่เพลง
          SliverPadding(
            padding:
                const EdgeInsets.only(left: 18, right: 20, top: 30, bottom: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'อารมณ์และแนวเพลง',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Iconify(
                        MaterialSymbols.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ใช้ GridView สำหรับการแสดงการ์ดใน 3 แถว
                  SizedBox(
                    height: 220,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.36,
                      ),
                      itemCount: categoryTitles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: CategoryCard(
                            title: categoryTitles[index],
                            color: Colors
                                .primaries[index % Colors.primaries.length]
                                .shade700,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final artist =
                      artists.firstWhere((a) => a.id == song.artistId);

                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: VideoCard(
                      title: song.name,
                      artist: artist.name,
                      views: '${song.likes} ครั้ง',
                      imagePath: song.imageUrl,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
