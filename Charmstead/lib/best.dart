import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each charm has been held with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a charm
/// nobody has set. The dead charms write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'charmed.';

  static String _key(String charm) => '$_prefix$charm';

  int? askingsFor(String charm) => _prefs.getInt(_key(charm));

  bool has(String charm) => askingsFor(charm) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a held charm down, and says whether it beat what was
  /// there.
  Future<bool> record(String charm, int askings) async {
    final before = askingsFor(charm);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(charm), askings);
    return true;
  }
}
