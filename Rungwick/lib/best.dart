import 'package:shared_preferences/shared_preferences.dart';

/// The fewest rungs each climb has been finished in.
///
/// Keyed on the two words rather than on the climb's place in the list, so
/// putting a new climb in the middle does not hand somebody else's record to
/// one they have never done.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'best.';

  static String _key(String from, String to) => '$_prefix$from-$to';

  /// The fewest rungs this climb has been finished in, or null.
  int? rungsFor(String from, String to) => _prefs.getInt(_key(from, to));

  bool has(String from, String to) => rungsFor(from, to) != null;

  int get climbed =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a climb, and says whether it beat what was there.
  Future<bool> record(String from, String to, int rungs) async {
    final before = rungsFor(from, to);
    if (before != null && before <= rungs) return false;
    await _prefs.setInt(_key(from, to), rungs);
    return true;
  }
}
