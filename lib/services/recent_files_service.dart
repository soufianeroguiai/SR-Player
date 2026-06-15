import 'package:shared_preferences/shared_preferences.dart';

class RecentFilesService {
  static const _key = 'recent_files';
  static const _maxItems = 20;

  static Future<void> add(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(path);
    list.insert(0, path);
    if (list.length > _maxItems) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  static Future<List<String>> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
