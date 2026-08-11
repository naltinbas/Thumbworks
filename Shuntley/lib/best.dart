import 'package:shared_preferences/shared_preferences.dart';

/// The fewest shunts each tray has come home with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a tray
/// nobody has slid. The swindle writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'shunted.';

  static String _key(String tray) => '$_prefix$tray';

  int? shuntsFor(String tray) => _prefs.getInt(_key(tray));

  bool has(String tray) => shuntsFor(tray) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a homecoming down, and says whether it beat what was there.
  Future<bool> record(String tray, int shunts) async {
    final before = shuntsFor(tray);
    if (before != null && before <= shunts) return false;
    await _prefs.setInt(_key(tray), shunts);
    return true;
  }
}
