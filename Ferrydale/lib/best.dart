import 'package:shared_preferences/shared_preferences.dart';

/// The fewest crossings each ferry has landed with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a river
/// nobody has rowed. The four and four write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'ferried.';

  static String _key(String ferry) => '$_prefix$ferry';

  int? crossingsFor(String ferry) => _prefs.getInt(_key(ferry));

  bool has(String ferry) => crossingsFor(ferry) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a landing down, and says whether it beat what was there.
  Future<bool> record(String ferry, int crossings) async {
    final before = crossingsFor(ferry);
    if (before != null && before <= crossings) return false;
    await _prefs.setInt(_key(ferry), crossings);
    return true;
  }
}
