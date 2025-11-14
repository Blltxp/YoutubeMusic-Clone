import 'package:flutter/material.dart';

class FullscreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullscreenImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // พื้นหลังสีดำ
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // กลับไปหน้าก่อนหน้าเมื่อกดที่หน้าจอ
        },
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain, // แสดงรูปภาพขนาดเต็มจอ
          ),
        ),
      ),
    );
  }
}
