import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each peal has been rung with. Nought is the one to
/// have.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a tower nobody has
/// rung.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'rung.';

  static String _key(String peal) => '$_prefix$peal';

  int? hintsFor(String peal) => _prefs.getInt(_key(peal));

  bool has(String peal) => hintsFor(peal) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a peal down, and says whether it beat what was there.
  Future<bool> record(String peal, int hints) async {
    final before = hintsFor(peal);
    if (before != null && before <= hints) return false;
    await _prefs.setInt(_key(peal), hints);
    return true;
  }
}
