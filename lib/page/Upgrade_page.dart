// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:youtubemusic_clone/mock_database.dart';
import '../class/card_class/Core_Appbar.dart';

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CoreAppbar(
            onAlertTap: () {},
            onProfileTap: () {},
            user: users[0],
            currentPage: 'UpgradePage',
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 150),
                Center(
                  child: Image.asset(
                    'assets/images/yt_music logo2.png',
                    height: 80,
                  ),
                ),
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    "สมัคร Music Premium เพื่อฟังเพลงแบบไม่มีโฆษณา แบบออฟไลน์และขณะปิดหน้าจอ",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: "Kanit", fontSize: 20),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "฿49.00/เดือน • ยกเลิกได้ทุกเมื่อ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("สมัคร Music Premium"),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text.rich(
                    TextSpan(
                      text: "หรือประหยัดเงินด้วย",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      children: [
                        TextSpan(
                          text: "แพ็กเกจสำหรับนักเรียนนักศึกษา",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text: " แพ็กเกจสำหรับครอบครัว",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text: " หรือแพ็กเกจรายปี",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text.rich(
                    TextSpan(
                      text:
                          "เรียกเก็บเงินตามรอบ การดำเนินการต่อเป็นการยืนยันว่าคุณมีอายุตั้งแต่ 18 ปีขึ้นไปและยอมรับ",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(
                          text: " ข้อกำหนดเหล่านี้",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text:
                              " ไม่มีการคืนเงินสำหรับช่วงเวลาที่เรียกเก็บเงินที่เหลือ",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Center(
                  child: Text(
                    "มีข้อจำกัด",
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 100),
                const Center(
                  child: Text(
                    "เพลง วิดีโอ การแสดงสดและอื่นๆอยู่ใกล้คุณแค่ปลายนิ้ว",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: "Kanit", fontSize: 20),
                  ),
                ),
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/clipArt/1.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'ฟังเพลงและศิลปินที่คุณชอบโดยไม่มีโฆษณามาคั่น',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Image(
                            image: AssetImage(
                              "assets/clipArt/2.gif",
                            ),
                            width: 70,
                            height: 70,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ดาวน์โหลดไว้ฟังแบบออฟไลน์ได้ทุกที่ทุกเวลา หรือเล่นขณะล็อกหน้าจอเพื่อให้ฟังได้แบบไม่ขาดตอน',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Image(
                            image: AssetImage(
                              "assets/clipArt/3.gif",
                            ),
                            width: 70,
                            height: 70,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'สลับจากเสียงเป็นวิดีโอขณะฟังเพลงได้ด้วยการแตะเพียงครั้งเดียว',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
