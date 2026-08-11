import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each tilth has been brought home with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a tilth
/// nobody has sown. Dead boards write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'barned.';

  static String _key(String tilth) => '$_prefix$tilth';

  int? askingsFor(String tilth) => _prefs.getInt(_key(tilth));

  bool has(String tilth) => askingsFor(tilth) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a homecoming down, and says whether it beat what was there.
  Future<bool> record(String tilth, int askings) async {
    final before = askingsFor(tilth);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(tilth), askings);
    return true;
  }
}
