// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:iconify_flutter/icons/radix_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:youtubemusic_clone/page/user_page.dart';
import 'package:youtubemusic_clone/page/Search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mock_database.dart';
import '../../page/login_page.dart';

class CoreAppbar extends StatelessWidget {
  final VoidCallback onAlertTap;
  final VoidCallback? onSearchTap;
  final VoidCallback onProfileTap;
  final String currentPage;
  final User user;
  final bool isExplorePage;

  const CoreAppbar({
    Key? key,
    required this.onAlertTap,
    this.onSearchTap,
    required this.onProfileTap,
    required this.user,
    required this.currentPage,
    this.isExplorePage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      pinned: false,
      floating: true,
      snap: true,
      title: Image.asset(
        'assets/images/yt_music logo.png',
        width: 100,
      ),
      actions: [
        if (currentPage == "LibraryPage")
          IconButton(
            icon: const Iconify(RadixIcons.counter_clockwise_clock,
                color: Colors.white, size: 24),
            onPressed: () {
              Navigator.pushNamed(context, "/history");
            },
          )
        else if (currentPage != "ExplorePage" && currentPage != "UpgradePage")
          IconButton(
            icon: const Icon(Ionicons.notifications_outline),
            onPressed: onAlertTap,
          ),
        IconButton(
          icon: const Icon(
            Ionicons.search_outline,
            size: 25,
          ),
          onPressed: () {
            if (onSearchTap != null) {
              onSearchTap!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () => showProfileModal(context, user),
            child: CircleAvatar(
              backgroundImage: AssetImage(user.imageUrl),
              radius: 16,
            ),
          ),
        ),
      ],
    );
  }

  void showProfileModal(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.black,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(user.imageUrl),
                radius: 40,
              ),
              const SizedBox(height: 10),
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading:
                    const Icon(Ionicons.person_circle, color: Colors.white),
                title: const Text("ช่องของฉัน",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserPage(userId: user.id),
                    ),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Ionicons.log_out_outline, color: Colors.red),
                title: const Text("ออกจากระบบ",
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context); // ปิด modal ก่อน

                  // ล้างข้อมูลจาก SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  // กลับไปหน้า Login และล้าง navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
