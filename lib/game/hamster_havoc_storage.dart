import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'hamster_havoc_state.dart';

class HamsterHavocStorage {
  static const String _key = 'hamster_havoc_progress';

  static Future<void> saveProgress(ProgressState progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(progress.toJson());
      await prefs.setString(_key, json);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  static Future<ProgressState> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return ProgressState();
      
      final data = jsonDecode(json) as Map<String, dynamic>;
      final progress = ProgressState();
      progress.load(data);
      return progress;
    } catch (e) {
      print('Error loading progress: $e');
      return ProgressState();
    }
  }
}
