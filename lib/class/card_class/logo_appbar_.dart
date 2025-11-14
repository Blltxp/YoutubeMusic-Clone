import 'package:flutter/material.dart';

class LogoAppbar extends StatelessWidget {
  const LogoAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.black,
      pinned: false,
      floating: true,
      snap: true,
      title: Image.asset(
        'assets/images/yt_music logo.png',
        width: 100,
      ),
    );
  }
}
