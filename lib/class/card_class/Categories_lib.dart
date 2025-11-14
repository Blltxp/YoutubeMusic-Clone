// ignore_for_file: file_names

import 'package:flutter/material.dart';


import '../music_categories_card.dart';
import '../sliver_app_bar_delegate.dart';

class Categorieslib extends StatelessWidget {
  const Categorieslib({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: SliverAppBarDelegate(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.fromLTRB(14.0, 20.0, 9.0, 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    MusicCategoryCard(title: "เพลย์ลิสต์"),
                    MusicCategoryCard(title: "เพลง"),
                    MusicCategoryCard(title: "อัลบั้ม"),
                    MusicCategoryCard(title: "ศิลปิน"),
                    MusicCategoryCard(title: "พอดแคสต์"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}