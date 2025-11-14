// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PlayAllButton extends StatelessWidget {
  final double width; // ความกว้างของปุ่ม
  final double height; // ความสูงของปุ่ม
  final double borderRadius; // ความโค้งของมุม
  final String text; // ข้อความในปุ่ม
  final double fontSize; // ขนาดตัวอักษร
  final Color borderColor; // สีของเส้นขอบ

  const PlayAllButton({
    Key? key,
    this.width = 70.0, // ค่าเริ่มต้นความกว้าง
    this.height =
        25.0, // ค่าเริ่มต้นความสูง (เพิ่มขึ้นเล็กน้อยเพื่อรองรับข้อความ)
    this.borderRadius = 20.0, // ค่าเริ่มต้นความโค้งของมุม
    this.text = "เล่นทั้งหมด", // ข้อความเริ่มต้น
    this.fontSize = 10.0, // ขนาดตัวอักษรเริ่มต้น
    this.borderColor = Colors.white60, // สีขอบเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor), // เส้นขอบ
        borderRadius: BorderRadius.circular(borderRadius), // ความโค้งของมุม
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize, // ขนาดตัวอักษร
            color: Colors.white, // สีตัวอักษร
            height: 1.0, // บังคับ line height
          ),
          maxLines: 1, // บังคับให้ข้อความอยู่ในบรรทัดเดียว
          overflow: TextOverflow.ellipsis, // ป้องกันข้อความยาวเกินไป
        ),
      ),
    );
  }
}
