import 'package:shared_preferences/shared_preferences.dart';

/// The fewest minutes each bridge has been crossed in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a bridge nobody has
/// crossed.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'crossed.';

  static String _key(String bridge) => '$_prefix$bridge';

  int? minutesFor(String bridge) => _prefs.getInt(_key(bridge));

  bool has(String bridge) => minutesFor(bridge) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a night down, and says whether it beat what was there.
  Future<bool> record(String bridge, int minutes) async {
    final before = minutesFor(bridge);
    if (before != null && before <= minutes) return false;
    await _prefs.setInt(_key(bridge), minutes);
    return true;
  }
}
