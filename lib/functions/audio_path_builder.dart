import '../mock_database.dart';

class AudioPathBuilder {
  static String? getAssetPathFromSong(Song song) {
    // ใช้ songAsset จาก Song object โดยตรง
    return song.songAsset;
  }

  static String getImagePathFromSong(Song song) {
    final artist = artists.firstWhere(
      (a) => a.id == song.artistId,
      orElse: () => throw Exception('Artist not found'),
    );

    String artistName = _sanitizeFileName(artist.name);
    String songTitle = _sanitizeFileName(song.name);

    return 'assets/images/SongImage/$artistName - $songTitle.jpg';
  }

  static String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[\\/:"*?<>|]'), '')
        .replaceAll(' ', '_')
        .trim();
  }
}
