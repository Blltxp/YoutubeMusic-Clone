// ignore_for_file: non_constant_identifier_names

// กำหนด Enum สำหรับประเภทข้อมูล

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum DataType { user, artist, album, song, playlist, genre, artistName }

enum UserStatus { premium, normal, admin }

// คลาสข้อมูลหลัก
class User {
  final int id;
  final String name;
  final String username;
  final String password;
  final String imageUrl;
  final String profilebackgroundUrl;
  final UserStatus status; // เพิ่มฟิลด์สถานะ

  User(
      {required this.id,
      required this.name,
      required this.username,
      required this.password,
      required this.imageUrl,
      required this.profilebackgroundUrl,
      required this.status});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      imageUrl: json['imageUrl'],
      profilebackgroundUrl: json['profilebackgroundUrl'],
      status: UserStatus.values[json['status']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'imageUrl': imageUrl,
      'profilebackgroundUrl': profilebackgroundUrl,
      'status': status.index,
    };
  }
}

class Artist {
  final int id;
  final String name;
  final int followers;
  final String imageUrl;
  final String profileBackgroundUrl;

  Artist({
    required this.id,
    required this.name,
    required this.followers,
    required this.imageUrl,
    required this.profileBackgroundUrl,
  });
}

class Album {
  final int id;
  final String name;
  final String albumType;
  final String artistName;
  final String imageUrl;

  Album({
    required this.id,
    required this.name,
    required this.albumType,
    required this.artistName,
    required this.imageUrl,
  });
}

class Song {
  final int id;
  final String name;
  final int artistId;
  final List<int> albumIds;
  final int likes;
  final int duration;
  final String lyrics;
  final String imageUrl;
  final String songAsset;
  final String videoAsset;
  Song(
      {required this.id,
      required this.name,
      required this.artistId,
      required this.albumIds,
      required this.likes,
      required this.duration,
      required this.lyrics,
      required this.imageUrl,
      required this.songAsset,
      required this.videoAsset});
}

class Playlist {
  final int id;
  final String name;
  final List<int> songIds;
  final String track;
  final int userId;
  final bool auto;
  final String imageUrl;

  Playlist(
      {required this.id,
      required this.name,
      required this.songIds,
      required this.track,
      required this.userId,
      required this.imageUrl,
      this.auto = false});
}

class Genre {
  final int id;
  final String name;
  final String imageUrl;

  Genre({required this.id, required this.name, required this.imageUrl});
}

// ข้อมูลจำลอง
List<User> users = [
  User(
      id: 0,
      name: 'admin',
      username: 'admin',
      password: '123456789',
      imageUrl: 'assets/images/User/nonUser.jpg',
      status: UserStatus.admin,
      profilebackgroundUrl: 'assets/images/User/nonUserBG.jpg'),
  User(
      id: 1,
      username: 'tanatatpna',
      password: 'tanatatpna',
      name: 'Tanatat Paungpaen',
      imageUrl: 'assets/images/User/จารย์แดง.jpg',
      status: UserStatus.premium,
      profilebackgroundUrl: 'assets/images/User/profileBG.jpg'),
  User(
      id: 3,
      name: 'test',
      username: 'test',
      password: '123456789',
      imageUrl: 'assets/images/User/nonUser.jpg',
      status: UserStatus.normal,
      profilebackgroundUrl: 'assets/images/User/nonUserBG.jpg'),
];

final List<Artist> artists = [
  Artist(
      id: 3001,
      name: 'Electric Neon Lamp',
      followers: 27200,
      imageUrl: 'assets/images/Artist/Electric Neon Lamp.jpg',
      profileBackgroundUrl:
          'assets/images/Artist/backgroundImage/Electric Neon Lamp.jpg'),
  Artist(
      id: 3002,
      name: 'Rex Orange Country',
      followers: 1730000,
      imageUrl: 'assets/images/Artist/Rex Orange Country.jpg',
      profileBackgroundUrl:
          'assets/images/Artist/backgroundImage/Rex Orange Country.jpg'),
  Artist(
      id: 3003,
      name: 'Slot Machine',
      followers: 617000,
      imageUrl: 'assets/images/Artist/Slot machine.jpg',
      profileBackgroundUrl:
          'assets/images/Artist/backgroundImage/Slot machine.jpg'),
  Artist(
      id: 3004,
      name: 'The Parkinson',
      followers: 54800,
      imageUrl: 'assets/images/Artist/The Parkinson.jpg',
      profileBackgroundUrl:
          'assets/images/Artist/backgroundImage/The Parkinson.jpg'),
];

