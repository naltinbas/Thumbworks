import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each pitch's wall has stood with.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// pitch nobody has walled. The fourth course writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'coped.';

  static String _key(String pitch) => '$_prefix$pitch';

  int? askingsFor(String pitch) => _prefs.getInt(_key(pitch));

  bool has(String pitch) => askingsFor(pitch) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a coping down, and says whether it beat what was there.
  Future<bool> record(String pitch, int askings) async {
    final before = askingsFor(pitch);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(pitch), askings);
    return true;
  }
}
