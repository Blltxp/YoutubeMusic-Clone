// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../mock_database.dart';

class Appbarlib extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final User user;

  const Appbarlib({
    Key? key,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      pinned: false,
      floating: true,
      snap: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า
        },
      ),
      title: const Text("ประวัติ", style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(
            Ionicons.search_outline,
            size: 25,
          ),
          onPressed: onSearchTap,
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
                title: const Text("บัญชีของฉัน",
                    style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading:
                    const Icon(Ionicons.log_out_outline, color: Colors.red),
                title: const Text("ออกจากระบบ",
                    style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
