import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each hedge has been held with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a hedge
/// nobody has cut. Lost hedges write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'hedged.';

  static String _key(String hedge) => '$_prefix$hedge';

  int? askingsFor(String hedge) => _prefs.getInt(_key(hedge));

  bool has(String hedge) => askingsFor(hedge) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a held hedge down, and says whether it beat what was there.
  Future<bool> record(String hedge, int askings) async {
    final before = askingsFor(hedge);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(hedge), askings);
    return true;
  }
}
