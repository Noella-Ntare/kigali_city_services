import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _locationNotifications = false;

  bool get locationNotifications => _locationNotifications;

  SettingsProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _locationNotifications = prefs.getBool('locationNotifications') ?? false;
    notifyListeners();
  }

  Future<void> toggleLocationNotifications() async {
    _locationNotifications = !_locationNotifications;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationNotifications', _locationNotifications);
    notifyListeners();
  }
}
