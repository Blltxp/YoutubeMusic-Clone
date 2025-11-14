import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final String title;
  final String imageUrl; // เพิ่ม imageUrl

  const PlaylistCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: Image.asset(
              // เพิ่ม Image.asset
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, object, stackTrace) =>
                  const Icon(Icons.error), // จัดการกรณีรูปภาพมีปัญหา
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
