import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionService {
  AuthSessionService._();

  static const String _userIdKey = 'auth_user_id';
  static const String _userDisplayNameKey = 'auth_user_display_name';
  static const String _userEmailKey = 'auth_user_email';
  static const String _userPhotoUrlKey = 'auth_user_photo_url';
  static const String _userAuthTypeKey = 'auth_user_type'; // 'google' or 'anonymous'

  static Future<void> saveUserSession(User user, String authType) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_userIdKey, user.uid),
      prefs.setString(
        _userDisplayNameKey,
        user.displayName ?? '',
      ),
      prefs.setString(_userEmailKey, user.email ?? ''),
      prefs.setString(_userPhotoUrlKey, user.photoURL ?? ''),
      prefs.setString(_userAuthTypeKey, authType),
    ]);
  }

  static Future<Map<String, String?>?> getLastUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    if (userId == null || userId.isEmpty) {
      return null;
    }

    return {
      'uid': userId,
      'displayName': prefs.getString(_userDisplayNameKey),
      'email': prefs.getString(_userEmailKey),
      'photoUrl': prefs.getString(_userPhotoUrlKey),
      'authType': prefs.getString(_userAuthTypeKey),
    };
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_userIdKey),
      prefs.remove(_userDisplayNameKey),
      prefs.remove(_userEmailKey),
      prefs.remove(_userPhotoUrlKey),
      prefs.remove(_userAuthTypeKey),
    ]);
  }
}
