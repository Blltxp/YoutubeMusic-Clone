// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

import '../mock_database.dart';

class GridSubtitleFormatted extends StatelessWidget {
  final Map<String, dynamic> item;
  final User currentUser;

  const GridSubtitleFormatted({
    Key? key,
    required this.item,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item['type'] == "playlist") {
      final int? playlistId = item['id'];
      final trackCount = item['trackCount'] ?? item['track'] ?? 0;

      if (playlistId == 5000) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(Ic.round_push_pin, color: Colors.grey, size: 16),
            SizedBox(width: 4),
            Text(' เพลย์ลิสต์อัตโนมัติ',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'เพลย์ลิสต์ • ${currentUser.name} • $trackCount เพลง',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      }
    } else if (item['type'] == "artist") {
      final followers = item['followers'] ?? 0;
      return Text(
        'ศิลปิน • $followers ผู้ติดตาม',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    return const SizedBox.shrink();
  }
}
