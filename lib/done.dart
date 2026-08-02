import 'package:shared_preferences/shared_preferences.dart';

/// Which levels have been solved, and with how little chalk.
///
/// Keyed on the level's name rather than its number, so putting a new level in
/// the middle of the list does not hand somebody else's record to a puzzle
/// they have never seen.
class Done {
  Done(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'done.';

  static String _key(String level) => '$_prefix$level';

  bool has(String level) => chalkFor(level) != null;

  /// The least chalk this level has been solved with, or null if it has not.
  double? chalkFor(String level) => _prefs.getDouble(_key(level));

  int get count =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a win, and says whether it was the tidiest one yet.
  Future<bool> record(String level, double chalk) async {
    final before = chalkFor(level);
    if (before != null && before <= chalk) return false;
    await _prefs.setDouble(_key(level), chalk);
    return true;
  }
}