// รายการอัลบั้มจำลอง
List<Album> albums = [
  Album(
    id: 4002,
    name: 'Apricot Princess',
    albumType: 'อัลบั้ม',
    artistName: 'Rex Orange County',
    imageUrl: 'assets/images/Album/Apricot Princess.jpg',
  ),
  Album(
    id: 4001,
    name: 'ซิงเกิลยอดฮิต',
    albumType: 'ซิงเกิล',
    artistName: 'Electric Neon Lamp',
    imageUrl: 'assets/images/Album/หนีไป.jpg',
  ),
  Album(
    id: 4003,
    name: 'Mutation',
    albumType: 'อัลบั้ม',
    artistName: 'Slot Machine',
    imageUrl: 'assets/images/Album/Mutation.jpg',
  ),
  Album(
    id: 4100,
    name: 'ฮิตติดชาร์ต',
    albumType: 'ซิงเกิล',
    artistName: 'Slot Machine, The Parkinson',
    imageUrl: 'assets/images/Album/Hit.jpg',
  ),
];

final List<Song> songs = [
  Song(
      id: 2001,
      name: 'สุขุมวิท',
      artistId: 3001,
      albumIds: [4001],
      likes: 2000,
      duration: 227,
      lyrics: '',
      imageUrl: 'assets/images/SongImage/สุขุมวิท.jpg',
      songAsset:
          'assets/music/electric.neon.lamp - สุขุมวิท [Official Music Video].mp3',
      videoAsset: 'assets/reels/enl_sukhumvit_official.mp4'),
  Song(
      id: 2002,
      name: 'หนีไป',
      artistId: 3001,
      albumIds: [4001],
      likes: 1500,
      duration: 221,
      imageUrl: 'assets/images/SongImage/หนีไป.jpg',
      lyrics: '',
      songAsset:
          'assets/music/electric.neon.lamp - หนีไป [Official Lyric Video].mp3',
      videoAsset: 'assets/reels/enl_nee_pai_lyric.mp4'),
  Song(
      id: 2003,
      name: 'แม้',
      artistId: 3001,
      albumIds: [4001],
      likes: 9900,
      duration: 218,
      imageUrl: 'assets/images/SongImage/แม้.jpg',
      lyrics: '',
      songAsset:
          'assets/music/electric.neon.lamp - แม้  [Official Lyric Video].mp3',
      videoAsset: 'assets/reels/enl_mae_lyric.mp4'),
  Song(
      id: 2004,
      name: 'Best Friend',
      artistId: 3002,
      albumIds: [4002],
      likes: 2000,
      duration: 263,
      imageUrl: 'assets/images/SongImage/Best Friend.jpg',
      lyrics: '',
      songAsset:
          'assets/music/Rex Orange County - Best Friend (Official Audio).mp3',
      videoAsset: ''),
  Song(
      id: 2005,
      name: 'Sunflower',
      artistId: 3002,
      albumIds: [4002],
      likes: 1500,
      duration: 253,
      imageUrl: 'assets/images/SongImage/Sunflower.jpg',
      lyrics: '',
      songAsset:
          'assets/music/Rex Orange County - Sunflower (Official Audio).mp3',
      videoAsset: 'assets/reels/roc_sunflower_audio.mp4'),
  Song(
      id: 2006,
      name: 'Television-so far so good',
      artistId: 3002,
      albumIds: [4002],
      likes: 9900,
      duration: 263,
      imageUrl: 'assets/images/SongImage/Television-so far so good.jpg',
      lyrics: '',
      songAsset:
          'assets/music/Rex Orange County - Television So Far So Good.mp3',
      videoAsset: ''),
  Song(
      id: 2007,
      name: 'ผ่าน',
      artistId: 3003,
      albumIds: [4003,4100],
      likes: 2000,
      duration: 242,
      imageUrl: 'assets/images/SongImage/ผ่าน.jpg',
      lyrics: '',
      songAsset: 'assets/music/Slot Machine - ผ่าน (Official Lyric Video).mp3',
      videoAsset: 'assets/reels/sm_parn_lyric.mp4'),
  Song(
      id: 2008,
      name: 'คำสุดท้าย',
      artistId: 3003,
      albumIds: [4003,4100],
      likes: 1500,
      duration: 253,
      imageUrl: 'assets/images/SongImage/คำสุดท้าย.jpg',
      lyrics: '',
      songAsset:
          'assets/music/Slot Machine - คำสุดท้าย (Official Lyric Video).mp3',
      videoAsset: 'assets/reels/sm_kum_sudtai_lyric.mp4'),
  Song(
      id: 2009,
      name: 'สิ่งหนึ่งในใจ',
      artistId: 3003,
      albumIds: [4003,4100],
      likes: 9900,
      duration: 235,
      imageUrl: 'assets/images/SongImage/สิ่งหนึ่งในใจ.jpg',
      lyrics: '',
      songAsset:
          'assets/music/Slot Machine - สิ่งหนึ่งในใจ (Official Lyric Video).mp3',
      videoAsset: ''),
  Song(
      id: 2010,
      name: 'เพื่อนรัก',
      artistId: 3004,
      albumIds: [4100],
      likes: 2000,
      duration: 290,
      imageUrl: 'assets/images/SongImage/เพื่อนรัก.jpg',
      lyrics: '',
      songAsset: 'assets/music/The Parkinson - เพื่อนรัก (Dear Friend).mp3',
      videoAsset: 'assets/reels/tp_dear_friend.mp4'),
  Song(
      id: 2011,
      name: 'จะบอกเธอว่ารัก',
      artistId: 3004,
      albumIds: [4100],
      likes: 1500,
      duration: 252,
      imageUrl: 'assets/images/SongImage/จะบอกเธอว่ารัก.jpg',
      lyrics: '',
      songAsset:
          'assets/music/The Parkinson - จะบอกเธอว่ารัก (Tell Her That I love).mp3',
      videoAsset: 'assets/reels/tp_tell_her_love.mp4'),
  Song(
      id: 2012,
      name: 'คนชั่ว 2018',
      artistId: 3004,
      albumIds: [4100],
      likes: 9900,
      duration: 235,
      imageUrl: 'assets/images/SongImage/คนชั่ว 2018.jpg',
      lyrics: '',
      songAsset: 'assets/music/The Parkinson - คนชั่ว 2018.mp3',
      videoAsset: 'assets/reels/tp_kon_chua_2018.mp4'),
];

