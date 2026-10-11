import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

class UserSession {
  UserSession._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const _kCurrentUserId = 'current_user_id';

  static Future<int?> getCurrentUserId() => _prefs.getInt(_kCurrentUserId);

  static Future<void> setCurrentUserId(int id) =>
      _prefs.setInt(_kCurrentUserId, id);

  static Future<void> clear() => _prefs.remove(_kCurrentUserId);

  static Future<User> signIn(String rawName) => _findOrCreateByName(rawName);

  static Future<User> loadCurrentUser({String? preferredName}) async {
    final db = DatabaseHelper.instance;

    final id = await getCurrentUserId();
    if (id != null) {
      final user = await db.getUserById(id);
      if (user != null) return user;
    }

    final name = preferredName?.trim() ?? '';
    if (name.isNotEmpty) {
      return _findOrCreateByName(name);
    }

    final users = await db.getUsers();
    if (users.isNotEmpty) {
      await setCurrentUserId(users.first.id!);
      return users.first;
    }

    return _findOrCreateByName('Aline Uwase', role: 'Project Lead');
  }

  static String displayNameFrom(String raw) {
    final words = raw
        .trim()
        .split(RegExp(r'[\s._-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase());
    final name = words.join(' ');
    return name.isEmpty ? 'User' : name;
  }

  static Future<User> _findOrCreateByName(
    String rawName, {
    String role = 'Project team member',
  }) async {
    final db = DatabaseHelper.instance;
    final displayName = displayNameFrom(rawName);

    final users = await db.getUsers();
    for (final user in users) {
      if (user.name.toLowerCase() == displayName.toLowerCase()) {
        await setCurrentUserId(user.id!);
        return user;
      }
    }

    final newId = await db.insertUser(User(name: displayName, role: role));
    await setCurrentUserId(newId);
    return User(id: newId, name: displayName, role: role);
  }
}
