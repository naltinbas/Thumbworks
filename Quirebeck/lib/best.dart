import 'package:shared_preferences/shared_preferences.dart';

/// The fewest weaves each quire has been settled in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// quire nobody has woven. The turned pair writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'woven.';

  static String _key(String quire) => '$_prefix$quire';

  int? weavesFor(String quire) => _prefs.getInt(_key(quire));

  bool has(String quire) => weavesFor(quire) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a settling down, and says whether it beat what was there.
  Future<bool> record(String quire, int weaves) async {
    final before = weavesFor(quire);
    if (before != null && before <= weaves) return false;
    await _prefs.setInt(_key(quire), weaves);
    return true;
  }
}
