// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ListArtistImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool isCircular;

  const ListArtistImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isCircular
          ? BorderRadius.circular(size / 2)
          : BorderRadius.zero, // กำหนด borderRadius ตาม isCircular
      child: Image.asset(
        // หรือ Image.network
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, object, stackTrace) =>
            const Icon(Icons.error), // เพิ่ม errorBuilder
      ),
    );
  }
}
