import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each watch has been set with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a watch
/// nobody has set. The short ring writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'watched.';

  static String _key(String watch) => '$_prefix$watch';

  int? askingsFor(String watch) => _prefs.getInt(_key(watch));

  bool has(String watch) => askingsFor(watch) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a full watch down, and says whether it beat what was there.
  Future<bool> record(String watch, int askings) async {
    final before = askingsFor(watch);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(watch), askings);
    return true;
  }
}
