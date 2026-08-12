import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each hall has been lit with.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// hall nobody has warded. The comb short writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'lit.';

  static String _key(String hall) => '$_prefix$hall';

  int? askingsFor(String hall) => _prefs.getInt(_key(hall));

  bool has(String hall) => askingsFor(hall) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a lighting down, and says whether it beat what was there.
  Future<bool> record(String hall, int askings) async {
    final before = askingsFor(hall);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(hall), askings);
    return true;
  }
}
