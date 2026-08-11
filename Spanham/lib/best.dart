import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each shelf has been set with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a shelf
/// nobody has set. Stranded shelves write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'set.';

  static String _key(String level) => '$_prefix$level';

  int? askingsFor(String level) => _prefs.getInt(_key(level));

  bool has(String level) => askingsFor(level) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a set shelf down, and says whether it beat what was there.
  Future<bool> record(String level, int askings) async {
    final before = askingsFor(level);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(level), askings);
    return true;
  }
}
