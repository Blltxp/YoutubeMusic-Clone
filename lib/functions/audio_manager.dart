// ignore_for_file: prefer_final_fields

import 'package:just_audio/just_audio.dart';
import 'package:youtubemusic_clone/functions/audio_path_builder.dart';
import 'package:youtubemusic_clone/mock_database.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSong = ""; // กำหนดค่าภายใน

  AudioManager._internal();

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Duration? get duration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  String? get currentSong => _currentSong;

  Future<void> playSong(Song song) async {
    try {
      String? path = AudioPathBuilder.getAssetPathFromSong(song);

      if (path != null) {
        if (path.startsWith("assets/")) {
          path = path.replaceFirst("assets/", "");
        }

        // กำหนดค่า _currentSong
        _currentSong = song.name;

        await _audioPlayer.setAsset(path);
        await _audioPlayer.play();
      } else {}
    } catch (e) {
      if (e is PlayerException) {}
    }
  }

  void pause() => _audioPlayer.pause();
  void stop() => _audioPlayer.stop();
  void seek(Duration position) => _audioPlayer.seek(position);
  void dispose() => _audioPlayer.dispose();
}
