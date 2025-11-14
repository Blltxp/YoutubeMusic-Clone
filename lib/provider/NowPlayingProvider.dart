import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math';
import '../mock_database.dart'; // เพิ่ม import Song

class NowPlayingProvider extends ChangeNotifier {
  // String? imagePath; // ลบออก ใช้ currentSong แทน
  // String? title;     // ลบออก ใช้ currentSong แทน
  // String? artist;    // ลบออก ใช้ currentSong แทน
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  int _currentSongIndex = -1;
  bool _isPlaying = false;
  bool _isShuffle = false;
  int _repeatMode = 0; // 0: no repeat, 1: repeat all, 2: repeat one
  double _currentPosition = 0.0;
  double _songDuration = 0.0;
  bool _hideMiniPlayer = false; // เพิ่มตัวแปรสำหรับซ่อน/แสดงมินิเพลเยอร์
  bool _isInReelsPage =
      false; // เพิ่มตัวแปรเพื่อติดตามว่ากำลังอยู่ในหน้า Reels หรือไม่

  // เพิ่มตัวแปรเก็บสถานะผู้ใช้
  UserStatus _userStatus = UserStatus.normal;
  int _songCountBeforeAd = 0; // นับจำนวนเพลงก่อนแสดงโฆษณา
  final int _maxSongsBeforeAd = 2; // แสดงโฆษณาทุกๆ 2 เพลง

  // Ad related variables
  bool _isAdPlaying = false;
  VideoPlayerController? _adController;
  bool _showSkipButton = false;
  Timer? _skipTimer;
  Song? _pendingNextSong;
  bool _isAdInitialized = false;
  int _skipCountdownSeconds = 5;
  Timer? _skipCountdownTimer;
  double _adPosition = 0.0;
  double _adDuration = 0.0;
  final List<String> _adAssets = [
    'assets/ads/Pepsi.mp4',
    'assets/ads/iPhoneiPadPro.mp4',
    'assets/ads/SamsungS20FE.mp4',
  ];

  // Getter สำหรับเพลงปัจจุบัน
  Song? get currentSong =>
      _currentSongIndex >= 0 && _currentSongIndex < _playlist.length
          ? _playlist[_currentSongIndex]
          : null;

  // Getter สำหรับ playlist
  List<Song> get playlist => _playlist;

  // Getter สำหรับ index ปัจจุบัน
  int get currentSongIndex => _currentSongIndex;
  set currentSongIndex(int value) {
    if (value >= 0 && value < _playlist.length) {
      _currentSongIndex = value;
      notifyListeners();
    }
  }

  // เพิ่ม setter สำหรับ userStatus
  set userStatus(UserStatus status) {
    _userStatus = status;
  }

  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  int get repeatMode => _repeatMode;
  double get currentPosition => _currentPosition;
  double get songDuration => _songDuration;
  bool get isAdPlaying => _isAdPlaying;
  bool get showSkipButton => _showSkipButton;
  int get skipCountdownSeconds => _skipCountdownSeconds;
  double get adPosition => _adPosition;
  double get adDuration => _adDuration;
  bool get isAdInitialized => _isAdInitialized;
  VideoPlayerController? get adController => _adController;
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Duration? get duration => _audioPlayer.duration;
  bool get isInReelsPage => _isInReelsPage;

  // Getter และ Setter สำหรับการซ่อน/แสดงมินิเพลเยอร์
  bool get hideMiniPlayer => _hideMiniPlayer;
  set hideMiniPlayer(bool value) {
    _hideMiniPlayer = value;
    notifyListeners();
  }

  // สำหรับอัพเดทค่า _currentPosition โดยตรงตาม _audioPlayer
  void _updateCurrentPosition() {
    _audioPlayer.positionStream.listen((position) {
      if (!_isAdPlaying) {
        _currentPosition = position.inSeconds.toDouble();
        notifyListeners();
      }
    });

    _audioPlayer.durationStream.listen((totalDuration) {
      if (totalDuration != null && !_isAdPlaying) {
        _songDuration = totalDuration.inSeconds.toDouble();
        notifyListeners();
      }
    });
  }

