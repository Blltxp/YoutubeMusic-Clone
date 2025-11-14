import 'package:flutter/material.dart';

class GridPlaylistImage extends StatelessWidget {
  final Map<String, dynamic> playlist; // รับข้อมูลแบบ Map มาใช้
  final double size;

  const GridPlaylistImage(
      {super.key, required this.playlist, required this.size});

  @override
  Widget build(BuildContext context) {
    // ดึง imageUrl จาก playlist
    String displayImageUrl = playlist['imageUrl'] ??
        'assets/images/placeholder.png'; // ใช้ placeholder ถ้า imageUrl เป็น null

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: displayImageUrl.isNotEmpty
            ? (displayImageUrl.startsWith('http')
                ? Image.network(
                    displayImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, object, stackTrace) =>
                        const Icon(Icons.error),
                  )
                : Image.asset(
                    displayImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, object, stackTrace) =>
                        const Icon(Icons.error),
                  ))
            : Image.asset(
                'assets/images/placeholder.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
