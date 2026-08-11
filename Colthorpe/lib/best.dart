import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each yard's round has been ridden with.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a yard nobody has
/// ridden. Unfinished rounds write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'ridden.';

  static String _key(String yard) => '$_prefix$yard';

  int? askingsFor(String yard) => _prefs.getInt(_key(yard));

  bool has(String yard) => askingsFor(yard) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a ridden round down, and says whether it beat what was there.
  Future<bool> record(String yard, int askings) async {
    final before = askingsFor(yard);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(yard), askings);
    return true;
  }
}
