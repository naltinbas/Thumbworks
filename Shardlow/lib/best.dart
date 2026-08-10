import 'package:shared_preferences/shared_preferences.dart';

/// The fewest drops each morning has been settled in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a ladder nobody has
/// climbed.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'settled.';

  static String _key(String ladder) => '$_prefix$ladder';

  int? dropsFor(String ladder) => _prefs.getInt(_key(ladder));

  bool has(String ladder) => dropsFor(ladder) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a morning down, and says whether it beat what was there.
  Future<bool> record(String ladder, int drops) async {
    final before = dropsFor(ladder);
    if (before != null && before <= drops) return false;
    await _prefs.setInt(_key(ladder), drops);
    return true;
  }
}
