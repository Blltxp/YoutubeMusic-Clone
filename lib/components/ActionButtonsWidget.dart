import 'package:flutter/material.dart';
import '../class/button/comment_bt.dart';
import '../class/button/like&dislike.dart';
import '../class/button/save_bt.dart';
import '../class/button/share_bt.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Color? backgroundColor;
  const ActionButtonsWidget({super.key, this.backgroundColor});

  Widget _buildButtonRow(Widget button) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color:
            backgroundColor?.withOpacity(0.7) ?? Colors.grey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [button]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildButtonRow(const LikeDislikeRow()),
          _buildButtonRow(const CommentBT()),
          _buildButtonRow(const SaveBT()),
          _buildButtonRow(const ShareBT()),
        ],
      ),
    );
  }
}
