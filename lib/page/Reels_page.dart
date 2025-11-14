// ignore_for_file: library_private_types_in_public_api, file_names, depend_on_referenced_packages, unused_import

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:async';

import '../mock_database.dart';
import '../provider/NowPlayingProvider.dart';
import 'SongPlaying_page.dart';

// สร้าง Global Key สำหรับเข้าถึงสถานะของ ReelPage
final GlobalKey<_ReelPageState> reelPageKey = GlobalKey<_ReelPageState>();

class ReelPage extends StatefulWidget {
  const ReelPage({Key? key}) : super(key: key);

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> with WidgetsBindingObserver {
  // เพิ่มตัวแปรและเมธอดสำหรับการจัดการสถานะ
  bool _isActive = false;

  // เมธอดสำหรับเรียกใช้งานจากข้างนอก
  void hideAndPauseMusic(BuildContext context) {
    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<NowPlayingProvider>(context, listen: false);
      provider.pauseAndHideMiniPlayer();
    });
  }

  void showMusicPlayer(BuildContext context) {
    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<NowPlayingProvider>(context, listen: false);
      provider.exitReelsPage();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // รอให้ widget เสร็จสิ้นการ build ก่อนเรียก provider
    _isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<NowPlayingProvider>(context, listen: false);
      provider.pauseAndHideMiniPlayer();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // เรียกใช้หลังจากที่ dependencies เปลี่ยนแปลง เช่น การกลับมาจากหน้าอื่น
    if (_isActive && mounted) {
      Future.microtask(() {
        if (!mounted) return;
        final provider =
            Provider.of<NowPlayingProvider>(context, listen: false);
        provider.enterReelsPage();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isActive = false;
    // เอาการเรียกใช้ Provider ออกจาก dispose() เพื่อป้องกัน Exception
    // ไม่จำเป็นต้องเรียก exitReelsPage() ตรงนี้เพราะจะมีการเรียกที่ onPageChanged ใน Main_page แล้ว
    super.dispose();
  }

  @override
  void deactivate() {
    // ใช้ flag แทนการเรียก provider โดยตรง
    _isActive = false;
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // เมื่อแอปกลับมาทำงานและหน้านี้ active อยู่
    if (state == AppLifecycleState.resumed && mounted && _isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final provider =
            Provider.of<NowPlayingProvider>(context, listen: false);
        provider.pauseAndHideMiniPlayer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter songs to include only those with a videoAsset
    final List<Song> reelSongs =
        songs.where((song) => song.videoAsset.isNotEmpty).toList();

    return WillPopScope(
      onWillPop: () async {
        if (mounted && _isActive) {
          Future.microtask(() {
            if (!mounted) return;
            final provider =
                Provider.of<NowPlayingProvider>(context, listen: false);
            provider.exitReelsPage();
          });
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/images/yt_music logo.png',
            width: 100,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: reelSongs.length,
          itemBuilder: (context, index) {
            final Song song = reelSongs[index];
            final Artist artist = artists.firstWhere(
              (artist) => artist.id == song.artistId,
              orElse: () => Artist(
                id: 0,
                name: 'Unknown Artist',
                imageUrl: '',
                followers: 0,
                profileBackgroundUrl: '',
              ),
            );

            return ReelCard(song: song, artist: artist);
          },
        ),
      ),
    );
  }
}

class ReelCard extends StatefulWidget {
  final Song song;
  final Artist artist;

  const ReelCard({
    super.key,
    required this.song,
    required this.artist,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  bool isLiked = false;
  bool isSaved = false;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showPauseIcon = false;
  bool _showPlayIcon = false;
  Timer? _playIconTimer;
  bool _wasManuallyPaused = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    final videoPath = widget.song.videoAsset;
    if (videoPath.isEmpty) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
      return;
    }

    if (_isDisposed) return;

    _controller = VideoPlayerController.asset(videoPath);

    try {
      await _controller.initialize();
      if (_isDisposed) {
        _controller.dispose();
        return;
      }

      _controller.setLooping(true);
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (widget.song.videoAsset.isNotEmpty) {
      _controller.dispose();
    }
    _playIconTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.song.videoAsset.isEmpty) {
      return Stack(fit: StackFit.expand, children: [
        Image.asset(widget.song.imageUrl, fit: BoxFit.cover),
        _buildOverlayContent(),
      ]);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isInitialized && !_isDisposed)
          GestureDetector(
            onTap: () {
              if (_isDisposed) return;
              if (_controller.value.isInitialized) {
                _playIconTimer?.cancel();
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                    _showPauseIcon = true;
                    _showPlayIcon = false;
                    _wasManuallyPaused = true;
                  } else {
                    _controller.play();
                    _showPauseIcon = false;
                    _showPlayIcon = true;
                    _wasManuallyPaused = false;
                    _playIconTimer =
                        Timer(const Duration(milliseconds: 800), () {
                      if (mounted && !_isDisposed) {
                        setState(() {
                          _showPlayIcon = false;
                        });
                      }
                    });
                  }
                });
              }
            },
            child: VisibilityDetector(
              key: Key(widget.song.id.toString()),
              onVisibilityChanged: (visibilityInfo) {
                if (_isDisposed) return;
                if (!_isInitialized || !widget.song.videoAsset.isNotEmpty)
                  return;

                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (_controller.value.isInitialized) {
                  if (visiblePercentage < 90) {
                    _playIconTimer?.cancel();
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      _wasManuallyPaused = false;
                    }
                    if (mounted &&
                        !_isDisposed &&
                        (_showPlayIcon || _showPauseIcon)) {
                      setState(() {
                        _showPlayIcon = false;
                        _showPauseIcon = false;
                      });
                    }
                  } else {
                    if (!_controller.value.isPlaying) {
                      if (_wasManuallyPaused) {
                        if (mounted && !_isDisposed && !_showPauseIcon) {
                          setState(() {
                            _showPauseIcon = true;
                          });
                        }
                      } else {
                        _controller.play();
                      }
                    }
                  }
                }
              },
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator()),
        if (_showPauseIcon)
          Center(
            child: Icon(
              Icons.pause_circle_filled,
              size: 70,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        if (_showPlayIcon)
          Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 70,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        _buildOverlayContent(),
      ],
    );
  }

  Widget _buildOverlayContent() {
    return Stack(
      children: [
        Positioned(
          left: 16,
          right: 16,
          bottom: 8,
          child: _buildSongInfo(),
        ),
        Positioned(
          right: 16,
          bottom: 100,
          child: _buildActionButtons(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Iconify(
            isLiked ? Ph.thumbs_up_fill : Ph.thumbs_up_bold,
            color: Colors.white,
          ),
          label: '6.4 แสน',
          onPressed: () {
            setState(() {
              isLiked = !isLiked;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: const Iconify(Ic.outline_comment, color: Colors.white),
          label: '8.1 พัน',
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Iconify(
            isSaved
                ? MaterialSymbols.playlist_add_check
                : MaterialSymbols.playlist_add,
            color: Colors.white,
            size: 30,
          ),
          label: 'บันทึก',
          onPressed: () {
            setState(() {
              isSaved = !isSaved;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: const Iconify(Uil.share, color: Colors.white),
          label: 'แชร์',
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: const Iconify(Ph.play_bold, color: Colors.white),
          label: 'เล่น',
          onPressed: () {
            if (widget.song.videoAsset.isNotEmpty &&
                _controller.value.isPlaying) {
              _controller.pause();
              _wasManuallyPaused = false;
              if (mounted)
                setState(() {
                  _showPauseIcon = false;
                  _showPlayIcon = false;
                });
            }

            // เมื่อกดปุ่ม "เล่น" ให้แจ้ง provider ว่าเราไม่ได้อยู่ในหน้า Reels แล้ว
            // เพื่อให้มินิเพลเยอร์แสดงเมื่อกลับมาหน้าอื่น
            Future.microtask(() {
              if (!mounted) return;
              final provider =
                  Provider.of<NowPlayingProvider>(context, listen: false);
              provider.exitReelsPage(); // รีเซ็ตสถานะก่อนเปิดหน้าเล่นเพลง
            });

            // ใช้ Future.microtask เพื่อแยกการเรียกใช้ Navigator ออกจากกระบวนการ build
            Future.microtask(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongPlayingPage(song: widget.song),
                ),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildSongInfo() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.song.imageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                child: widget.song.name.length > 30
                    ? Marquee(
                        text: widget.song.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        scrollAxis: Axis.horizontal,
                        blankSpace: 50.0,
                        velocity: 30.0,
                        pauseAfterRound: const Duration(seconds: 2),
                      )
                    : Text(
                        widget.song.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              Text(
                widget.artist.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.4),
            ),
            child: icon,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
