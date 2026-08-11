import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each riddle has been answered with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a riddle
/// nobody has read. The liar's riddle writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'answered.';

  static String _key(String riddle) => '$_prefix$riddle';

  int? askingsFor(String riddle) => _prefs.getInt(_key(riddle));

  bool has(String riddle) => askingsFor(riddle) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes an answer down, and says whether it beat what was there.
  Future<bool> record(String riddle, int askings) async {
    final before = askingsFor(riddle);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(riddle), askings);
    return true;
  }
}
