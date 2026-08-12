import 'package:shared_preferences/shared_preferences.dart';

/// The fewest tries each ring's good starts have been found in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// ring nobody has walked. The tied vote writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'found.';

  static String _key(String ring) => '$_prefix$ring';

  int? triesFor(String ring) => _prefs.getInt(_key(ring));

  bool has(String ring) => triesFor(ring) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a finding down, and says whether it beat what was there.
  Future<bool> record(String ring, int tries) async {
    final before = triesFor(ring);
    if (before != null && before <= tries) return false;
    await _prefs.setInt(_key(ring), tries);
    return true;
  }
}
