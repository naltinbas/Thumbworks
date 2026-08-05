import 'package:shared_preferences/shared_preferences.dart';

/// Which boxes have been packed, and how much help it took.
///
/// Kept as the number of times **Show me** was asked on the run that finished
/// it, because that is the only thing that varies: a box has one packing, so
/// finishing it is finishing it, and the question is only whether it was
/// worked out or fetched.
///
/// Keyed on the puzzle's name rather than its place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a puzzle
/// they have never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'packed.';

  static String _key(String puzzle) => '$_prefix$puzzle';

  int? hintsFor(String puzzle) => _prefs.getInt(_key(puzzle));

  bool has(String puzzle) => hintsFor(puzzle) != null;

  bool alone(String puzzle) => hintsFor(puzzle) == 0;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a puzzle, and says whether it beat what was there.
  Future<bool> record(String puzzle, int hints) async {
    final before = hintsFor(puzzle);
    if (before != null && before <= hints) return false;
    await _prefs.setInt(_key(puzzle), hints);
    return true;
  }
}
