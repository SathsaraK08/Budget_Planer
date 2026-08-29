import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static bool get isConfigured => _client != null && _isInitialized;
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase is not initialized. Please configure URL and Anon Key in Settings.');
    }
    return _client!;
  }

  static Future<bool> initializeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(AppConstants.keySupabaseUrl);
      final anonKey = prefs.getString(AppConstants.keySupabaseAnonKey);

      if (url != null && url.isNotEmpty && anonKey != null && anonKey.isNotEmpty) {
        await Supabase.initialize(url: url, anonKey: anonKey);
        _client = Supabase.instance.client;
        _isInitialized = true;
        return true;
      }
    } catch (e) {
      // Ignored if not configured yet
    }
    return false;
  }

  static Future<void> saveCredentials(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySupabaseUrl, url);
    await prefs.setString(AppConstants.keySupabaseAnonKey, anonKey);
    
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
    _isInitialized = true;
  }
}
