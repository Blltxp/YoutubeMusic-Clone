import 'package:flutter/material.dart';

class BottomBarWidget extends StatelessWidget {
  final bool isAdPlaying;
  final VoidCallback? onNext;
  final VoidCallback? onLyrics;
  final VoidCallback? onRelated;

  const BottomBarWidget({
    super.key,
    required this.isAdPlaying,
    this.onNext,
    this.onLyrics,
    this.onRelated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: isAdPlaying ? null : onNext,
          child: Text('ถัดไป',
              style: TextStyle(
                  color: isAdPlaying ? Colors.grey[600] : Colors.white)),
        ),
        TextButton(
          onPressed: isAdPlaying ? null : onLyrics,
          child: Text('เนื้อเพลง',
              style: TextStyle(
                  color: isAdPlaying ? Colors.grey[600] : Colors.white)),
        ),
        TextButton(
          onPressed: isAdPlaying ? null : onRelated,
          child: Text('เกี่ยวข้อง',
              style: TextStyle(
                  color: isAdPlaying ? Colors.grey[600] : Colors.white)),
        ),
      ],
    );
  }
}
