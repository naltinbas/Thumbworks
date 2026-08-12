import 'package:shared_preferences/shared_preferences.dart';

/// The fewest flips each yard's crowning has come in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// yard nobody has flipped. The two kings write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'crowned.';

  static String _key(String yard) => '$_prefix$yard';

  int? flipsFor(String yard) => _prefs.getInt(_key(yard));

  bool has(String yard) => flipsFor(yard) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a crowning down, and says whether it beat what was there.
  Future<bool> record(String yard, int flips) async {
    final before = flipsFor(yard);
    if (before != null && before <= flips) return false;
    await _prefs.setInt(_key(yard), flips);
    return true;
  }
}
