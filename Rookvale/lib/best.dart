import 'package:shared_preferences/shared_preferences.dart';

/// Which puzzles have been finished, and which were finished unaided.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'done.';

  static String _key(String puzzle) => '$_prefix$puzzle';

  /// Nought for not yet, one for finished, two for finished first time
  /// through without taking anything back or being shown.
  int standingOn(String puzzle) => _prefs.getInt(_key(puzzle)) ?? 0;

  bool has(String puzzle) => standingOn(puzzle) > 0;
  bool isClean(String puzzle) => standingOn(puzzle) > 1;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a finish, and says whether it is the first clean one.
  ///
  /// With one way through, finishing is only half of it: the question is
  /// whether the way through was found or stumbled into after a few goes.
  Future<bool> record(String puzzle, {required bool clean}) async {
    final was = standingOn(puzzle);
    final now = clean ? 2 : 1;
    if (now <= was) return false;
    await _prefs.setInt(_key(puzzle), now);
    return now == 2;
  }
}
