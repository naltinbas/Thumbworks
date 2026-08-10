import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each round has been won in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a round nobody has
/// played. The round that cannot be won never gets a number, which is right.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'won.';

  static String _key(String round) => '$_prefix$round';

  int? movesFor(String round) => _prefs.getInt(_key(round));

  bool has(String round) => movesFor(round) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a round down, and says whether it beat what was there.
  Future<bool> record(String round, int moves) async {
    final before = movesFor(round);
    if (before != null && before <= moves) return false;
    await _prefs.setInt(_key(round), moves);
    return true;
  }
}
