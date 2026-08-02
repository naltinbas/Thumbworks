import 'package:shared_preferences/shared_preferences.dart';

/// The fewest guesses each lock has been picked in.
///
/// Keyed on the board's name rather than its place in the list, so putting a
/// new lock in the middle does not hand somebody else's record to one they
/// have never opened.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'best.';

  static String _key(String board) => '$_prefix$board';

  /// The fewest guesses this lock has been opened in, or null.
  int? guessesFor(String board) => _prefs.getInt(_key(board));

  bool has(String board) => guessesFor(board) != null;

  int get opened =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down an opening, and says whether it beat what was there.
  Future<bool> record(String board, int guesses) async {
    final before = guessesFor(board);
    if (before != null && before <= guesses) return false;
    await _prefs.setInt(_key(board), guesses);
    return true;
  }
}
