import 'package:shared_preferences/shared_preferences.dart';

/// Which rounds have been won, and which have been won without a slip.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'won.';

  static String _key(String round) => '$_prefix$round';

  /// Whether this round has been won, and whether it was ever won without
  /// giving it away first. Nought for not yet, one for won, two for clean.
  int standingOn(String round) => _prefs.getInt(_key(round)) ?? 0;

  bool has(String round) => standingOn(round) > 0;
  bool isClean(String round) => standingOn(round) > 1;

  int get won =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a round, and says whether it is the first clean win.
  ///
  /// Winning is the easy half. Every round starts winnable, so the thing
  /// worth keeping is whether it was won without ever handing it back.
  Future<bool> record(String round, {required bool win, required int wrong}) async {
    if (!win) return false;
    final was = standingOn(round);
    final now = wrong == 0 ? 2 : 1;
    if (now <= was) return false;
    await _prefs.setInt(_key(round), now);
    return now == 2;
  }
}
