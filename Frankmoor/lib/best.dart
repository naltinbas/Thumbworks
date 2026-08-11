import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each letter has been paid with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a letter
/// nobody has franked. Unpaid letters write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'franked.';

  static String _key(String letter) => '$_prefix$letter';

  int? askingsFor(String letter) => _prefs.getInt(_key(letter));

  bool has(String letter) => askingsFor(letter) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a paid letter down, and says whether it beat what was there.
  Future<bool> record(String letter, int askings) async {
    final before = askingsFor(letter);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(letter), askings);
    return true;
  }
}
