import 'package:shared_preferences/shared_preferences.dart';

/// The fewest pushes each field's fee has been won on.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a field nobody has
/// driven. Lost drives write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'penned.';

  static String _key(String field) => '$_prefix$field';

  int? pushesFor(String field) => _prefs.getInt(_key(field));

  bool has(String field) => pushesFor(field) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a won drive down, and says whether it beat what was there.
  Future<bool> record(String field, int pushes) async {
    final before = pushesFor(field);
    if (before != null && before <= pushes) return false;
    await _prefs.setInt(_key(field), pushes);
    return true;
  }
}
