import 'package:shared_preferences/shared_preferences.dart';

/// The fewest strings each ring's shelf has been filled in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// ring nobody has strung. The seventh writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'strung.';

  static String _key(String ring) => '$_prefix$ring';

  int? stringsFor(String ring) => _prefs.getInt(_key(ring));

  bool has(String ring) => stringsFor(ring) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a filling down, and says whether it beat what was there.
  Future<bool> record(String ring, int strings) async {
    final before = stringsFor(ring);
    if (before != null && before <= strings) return false;
    await _prefs.setInt(_key(ring), strings);
    return true;
  }
}
