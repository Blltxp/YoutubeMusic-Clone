import 'package:flutter/material.dart';

// Delegate สำหรับ SliverPersistentHeader เพื่อให้ custom header สามารถ scroll ได้
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 80; // ความสูงต่ำสุดของ header
  @override
  double get maxExtent => 80; // ความสูงสูงสุดของ header

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
