// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtubemusic_clone/mock_database.dart';
import 'package:youtubemusic_clone/page/Main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../provider/UserProvider.dart';
// import 'register_page.dart'; // No longer needed

// Enum for registration steps
enum RegistrationStep { initial, enterNameUsername, enterPassword, completed }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late VideoPlayerController _videoController;
  // Login form controllers
  final TextEditingController _loginUsernameController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  // Registration form controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController =
      TextEditingController();

  String? _errorTextLogin;
  String? _errorTextRegister;
  bool _isLoadingLogin = false;
  bool _isLoadingRegister = false;

  bool _showLoginForm = false;
  RegistrationStep _registrationStep = RegistrationStep.initial;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/clipArt/0508.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regUsernameController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoadingLogin = true;
      _errorTextLogin = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    String enteredUsername = _loginUsernameController.text.trim();
    String enteredPassword = _loginPasswordController.text;

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorTextLogin = 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน';
        _isLoadingLogin = false;
      });
      return;
    }

    User? matchedUser;
    try {
      matchedUser = users.firstWhere(
        (user) =>
            user.username == enteredUsername &&
            user.password == enteredPassword,
      );
    } catch (e) {
      matchedUser = null;
    }

    if (!mounted) return;

    if (matchedUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', matchedUser.id);

      context.read<UserProvider>().setUser(matchedUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(currentUser: matchedUser!),
        ),
      );
    } else {
      setState(() {
        _errorTextLogin = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
        _isLoadingLogin = false;
      });
    }
  }

  // --- Registration Logic ---
  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  void _proceedToPasswordStep() {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    String name = _regNameController.text.trim();
    String username = _regUsernameController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      setState(() {
        _errorTextRegister = 'กรุณากรอกชื่อและ Username';
      });
      return;
    }
    bool usernameExists = users
        .any((user) => user.username.toLowerCase() == username.toLowerCase());
    if (usernameExists) {
      setState(() {
        _errorTextRegister = 'ชื่อผู้ใช้นี้มีอยู่แล้ว';
      });
      return;
    }
    setState(() {
      _registrationStep = RegistrationStep.enterPassword;
      _errorTextRegister = null; // Clear previous error
    });
  }

  void _registerNewUser() async {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoadingRegister = true;
      _errorTextRegister = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    String name = _regNameController.text
        .trim(); // Already validated in previous step but keep for clarity
    String username = _regUsernameController.text.trim(); // Already validated
    String password = _regPasswordController.text;
    String confirmPassword = _regConfirmPasswordController.text;

    // Name and username should have been validated in _proceedToPasswordStep
    // But password fields are validated here
    if (password.isEmpty || confirmPassword.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorTextRegister = 'กรุณากรอกรหัสผ่านและยืนยันรหัสผ่าน';
        _isLoadingRegister = false;
      });
      return;
    }
    if (password != confirmPassword) {
      if (!mounted) return;
      setState(() {
        _errorTextRegister = 'รหัสผ่านไม่ตรงกัน';
        _isLoadingRegister = false;
      });
      return;
    }
    if (!_isPasswordValid(password)) {
      if (!mounted) return;
      setState(() {
        _errorTextRegister =
            'รหัสผ่านต้องมีอย่างน้อย 8 ตัว มีตัวพิมพ์ใหญ่ และตัวเลขอย่างน้อย 1 ตัว';
        _isLoadingRegister = false;
      });
      return;
    }

    User newUser = User(
      id: users.isEmpty
          ? 1
          : users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1,
      name: name,
      username: username,
      password: password,
      status: UserStatus.normal,
      imageUrl: 'assets/images/default_profile.png',
      profilebackgroundUrl: 'assets/images/default_background.png',
    );
    users.add(newUser);

    if (!mounted) return;
    setState(() {
      _isLoadingRegister = false;
      _registrationStep =
          RegistrationStep.initial; // Go back to initial buttons
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สมัครสมาชิกสำเร็จ! กรุณาลงชื่อเข้าใช้')),
      );
      _regNameController.clear();
      _regUsernameController.clear();
      _regPasswordController.clear();
      _regConfirmPasswordController.clear();
    });
  }
  // --- End Registration Logic ---

  Widget _buildVideoBackground() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController.value.size.width,
          height: _videoController.value.size.height,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(color: Colors.black.withOpacity(0.1));
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0, bottom: 40.0),
      child: Image.asset('assets/images/yt_music logo2.png', height: 60),
    );
  }

  Widget _buildInitialButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => setState(() => _showLoginForm = true),
            child: const Text('เข้าสู่ระบบ',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => setState(
                () => _registrationStep = RegistrationStep.enterNameUsername),
            child: const Text('สร้างบัญชีใหม่',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFormWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ลงชื่อเข้าใช้บัญชีของคุณ',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 25),
            TextField(
                controller: _loginUsernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8)),
                )),
            const SizedBox(height: 15),
            TextField(
                controller: _loginPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8)),
                )),
            const SizedBox(height: 20),
            if (_errorTextLogin != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(_errorTextLogin!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 14))),
            _isLoadingLogin
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _login,
                        child: const Text('เข้าสู่ระบบ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showLoginForm = false;
                  _errorTextLogin = null;
                  _isLoadingLogin = false;
                  _loginUsernameController.clear();
                  _loginPasswordController.clear();
                });
              },
              child: Text('← กลับ', style: TextStyle(color: Colors.grey[400])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationFormWidget() {
    List<Widget> formFields = [];
    String buttonText = "";
    VoidCallback onButtonPressed = () {};
    String titleText = "";

    if (_registrationStep == RegistrationStep.enterNameUsername) {
      titleText = "สร้างบัญชีใหม่";
      formFields.addAll([
        TextField(
            controller: _regNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'ชื่อ-นามสกุล',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 12),
        TextField(
            controller: _regUsernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Username (ชื่อผู้ใช้)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)))),
      ]);
      buttonText = "ถัดไป";
      onButtonPressed = _proceedToPasswordStep;
    } else if (_registrationStep == RegistrationStep.enterPassword) {
      titleText = "สร้างบัญชีใหม่";
      formFields.addAll([
        TextField(
            controller: _regPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Password (รหัสผ่าน)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 12),
        TextField(
            controller: _regConfirmPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Confirm Password (ยืนยันรหัสผ่าน)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8)))),
      ]);
      buttonText = "สมัครสมาชิก";
      onButtonPressed = _registerNewUser;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titleText,
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            ...formFields,
            const SizedBox(height: 15),
            if (_errorTextRegister != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(_errorTextRegister!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 14))),
            _isLoadingRegister
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: onButtonPressed,
                      child: Text(buttonText,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_registrationStep == RegistrationStep.enterPassword) {
                    _registrationStep =
                        RegistrationStep.enterNameUsername; // Go back to step 1
                    _errorTextRegister = null; // Clear errors from step 2
                    _regPasswordController.clear();
                    _regConfirmPasswordController.clear();
                  } else {
                    _registrationStep =
                        RegistrationStep.initial; // Go back to initial buttons
                    _errorTextRegister = null;
                    _isLoadingRegister = false;
                    _regNameController.clear();
                    _regUsernameController.clear();
                    _regPasswordController.clear();
                    _regConfirmPasswordController.clear();
                  }
                });
              },
              child: Text('← กลับ', style: TextStyle(color: Colors.grey[400])),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentFormWidget;
    if (_showLoginForm) {
      currentFormWidget = _buildLoginFormWidget();
    } else if (_registrationStep == RegistrationStep.enterNameUsername ||
        _registrationStep == RegistrationStep.enterPassword) {
      currentFormWidget = _buildRegistrationFormWidget();
    } else {
      // RegistrationStep.initial or completed
      currentFormWidget = _buildInitialButtons();
    }

    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure scaffold resizes
      body: Stack(
        children: [
          if (_videoController.value.isInitialized) _buildVideoBackground(),
          _buildOverlay(),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: isKeyboardVisible
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (!isKeyboardVisible)
                    _buildLogo(), // Show logo only if keyboard is not visible
                  currentFormWidget,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
