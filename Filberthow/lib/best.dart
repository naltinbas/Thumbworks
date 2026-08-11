import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each hoard has been won with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a hoard
/// nobody has emptied. Lost hoards write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'hoarded.';

  static String _key(String hoard) => '$_prefix$hoard';

  int? askingsFor(String hoard) => _prefs.getInt(_key(hoard));

  bool has(String hoard) => askingsFor(hoard) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a won hoard down, and says whether it beat what was there.
  Future<bool> record(String hoard, int askings) async {
    final before = askingsFor(hoard);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(hoard), askings);
    return true;
  }
}
