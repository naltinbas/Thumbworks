import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each map has been won in.
///
/// Keyed on the map's name rather than its place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a map they
/// have never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'caught.';

  static String _key(String warren) => '$_prefix$warren';

  int? movesFor(String warren) => _prefs.getInt(_key(warren));

  bool has(String warren) => movesFor(warren) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a map, and says whether it beat what was there.
  Future<bool> record(String warren, int moves) async {
    final before = movesFor(warren);
    if (before != null && before <= moves) return false;
    await _prefs.setInt(_key(warren), moves);
    return true;
  }
}
