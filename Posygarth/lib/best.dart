import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each garth has bloomed with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a garth
/// nobody has planted. Stranded garths write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'bloomed.';

  static String _key(String garth) => '$_prefix$garth';

  int? askingsFor(String garth) => _prefs.getInt(_key(garth));

  bool has(String garth) => askingsFor(garth) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a bloomed garth down, and says whether it beat what was
  /// there.
  Future<bool> record(String garth, int askings) async {
    final before = askingsFor(garth);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(garth), askings);
    return true;
  }
}
