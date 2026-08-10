import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each yard has been worked in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a yard nobody has
/// worked.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'home.';

  static String _key(String yard) => '$_prefix$yard';

  int? movesFor(String yard) => _prefs.getInt(_key(yard));

  bool has(String yard) => movesFor(yard) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a yard down, and says whether it beat what was there.
  Future<bool> record(String yard, int moves) async {
    final before = movesFor(yard);
    if (before != null && before <= moves) return false;
    await _prefs.setInt(_key(yard), moves);
    return true;
  }
}
