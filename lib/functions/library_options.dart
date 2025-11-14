import 'package:flutter/material.dart';

void showLibraryOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[850],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ดู',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, thickness: 1),
          _buildLibraryOption(context, 'คลังเพลง', Icons.library_music),
          _buildLibraryOption(context, 'รายการที่ดาวน์โหลด', Icons.download),
          _buildLibraryOption(context, 'ไฟล์จากอุปกรณ์', Icons.folder),
        ],
      );
    },
  );
}

Widget _buildLibraryOption(BuildContext context, String title, IconData icon) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    onTap: () {
      Navigator.pop(context); // ปิด BottomSheet
    },
  );
}
