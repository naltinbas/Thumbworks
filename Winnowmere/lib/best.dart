import 'package:shared_preferences/shared_preferences.dart';

/// The fewest comparators each puzzle has been sorted with.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a puzzle they have
/// never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'sifted.';

  static String _key(String puzzle) => '$_prefix$puzzle';

  int? crossesFor(String puzzle) => _prefs.getInt(_key(puzzle));

  bool has(String puzzle) => crossesFor(puzzle) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a puzzle, and says whether it beat what was there.
  Future<bool> record(String puzzle, int crosses) async {
    final before = crossesFor(puzzle);
    if (before != null && before <= crosses) return false;
    await _prefs.setInt(_key(puzzle), crosses);
    return true;
  }
}
