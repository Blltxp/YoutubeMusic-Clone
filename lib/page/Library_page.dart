// ignore_for_file: non_constant_identifier_names, avoid_print, library_prefixes, unused_import, file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../class/card_class/Categories_lib.dart';
import '../class/card_class/Core_Appbar.dart';
import '../class/setting/grid_artistImage.dart';
import '../class/setting/grid_playlist.dart';
import '../class/setting/library_ArtistImages.dart';
import '../functions/Grid_SubtitleFormatted.dart';
import '../functions/ListSubtitleFormatted.dart';
import '../functions/library_tapswapview.dart';
import '../mock_database.dart';
import '../provider/UserProvider.dart';
import '../page/ArtistDetail_page.dart';

class LibraryPage extends StatefulWidget {
  final ScrollController controller;
  const LibraryPage({super.key, required this.controller});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final ValueNotifier<bool> _isGridView = ValueNotifier(false);
  final DataProvider _dataProvider = DataProvider();

  @override
  Widget build(BuildContext context) {
    final User? currentUserFromProvider =
        context.watch<UserProvider>().currentUser;
    final User userForAppbar;

    if (currentUserFromProvider != null) {
      userForAppbar = currentUserFromProvider;
    } else {
      userForAppbar = users.isNotEmpty
          ? users[0]
          : User(
              id: 0,
              name: "Guest",
              username: "guest",
              password: "",
              imageUrl: "",
              profilebackgroundUrl: "",
              status: UserStatus.normal);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: widget.controller,
        slivers: [
          CoreAppbar(
            onAlertTap: () {},
            onProfileTap: () {},
            user: userForAppbar,
            isExplorePage: false,
            currentPage: 'LibraryPage',
          ),
          const Categorieslib(),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Tapswapview(isGridView: _isGridView),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isGridView,
            builder: (context, isGridView, child) =>
                FutureBuilder<List<Map<String, dynamic>>>(
              future: _dataProvider.loadData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                      child: Center(child: Text('Error: ${snapshot.error}')));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final allItems = snapshot.data!;
                  final artistsData = allItems
                      .where((item) => item['type'] == 'artist')
                      .toList();
                  final autoPlaylistOriginal = allItems.firstWhere(
                    (item) =>
                        item['type'] == 'playlist' && item['auto'] == true,
                    orElse: () => <String, dynamic>{},
                  );
                  Map<String, dynamic>? autoPlaylist;
                  if (autoPlaylistOriginal.isNotEmpty) {
                    autoPlaylist =
                        Map<String, dynamic>.of(autoPlaylistOriginal);
                  }
                  final playlists = allItems
                      .where((item) =>
                          item['type'] == 'playlist' &&
                          item != autoPlaylistOriginal)
                      .toList();
                  final displayItems = <Map<String, dynamic>>[
                    if (autoPlaylist != null) autoPlaylist,
                    ...playlists,
                    ...artistsData,
                  ];
                  return isGridView
                      ? buildGridView(displayItems, userForAppbar)
                      : buildListView(displayItems, userForAppbar);
                } else {
                  return const SliverToBoxAdapter(
                      child: Center(child: Text('ไม่มีข้อมูล')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  SliverGrid buildGridView(
      List<Map<String, dynamic>> displayItems, User currentUser) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        mainAxisExtent: 280,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = displayItems[index];
          final imageUrl = (item['imageUrl'] is String)
              ? item['imageUrl']
              : 'assets/images/placeholder.png';
          bool isArtist = item['type'] == 'artist';
          Artist? artistForDetail;
          if (isArtist) {
            artistForDetail = artists
                .firstWhere((artist) => artist.id == item['id'], orElse: () {
              return Artist(
                  id: -1,
                  name: "Unknown Artist",
                  followers: 0,
                  imageUrl: '',
                  profileBackgroundUrl: '');
            });
          }
          return GestureDetector(
            onTap: () {
              if (isArtist &&
                  artistForDetail != null &&
                  artistForDetail.id != -1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ArtistDetailPage(artist: artistForDetail!),
                  ),
                );
              } else if (!isArtist) {}
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isArtist
                      ? GridArtistImage(
                          imageUrl: imageUrl,
                          size: 180.0,
                          isCircular: true,
                        )
                      : GridPlaylistImage(
                          playlist: item,
                          size: 180.0,
                        ),
                  const SizedBox(height: 8),
                  Text(
                    item['name'] ?? 'Unnamed',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  GridSubtitleFormatted(item: item, currentUser: currentUser),
                ],
              ),
            ),
          );
        },
        childCount: displayItems.length,
      ),
    );
  }

  SliverPadding buildListView(
      List<Map<String, dynamic>> displayItems, User currentUser) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 50),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = displayItems[index];
            final imageUrl = (item['imageUrl'] is String)
                ? item['imageUrl']
                : 'assets/images/placeholder.png';
            bool isArtist = item['type'] == 'artist';
            Artist? artistForDetail;
            if (isArtist) {
              artistForDetail = artists
                  .firstWhere((artist) => artist.id == item['id'], orElse: () {
                return Artist(
                    id: -1,
                    name: "Unknown Artist",
                    followers: 0,
                    imageUrl: '',
                    profileBackgroundUrl: '');
              });
            }
            return ListTile(
              leading: ListArtistImage(
                imageUrl: imageUrl,
                size: 50.0,
                isCircular: item['type'] == 'artist',
              ),
              title: Text(item['name'] ?? 'Unnamed',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle:
                  ListSubtitleFormatted(item: item, currentUser: currentUser),
              trailing: const Icon(Icons.more_vert, color: Colors.white),
              onTap: () {
                if (isArtist &&
                    artistForDetail != null &&
                    artistForDetail.id != -1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArtistDetailPage(artist: artistForDetail!),
                    ),
                  );
                } else if (!isArtist) {}
              },
            );
          },
          childCount: displayItems.length,
        ),
      ),
    );
  }
}

class DataProvider {
  Future<List<Map<String, dynamic>>> loadData() => Future.value(mockData);
}
