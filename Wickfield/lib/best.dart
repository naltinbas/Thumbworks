import 'package:shared_preferences/shared_preferences.dart';

/// The fewest presses each wick has been darkened with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a board
/// nobody has pressed. The dead board writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'quenched.';

  static String _key(String wick) => '$_prefix$wick';

  int? pressesFor(String wick) => _prefs.getInt(_key(wick));

  bool has(String wick) => pressesFor(wick) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a darkening down, and says whether it beat what was there.
  Future<bool> record(String wick, int presses) async {
    final before = pressesFor(wick);
    if (before != null && before <= presses) return false;
    await _prefs.setInt(_key(wick), presses);
    return true;
  }
}