final List<Playlist> playlists = [
  Playlist(
      id: 5000,
      name: 'เพลงที่ชอบ',
      songIds: [
        2001,
        2002,
        2003,
        2004,
        2005,
        2006,
        2007,
        2008,
        2009,
        2010,
        2011,
        2012,
      ],
      track: '50 แทร็ค',
      userId: 1,
      imageUrl: 'assets/images/Playlist/like.jpg',
      auto: true),
  Playlist(
      id: 5001,
      name: 'เพลย์ลิสต์ฮิต',
      songIds: [2001, 2002, 2003],
      track: '50 แทร็ค',
      imageUrl: 'assets/images/placeholder.png',
      userId: 1),
  Playlist(
      id: 5002,
      name: 'รวมเพลงเศร้า',
      songIds: [2004, 2005, 2006],
      track: '84 แทร็ค',
      imageUrl: 'assets/images/placeholder.png',
      userId: 1),
  Playlist(
      id: 5003,
      name: 'เพลงใหม่ล่าสุด',
      songIds: [2007, 2008, 2009],
      track: '30 เพลง',
      imageUrl: 'assets/images/placeholder.png',
      userId: 1),
];

final List<Genre> genres = [
  Genre(id: 801, name: 'Pop', imageUrl: 'assets/images/Genre/pop.jpg'),
  Genre(id: 802, name: 'Hip-Hop', imageUrl: 'assets/images/Genre/hiphop.jpg'),
  Genre(id: 803, name: 'Rock', imageUrl: 'assets/images/Genre/rock.jpg'),
  Genre(id: 804, name: 'Jazz', imageUrl: 'assets/images/Genre/jazz.jpg'),
];

