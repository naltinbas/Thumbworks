import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each web has been woven well with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a web
/// nobody has woven. The first thread writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'woven.';

  static String _key(String web) => '$_prefix$web';

  int? askingsFor(String web) => _prefs.getInt(_key(web));

  bool has(String web) => askingsFor(web) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a well-woven web down, and says whether it beat what was
  /// there.
  Future<bool> record(String web, int askings) async {
    final before = askingsFor(web);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(web), askings);
    return true;
  }
}
