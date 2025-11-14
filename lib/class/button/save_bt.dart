// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class SaveBT extends StatefulWidget {
  const SaveBT({super.key});

  @override
  _SaveBTState createState() => _SaveBTState();
}

class _SaveBTState extends State<SaveBT> {
  bool isSaved = false; // ตัวแปรสถานะสำหรับปุ่ม "บันทึก"

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ใช้ GestureDetector ครอบทั้ง Row
      onTap: () {
        setState(() {
          isSaved = !isSaved; // สลับสถานะของปุ่ม
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ปุ่มบันทึก
          Iconify(
            isSaved
                ? MaterialSymbols.playlist_add_check
                : MaterialSymbols.playlist_add, // เปลี่ยนไอคอนตามสถานะ
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 10), // ระยะห่างระหว่างปุ่ม
          const Text(
            'บันทึก', // ข้อความในปุ่ม
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
