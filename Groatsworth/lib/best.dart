import 'package:shared_preferences/shared_preferences.dart';

/// The fewest coins each round has been counted out in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a round nobody has
/// paid.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'paid.';

  static String _key(String round) => '$_prefix$round';

  int? coinsFor(String round) => _prefs.getInt(_key(round));

  bool has(String round) => coinsFor(round) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a round down, and says whether it beat what was there.
  Future<bool> record(String round, int coins) async {
    final before = coinsFor(round);
    if (before != null && before <= coins) return false;
    await _prefs.setInt(_key(round), coins);
    return true;
  }
}
