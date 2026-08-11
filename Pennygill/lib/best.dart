import 'package:shared_preferences/shared_preferences.dart';

/// The cleanest each table's match has been taken: rounds the house got.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a table
/// nobody has beaten. Lost matches write nothing, and on the crooked
/// tables a win is luck, but luck gets written down too.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'won.';

  static String _key(String wager) => '$_prefix$wager';

  int? concededFor(String wager) => _prefs.getInt(_key(wager));

  bool has(String wager) => concededFor(wager) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a taken match down, and says whether it beat what was there.
  Future<bool> record(String wager, int conceded) async {
    final before = concededFor(wager);
    if (before != null && before <= conceded) return false;
    await _prefs.setInt(_key(wager), conceded);
    return true;
  }
}
