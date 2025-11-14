// ignore_for_file: file_names, unnecessary_string_interpolations, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:youtubemusic_clone/mock_database.dart';
import 'package:provider/provider.dart';
import '../provider/NowPlayingProvider.dart';
import '../page/SongPlaying_page.dart';

class ArtistDetailPage extends StatefulWidget {
  final Artist artist;

  const ArtistDetailPage({super.key, required this.artist});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  late List<Song> _fullArtistSongs;
  late List<Song> _filteredSongs;
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullArtistSongs =
        songs.where((song) => song.artistId == widget.artist.id).toList();
    _filteredSongs = List.from(_fullArtistSongs);
    _searchController.addListener(() {
      if (_searchController.text.isEmpty && _searchQuery.isNotEmpty) {
        setState(() {
          _searchQuery = "";
          _filterSongsLogic();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getArtistSongCount(Artist currentArtist) {
    return _fullArtistSongs.length; // ใช้ _fullArtistSongs ที่โหลดไว้แล้ว
  }

  void _filterSongsLogic() {
    if (_searchQuery.isEmpty) {
      _filteredSongs = List.from(_fullArtistSongs);
    } else {
      _filteredSongs = _fullArtistSongs.where((song) {
        final songNameLower = song.name.toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        return songNameLower.contains(queryLower);
      }).toList();
    }
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor:
            Colors.black.withOpacity(0.9), // สีพื้นหลัง AppBar ตอนค้นหา
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = "";
              _searchController.clear();
              _filterSongsLogic(); // รีเซ็ตรายการเพลง
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search in ${widget.artist.name}\'s songs...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
              _filterSongsLogic();
            });
          },
        ),
        // actions: [], // อาจจะไม่ต้องมี actions ตอนค้นหา
      );
    } else {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Share for ${widget.artist.name} (not implemented)")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
                _filteredSongs =
                    List.from(_fullArtistSongs); // เริ่มค้นหาด้วยเพลงทั้งหมด
              });
            },
          ),
        ],
      );
    }
  }

  Widget _buildSongListWidget(List<Song> songsToDisplay) {
    if (songsToDisplay.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No songs found matching your search.",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
        ),
      );
    }
    if (songsToDisplay.isEmpty && !_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("This artist has no songs yet.",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (songsToDisplay.isNotEmpty && !_isSearching)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 8.0, top: 10.0),
            child: Text("Songs by ${widget.artist.name}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ...songsToDisplay.asMap().entries.map((entry) {
          Song currentSong = entry.value;
          int originalIndexForPlayback =
              _fullArtistSongs.indexWhere((s) => s.id == currentSong.id);
          if (originalIndexForPlayback == -1) originalIndexForPlayback = 0;

          return ListTile(
            leading: Image.asset(currentSong.imageUrl,
                width: 50, height: 50, fit: BoxFit.cover),
            title: Text(currentSong.name,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(widget.artist.name,
                style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.more_vert, color: Colors.white),
            onTap: () {
              final nowPlayingProvider =
                  Provider.of<NowPlayingProvider>(context, listen: false);
              nowPlayingProvider.setPlaylistAndPlay(
                  _fullArtistSongs, originalIndexForPlayback);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongPlayingPage(
                    song: currentSong,
                    initialPlaylist: _fullArtistSongs,
                    initialIndex: originalIndexForPlayback,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songCount = _getArtistSongCount(widget.artist);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: !_isSearching,
      appBar: _buildAppBar(),
      body: _isSearching
          ? _buildSongListWidget(_filteredSongs)
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: screenWidth * 0.8,
                  width: screenWidth,
                  child: Hero(
                    tag: 'artist_image_${widget.artist.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.artist.profileBackgroundUrl.isNotEmpty
                              ? widget.artist.profileBackgroundUrl
                              : widget.artist.imageUrl,
                          width: screenWidth,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                  Colors.black
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.artist.name,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.artist.followers} followers',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        '$songCount songs',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text('Play',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (_fullArtistSongs.isNotEmpty) {
                        final nowPlayingProvider =
                            Provider.of<NowPlayingProvider>(context,
                                listen: false);
                        nowPlayingProvider.setPlaylistAndPlay(
                            _fullArtistSongs, 0);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongPlayingPage(
                              song: _fullArtistSongs[0],
                              initialPlaylist: _fullArtistSongs,
                              initialIndex: 0,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('This artist has no songs to play.')),
                        );
                      }
                    },
                  ),
                ),
                _buildSongListWidget(_fullArtistSongs),
              ],
            ),
    );
  }
}
