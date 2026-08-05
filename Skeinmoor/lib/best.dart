import 'package:shared_preferences/shared_preferences.dart';

/// Which boards have been filled, and how much help it took.
///
/// Kept as the number of times **Show me** was asked on the run that finished
/// it, because that is the only thing that varies: a board has one answer, so
/// finishing it is finishing it, and the question is only whether it was
/// found or fetched.
///
/// Keyed on the board's name rather than its place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a board they
/// have never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'done.';

  static String _key(String board) => '$_prefix$board';

  int? hintsFor(String board) => _prefs.getInt(_key(board));

  bool has(String board) => hintsFor(board) != null;

  bool alone(String board) => hintsFor(board) == 0;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a board, and says whether it beat what was there.
  Future<bool> record(String board, int hints) async {
    final before = hintsFor(board);
    if (before != null && before <= hints) return false;
    await _prefs.setInt(_key(board), hints);
    return true;
  }
}
