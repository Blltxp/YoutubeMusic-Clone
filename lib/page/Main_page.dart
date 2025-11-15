// ignore_for_file: file_names, prefer_const_constructors, unused_field, empty_catches, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../mock_database.dart';
import '../provider/NowPlayingProvider.dart';
import 'Explore_page.dart';
import 'From_directory.dart';
import 'Reels_page.dart';
import 'Home_page.dart';
import 'Library_page.dart';
import 'List_download.dart';
import 'Upgrade_page.dart';
import 'SongPlaying_page.dart';
import '../class/card_class/MiniPlayer.dart';

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class MainPage extends StatefulWidget {
  final User currentUser;
  const MainPage({super.key, required this.currentUser});

  static final GlobalKey<MainPageState> mainPageStateKey =
      GlobalKey<MainPageState>();

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late int _selectedLibraryPageIndex;
  final ScrollController _homeController = ScrollController();
  final ScrollController _exploreController = ScrollController();
  final ScrollController _libraryController = ScrollController();
  late final List<Widget> _pages;
  String? nowPlayingImage;
  String? nowPlayingTitle;
  String? nowPlayingArtist;
  bool isPlaying = false;
  Song? currentSong;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PageController _pageController = PageController();
  int _currentIndex = 0;

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    nowPlayingTitle = 'ไม่มีเพลงที่กำลังเล่น';

    // สร้างรายการหน้าตามสถานะของ user
    if (widget.currentUser.status == UserStatus.premium) {
      _pages = [
        HomePage(controller: _homeController, user: widget.currentUser),
        const ReelPage(),
        ExplorePage(controller: _exploreController),
        LibraryPage(controller: _libraryController),
        //ListDownloadPage(),
        //FromDirectoryPage(),
      ];
      _selectedLibraryPageIndex = 4;
    } else {
      _pages = [
        HomePage(controller: _homeController, user: widget.currentUser),
        const ReelPage(),
        ExplorePage(controller: _exploreController),
        const UpgradePage(),
        LibraryPage(controller: _libraryController),
        ListDownloadPage(),
        FromDirectoryPage(),
      ];
      _selectedLibraryPageIndex = 4;
    }

    // ฟังการเปลี่ยนสถานะการเล่น
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });

    // ฟังการเปลี่ยนเพลง
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && mounted && index < songs.length) {
        setState(() {
          currentSong = songs[index];
          nowPlayingTitle = currentSong!.name;
          nowPlayingArtist = artists
              .firstWhere(
                (artist) => artist.id == currentSong!.artistId,
                orElse: () => Artist(
                    id: 0,
                    name: '',
                    followers: 0,
                    imageUrl: '',
                    profileBackgroundUrl: ''),
              )
              .name;
          nowPlayingImage = currentSong!.imageUrl;
        });
      }
    });
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  void _onNavItemTapped(int index) {
    final bool isPremium = widget.currentUser.status == UserStatus.premium;
    final int libraryNavTabGastronomic = isPremium ? 3 : 4;
    final int mainLibraryViewPageIndex = isPremium ? 3 : 4;
    // เก็บค่า index เดิมไว้
    final previousIndex = _selectedIndex;

    // จัดการการเปลี่ยนแปลง UI ก่อน
    if (_selectedIndex == index) {
      if (index == libraryNavTabGastronomic) {
        if (_selectedLibraryPageIndex == mainLibraryViewPageIndex) {
          if (_libraryController.hasClients && _libraryController.offset == 0) {
            _showLibraryOptions();
          } else if (_libraryController.hasClients) {
            _libraryController.animateTo(0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut);
          } else {
            _showLibraryOptions();
          }
        } else {
          _showLibraryOptions();
        }
      } else {
        switch (index) {
          case 0:
            if (_homeController.hasClients) {
              _homeController.animateTo(0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut);
            }
            break;
          case 1:
            break;
          case 2:
            if (_exploreController.hasClients) {
              _exploreController.animateTo(0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut);
            }
            break;
        }
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    // จัดการกับการออกจากหน้า Reels
    if (previousIndex == 1 && index != 1) {
      // ใช้ Future.microtask เพื่อหลีกเลี่ยงการเรียก provider ระหว่าง build
      Future.microtask(() {
        if (!mounted) return;
        try {
          final provider =
              Provider.of<NowPlayingProvider>(context, listen: false);
          provider.exitReelsPage();
        } catch (e) {
          // ดักจับ Exception กรณีที่ widget ถูก deactivated
          print('Exception during exitReelsPage in _onNavItemTapped: $e');
        }
      });
    }

    // จัดการกับการเข้าสู่หน้า Reels
    if (previousIndex != 1 && index == 1) {
      Future.microtask(() {
        if (!mounted) return;
        try {
          final provider =
              Provider.of<NowPlayingProvider>(context, listen: false);
          provider.enterReelsPage();
        } catch (e) {
          // ดักจับ Exception กรณีที่ widget ถูก deactivated
          print('Exception during enterReelsPage in _onNavItemTapped: $e');
        }
      });
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  void _showLibraryOptions() {
    final isPremium = widget.currentUser.status == UserStatus.premium;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.zero,
        ),
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
            _buildLibraryOption(
                isPremium ? 3 : 4, 'คลังเพลง', Icons.library_music),
            _buildLibraryOption(
                isPremium ? 4 : 5, 'รายการที่ดาวน์โหลด', Icons.download),
            _buildLibraryOption(
                isPremium ? 5 : 6, 'ไฟล์จากอุปกรณ์', Icons.folder),
          ],
        );
      },
    );
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Widget _buildLibraryOption(
      int pageIndexOfPages, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: _selectedLibraryPageIndex == pageIndexOfPages
          ? const Icon(Icons.check, color: Colors.white)
          : null,
      onTap: () {
        if (_selectedLibraryPageIndex != pageIndexOfPages) {
          setState(() {
            _selectedLibraryPageIndex = pageIndexOfPages;
          });
        }
        Navigator.pop(context);
      },
    );
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  void _playSong(Song song) async {
    try {
      setState(() {
        currentSong = song;
        nowPlayingTitle = song.name;
        nowPlayingArtist = artists
            .firstWhere(
              (artist) => artist.id == song.artistId,
              orElse: () => Artist(
                  id: 0,
                  name: '',
                  followers: 0,
                  imageUrl: '',
                  profileBackgroundUrl: ''),
            )
            .name;
        nowPlayingImage = song.imageUrl;
      });

      // รีเซ็ตสถานะ Reels เมื่อเล่นเพลง
      final provider = Provider.of<NowPlayingProvider>(context, listen: false);
      if (provider.isInReelsPage) {
        Future.microtask(() {
          provider.exitReelsPage();
        });
      }

      await _audioPlayer.stop();
      await _audioPlayer.setAsset(song.songAsset);
      await _audioPlayer.play();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SongPlayingPage(
            song: song,
            initialPlaylist: songs,
            initialIndex: songs.indexOf(song),
          ),
        ),
      );
    } catch (e) {}
  }

  void _playNextSong() async {
    if (currentSong != null) {
      final currentIndex = songs.indexOf(currentSong!);
      if (currentIndex != -1 && songs.isNotEmpty) {
        final nextIndex = (currentIndex + 1) % songs.length;
        _playSong(songs[nextIndex]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPremium = widget.currentUser.status == UserStatus.premium;
    final int libraryNavTabGastronomic = isPremium ? 3 : 4;

    return Scaffold(
      key: MainPage.mainPageStateKey,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              // เก็บค่า index เดิมไว้ก่อนอัปเดต state
              final previousIndex = _selectedIndex;

              setState(() {
                _selectedIndex = index;
              });

              // จัดการการย้ายระหว่างหน้าด้วย Future.microtask ซึ่งจะทำงานหลังจากสร้าง frame เสร็จแล้ว
              // ช่วยป้องกันการเรียก setState ระหว่าง build
              Future.microtask(() {
                if (!mounted) return;

                // กำลังเปลี่ยนจากหน้า Reels ไปหน้าอื่น
                if (previousIndex == 1 && index != 1) {
                  try {
                    // ใช้ provider ด้วยความระมัดระวังเนื่องจาก Future.microtask ทำงานหลัง build
                    final provider =
                        Provider.of<NowPlayingProvider>(context, listen: false);
                    provider.exitReelsPage();
                  } catch (e) {
                    // ดักจับ Exception กรณีที่ widget ถูก deactivated
                    print('Exception during exitReelsPage: $e');
                  }
                }

                // กำลังเปลี่ยนไปหน้า Reels
                if (previousIndex != 1 && index == 1) {
                  try {
                    final provider =
                        Provider.of<NowPlayingProvider>(context, listen: false);
                    provider.enterReelsPage();
                  } catch (e) {
                    // ดักจับ Exception กรณีที่ widget ถูก deactivated
                    print('Exception during enterReelsPage: $e');
                  }
                }
              });
            },
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                NavBottomBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onNavItemTapped,
                  userStatus: widget.currentUser.status,
                ),
              ],
            ),
          ),
          if (currentSong != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up,
                          color: Colors.white),
                      onPressed: () {
                        if (currentSong != null) {
                          _playSong(currentSong!);
                        }
                      },
                    ),
                    if (nowPlayingImage != null && nowPlayingImage!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          nowPlayingImage!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey[700],
                                  child: Icon(Icons.music_note,
                                      color: Colors.white54)),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nowPlayingTitle ?? 'Not Playing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            nowPlayingArtist ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (_audioPlayer.processingState !=
                                ProcessingState.idle) {
                              if (isPlaying) {
                                _audioPlayer.pause();
                              } else {
                                _audioPlayer.play();
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.skip_next, color: Colors.white),
                          onPressed: () {
                            if (_audioPlayer.processingState !=
                                ProcessingState.idle) {
                              _playNextSong();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class NavBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final UserStatus userStatus;

  const NavBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.userStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final bool isIOS = platform == TargetPlatform.iOS;
    final double barHeight = isIOS ? 83 : 44; // สูงพอให้ hitbox ครอบเต็ม

    return Container(
      height: 60,
      color: Colors.grey[850],
      child: Row(
        children: [
          _buildDestination(
            index: 0,
            icon: MaterialSymbols.home_outline,
            selectedIcon: MaterialSymbols.home,
            label: 'หน้าแรก',
          ),
          _buildDestination(
            index: 1,
            icon: Ph.fast_forward,
            selectedIcon: Ph.fast_forward_fill,
            label: 'ลองฟัง',
          ),
          _buildDestination(
            index: 2,
            icon: MaterialSymbols.assistant_navigation_outline,
            selectedIcon: MaterialSymbols.assistant_navigation,
            label: 'สำรวจ',
          ),
          if (userStatus != UserStatus.premium)
            _buildDestination(
              index: 3,
              icon: MaterialSymbols.play_circle_outline,
              selectedIcon: MaterialSymbols.play_circle,
              label: 'อัปเกรด',
            ),
          _buildDestination(
            index: 4,
            icon: MaterialSymbols.library_music_outline_sharp,
            selectedIcon: MaterialSymbols.library_music,
            label: 'คลังเพลง',
          ),
        ],
      ),
    );
  }

  Widget _buildDestination({
    required int index,
    required String icon,
    required String selectedIcon,
    required String label,
  }) {
    final bool isSelected = index == selectedIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              isSelected ? selectedIcon : icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
