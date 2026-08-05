import 'package:shared_preferences/shared_preferences.dart';

/// The fewest days each frame has been raised in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a frame nobody has
/// raised.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'raised.';

  static String _key(String frame) => '$_prefix$frame';

  int? daysFor(String frame) => _prefs.getInt(_key(frame));

  bool has(String frame) => daysFor(frame) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a frame down, and says whether it beat what was there.
  Future<bool> record(String frame, int days) async {
    final before = daysFor(frame);
    if (before != null && before <= days) return false;
    await _prefs.setInt(_key(frame), days);
    return true;
  }
}
