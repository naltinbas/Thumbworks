import 'package:shared_preferences/shared_preferences.dart';

/// The fewest steps each field's banks have been linked in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// field nobody has stepped. The second chair writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'linked.';

  static String _key(String field) => '$_prefix$field';

  int? stepsFor(String field) => _prefs.getInt(_key(field));

  bool has(String field) => stepsFor(field) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a linking down, and says whether it beat what was there.
  Future<bool> record(String field, int steps) async {
    final before = stepsFor(field);
    if (before != null && before <= steps) return false;
    await _prefs.setInt(_key(field), steps);
    return true;
  }
}
