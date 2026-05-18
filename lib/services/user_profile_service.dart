import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  // Profile data
  String _name = 'Pengguna';
  String _city = '';
  String? _photoPath;
  String _occupation = '';

  // Settings
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  int _appOpenCount = 0;

  // Achievement unlock state
  bool _achievementPencatatRajin = false;
  bool _achievementPenabungHebat = false;
  bool _achievementHematMaster = false;
  bool _achievementKancilFan = false;

  // Getters
  String get name => _name;
  String get city => _city;
  String? get photoPath => _photoPath;
  String get occupation => _occupation;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get appOpenCount => _appOpenCount;
  bool get achievementPencatatRajin => _achievementPencatatRajin;
  bool get achievementPenabungHebat => _achievementPenabungHebat;
  bool get achievementHematMaster => _achievementHematMaster;
  bool get achievementKancilFan => _achievementKancilFan;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi ☀️';
    if (hour >= 11 && hour < 15) return 'Selamat siang 🌤️';
    if (hour >= 15 && hour < 18) return 'Selamat sore 🌇';
    return 'Selamat malam 🌙';
  }

  String get initials {
    if (_name.isEmpty) return 'S';
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name[0].toUpperCase();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? 'Pengguna';
    _city = prefs.getString('profile_city') ?? '';
    _photoPath = prefs.getString('profile_photo');
    _occupation = prefs.getString('profile_occupation') ?? '';
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _appOpenCount = prefs.getInt('app_open_count') ?? 0;
    _achievementPencatatRajin = prefs.getBool('ach_pencatat_rajin') ?? false;
    _achievementPenabungHebat = prefs.getBool('ach_penabung_hebat') ?? false;
    _achievementHematMaster = prefs.getBool('ach_hemat_master') ?? false;
    _achievementKancilFan = prefs.getBool('ach_kancil_fan') ?? false;

    // Increment app open count
    _appOpenCount++;
    await prefs.setInt('app_open_count', _appOpenCount);

    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? city,
    String? photoPath,
    String? occupation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _name = name;
      await prefs.setString('profile_name', name);
    }
    if (city != null) {
      _city = city;
      await prefs.setString('profile_city', city);
    }
    if (photoPath != null) {
      _photoPath = photoPath;
      await prefs.setString('profile_photo', photoPath);
    }
    if (occupation != null) {
      _occupation = occupation;
      await prefs.setString('profile_occupation', occupation);
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool val) async {
    _isDarkMode = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', val);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool val) async {
    _notificationsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    notifyListeners();
  }

  Future<void> checkAndUnlockAchievements({
    required int transactionDays,
    required bool balancePositive30Days,
    required bool expenseLowerThanIncome,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool changed = false;

    if (!_achievementPencatatRajin && transactionDays >= 7) {
      _achievementPencatatRajin = true;
      await prefs.setBool('ach_pencatat_rajin', true);
      changed = true;
    }
    if (!_achievementPenabungHebat && balancePositive30Days) {
      _achievementPenabungHebat = true;
      await prefs.setBool('ach_penabung_hebat', true);
      changed = true;
    }
    if (!_achievementHematMaster && expenseLowerThanIncome) {
      _achievementHematMaster = true;
      await prefs.setBool('ach_hemat_master', true);
      changed = true;
    }
    if (!_achievementKancilFan && _appOpenCount >= 5) {
      _achievementKancilFan = true;
      await prefs.setBool('ach_kancil_fan', true);
      changed = true;
    }

    if (changed) notifyListeners();
  }

  Future<String> detectCity() async {
    if (kIsWeb) return '';
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return '';
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      debugPrint(
        'Location detected: ${position.latitude}, ${position.longitude}',
      );
      return '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
    } catch (e) {
      debugPrint('Location error: $e');
      return '';
    }
  }

  Future<bool> requestLocationPermission() async {
    if (kIsWeb) return false;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }
}
