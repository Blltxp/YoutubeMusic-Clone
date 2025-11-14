// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

class CommentBT extends StatefulWidget {
  const CommentBT({super.key});

  @override
  _CommentBTState createState() => _CommentBTState();
}

class _CommentBTState extends State<CommentBT> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // ปุ่มไลค์
        GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: const Row(
            children: [
              Iconify(Ic.outline_comment, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
