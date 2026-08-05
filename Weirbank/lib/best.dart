import 'package:shared_preferences/shared_preferences.dart';

/// Which works have been set, and in how few turns of a pipe.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a works they have
/// never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'set.';

  static String _key(String works) => '$_prefix$works';

  int? turnsFor(String works) => _prefs.getInt(_key(works));

  bool has(String works) => turnsFor(works) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a works, and says whether it beat what was there.
  Future<bool> record(String works, int turns) async {
    final before = turnsFor(works);
    if (before != null && before <= turns) return false;
    await _prefs.setInt(_key(works), turns);
    return true;
  }
}
