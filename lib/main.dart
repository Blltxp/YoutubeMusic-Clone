// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:youtubemusic_clone/page/Login_page.dart';
import 'package:youtubemusic_clone/page/History_Page.dart';
import 'package:youtubemusic_clone/page/Main_page.dart'; // เพิ่ม MainPage
import 'package:youtubemusic_clone/mock_database.dart'; // เพิ่ม mock_database
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'functions/audio_manager.dart';
import 'functions/lifecycle_event_handler.dart';
import 'provider/NowPlayingProvider.dart';
import 'provider/UserProvider.dart'; // <-- Import UserProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadUsersFromPrefs();
  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(
      detachedCallBack: () async {
        AudioManager().stop();
      },
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NowPlayingProvider()),
        ChangeNotifierProvider(
            create: (context) => UserProvider()), // <-- Add UserProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YoutubeMusic Clone',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.transparent,
        ),
      ),
      home: FutureBuilder<int?>(
        future: _getLoggedInUserId(), // เช็คสถานะล็อกอิน
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // รอสถานะ
          }

          if (snapshot.hasData && snapshot.data != null) {
            int userId = snapshot.data!;
            User loggedInUser =
                users.firstWhere((user) => user.id == userId, orElse: () {
              print(
                  "Error: Could not find user with id $userId in main.dart FutureBuilder. Logging out.");
              _logout(context);
              return users.first; // Return dummy user temporarily
            });

            if (loggedInUser.id == userId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<UserProvider>(context, listen: false)
                    .setUser(loggedInUser);
              });
              return MainPage(currentUser: loggedInUser);
            } else {
              return const LoginPage();
            }
          } else {
            return const LoginPage();
          }
        },
      ),
      initialRoute: '/',
      routes: {
        '/history': (context) => const HistoryPage(),
      },
    );
  }

  // ฟังก์ชันเช็คสถานะล็อกอิน
  Future<int?> _getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // ดึง userId ที่บันทึกไว้
  }

  // Added logout function for safety
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    // Use Provider to clear user state if context is available and mounted
    // We might not have a valid context here, depending on when FutureBuilder fails.
    // Consider handling this clear operation more robustly if needed.
    // Provider.of<UserProvider>(context, listen: false).clearUser();
  }
}
