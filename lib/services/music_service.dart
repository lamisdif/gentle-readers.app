import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;
  static bool _isInitialized = false;

  // Load saved preference
  static Future<void> loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getBool('music_enabled') ?? true; // Default ON
      _isPlaying = savedState;
      _isInitialized = true;
      
      if (_isPlaying) {
        await _playInternal();
      }
    } catch (e) {
      print('Error loading music preference: $e');
      _isPlaying = true;
      _isInitialized = true;
    }
  }

  static Future<void> _playInternal() async {
    try {
      await _player.play(AssetSource('music/background.mp3'));
      _player.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    } catch (e) {
      print('Music play error: $e');
    }
  }

  static Future<void> play() async {
    if (!_isInitialized) {
      await loadPreference();
    }
    if (!_isPlaying) {
      await _playInternal();
      await _savePreference(true);
    }
  }

  static Future<void> stop() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
      await _savePreference(false);
    }
  }

  static Future<void> toggle() async {
    if (_isPlaying) {
      await stop();
    } else {
      await play();
    }
  }

  static Future<void> _savePreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', enabled);
    } catch (e) {
      print('Error saving music preference: $e');
    }
  }

  static bool get isPlaying => _isPlaying;
}