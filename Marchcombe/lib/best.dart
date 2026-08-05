import 'package:shared_preferences/shared_preferences.dart';

/// The fewest dyes each estate has been painted in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to an estate they have
/// never painted.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'painted.';

  static String _key(String estate) => '$_prefix$estate';

  int? dyesFor(String estate) => _prefs.getInt(_key(estate));

  bool has(String estate) => dyesFor(estate) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down an estate, and says whether it beat what was there.
  Future<bool> record(String estate, int dyes) async {
    final before = dyesFor(estate);
    if (before != null && before <= dyes) return false;
    await _prefs.setInt(_key(estate), dyes);
    return true;
  }
}