  NowPlayingProvider() {
    _initializeAudioPlayer();
    _updateCurrentPosition();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && !_isAdPlaying) {
        _handleSongCompletion();
      }
    });
  }

  void _handleSongCompletion() {
    if (_repeatMode == 2) {
      // Repeat one
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else {
      int nextIndex = _currentSongIndex + 1;
      if (nextIndex >= _playlist.length) {
        if (_repeatMode == 1) {
          // Repeat all
          nextIndex = 0;
        } else {
          // Stop playback
          _isPlaying = false;
          _currentPosition = 0.0;
          notifyListeners();
          return;
        }
      }

      // เพิ่มการตรวจสอบสถานะผู้ใช้และนับจำนวนเพลงก่อนแสดงโฆษณา
      if (_userStatus == UserStatus.normal) {
        _songCountBeforeAd++;
        if (_songCountBeforeAd >= _maxSongsBeforeAd) {
          _songCountBeforeAd = 0;
          _pendingNextSong = _playlist[nextIndex];
          _playAd();
          return;
        }
      }

      // เล่นเพลงถัดไปตามปกติ
      _currentSongIndex = nextIndex;
      _loadAndPlaySong(_playlist[_currentSongIndex]);
    }
  }

  Future<void> playSong(Song song) async {
    _playlist = [song];
    _currentSongIndex = 0;

    // เมื่อมีการเล่นเพลง ให้รีเซ็ตสถานะการซ่อนมินิเพลเยอร์และสถานะหน้า Reels
    _isInReelsPage = false;
    _hideMiniPlayer = false;

    await _loadAndPlaySong(song);
  }

  Future<void> setPlaylistAndPlay(List<Song> playlist, int index,
      {bool shuffle = false}) async {
    if (playlist.isEmpty || index < 0 || index >= playlist.length) return;

    if (shuffle) {
      // สุ่มลำดับเพลง
      final allSongs = List<Song>.from(songs);
      allSongs.shuffle();

      // เริ่มต้นด้วยเพลงที่เลือก
      _playlist = [playlist[index]];

      // เพิ่มเพลงอื่นๆ เข้าไปในคิว (ไม่รวมเพลงปัจจุบัน)
      for (var song in allSongs) {
        if (song.id != playlist[index].id && _playlist.length < 10) {
          _playlist.add(song);
        }
      }
    } else {
      // ใช้ playlist ที่ส่งมาโดยไม่สุ่มใหม่
      _playlist = List<Song>.from(playlist);
    }

    // ตั้งค่า index ของเพลงปัจจุบัน
    _currentSongIndex = index;
    _currentPosition = 0.0;
    _songDuration = playlist[index].duration.toDouble();
    _songCountBeforeAd = 0; // รีเซ็ตตัวนับเพลงเมื่อเริ่มเล่น playlist ใหม่

    // เมื่อมีการเล่นเพลง ให้รีเซ็ตสถานะการซ่อนมินิเพลเยอร์และสถานะหน้า Reels
    _isInReelsPage = false;
    _hideMiniPlayer = false;

    notifyListeners();

    await _loadAndPlaySong(_playlist[_currentSongIndex]);
  }

  Future<void> _loadAndPlaySong(Song song) async {
    try {
      await _audioPlayer.stop();

      // ตั้งค่า duration จาก Song model
      _songDuration = song.duration.toDouble();
      _currentPosition = 0.0;
      notifyListeners();

      await _audioPlayer.setAsset(song.songAsset);
      await _audioPlayer.play();
      _isPlaying = true;

      // เมื่อเล่นเพลง ควรแสดงมินิเพลเยอร์
      _isInReelsPage = false;
      _hideMiniPlayer = false;

      notifyListeners();
    } catch (e) {
      print('Error loading song: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isAdPlaying) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  Future<void> playNext() async {
    if (_isAdPlaying || _playlist.isEmpty) return;

    try {
      int nextIndex = _currentSongIndex + 1;
      if (nextIndex >= _playlist.length) {
        if (_repeatMode == 1) {
          nextIndex = 0;
        } else {
          return;
        }
      }

      // เพิ่มการตรวจสอบสถานะผู้ใช้และนับจำนวนเพลงก่อนแสดงโฆษณา
      if (_userStatus == UserStatus.normal) {
        _songCountBeforeAd++;
        if (_songCountBeforeAd >= _maxSongsBeforeAd) {
          _songCountBeforeAd = 0;
          _pendingNextSong = _playlist[nextIndex];
          await _playAd();
          return;
        }
      }

      await _audioPlayer.stop();
      _currentSongIndex = nextIndex;
      await _loadAndPlaySong(_playlist[_currentSongIndex]);
      notifyListeners();
    } catch (e) {
      print('Error playing next song: $e');
    }
  }

  Future<void> playPrevious() async {
    if (_isAdPlaying || _playlist.isEmpty) return;

    try {
      int prevIndex = _currentSongIndex - 1;
      if (prevIndex < 0) {
        if (_repeatMode == 1) {
          prevIndex = _playlist.length - 1;
        } else {
          await _audioPlayer.seek(Duration.zero);
          _currentPosition = 0.0;
          notifyListeners();
          return;
        }
      }
      await _audioPlayer.stop();
      _currentSongIndex = prevIndex;
      await _loadAndPlaySong(_playlist[_currentSongIndex]);
      notifyListeners();
    } catch (e) {
      print('Error playing previous song: $e');
    }
  }

  Future<void> toggleShuffle() async {
    if (_isAdPlaying) return;

    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      final currentSong = _playlist[_currentSongIndex];
      _playlist.remove(currentSong);
      _playlist.shuffle();
      _playlist.insert(0, currentSong);
      _currentSongIndex = 0;
    } else {
      // Revert to original order
      _playlist = List.from(songs);
      _currentSongIndex = _playlist.indexWhere((s) => s.id == currentSong?.id);
      if (_currentSongIndex < 0) _currentSongIndex = 0;
    }
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    if (_isAdPlaying) return;

    _repeatMode = (_repeatMode + 1) % 3; // Cycle through 0, 1, 2
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (_isAdPlaying) return;
    try {
      // ตรวจสอบว่า position ไม่เป็น null และมีค่าที่ถูกต้อง
      final int seekSeconds = position.inSeconds;

      // กำหนดขอบเขตที่ถูกต้อง
      int safeSeconds = seekSeconds;
      if (safeSeconds < 0) safeSeconds = 0;
      if (_songDuration > 0 && safeSeconds > _songDuration.ceil()) {
        safeSeconds = _songDuration.ceil() - 1;
      }

      // สร้าง Duration ที่ปลอดภัย
      final safeDuration = Duration(seconds: safeSeconds);

      print(
          "กำลัง seek ไปที่ $safeSeconds วินาที จาก $_currentPosition ถึง $_songDuration");

      // อัพเดตค่า UI ทันที
      _currentPosition = safeSeconds.toDouble();
      notifyListeners();

      // ทำการ seek จริงๆ
      await _audioPlayer.seek(safeDuration);

      // อัพเดต UI อีกครั้งหลังจาก seek เสร็จ
      _currentPosition = safeSeconds.toDouble();
      notifyListeners();
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  Future<void> skipAd() async {
    await _skipAd();
  }

  Future<void> setVolume(double volume) async {
    if (_isAdPlaying) return;
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  // Ad related methods
  Future<void> _playAd() async {
    if (_adAssets.isEmpty) {
      _skipAd();
      return;
    }

    await _audioPlayer.pause();
    _isAdPlaying = true;
    _isAdInitialized = false;
    _showSkipButton = false;
    _isPlaying = false;
    _adPosition = 0.0;
    _adDuration = 0.0;
    _skipCountdownSeconds = 5;
    notifyListeners();

    final randomAdIndex = Random().nextInt(_adAssets.length);
    final adAssetPath = _adAssets[randomAdIndex];

    await _adController?.dispose();
    _adController = null;

    _adController = VideoPlayerController.asset(adAssetPath);

    try {
      await _adController!.initialize();
      _isAdInitialized = true;
      _adDuration = _adController!.value.duration.inSeconds.toDouble();
      if (_adDuration <= 0) _adDuration = 1.0;

      _adController!.setLooping(false);
      _adController!.play();

      _adController!.removeListener(_adPlaybackListener);
      _adController!.addListener(_adPlaybackListener);

      _skipCountdownTimer?.cancel();
      _skipCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // เพิ่มการตรวจสอบว่าโฆษณากำลังเล่นอยู่จริงหรือไม่
        if (_adController == null || !_adController!.value.isPlaying) {
          return; // ไม่นับถอยหลังถ้าโฆษณาไม่ได้เล่นอยู่
        }

        if (_skipCountdownSeconds > 0) {
          _skipCountdownSeconds--;
          notifyListeners();
        }
        if (_skipCountdownSeconds <= 0) {
          timer.cancel();
          _showSkipButton = true;
          notifyListeners();
        }
      });
    } catch (e) {
      _skipAd();
    }
  }

  void _adPlaybackListener() {
    if (_adController == null || !_adController!.value.isInitialized) return;

    _adPosition = _adController!.value.position.inSeconds.toDouble();
    _adDuration = _adController!.value.duration.inSeconds.toDouble();

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

    if (_adController!.value.position >= _adController!.value.duration) {
      _skipAd();
    }

    notifyListeners();
  }

  Future<void> _skipAd() async {
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
      } catch (e) {}
      await _adController!.dispose();
      _adController = null;
    }

    final songToPlay = _pendingNextSong;
    _pendingNextSong = null;

    _isAdPlaying = false;
    _isAdInitialized = false;
    _showSkipButton = false;
    _adPosition = 0.0;
    _adDuration = 0.0;
    _skipCountdownSeconds = 5;
    _currentPosition = 0.0;
    notifyListeners();

    if (songToPlay != null) {
      _currentSongIndex = _playlist.indexWhere((s) => s.id == songToPlay.id);
      if (_currentSongIndex < 0) _currentSongIndex = 0;
      await _loadAndPlaySong(songToPlay);
    } else {
      await _audioPlayer.stop();
    }
  }

  Future<void> pauseAndHideMiniPlayer() async {
    // หยุดเพลงเฉพาะเมื่อกำลังเล่นอยู่
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }

    // ใช้เฉพาะเมื่อกำลังเข้าหน้า Reels
    _isInReelsPage = true;
    _hideMiniPlayer = true;
    notifyListeners();
  }

  void restoreMiniPlayer() {
    // แสดงมินิเพลเยอร์เมื่อมีการเล่นเพลงอยู่แล้ว (currentSong ไม่เป็น null)
    // หรือเมื่อมีการกำหนดไว้แล้วใน playlist และไม่ได้อยู่ในหน้า Reels
    bool shouldNotify = false;

    // ไม่ต้องทำอะไรถ้ายังอยู่ในหน้า Reels
    if (_isInReelsPage) {
      return;
    }

    // แสดงมินิเพลเยอร์เมื่อมีการเล่นเพลงอยู่แล้วเท่านั้น
    if (currentSong != null ||
        (_playlist.isNotEmpty && _currentSongIndex >= 0)) {
      if (_hideMiniPlayer) {
        _hideMiniPlayer = false;
        shouldNotify = true;
      }
    }

    // แจ้งเตือนเฉพาะเมื่อมีการเปลี่ยนแปลงสถานะจริงๆ
    if (shouldNotify) {
      notifyListeners();
    }
  }

  void exitReelsPage() {
    bool shouldNotify = false;

    // ตรวจสอบว่าควรแจ้งเตือนหรือไม่
    if (_isInReelsPage) {
      _isInReelsPage = false;
      shouldNotify = true;
    }

    // แสดงมินิเพลเยอร์เมื่อมีการเล่นเพลงอยู่แล้วเท่านั้น
    if (currentSong != null ||
        (_playlist.isNotEmpty && _currentSongIndex >= 0)) {
      if (_hideMiniPlayer) {
        _hideMiniPlayer = false;
        shouldNotify = true;
      }
    }

    // แจ้งเตือนเฉพาะเมื่อมีการเปลี่ยนแปลงสถานะจริงๆ
    if (shouldNotify) {
      notifyListeners();
    }
  }

  // เมธอดเพื่อแจ้งว่าเข้าสู่หน้า Reels (ใช้ในกรณีต้องการแต่ไม่ต้องหยุดเพลง)
  void enterReelsPage() {
    // ไม่ต้องทำอะไรถ้าอยู่ในหน้า Reels อยู่แล้ว
    if (_isInReelsPage && _hideMiniPlayer) {
      return;
    }

    _isInReelsPage = true;
    _hideMiniPlayer = true;
    notifyListeners();
  }

  // เพิ่มฟังก์ชัน playWithAd เพื่อให้เรียกใช้จากภายนอกได้
  Future<void> playWithAd(Song song) async {
    // ตรวจสอบว่าผู้ใช้เป็นระดับ normal หรือไม่
    if (_userStatus != UserStatus.normal) {
      // ถ้าไม่ใช่ normal ให้เล่นเพลงทันที
      await playSong(song);
      return;
    }

    // แสดงข้อความล็อก
    print("กำลังเล่นโฆษณาก่อนเล่นเพลง: ${song.name}");

    // ตั้งค่าเพลงที่จะเล่นหลังโฆษณา
    _pendingNextSong = song;

    // เล่นโฆษณา
    await _playAd();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _adController?.removeListener(_adPlaybackListener);
    _adController?.dispose();
    _skipTimer?.cancel();
    _skipCountdownTimer?.cancel();
    super.dispose();
  }
}
