import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each tower has been raised home with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a tower
/// nobody has raised.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'raised.';

  static String _key(String tower) => '$_prefix$tower';

  int? movesFor(String tower) => _prefs.getInt(_key(tower));

  bool has(String tower) => movesFor(tower) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a homecoming down, and says whether it beat what was there.
  Future<bool> record(String tower, int moves) async {
    final before = movesFor(tower);
    if (before != null && before <= moves) return false;
    await _prefs.setInt(_key(tower), moves);
    return true;
  }
}
