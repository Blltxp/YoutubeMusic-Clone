// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ListDownloadPage extends StatelessWidget {
  const ListDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการที่ดาวน์โหลด'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: 10, // จำนวนเพลงที่ดาวน์โหลด
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title: Text('เพลงที่ดาวน์โหลด $index',
                style: const TextStyle(color: Colors.white)),
            subtitle:
                Text('ศิลปิน $index', style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // ลบเพลงออกจากรายการ
              },
            ),
            onTap: () {
              // เล่นเพลงจากรายการดาวน์โหลด
            },
          );
        },
      ),
    );
  }
}
