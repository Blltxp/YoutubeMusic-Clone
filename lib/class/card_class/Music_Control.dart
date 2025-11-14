// ignore_for_file: file_names

import 'dart:async';

class MusicControl {
  Timer? timer;

  // ฟังก์ชันที่ควบคุมการเล่น/หยุดเพลง
  void togglePlayPause(
      bool isPlaying,
      double songDuration,
      double currentPosition,
      Function(bool) onPlayPauseChanged,
      Function(double) onPositionChanged) {
    if (isPlaying) {
      timer?.cancel(); // หยุดการเล่น
      onPlayPauseChanged(false); // เปลี่ยนสถานะเป็นหยุด
    } else {
      onPlayPauseChanged(true); // เปลี่ยนสถานะเป็นเล่น
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentPosition >= songDuration) {
          timer.cancel(); // หยุดถ้าเล่นครบ
          onPlayPauseChanged(false); // เปลี่ยนสถานะเป็นหยุด
        } else {
          onPositionChanged(currentPosition + 1); // อัพเดตตำแหน่งเพลง
        }
      });
    }
  }

  // ฟังก์ชันข้ามเพลงถัดไป
  void skipNext(int currentSongIndex, List<String> songList,
      Function(int) onSongChanged) {
    int nextIndex = (currentSongIndex + 1) % songList.length;
    onSongChanged(nextIndex); // เปลี่ยนเพลงไปที่เพลงถัดไป
  }

  // ฟังก์ชันข้ามเพลงก่อนหน้า
  void skipPrevious(int currentSongIndex, List<String> songList,
      Function(int) onSongChanged) {
    int prevIndex = (currentSongIndex - 1 + songList.length) % songList.length;
    onSongChanged(prevIndex); // เปลี่ยนเพลงไปที่เพลงก่อนหน้า
  }

  // ฟังก์ชันสุ่มเพลง
  void shuffle(List<String> songList, Function(List<String>) onShuffle) {
    songList.shuffle(); // สุ่มลำดับเพลงในลิสต์
    onShuffle(List.from(songList)); // อัพเดตลิสต์เพลงที่ถูกสุ่ม
  }

  // ฟังก์ชันเล่นซ้ำ
  void repeat(double currentPosition, Function(double) onPositionChanged) {
    onPositionChanged(0); // รีเซ็ตตำแหน่งเพลงกลับไปที่เริ่มต้น
  }
}
