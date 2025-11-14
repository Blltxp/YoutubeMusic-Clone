import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

// คลาสสำหรับปุ่มกรอง (Filter Button)
class FilterButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const FilterButton({
    required this.title,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106,
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.2,
              ),
              textAlign: TextAlign.left,
              maxLines: 2, // จำกัดจำนวนบรรทัดที่แสดง
              overflow: TextOverflow.ellipsis, // ถ้าข้อความเกินจะแสดง "..."
            ),
          )
        ],
      ),
    );
  }
}

// คลาสสำหรับการ์ดหมวดหมู่ (Category Card)
class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;

  const CategoryCard({
    required this.title,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 10)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 0), // ระยะห่างจากขอบซ้าย
        child: Align(
          alignment: Alignment.centerLeft, // จัดตำแหน่งข้อความที่ด้านซ้าย
          child: Text(
            title,
            maxLines: 2, // จำกัดบรรทัด
            overflow: TextOverflow.ellipsis, // ตัดข้อความที่ยาวเกิน
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// คลาสสำหรับหัวข้อส่วนต่างๆ (Section Title)
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 18, right: 20, top: 20),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Iconify(
              MaterialSymbols.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// คลาสสำหรับการ์ดวิดีโอ (Video Card)
class VideoCard extends StatelessWidget {
  final String title;
  final String artist;
  final String views;
  final String imagePath;

  const VideoCard({super.key, 
    required this.title,
    required this.artist,
    required this.views,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 20, right: 5, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center, // จัดตำแหน่งให้ไอคอนอยู่กลาง
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 330, // ปรับขนาดให้เล็กลง
                  height: 200, // ปรับขนาดให้เล็กลง
                  fit: BoxFit.cover, // ทำให้ภาพไม่เสียสัดส่วน
                ),
              ),
              const Icon(
                Icons.play_circle_fill, // ไอคอน play
                color: Colors.white, // สีไอคอน
                size: 60, // ขนาดไอคอน
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            '$artist • $views',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// คลาสสำหรับการ์ดอัลบั้ม (Album Card)
class AlbumCard extends StatelessWidget {
  final String imagePath;
  final String albumTitle;
  final String albumType;
  final String artistName;

  const AlbumCard({super.key, 
    required this.imagePath,
    required this.albumTitle,
    required this.albumType,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: 150,
              width: 150,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            albumTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: albumType,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const TextSpan(
                  text: ' • ',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                TextSpan(
                  text: artistName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
