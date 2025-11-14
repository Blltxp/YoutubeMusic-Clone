import 'package:just_audio/just_audio.dart';
import '../mock_database.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAllSongs(List<Song> songsToPlay) async {
    try {
      print('AudioPlayerService: เริ่มเล่นเพลง');
      print('AudioPlayerService: หยุดเพลงที่กำลังเล่นอยู่');
      await _audioPlayer.stop();

      print('AudioPlayerService: สร้าง playlist');
      final playlist = ConcatenatingAudioSource(
        children: songsToPlay
            .map((song) => AudioSource.asset(song.songAsset))
            .toList(),
      );

      print('AudioPlayerService: ตั้งค่า playlist');
      await _audioPlayer.setAudioSource(playlist);

      print('AudioPlayerService: เริ่มเล่นเพลง');
      await _audioPlayer.play();
      print('AudioPlayerService: เล่นเพลงสำเร็จ');
    } catch (e) {
      print('Error playing songs: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;

  void dispose() {
    _audioPlayer.dispose();
  }
}
