import 'package:shared_preferences/shared_preferences.dart';

/// The cleanest each evening has been read: slips and askings together.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to an evening nobody
/// has read.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'read.';

  static String _key(String evening) => '$_prefix$evening';

  int? slipsFor(String evening) => _prefs.getInt(_key(evening));

  bool has(String evening) => slipsFor(evening) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a settled evening down, and says whether it beat what was
  /// there.
  Future<bool> record(String evening, int slips) async {
    final before = slipsFor(evening);
    if (before != null && before <= slips) return false;
    await _prefs.setInt(_key(evening), slips);
    return true;
  }
}
