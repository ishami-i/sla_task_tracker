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

  static Future<User> loadCurrentUser() async {
    final db = DatabaseHelper.instance;

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

    final fallback = User(name: 'Aline Uwase', role: 'Project Lead');
    final newId = await db.insertUser(fallback);
    await setCurrentUserId(newId);
    return User(id: newId, name: fallback.name, role: fallback.role);
  }
}