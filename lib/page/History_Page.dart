// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../class/card_class/Appbar_lib.dart';
import '../mock_database.dart';
import '../provider/UserProvider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser ??
        User(
          id: 0,
          name: 'Guest',
          username: 'guest',
          password: '',
          status: UserStatus.normal,
          imageUrl: 'assets/images/default_profile.png',
          profilebackgroundUrl: 'assets/images/default_background.png',
        );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Appbarlib(
            onSearchTap: () {},
            onProfileTap: () {},
            user: currentUser,
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                "สิ่งที่คุณฟังจะปรากฏขึ้นที่นี่",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
