import 'package:shared_preferences/shared_preferences.dart';

/// The fewest goes each morning has been measured out in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a morning nobody has
/// worked.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'measured.';

  static String _key(String morning) => '$_prefix$morning';

  int? goesFor(String morning) => _prefs.getInt(_key(morning));

  bool has(String morning) => goesFor(morning) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a morning down, and says whether it beat what was there.
  Future<bool> record(String morning, int goes) async {
    final before = goesFor(morning);
    if (before != null && before <= goes) return false;
    await _prefs.setInt(_key(morning), goes);
    return true;
  }
}