// เพิ่มรายการหมวดหมู่เพลง
List<String> categoryTitles = [
  'เพลงไทย',
  'โรแมนติก',
  'Thai Rock',
  'รู้สึกดี',
  'Thai Pop',
  'ตัวช่วยปลุกพลัง',
  'กลุ่ม',
  'เศร้า',
  'ยุค 2010',
  'ผ่อนคลาย',
  'ยุค 2000',
  'เพลงพื้นบ้านและดั้งเดิม',
  'ออกกำลังกาย',
  'การเดินทาง',
  'ลูกทุ่ง',
  'จดจ่อ',
  'K-Pop',
  'อินโดนีเซีย',
  'ฮิปฮอปเกาหลี',
  'แจ๊ส',
  'ป๊อป',
  'เพลงประกอบภาพยนต์และ...',
  'อินดี้และอัลเทอร์เนทีฟ',
  'บอลลีวูดและอินเดีย',
  'นอน',
  'เจ-ป๊อป',
  'อาร์แอนด์บีและโซล',
  'เมทัล',
  'แมนโดป๊อปและแคนโทป๊อป',
  'เจแร๊ป',
  'ครอบครัว',
  'ร็อค',
  'คลาสสิค',
  'อิรัก',
  'เรกเก้และแคริบเบียน',
  'บริติชแร๊ป',
  'ยุค 1970',
  'อาหรับ',
  'บลูส์',
  'ยุค 1960',
  'ฮิปฮอปฝรั่งเศศ',
  'แอฟริกา',
  'คันทรีและอเมริกานา',
  'ฮิปฮอปเยอรมัน',
  'ยุค 1950',
  'ละติน',
  'ยุค 1990',
  'ฮิปฮอปบราซิล',
  'ฮิปฮอปสเปน',
  'ฮิปฮอปอาหรับ',
  'ฮิปฮอปตุรกี',
  'Rock an Español',
  'ยุค 1980'
];

// ข้อมูลจำลอง
final List<Map<String, dynamic>> mockData = [
  ...users.map((user) => {
        'type': 'user',
        'name': user.name,
        'imageUrl': user.imageUrl,
        'profilebackgroundUrl': user.profilebackgroundUrl,
        'id': user.id,
        'status': user.status,
      }),
  ...artists.map((artist) => {
        'type': 'artist',
        'name': artist.name,
        'imageUrl': artist.imageUrl,
        'followers': artist.followers,
        'id': artist.id,
        'profileBackgroundUrl': artist.profileBackgroundUrl
      }),
  ...albums.map((album) => {
        'type': 'album',
        'id': album.id.toString(),
        'albumTitle': album.name,
        'albumType': album.albumType,
        'artistName': album.artistName,
        'imageUrl': album.imageUrl
      }),
  ...songs.map((song) => {
        'type': 'song',
        'id': song.id,
        'name': song.name,
        'artistId': song.artistId,
        'albumIds': song.albumIds,
        'likes': song.likes,
        'duration': song.duration,
        'imageUrl': song.imageUrl,
        'songAsset': song.songAsset,
        'videoAsset': song.videoAsset,
      }),
  ...playlists.map((playlist) => {
        'type': 'playlist',
        'name': playlist.name,
        'songIds': playlist.songIds,
        'track': playlist.track,
        'imageUrl': playlist.imageUrl,
        'id': playlist.id,
      }),
  ...genres.map((genre) =>
      {'type': 'genre', 'name': genre.name, 'imageUrl': genre.imageUrl}),
  {'type': 'categoryTitles', 'titles': categoryTitles},
];
List<Map<String, dynamic>> getSongs() {
  return mockData.where((item) => item['type'] == 'song').toList();
}

List<Map<String, dynamic>> getArtists() {
  return mockData.where((item) => item['type'] == 'artist').toList();
}

Future<void> saveUsersToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> userJsonList =
      users.map((user) => jsonEncode(user.toJson())).toList();
  await prefs.setStringList('users', userJsonList);
}

Future<void> loadUsersFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? userJsonList = prefs.getStringList('users');
  if (userJsonList != null) {
    users = userJsonList
        .map((userJson) => User.fromJson(jsonDecode(userJson))) // ✅ decode ก่อน
        .toList();
  }
}
