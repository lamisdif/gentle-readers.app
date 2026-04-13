import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool get isLoggedIn {
    final session = SupabaseConfig.client.auth.currentSession;
    return session != null;
  }

  User? get currentUser {
    return SupabaseConfig.client.auth.currentUser;
  }

  Future<void> logout() async {
    await SupabaseConfig.client.auth.signOut();
  }
}