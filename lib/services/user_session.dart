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

  static Future<User> loadCurrentUser({String? preferredName}) async {
    final db = DatabaseHelper.instance;

    final name = preferredName?.trim() ?? '';
    if (name.isNotEmpty) {
      return _findOrCreateByName(name);
    }

    final id = await getCurrentUserId();
    if (id != null) {
      final user = await db.getUserById(id);
      if (user != null) return user;
    }

    final users = await db.getUsers();
    if (users.isNotEmpty) {
      await setCurrentUserId(users.first.id!);
      return users.first;
    }

    return _findOrCreateByName('Aline Uwase', role: 'Project Lead');
  }

  static Future<User> _findOrCreateByName(
    String name, {
    String role = 'Project team member',
  }) async {
    final db = DatabaseHelper.instance;

    final users = await db.getUsers();
    for (final user in users) {
      if (user.name.toLowerCase() == name.toLowerCase()) {
        await setCurrentUserId(user.id!);
        return user;
      }
    }

    final displayName = name[0].toUpperCase() + name.substring(1);
    final newId = await db.insertUser(User(name: displayName, role: role));
    await setCurrentUserId(newId);
    return User(id: newId, name: displayName, role: role);
  }
}