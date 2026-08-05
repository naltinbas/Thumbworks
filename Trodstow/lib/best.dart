import 'package:shared_preferences/shared_preferences.dart';

/// The fewest yards each parish has been joined up on.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a parish nobody has
/// joined up.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'joined.';

  static String _key(String parish) => '$_prefix$parish';

  int? yardsFor(String parish) => _prefs.getInt(_key(parish));

  bool has(String parish) => yardsFor(parish) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a parish down, and says whether it beat what was there.
  Future<bool> record(String parish, int yards) async {
    final before = yardsFor(parish);
    if (before != null && before <= yards) return false;
    await _prefs.setInt(_key(parish), yards);
    return true;
  }
}
