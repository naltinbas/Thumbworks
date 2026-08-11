import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each ruler has been cut with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a ruler
/// nobody has notched. The perfect ten writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'notched.';

  static String _key(String cut) => '$_prefix$cut';

  int? askingsFor(String cut) => _prefs.getInt(_key(cut));

  bool has(String cut) => askingsFor(cut) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a cut ruler down, and says whether it beat what was there.
  Future<bool> record(String cut, int askings) async {
    final before = askingsFor(cut);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(cut), askings);
    return true;
  }
}
