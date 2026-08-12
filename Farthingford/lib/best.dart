import 'package:shared_preferences/shared_preferences.dart';

/// The fewest wades each reach's crossing has been made in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// reach nobody has waded. The shallow ford writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'crossed.';

  static String _key(String reach) => '$_prefix$reach';

  int? wadesFor(String reach) => _prefs.getInt(_key(reach));

  bool has(String reach) => wadesFor(reach) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a crossing down, and says whether it beat what was there.
  Future<bool> record(String reach, int wades) async {
    final before = wadesFor(reach);
    if (before != null && before <= wades) return false;
    await _prefs.setInt(_key(reach), wades);
    return true;
  }
}
