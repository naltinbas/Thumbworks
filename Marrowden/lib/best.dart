import 'package:shared_preferences/shared_preferences.dart';

/// The fewest sittings each bench's five wins have come in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// bench nobody has judged. The sure pick writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'landed.';

  static String _key(String show) => '$_prefix$show';

  int? sittingsFor(String show) => _prefs.getInt(_key(show));

  bool has(String show) => sittingsFor(show) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a bench down, and says whether it beat what was there.
  Future<bool> record(String show, int sittings) async {
    final before = sittingsFor(show);
    if (before != null && before <= sittings) return false;
    await _prefs.setInt(_key(show), sittings);
    return true;
  }
}
