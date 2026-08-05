import 'package:shared_preferences/shared_preferences.dart';

/// The most work each day at the fair has been covered with.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a day nobody has
/// worked.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'hired.';

  static String _key(String day) => '$_prefix$day';

  int? coveredFor(String day) => _prefs.getInt(_key(day));

  bool has(String day) => coveredFor(day) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a day down, and says whether it beat what was there. More work
  /// covered is better here, which is the other way round from most of these
  /// games.
  Future<bool> record(String day, int covered) async {
    final before = coveredFor(day);
    if (before != null && before >= covered) return false;
    await _prefs.setInt(_key(day), covered);
    return true;
  }
}
