import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each moor has been set with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a moor
/// nobody has set. Stranded moors write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'milled.';

  static String _key(String moor) => '$_prefix$moor';

  int? askingsFor(String moor) => _prefs.getInt(_key(moor));

  bool has(String moor) => askingsFor(moor) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a set moor down, and says whether it beat what was there.
  Future<bool> record(String moor, int askings) async {
    final before = askingsFor(moor);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(moor), askings);
    return true;
  }
}
