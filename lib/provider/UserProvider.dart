import 'package:flutter/material.dart';
import '../mock_database.dart'; // Import User class and UserStatus enum

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Function to set the current user after login or app start
  void setUser(User user) {
    if (_currentUser?.id != user.id) {
      // Avoid unnecessary notifications if user is the same
      _currentUser = user;
      print(
          "UserProvider: Set user to ${user.username} (Status: ${user.status})");
      notifyListeners(); // Notify widgets listening to this provider
    }
  }

  // Function to clear user on logout
  void clearUser() {
    if (_currentUser != null) {
      print("UserProvider: Clearing user");
      _currentUser = null;
      notifyListeners();
    }
  }

  // Helper to get status easily, defaults to normal if no user
  UserStatus get currentUserStatus => _currentUser?.status ?? UserStatus.normal;
}
