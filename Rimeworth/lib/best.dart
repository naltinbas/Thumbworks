import 'package:shared_preferences/shared_preferences.dart';

/// The fewest runs each parish has been salted in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a parish they have
/// never driven.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'salted.';

  static String _key(String parish) => '$_prefix$parish';

  int? runsFor(String parish) => _prefs.getInt(_key(parish));

  bool has(String parish) => runsFor(parish) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a parish, and says whether it beat what was there.
  Future<bool> record(String parish, int runs) async {
    final before = runsFor(parish);
    if (before != null && before <= runs) return false;
    await _prefs.setInt(_key(parish), runs);
    return true;
  }
}
