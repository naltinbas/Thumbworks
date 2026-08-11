import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each alley has been won with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to an alley
/// nobody has bowled. The even alley writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'bowled.';

  static String _key(String frame) => '$_prefix$frame';

  int? askingsFor(String frame) => _prefs.getInt(_key(frame));

  bool has(String frame) => askingsFor(frame) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a won alley down, and says whether it beat what was there.
  Future<bool> record(String frame, int askings) async {
    final before = askingsFor(frame);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(frame), askings);
    return true;
  }
}
