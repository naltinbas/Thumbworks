import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each board has been finished in.
///
/// Keyed on the board's name rather than its place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a board they
/// have never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'moves.';

  static String _key(String board) => '$_prefix$board';

  int? movesFor(String board) => _prefs.getInt(_key(board));

  bool has(String board) => movesFor(board) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a board, and says whether it beat what was there.
  Future<bool> record(String board, int moves) async {
    final before = movesFor(board);
    if (before != null && before <= moves) return false;
    await _prefs.setInt(_key(board), moves);
    return true;
  }
}
