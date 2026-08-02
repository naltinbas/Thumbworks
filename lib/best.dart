import 'package:shared_preferences/shared_preferences.dart';

/// The best time on each size, and how many boards have been cleared.
///
/// Keyed on the size's name rather than its place in the list, so adding a
/// size in the middle does not hand somebody else's record to a board they
/// have never played.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static String _time(String size) => 'best.$size';
  static String _count(String size) => 'cleared.$size';

  /// The quickest clear of this size, in seconds, or null.
  int? secondsFor(String size) => _prefs.getInt(_time(size));

  int clearedOn(String size) => _prefs.getInt(_count(size)) ?? 0;

  int get cleared {
    var total = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith('cleared.')) total += _prefs.getInt(key) ?? 0;
    }
    return total;
  }

  /// Writes down a clear, and says whether it was the quickest yet.
  Future<bool> record(String size, int seconds) async {
    await _prefs.setInt(_count(size), clearedOn(size) + 1);
    final before = secondsFor(size);
    if (before != null && before <= seconds) return false;
    await _prefs.setInt(_time(size), seconds);
    return true;
  }
}
