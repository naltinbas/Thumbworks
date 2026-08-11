import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each ring has been survived with.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a ring nobody has
/// stood in. Lost dips write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'stood.';

  static String _key(String ring) => '$_prefix$ring';

  int? askingsFor(String ring) => _prefs.getInt(_key(ring));

  bool has(String ring) => askingsFor(ring) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a survived dip down, and says whether it beat what was there.
  Future<bool> record(String ring, int askings) async {
    final before = askingsFor(ring);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(ring), askings);
    return true;
  }
}
