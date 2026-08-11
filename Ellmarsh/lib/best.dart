import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each bench has been held with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a bench
/// nobody has cut. Lost benches write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'held.';

  static String _key(String bench) => '$_prefix$bench';

  int? askingsFor(String bench) => _prefs.getInt(_key(bench));

  bool has(String bench) => askingsFor(bench) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a held bench down, and says whether it beat what was there.
  Future<bool> record(String bench, int askings) async {
    final before = askingsFor(bench);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(bench), askings);
    return true;
  }
}
