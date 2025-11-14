// ignore_for_file: file_names, unused_field, unrelated_type_equality_checks, avoid_unnecessary_containers, unused_element, duplicate_import, use_build_context_synchronously, unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math'; // Import Random
import 'package:video_player/video_player.dart'; // Import VideoPlayer
import 'package:provider/provider.dart'; // Import Provider
import '../provider/UserProvider.dart'; // Import UserProvider
import '../provider/NowPlayingProvider.dart';
import '../class/button/comment_bt.dart';
import '../class/button/like&dislike.dart';
import '../class/button/save_bt.dart';
import '../class/button/share_bt.dart';
import '../class/card_class/Music_Control.dart';
import '../functions/audio_manager.dart';
import '../mock_database.dart';
import '../components/ArtworkWidget.dart';
import '../components/AdWidget.dart';
import '../components/PlaybackControlsWidget.dart';
import '../components/SongInfoWidget.dart';
import '../components/ActionButtonsWidget.dart';
import '../components/SliderWidget.dart';
import '../components/BottomBarWidget.dart';

class SongPlayingPage extends StatefulWidget {
  final Song song;
  final List<Song>? initialPlaylist;
  final int? initialIndex;

  const SongPlayingPage({
    super.key,
    required this.song,
    this.initialPlaylist,
    this.initialIndex,
  });

  @override
  createState() => _SongPlayingPageState();
}

class _SongPlayingPageState extends State<SongPlayingPage> {
  Color? backgroundColor;
  bool isSongSelected = true;
  bool showIcon = false;
  bool isPlaying = false;
  double currentPosition = 0.0;
  late double songDuration = 300; // Default duration
  AudioPlayer? _audioPlayer; // เปลี่ยนเป็น nullable
  Timer? timer;
  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isInitialPlay = true;
  late Song _currentSong;
  bool _isShuffle = false;
  int _repeatMode = 0; // 0: no repeat, 1: repeat all, 2: repeat one

  // เก็บ reference ของ Provider เพื่อใช้ในภายหลัง
  NowPlayingProvider? _nowPlayingProvider;

  // --- Ad State Variables ---
  bool _isAdPlaying = false;
  VideoPlayerController? _adController;
  bool _showSkipButton = false;
  Timer? _skipTimer;
  Song? _pendingNextSong;
  bool _isAdInitialized = false;
  final List<String> _adAssets = [
    'assets/ads/Pepsi.mp4',
    'assets/ads/iPhoneiPadPro.mp4',
    'assets/ads/SamsungS20FE.mp4',
  ];
  // --- New/Modified Ad State ---
  int _skipCountdownSeconds = 5;
  Timer? _skipCountdownTimer;
  double _adPosition = 0.0;
  double _adDuration = 0.0;
  // --- End Ad State Variables ---

  final audioManager = AudioManager();
  final MusicControl _musicControl = MusicControl();
  final GlobalKey<State> _bottomSheetKey = GlobalKey<State>();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.song;
    _audioPlayer = AudioPlayer();

    // รอให้ widget เสร็จสิ้นการ build ก่อนเรียกเมธอดอื่นๆ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // ทำการโหลดข้อมูลเริ่มต้น
      _loadInitialData();
      _initializeAudioPlayer();

