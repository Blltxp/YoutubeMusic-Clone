// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';

class LikeDislikeRow extends StatefulWidget {
  const LikeDislikeRow({super.key});

  @override
  _LikeDislikeRowState createState() => _LikeDislikeRowState();
}

class _LikeDislikeRowState extends State<LikeDislikeRow> {
  bool isLiked = false;
  bool isDisliked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // ปุ่มไลค์
        GestureDetector(
          onTap: () {
            setState(() {
              isLiked = !isLiked;
              if (isLiked) isDisliked = false; // หากกดไลค์จะปิดสถานะดิสไลค์
            });
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: isLiked ? Colors.white : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                isLiked ? '1' : '', // ตัวอย่างการเปลี่ยนตัวเลข
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // ตัวคั่น
        const Text(
          '|',
          style: TextStyle(fontSize: 25, color: Colors.white38),
        ),
        const SizedBox(width: 16),

        // ปุ่มดิสไลค์
        GestureDetector(
          onTap: () {
            setState(() {
              isDisliked = !isDisliked;
              if (isDisliked) isLiked = false; // หากกดดิสไลค์จะปิดสถานะไลค์
            });
          },
          child: Icon(
            isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            color: isDisliked ? Colors.white : Colors.white,
          ),
        ),
      ],
    );
  }
}
