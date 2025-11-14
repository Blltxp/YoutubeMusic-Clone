// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FromDirectoryPage extends StatelessWidget {
  const FromDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ไฟล์จากอุปกรณ์'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'หน้านี้สำหรับเข้าถึงไฟล์เพลงจากอุปกรณ์',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
