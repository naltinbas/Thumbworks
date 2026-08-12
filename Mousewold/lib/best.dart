import 'package:shared_preferences/shared_preferences.dart';

/// The fewest rounds each ground's mouse has been cornered in.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a ground
/// nobody has swept. The ring fence writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'cornered.';

  static String _key(String ground) => '$_prefix$ground';

  int? roundsFor(String ground) => _prefs.getInt(_key(ground));

  bool has(String ground) => roundsFor(ground) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a catch down, and says whether it beat what was there.
  Future<bool> record(String ground, int rounds) async {
    final before = roundsFor(ground);
    if (before != null && before <= rounds) return false;
    await _prefs.setInt(_key(ground), rounds);
    return true;
  }
}
