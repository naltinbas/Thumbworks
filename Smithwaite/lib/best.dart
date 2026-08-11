import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each puzzle's bar has been freed on.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a puzzle nobody has
/// worked.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'freed.';

  static String _key(String puzzle) => '$_prefix$puzzle';

  int? movesFor(String puzzle) => _prefs.getInt(_key(puzzle));

  bool has(String puzzle) => movesFor(puzzle) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a freeing down, and says whether it beat what was there.
  Future<bool> record(String puzzle, int moves) async {
    final before = movesFor(puzzle);
    if (before != null && before <= moves) return false;
    await _prefs.setInt(_key(puzzle), moves);
    return true;
  }
}
