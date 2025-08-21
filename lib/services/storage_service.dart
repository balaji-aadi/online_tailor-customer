import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zayyan/models/models.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _languageKey = 'selected_language';
  static const String _measurementsKey = 'user_measurements';
  static const String _ordersKey = 'user_orders';
  static const String _favoritesKey = 'favorite_tailors';
  static const String _notificationSettingsKey = 'notification_settings';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // User Management
  static Future<void> saveUser(User user) async {
    await init();
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getCurrentUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> clearUser() async {
    await init();
    await _prefs!.remove(_userKey);
  }

  static Future<bool> isUserLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Language Management
  static Future<void> setLanguage(String language) async {
    await init();
    await _prefs!.setString(_languageKey, language);
  }

  static Future<String> getLanguage() async {
    await init();
    return _prefs!.getString(_languageKey) ?? 'en';
  }

  // Measurements Management
  static Future<void> saveMeasurement(Measurement measurement) async {
    await init();
    final measurements = await getMeasurements();
    measurements.removeWhere((m) => m.id == measurement.id);
    measurements.add(measurement);
    
    final measurementsJson = measurements.map((m) => m.toJson()).toList();
    await _prefs!.setString(_measurementsKey, jsonEncode(measurementsJson));
  }

  static Future<List<Measurement>> getMeasurements() async {
    await init();
    final measurementsJson = _prefs!.getString(_measurementsKey);
    if (measurementsJson != null) {
      final List<dynamic> list = jsonDecode(measurementsJson);
      return list.map((json) => Measurement.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> deleteMeasurement(String measurementId) async {
    await init();
    final measurements = await getMeasurements();
    measurements.removeWhere((m) => m.id == measurementId);
    
    final measurementsJson = measurements.map((m) => m.toJson()).toList();
    await _prefs!.setString(_measurementsKey, jsonEncode(measurementsJson));
  }

  // Orders Management
  static Future<void> saveOrder(Order order) async {
    await init();
    final orders = await getOrders();
    orders.removeWhere((o) => o.id == order.id);
    orders.add(order);
    
    final ordersJson = orders.map((o) => o.toJson()).toList();
    await _prefs!.setString(_ordersKey, jsonEncode(ordersJson));
  }

  static Future<List<Order>> getOrders() async {
    await init();
    final ordersJson = _prefs!.getString(_ordersKey);
    if (ordersJson != null) {
      final List<dynamic> list = jsonDecode(ordersJson);
      return list.map((json) => Order.fromJson(json)).toList();
    }
    return [];
  }

  // Favorites Management
  static Future<void> toggleFavorite(String tailorId) async {
    await init();
    final favorites = await getFavorites();
    if (favorites.contains(tailorId)) {
      favorites.remove(tailorId);
    } else {
      favorites.add(tailorId);
    }
    await _prefs!.setStringList(_favoritesKey, favorites);
  }

  static Future<List<String>> getFavorites() async {
    await init();
    return _prefs!.getStringList(_favoritesKey) ?? [];
  }

  static Future<bool> isFavorite(String tailorId) async {
    final favorites = await getFavorites();
    return favorites.contains(tailorId);
  }

  // Notification Settings
  static Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    await init();
    await _prefs!.setString(_notificationSettingsKey, jsonEncode(settings));
  }

  static Future<Map<String, bool>> getNotificationSettings() async {
    await init();
    final settingsJson = _prefs!.getString(_notificationSettingsKey);
    if (settingsJson != null) {
      return Map<String, bool>.from(jsonDecode(settingsJson));
    }
    return {
      'orderUpdates': true,
      'promotions': false,
      'messages': true,
      'measurements': true,
    };
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await init();
    await _prefs!.clear();
  }
}