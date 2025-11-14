import 'package:flutter/material.dart';

// Card สำหรับหมวดเพลง
class MusicCategoryCard extends StatelessWidget {
  final String title;

  const MusicCategoryCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // เพิ่ม padding รอบตัวอักษร
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white, width: 0.5),
      ),
      child: IntrinsicWidth(
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
