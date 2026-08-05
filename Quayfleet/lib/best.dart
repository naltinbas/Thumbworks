import 'package:shared_preferences/shared_preferences.dart';

/// The most ships each day has been worked up to.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a day nobody has
/// worked.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'berthed.';

  static String _key(String day) => '$_prefix$day';

  int? shipsFor(String day) => _prefs.getInt(_key(day));

  bool has(String day) => shipsFor(day) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a day down, and says whether it beat what was there. More ships is
  /// better here, which is the other way round from most of these games.
  Future<bool> record(String day, int ships) async {
    final before = shipsFor(day);
    if (before != null && before >= ships) return false;
    await _prefs.setInt(_key(day), ships);
    return true;
  }
}
