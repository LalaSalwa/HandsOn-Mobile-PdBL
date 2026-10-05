import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.isEmpty || password.isEmpty) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'eyJhbGciOi-PALSU-$email');
    return true;
  }
}