      // ไม่เรียก _initializePlaylist() ที่นี่ เพราะจะเรียกใน didChangeDependencies แทน
      _listenToSongEnd();
    });

    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // เก็บ reference ของ Provider ไว้ใช้งาน
    _nowPlayingProvider =
        Provider.of<NowPlayingProvider>(context, listen: false);

    // รีเซ็ตสถานะของหน้า Reels (เพื่อให้ MiniPlayer แสดงเมื่อกลับไปหน้าอื่น)
    if (_nowPlayingProvider != null && _nowPlayingProvider!.isInReelsPage) {
      // ใช้ Future.microtask เพื่อหลีกเลี่ยงการเรียก setState ระหว่าง build
      Future.microtask(() {
        if (!mounted) return;
        _nowPlayingProvider!.exitReelsPage();
      });
    }

    // ตรวจสอบว่าเพลงที่กำลังเล่นอยู่แล้วหรือไม่
    if (_nowPlayingProvider != null &&
        _nowPlayingProvider!.currentSong?.id == widget.song.id) {
      // ถ้าเป็นเพลงเดียวกัน ไม่ต้องเริ่มเล่นใหม่
      setState(() {
        _currentSong = _nowPlayingProvider!.currentSong!;
        _playlist = _nowPlayingProvider!.playlist;
        _currentIndex = _nowPlayingProvider!.currentSongIndex;
      });
    } else if (!_isInitialPlay) {
      // ถ้าไม่ใช่เพลงเดียวกันและไม่ใช่การเล่นครั้งแรก ให้เริ่มเล่นเพลงใหม่
      _initializePlaylist();
    }

    // ตั้งค่า _isInitialPlay เป็น false หลังจากเรียก didChangeDependencies ครั้งแรก
    _isInitialPlay = false;
  }

  @override
  void didUpdateWidget(SongPlayingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _loadInitialData() {
    _updateBackgroundColor();
    _setSongDuration(); // Call this to set initial duration
  }

  void _initializeAudioPlayer() {
    _audioPlayer?.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
    _listenToProgress(); // Listen to progress immediately
  }

  void _initializePlaylist() {
    // ตรวจสอบว่ายังคงอยู่ในหน้านี้หรือไม่ ถ้าไม่ให้ยกเลิกการทำงาน
    if (!mounted || _nowPlayingProvider == null) return;

    if (widget.initialPlaylist != null && widget.initialIndex != null) {
      // ใช้ playlist ที่ส่งมาโดยไม่สุ่มใหม่
      _playlist = List<Song>.from(widget.initialPlaylist!);
      _currentIndex = widget.initialIndex!;
    } else {
      // สร้างคิวเพลงใหม่ทุกครั้ง
      final allSongs = List<Song>.from(songs);
      allSongs.shuffle();

      // เริ่มต้นด้วยเพลงปัจจุบัน
      _playlist = [widget.song];

      // เพิ่มเพลงอื่นๆ เข้าไปในคิว (ไม่รวมเพลงปัจจุบัน)
      for (var song in allSongs) {
        if (song.id != widget.song.id && _playlist.length < 10) {
          _playlist.add(song);
        }
      }

      _currentIndex = 0;
    }

    // อัปเดต NowPlayingProvider โดยใช้ Future.microtask เพื่อไม่ให้เกิดการอัปเดตระหว่างการ build
    Future.microtask(() {
      if (!mounted || _nowPlayingProvider == null)
        return; // ตรวจสอบอีกครั้งว่ายังคงอยู่ในหน้านี้หรือไม่

      try {
        _nowPlayingProvider!.setPlaylistAndPlay(_playlist, _currentIndex,
            shuffle: widget.initialPlaylist == null);
        _initAudio();
      } catch (e) {
        print('Error in _initializePlaylist: $e');
      }
    });
  }

  void _initAudio() async {
    if (_playlist.isEmpty ||
        _currentIndex < 0 ||
        _currentIndex >= _playlist.length) {
      return;
    }
    // Ensure we don't play an ad immediately on first load
    if (_isAdPlaying) {
      return;
    }

    final songToPlay = _playlist[_currentIndex];

    try {
      await _loadAndPlaySongInternal(songToPlay);
    } catch (e) {
      print('Error in _initAudio: $e');
    }
  }

  void _listenToProgress() {
    if (_audioPlayer == null) return;

    // สร้างตัวแปรเก็บการติดตาม subscription เพื่อให้สามารถยกเลิกได้ในภายหลัง
    _audioPlayer!.positionStream.listen((position) {
      if (mounted && !_isAdPlaying) {
        // Only update slider if not playing ad
        try {
          setState(() {
            currentPosition = position.inSeconds.toDouble();
          });
        } catch (e) {
          print('Error in _listenToProgress from positionStream: $e');
        }
      }
    });

    // กำหนดค่า songDuration เมื่อโหลดเพลง
    _audioPlayer!.durationStream.listen((totalDuration) {
      if (mounted && !_isAdPlaying && totalDuration != null) {
        try {
          setState(() {
            songDuration = totalDuration.inSeconds.toDouble();
          });
        } catch (e) {
          print('Error in _listenToProgress from durationStream: $e');
        }
      }
    });
  }

  void _listenToSongEnd() {
    if (_audioPlayer == null) return;

    _audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && !_isAdPlaying) {
        // เช็คว่า widget ยังถูก mount อยู่หรือไม่
        if (!mounted) return;

        // ใช้ Future.microtask เพื่อแยกการเรียกใช้ Provider ออกจากกระบวนการ build
        Future.microtask(() {
          if (!mounted) return;

          try {
            // Get user status HERE before deciding next action
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            final currentUserStatus = userProvider.currentUserStatus;

            if (_repeatMode == 2) {
              // Repeat one
              _audioPlayer?.seek(Duration.zero);
              _audioPlayer?.play();
            } else {
              // Determine next song index
              int nextIndex = _currentIndex + 1;
              bool shouldRepeatPlaylist = false;
              if (nextIndex >= _playlist.length) {
                if (_repeatMode == 1) {
                  // Repeat all
                  nextIndex = 0;
                  shouldRepeatPlaylist = true;
                } else {
                  // Option: Stop playback, or start a new random playlist?
                  // For now, just stop or do nothing.
                  setState(() {
                    isPlaying = false;
                    currentPosition = 0.0;
                  });
                  _audioPlayer?.stop(); // Explicitly stop
                  return;
                }
              }

              // Check if user is normal and eligible for an ad
              if (currentUserStatus == UserStatus.normal) {
                _pendingNextSong = _playlist[nextIndex];
                _playAd(); // Play Ad before the next song
              } else {
                // Play next song directly if premium/admin or if repeating playlist
                _playNextSongInternal(nextIndex); // Use internal function
              }
            }
          } catch (e) {
            print('Error in _listenToSongEnd: $e');
          }
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isAdPlaying || _audioPlayer == null)
      return; // Don't allow toggle during ad or if player is null

    try {
      if (isPlaying) {
        _audioPlayer!.pause();
      } else {
        _audioPlayer!.play();
      }
    } catch (e) {
      print('Error in _togglePlayPause: $e');
    }
  }

  void _toggleShuffle() {
    if (_isAdPlaying) return; // Don't allow during ad
    setState(() {
      _isShuffle = !_isShuffle;
      if (_isShuffle) {
        final currentSong = _playlist[_currentIndex];
        _playlist.remove(currentSong); // Remove current song
        _playlist.shuffle(); // Shuffle the rest
        _playlist.insert(0, currentSong); // Add current song back to the start
        _currentIndex = 0; // Update index
      } else {
        // Revert to original order (or potentially the order when shuffle was turned on)
        // For simplicity, re-fetch or use a non-shuffled list if available
        // This might need adjustment based on desired behavior.
        _playlist = List.from(
            widget.initialPlaylist ?? songs); // Revert to original or mock
        _currentIndex = _playlist.indexWhere((s) => s.id == _currentSong.id);
        if (_currentIndex < 0) _currentIndex = 0;
      }
      _updateBottomSheet(); // Update queue view if open
    });
  }

  void _toggleRepeat() {
    if (_isAdPlaying) return; // Don't allow during ad
    setState(() {
      _repeatMode = (_repeatMode + 1) % 3; // Cycle through 0, 1, 2
    });
  }

  void _playNextSong() {
    if (_isAdPlaying || !mounted) return; // Don't allow manual skip during ad

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUserStatus = userProvider.currentUserStatus;

      int nextIndex = _currentIndex + 1;
      bool isEndOfPlaylist = false;
      if (nextIndex >= _playlist.length) {
        if (_repeatMode == 1) {
          // Repeat all
          nextIndex = 0;
        } else {
          isEndOfPlaylist = true;
          // Optional: Show a message or disable the button?
          // For now, do nothing if at the end and not repeating.
          return;
        }
      }

      if (currentUserStatus == UserStatus.normal) {
        _pendingNextSong = _playlist[nextIndex];
        _playAd();
      } else {
        setState(() {
          _playNextSongInternal(nextIndex);
        });
      }
    } catch (e) {
      print('Error in _playNextSong: $e');
    }
  }

  // Internal function to actually play the next song without ad check
  void _playNextSongInternal(int nextIndex) {
    if (nextIndex < 0 || nextIndex >= _playlist.length || !mounted) {
      return;
    }

    try {
      setState(() {
        _currentIndex = nextIndex;
        _currentSong = _playlist[_currentIndex];
      });

      _updateUIForNewSong();
      _loadAndPlaySongInternal(_currentSong);
      _updateBottomSheet(); // Update queue view if open
    } catch (e) {
      print('Error in _playNextSongInternal: $e');
    }
  }

  void _playPreviousSong() {
    if (_isAdPlaying || !mounted || _audioPlayer == null)
      return; // Don't allow during ad

    try {
      // Generally, ads don't play when going back.
      int prevIndex = _currentIndex - 1;
      if (prevIndex < 0) {
        if (_repeatMode == 1) {
          // Wrap around if repeating all
          prevIndex = _playlist.length - 1;
        } else {
          // Go to start of current song if at the beginning and not repeating
          _audioPlayer!.seek(Duration.zero);
          setState(() {
            currentPosition = 0.0;
          });
          return;
        }
      }

      setState(() {
        _currentIndex = prevIndex;
        _currentSong = _playlist[_currentIndex];
      });

      _updateUIForNewSong();
      _loadAndPlaySongInternal(_currentSong);
      _updateBottomSheet(); // Update queue view if open
    } catch (e) {
      print('Error in _playPreviousSong: $e');
    }
  }

  // Renamed to avoid confusion with external calls potentially needing ad checks
  Future<void> _loadAndPlaySongInternal(Song song) async {
    if (_isAdPlaying || !mounted) {
      return; // Prevent song loading during ad or if widget is not mounted
    }
    try {
      await _audioPlayer?.stop(); // Stop previous song explicitly

      if (_audioPlayer == null || !mounted) return;

      await _audioPlayer!.setAsset(song.songAsset);

      // Update duration after setting asset
      if (_audioPlayer?.duration != null && mounted) {
        setState(() {
          songDuration = _audioPlayer!.duration!.inSeconds.toDouble();
          currentPosition = 0.0; // Reset position for new song
        });
      } else {
        // Fallback or wait slightly? Duration might not be available immediately.
        // Using mock duration for now if unavailable.
        if (mounted) {
          final mockSong =
              songs.firstWhere((s) => s.id == song.id, orElse: () => song);
          setState(() {
            songDuration = mockSong.duration.toDouble();
            currentPosition = 0.0;
          });
        }
      }

      if (_audioPlayer != null && mounted) {
        await _audioPlayer!.play();
      }
    } catch (e) {
      print('Error in _loadAndPlaySongInternal: $e');
      // Handle error, maybe try next song or show message
    }
  }

  @override
  void dispose() {
    // เอาการเรียกใช้ Provider ออกจาก dispose() เพื่อป้องกัน Exception
    // ทำความสะอาดทรัพยากรอื่นๆ
    _audioPlayer?.dispose(); // ใช้ null-safe operator
    _adController?.removeListener(_adPlaybackListener);
    _adController?.dispose();
    _skipTimer?.cancel();
    _skipCountdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // --- Ad Playback Functions ---
  void _playAd() async {
    if (_adAssets.isEmpty || !mounted) {
      _skipAd();
      return;
    }

    try {
      await _audioPlayer?.pause();

      setState(() {
        _isAdPlaying = true;
        _isAdInitialized = false;
        _showSkipButton = false; // Start with countdown text, not button
        isPlaying = false;
        _adPosition = 0.0; // Reset ad position
        _adDuration = 0.0; // Reset ad duration
        _skipCountdownSeconds = 5; // Reset countdown
      });

      final randomAdIndex = Random().nextInt(_adAssets.length);
      final adAssetPath = _adAssets[randomAdIndex];

      await _adController?.dispose();
      _adController = null;

      _adController = VideoPlayerController.asset(adAssetPath);

      if (!mounted) return;

      await _adController!.initialize();

      if (!mounted) return;

      setState(() {
        _isAdInitialized = true;
        _adDuration = _adController!.value.duration.inSeconds.toDouble();
        if (_adDuration <= 0) _adDuration = 1.0; // Avoid division by zero
      });

      _adController!.setLooping(false);
      _adController!.play();

      // Remove old listener before adding new one
      _adController!.removeListener(_adPlaybackListener);
      _adController!.addListener(_adPlaybackListener);

      // Start Skip Countdown Timer
      _skipCountdownTimer?.cancel();
      _skipCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isAdPlaying) {
          timer.cancel();
          return;
        }

        // เพิ่มการตรวจสอบว่าโฆษณากำลังเล่นอยู่จริงหรือไม่
        if (_adController == null || !_adController!.value.isPlaying) {
          return; // ไม่นับถอยหลังถ้าโฆษณาไม่ได้เล่นอยู่
        }

        if (_skipCountdownSeconds > 0) {
          setState(() {
            _skipCountdownSeconds--;
          });
        }
        // Check if timer should be cancelled AND button shown
        if (_skipCountdownSeconds <= 0) {
          timer.cancel();
          if (mounted) {
            // Check mounted again before setting state
            setState(() {
              _showSkipButton = true; // Allow showing the actual button
            });
          }
        }
      });
    } catch (e) {
      print('Error in _playAd: $e');
      if (mounted) {
        _skipAd();
      }
    }
  }

  void _adPlaybackListener() {
    if (!mounted ||
        _adController == null ||
        !_adController!.value.isInitialized) {
      return;
    }

    try {
      // Update ad position state
      setState(() {
        _adPosition = _adController!.value.position.inSeconds.toDouble();
      });

      // ตรวจสอบการเล่น/หยุดของโฆษณาและจัดการกับตัวนับถอยหลัง
      if (!_adController!.value.isPlaying &&
          _skipCountdownSeconds > 0 &&
          _isAdPlaying) {
        // โฆษณาถูกหยุด - ไม่ต้องทำอะไร การนับถอยหลังจะหยุดในฟังก์ชันนับถอยหลัง
      } else if (_adController!.value.isPlaying &&
          _skipCountdownSeconds > 0 &&
          _isAdPlaying) {
        // โฆษณากำลังเล่น - ไม่ต้องทำอะไร การนับถอยหลังจะดำเนินต่อในฟังก์ชันนับถอยหลัง
      }

      if (_adController!.value.hasError) {
        if (_isAdPlaying) _skipAd();
      } else if (!_adController!.value.isPlaying &&
          _adController!.value.position >= _adController!.value.duration) {
        final bool isEnded =
            (_adController!.value.duration - _adController!.value.position)
                    .abs() <
                const Duration(milliseconds: 500);
        if (isEnded) {
          if (_isAdPlaying) _skipAd();
        }
      }
    } catch (e) {
      print('Error in _adPlaybackListener: $e');
    }
  }

  void _skipAd() async {
    try {
      _skipTimer?.cancel();
      _skipTimer = null;
      _skipCountdownTimer?.cancel();
      _skipCountdownTimer = null;

      if (_adController != null) {
        _adController!.removeListener(_adPlaybackListener);
        try {
          if (_adController!.value.isInitialized) {
            await _adController!.pause();
          }
        } catch (e) {
          print('Error pausing ad controller: $e');
        }
        await _adController!.dispose();
        _adController = null;
      }

      final songToPlay = _pendingNextSong;
      _pendingNextSong = null;

      if (!mounted) return;

      setState(() {
        _isAdPlaying = false;
        _isAdInitialized = false;
        _showSkipButton = false;
        _adPosition = 0.0;
        _adDuration = 0.0;
        _skipCountdownSeconds = 5; // Reset for next ad
        currentPosition = 0.0;
      });

      if (songToPlay != null) {
        _currentSong = songToPlay;
        _currentIndex = _playlist.indexWhere((s) => s.id == songToPlay.id);
        if (_currentIndex < 0) _currentIndex = 0;
        await _updateUIForNewSong();
        await _loadAndPlaySongInternal(songToPlay);
        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }
      } else {
        await _audioPlayer?.stop();
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      }
    } catch (e) {
      print('Error in _skipAd: $e');
    }
  }
  // --- End Ad Playback Functions ---

  Future<void> _updateBackgroundColor() async {
    // Avoid background update during ad
    if (_isAdPlaying || !mounted) return;

    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        AssetImage(_currentSong.imageUrl),
        // Optional: Add timeout
        timeout: const Duration(seconds: 5),
      );
      if (!mounted) return; // Check after await

      setState(() {
        backgroundColor = paletteGenerator.dominantColor?.color ?? Colors.black;
        // Adjust brightness logic...
        // (Keep existing brightness adjustment)
        if (backgroundColor != null) {
          final brightness = backgroundColor!.computeLuminance();
          if (brightness > 0.5) {
            backgroundColor = Color.fromARGB(
              255,
              (backgroundColor!.red * 0.7).round(),
              (backgroundColor!.green * 0.7).round(),
              (backgroundColor!.blue * 0.7).round(),
            ).withOpacity(0.7);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          backgroundColor = Colors.black.withOpacity(0.6);
        }); // Fallback color
      }
      print('Error in _updateBackgroundColor: $e');
    }
  }

  void _setSongDuration() {
    if (!mounted) return;

    try {
      // Find the song in the main list to get its stored duration
      final songData = songs.firstWhere((s) => s.id == _currentSong.id,
          orElse: () => _currentSong);
      // Use the duration from mock_database as the primary source
      if (mounted) {
        setState(() {
          // Ensure duration is treated as seconds directly
          songDuration = songData.duration.toDouble();
        });
      }
    } catch (e) {
      print('Error in _setSongDuration: $e');
    }
  }

  String _formatTime(double seconds) {
    // Handle potential NaN or infinite values
    if (seconds.isNaN || seconds.isInfinite) {
      return '0:00';
    }
    int minutes = seconds ~/ 60;
    int secs =
        (seconds % 60).toInt().abs(); // Use abs to avoid negative seconds
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildButtonRow(Widget button) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color:
            backgroundColor?.withOpacity(0.7) ?? Colors.grey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [button]),
    );
  }

  Future<void> _updateUIForNewSong() async {
    if (!mounted) return;

    try {
      await _updateBackgroundColor();
      _setSongDuration();
      // Reset position in UI immediately
      if (mounted) {
        setState(() {
          currentPosition = 0.0;
        });
      }
    } catch (e) {
      print('Error in _updateUIForNewSong: $e');
    }
  }

  void _removeFromQueue(int index) {
    if (_isAdPlaying) return; // Prevent queue changes during ad
    if (index < 0 || index >= _playlist.length) return; // Bounds check

    final removedSongId = _playlist[index].id;

    setState(() {
      // Adjust current index BEFORE removing if the removed item is before/at current
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex) {
        // If removing the currently playing song, stop playback and move to next (or previous if last)

        _audioPlayer?.stop();
        isPlaying = false;
        currentPosition = 0.0;

        _playlist.removeAt(index); // Remove the song

        if (_playlist.isEmpty) {
          // Handle empty playlist - maybe navigate back or show message
          _currentSong = songs.first; // Placeholder?
          _currentIndex = -1; // Indicate invalid index
          // Consider navigating back: Navigator.pop(context);
          return; // Exit early
        }

        // Determine the new current index
        if (_currentIndex >= _playlist.length) {
          // Was last element removed?
          _currentIndex = _playlist.length - 1; // Go to new last element
        }
        // If not last, index effectively stays same relative to remaining items

        _currentSong = _playlist[_currentIndex]; // Update current song
        _updateUIForNewSong();
        _loadAndPlaySongInternal(_currentSong); // Play the new current song
        return; // Handled removal of current song
      }

      // If removing item after current, just remove
      _playlist.removeAt(index);
    });
    _updateBottomSheet(); // Update queue view if open
  }

  void _addToQueue(Song song) {
    if (_isAdPlaying) return; // Prevent queue changes during ad
    setState(() {
      _playlist.add(song);
    });
    _updateBottomSheet(); // Update queue view if open
  }

  void _moveSongInQueue(int oldIndex, int newIndex) {
    if (_isAdPlaying) return; // Prevent queue changes during ad
    if (oldIndex < 0 || oldIndex >= _playlist.length || newIndex < 0)
      return; // Bounds check

    setState(() {
      // Adjust newIndex based on Flutter's ReorderableListView behavior
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      // Ensure newIndex is within bounds after adjustment
      if (newIndex >= _playlist.length) {
        newIndex = _playlist.length - 1;
      }

      final song = _playlist.removeAt(oldIndex);
      _playlist.insert(newIndex, song);

      // Update _currentIndex if the currently playing song was moved
      if (oldIndex == _currentIndex) {
        _currentIndex = newIndex;
      } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
        // If an item BEFORE the current song was moved to AFTER/AT the current song
        _currentIndex--;
      } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
        // If an item AFTER the current song was moved to BEFORE/AT the current song
        _currentIndex++;
      }
    });
    _updateBottomSheet(); // Update queue view if open
  }

  void _showSongMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white),
              title: const Text('ลบออกจากคิว',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                _removeFromQueue(index);
                Navigator.pop(context);
              },
            ),
            if (index > 0)
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.white),
                title: const Text('ย้ายขึ้น',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  _moveSongInQueue(index, index - 1);
                  Navigator.pop(context);
                },
              ),
            if (index < _playlist.length - 1)
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.white),
                title:
                    const Text('ย้ายลง', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _moveSongInQueue(index, index + 1);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _updateBottomSheet() {
    if (_bottomSheetKey.currentContext != null) {
      Navigator.pop(_bottomSheetKey.currentContext!);
      _showBottomSheet();
    }
  }

  void _showBottomSheet({int initialIndex = 0}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final nowPlayingProvider = Provider.of<NowPlayingProvider>(context);
        final currentSongId = nowPlayingProvider.currentSong?.id ?? -1;
        final currentArtistId = nowPlayingProvider.currentSong?.artistId ?? -1;

        // ค้นหาชื่อศิลปินจาก artistId ปัจจุบัน
        final artist = artists.firstWhere(
          (artist) => artist.id == currentArtistId,
          orElse: () => Artist(
              id: 0,
              name: "Unknown Artist",
              followers: 0,
              imageUrl: "",
              profileBackgroundUrl: ""),
        );
        final artistName = artist.name;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DefaultTabController(
              length: 3,
              initialIndex: initialIndex,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C).withOpacity(0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        top: 6,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                    const TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: [
                        Tab(text: 'ถัดไป'),
                        Tab(text: 'เนื้อเพลง'),
                        Tab(text: 'เกี่ยวข้อง'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ReorderableListView.builder(
                            itemCount: nowPlayingProvider.playlist.length,
                            onReorder: (oldIndex, newIndex) {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              setModalState(() {
                                final song = nowPlayingProvider.playlist
                                    .removeAt(oldIndex);
                                nowPlayingProvider.playlist
                                    .insert(newIndex, song);
                                if (oldIndex ==
                                    nowPlayingProvider.currentSongIndex) {
                                  nowPlayingProvider.currentSongIndex =
                                      newIndex;
                                } else if (oldIndex <
                                        nowPlayingProvider.currentSongIndex &&
                                    newIndex >=
                                        nowPlayingProvider.currentSongIndex) {
                                  nowPlayingProvider.currentSongIndex--;
                                } else if (oldIndex >
                                        nowPlayingProvider.currentSongIndex &&
                                    newIndex <=
                                        nowPlayingProvider.currentSongIndex) {
                                  nowPlayingProvider.currentSongIndex++;
                                }
                              });
                            },
                            itemBuilder: (context, index) {
                              final song = nowPlayingProvider.playlist[index];
                              final isCurrentSong =
                                  index == nowPlayingProvider.currentSongIndex;
                              final songArtist = artists.firstWhere(
                                (artist) => artist.id == song.artistId,
                              );
                              final songArtistName = songArtist.name;

                              return Dismissible(
                                key: Key(song.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  setModalState(() {
                                    nowPlayingProvider.playlist.removeAt(index);
                                    if (index <
                                        nowPlayingProvider.currentSongIndex) {
                                      nowPlayingProvider.currentSongIndex--;
                                    }
                                  });
                                },
                                child: ListTile(
                                  key: Key(song.id.toString()),
                                  leading: Stack(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(song.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (isCurrentSong)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                            child: const Icon(
                                              Icons.volume_up,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    song.name,
                                    style: TextStyle(
                                      color: isCurrentSong
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: isCurrentSong
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    songArtistName,
                                    style: TextStyle(
                                      color: isCurrentSong
                                          ? Colors.white70
                                          : Colors.white70,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.drag_handle,
                                    color: Colors.white70,
                                  ),
                                  tileColor: isCurrentSong
                                      ? Colors.white.withOpacity(0.15)
                                      : null,
                                  onTap: () {
                                    // ตรวจสอบสถานะผู้ใช้ว่าเป็น normal หรือไม่
                                    final userProvider =
                                        Provider.of<UserProvider>(context,
                                            listen: false);
                                    final userStatus =
                                        userProvider.currentUserStatus;

                                    // ปิด bottom sheet
                                    Navigator.pop(context);

                                    if (userStatus == UserStatus.normal) {
                                      // สำหรับผู้ใช้ normal จะแสดงโฆษณาก่อนเล่นเพลง
                                      nowPlayingProvider.playWithAd(song);
                                    } else {
                                      // สำหรับผู้ใช้ premium หรือ admin เล่นเพลงทันที
                                      nowPlayingProvider.setPlaylistAndPlay(
                                        nowPlayingProvider.playlist,
                                        index,
                                        shuffle:
                                            false, // ไม่สุ่มเมื่อเลือกจากคิว
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          Center(
                            child: Text(
                              nowPlayingProvider.currentSong?.lyrics.isEmpty ??
                                      true
                                  ? 'ไม่มีเนื้อเพลง'
                                  : nowPlayingProvider.currentSong?.lyrics ??
                                      '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              // ค้นหาเพลงที่เกี่ยวข้องโดยใช้ artistId จาก nowPlayingProvider.currentSong
                              final relatedSongs = songs
                                  .where((s) => s.artistId == currentArtistId)
                                  .toList();

                              // เรียงลำดับเพลงให้เพลงปัจจุบันอยู่ข้างบน
                              relatedSongs.sort((a, b) {
                                if (a.id == currentSongId) return -1;
                                if (b.id == currentSongId) return 1;
                                return 0;
                              });

                              return ListView.builder(
                                itemCount: relatedSongs.length,
                                itemBuilder: (context, index) {
                                  final relatedSong = relatedSongs[index];
                                  final isCurrentSong =
                                      relatedSong.id == currentSongId;

                                  return ListTile(
                                    leading: Stack(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  relatedSong.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        if (isCurrentSong)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                              ),
                                              child: const Icon(
                                                Icons.volume_up,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    title: Text(
                                      relatedSong.name,
                                      style: TextStyle(
                                        color: isCurrentSong
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: isCurrentSong
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      artistName,
                                      style: TextStyle(
                                        color: isCurrentSong
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                    ),
                                    onTap: () {
                                      // ตรวจสอบสถานะผู้ใช้ว่าเป็น normal หรือไม่
                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      final userStatus =
                                          userProvider.currentUserStatus;

                                      // ปิด bottom sheet
                                      Navigator.pop(context);

                                      if (userStatus == UserStatus.normal) {
                                        // สำหรับผู้ใช้ normal จะแสดงโฆษณาก่อนเล่นเพลง
                                        nowPlayingProvider
                                            .playWithAd(relatedSong);
                                      } else {
                                        // สำหรับผู้ใช้ premium หรือ admin เล่นเพลงทันที
                                        nowPlayingProvider.setPlaylistAndPlay(
                                          relatedSongs,
                                          index,
                                          shuffle:
                                              false, // ไม่สุ่มเมื่อเลือกจากคิว
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ฟังก์ชันเพื่อป้องกันไม่ให้ค่า slider เกินกว่า max หรือน้อยกว่า min
  double _safeSliderValue(double value,
      {required double max, double min = 0.0}) {
    if (value > max) return max;
    if (value < min) return min;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // เรียกใช้ widget ย่อยแทนโค้ด UI หลัก
    return Consumer<NowPlayingProvider>(
      builder: (context, nowPlayingProvider, child) {
        final artist = artists.firstWhere(
          (artist) => artist.id == nowPlayingProvider.currentSong?.artistId,
          orElse: () => Artist(
              id: 0,
              name: "Unknown Artist",
              followers: 0,
              imageUrl: "",
              profileBackgroundUrl: ""),
        );
        final artistName = artist.name;

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
          },
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: Stack(
                children: [
                  // Background Layer (Ad or Artwork)
                  Positioned.fill(
                    child: ArtworkWidget(
                      imageUrl: nowPlayingProvider.currentSong?.imageUrl ??
                          _currentSong.imageUrl,
                      isAdPlaying: nowPlayingProvider.isAdPlaying,
                      isAdInitialized: nowPlayingProvider.isAdInitialized,
                      adWidget: nowPlayingProvider.isAdPlaying &&
                              nowPlayingProvider.isAdInitialized
                          ? AdWidget(
                              adController: nowPlayingProvider.adController,
                              showSkipButton: nowPlayingProvider.showSkipButton,
                              skipCountdownSeconds:
                                  nowPlayingProvider.skipCountdownSeconds,
                              onSkip: () => nowPlayingProvider.skipAd(),
                            )
                          : null,
                    ),
                  ),
                  // Blur Overlay
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 90),
                      child: Container(
                          color: backgroundColor?.withOpacity(0.2) ??
                              Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  // Top Controls (คงไว้เหมือนเดิม)
                  Positioned(
                      top: 30,
                      left: 12,
                      child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_outlined,
                              color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context))),
                  Positioned(
                      top: 30,
                      left: MediaQuery.of(context).size.width / 2 - 75,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => isSongSelected = !isSongSelected),
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 100),
                                left: isSongSelected ? 0 : 75,
                                right: isSongSelected ? 75 : 0,
                                child: Container(
                                  width: 75,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: backgroundColor?.withOpacity(0.7) ??
                                        Colors.grey.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text("เพลง",
                                          style: TextStyle(
                                              color: isSongSelected
                                                  ? Colors.white
                                                  : Colors.white70)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text("วิดีโอ",
                                          style: TextStyle(
                                              color: isSongSelected
                                                  ? Colors.white70
                                                  : Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  Positioned(
                      top: 30,
                      right: 60,
                      child: IconButton(
                          icon: const Icon(Icons.tv, color: Colors.white),
                          onPressed: () {})),
                  Positioned(
                      top: 30,
                      right: 10,
                      child: IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {})),
                  // Main Content Area
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        // Artwork/Ad Display Area
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black.withOpacity(0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: ArtworkWidget(
                                imageUrl:
                                    nowPlayingProvider.currentSong?.imageUrl ??
                                        _currentSong.imageUrl,
                                isAdPlaying: nowPlayingProvider.isAdPlaying,
                                isAdInitialized:
                                    nowPlayingProvider.isAdInitialized,
                                adWidget: nowPlayingProvider.isAdPlaying &&
                                        nowPlayingProvider.isAdInitialized
                                    ? AdWidget(
                                        adController:
                                            nowPlayingProvider.adController,
                                        showSkipButton:
                                            nowPlayingProvider.showSkipButton,
                                        skipCountdownSeconds: nowPlayingProvider
                                            .skipCountdownSeconds,
                                        onSkip: () =>
                                            nowPlayingProvider.skipAd(),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Song Title and Artist
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          child: SongInfoWidget(
                            songName: nowPlayingProvider.currentSong?.name ??
                                _currentSong.name,
                            artistName: artistName,
                          ),
                        ),
                        // Action Buttons Row
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 20),
                          child: ActionButtonsWidget(
                              backgroundColor: backgroundColor),
                        ),
                        // Slider and Time
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: SliderWidget(
                            value: nowPlayingProvider.isAdPlaying
                                ? _safeSliderValue(
                                    nowPlayingProvider.adPosition,
                                    max: nowPlayingProvider.adDuration <= 0.0
                                        ? 1.0
                                        : nowPlayingProvider.adDuration)
                                : _safeSliderValue(
                                    nowPlayingProvider.currentPosition,
                                    max: nowPlayingProvider.songDuration <= 0.0
                                        ? 1.0
                                        : nowPlayingProvider.songDuration),
                            min: 0.0,
                            max: nowPlayingProvider.isAdPlaying
                                ? (nowPlayingProvider.adDuration <= 0.0
                                    ? 1.0
                                    : nowPlayingProvider.adDuration)
                                : (nowPlayingProvider.songDuration <= 0.0
                                    ? 1.0
                                    : nowPlayingProvider.songDuration),
                            onChanged: nowPlayingProvider.isAdPlaying
                                ? null
                                : (value) {
                                    setState(() {
                                      currentPosition = value;
                                    });
                                    final position =
                                        Duration(seconds: value.toInt());
                                    nowPlayingProvider.seek(position);
                                  },
                            currentTime: nowPlayingProvider.isAdPlaying
                                ? _formatTime(nowPlayingProvider.adPosition)
                                : _formatTime(
                                    nowPlayingProvider.currentPosition),
                            totalTime: nowPlayingProvider.isAdPlaying
                                ? _formatTime(nowPlayingProvider.adDuration)
                                : _formatTime(nowPlayingProvider.songDuration),
                            isAdPlaying: nowPlayingProvider.isAdPlaying,
                          ),
                        ),
                        // Playback Controls
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 20, right: 20),
                          child: PlaybackControlsWidget(
                            isAdPlaying: nowPlayingProvider.isAdPlaying,
                            isShuffle: nowPlayingProvider.isShuffle,
                            repeatMode: nowPlayingProvider.repeatMode,
                            isPlaying: nowPlayingProvider.isAdPlaying
                                ? (nowPlayingProvider
                                        .adController?.value.isPlaying ??
                                    false)
                                : nowPlayingProvider.isPlaying,
                            onShuffle: nowPlayingProvider.isAdPlaying
                                ? null
                                : () => nowPlayingProvider.toggleShuffle(),
                            onPrevious: nowPlayingProvider.isAdPlaying
                                ? null
                                : () => nowPlayingProvider.playPrevious(),
                            onPlayPause: () {
                              if (nowPlayingProvider.isAdPlaying) {
                                if (nowPlayingProvider
                                        .adController?.value.isPlaying ??
                                    false) {
                                  nowPlayingProvider.adController?.pause();
                                } else {
                                  nowPlayingProvider.adController?.play();
                                }
                              } else {
                                nowPlayingProvider.togglePlayPause();
                              }
                            },
                            onNext: nowPlayingProvider.isAdPlaying
                                ? null
                                : () => nowPlayingProvider.playNext(),
                            onRepeat: nowPlayingProvider.isAdPlaying
                                ? null
                                : () => nowPlayingProvider.toggleRepeat(),
                          ),
                        ),
                        const Spacer(),
                        // Bottom Bar
                        BottomBarWidget(
                          isAdPlaying: nowPlayingProvider.isAdPlaying,
                          onNext: nowPlayingProvider.isAdPlaying
                              ? null
                              : () => _showBottomSheet(initialIndex: 0),
                          onLyrics: nowPlayingProvider.isAdPlaying
                              ? null
                              : () => _showBottomSheet(initialIndex: 1),
                          onRelated: nowPlayingProvider.isAdPlaying
                              ? null
                              : () => _showBottomSheet(initialIndex: 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
