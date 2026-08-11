import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each town has been walked with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a town
/// nobody has walked. The seven bridges write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'walked.';

  static String _key(String town) => '$_prefix$town';

  int? askingsFor(String town) => _prefs.getInt(_key(town));

  bool has(String town) => askingsFor(town) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a walk down, and says whether it beat what was there.
  Future<bool> record(String town, int askings) async {
    final before = askingsFor(town);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(town), askings);
    return true;
  }
}
