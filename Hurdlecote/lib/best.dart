import 'package:shared_preferences/shared_preferences.dart';

/// The fewest hurdles each green's task has been penned with.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// green nobody has fenced. The third acre writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'penned.';

  static String _key(String green) => '$_prefix$green';

  int? hurdlesFor(String green) => _prefs.getInt(_key(green));

  bool has(String green) => hurdlesFor(green) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a penning down, and says whether it beat what was there.
  Future<bool> record(String green, int hurdles) async {
    final before = hurdlesFor(green);
    if (before != null && before <= hurdles) return false;
    await _prefs.setInt(_key(green), hurdles);
    return true;
  }
}
