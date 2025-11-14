import 'package:flutter/material.dart';

class GenreCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const GenreCard({required this.title, required this.imageUrl, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover, // ให้รูปเต็มพื้นที่
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.black
              .withOpacity(0.5), // เพิ่มความมืดให้ข้อความอ่านง่ายขึ้น
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
