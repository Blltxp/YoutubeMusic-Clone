// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/uil.dart';

class ShareBT extends StatefulWidget {
  const ShareBT({super.key});

  @override
  _ShareBTState createState() => _ShareBTState();
}

class _ShareBTState extends State<ShareBT> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // ปุ่มแชร์
        GestureDetector(
          onTap: () {
            // เมื่อกดปุ่มให้แสดง BottomSheet
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200, // ความสูงของ BottomSheet
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.share, color: Colors.black),
                        title: const Text('แชร์ไปยัง...'),
                        onTap: () {
                          // เพิ่มฟังก์ชันการแชร์ของคุณที่นี่
                          Navigator.pop(context); // ปิด BottomSheet
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.link, color: Colors.black),
                        title: const Text('คัดลอกลิงก์'),
                        onTap: () {
                          // ฟังก์ชันคัดลอกลิงก์
                          Navigator.pop(context); // ปิด BottomSheet
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Row(
            children: [
              Iconify(Uil.share, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
