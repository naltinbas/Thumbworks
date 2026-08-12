import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each green's ring has stood with.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// green nobody has walked. The odd stone writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'stood.';

  static String _key(String green) => '$_prefix$green';

  int? askingsFor(String green) => _prefs.getInt(_key(green));

  bool has(String green) => askingsFor(green) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a standing down, and says whether it beat what was there.
  Future<bool> record(String green, int askings) async {
    final before = askingsFor(green);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(green), askings);
    return true;
  }
}
