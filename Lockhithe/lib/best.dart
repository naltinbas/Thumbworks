import 'package:shared_preferences/shared_preferences.dart';

/// The cleanest each berth's crew has come through: askings used.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a berth
/// nobody has sailed. Sunk rounds write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'through.';

  static String _key(String berth) => '$_prefix$berth';

  int? askingsFor(String berth) => _prefs.getInt(_key(berth));

  bool has(String berth) => askingsFor(berth) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a crew's coming-through down, and says whether it beat what
  /// was there.
  Future<bool> record(String berth, int askings) async {
    final before = askingsFor(berth);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(berth), askings);
    return true;
  }
}
