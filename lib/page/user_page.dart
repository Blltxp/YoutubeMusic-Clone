import 'package:flutter/material.dart';
import '../mock_database.dart';

class UserPage extends StatelessWidget {
  final int userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = users.firstWhere(
      (u) => u.id == userId,
      orElse: () => users.firstWhere((u) => u.id == 0),
    );

    return DefaultTabController(
      length: 3, // แท็บที่มี เช่น เพลง, เพลย์ลิสต์, กิจกรรม (จะใส่อะไรก็ได้)
      child: Scaffold(

        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 250,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {}, // : แก้ไขโปรไฟล์
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {}, // : แชร์
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {}, // : ค้นหา
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      user.profilebackgroundUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                        color: Colors.black.withOpacity(0.5)), // ทับให้มืด
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(user.imageUrl),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "เพลง"),
                  Tab(text: "เพลย์ลิสต์"),
                  Tab(text: "กิจกรรม"),
                ],
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              Center(
                  child: Text("เพลงของผู้ใช้",
                      style: TextStyle(color: Colors.white))),
              Center(
                  child: Text("เพลย์ลิสต์",
                      style: TextStyle(color: Colors.white))),
              Center(
                  child: Text("กิจกรรมล่าสุด",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}
