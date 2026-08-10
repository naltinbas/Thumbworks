import 'package:shared_preferences/shared_preferences.dart';

/// The fewest slides each forme has been locked in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a forme nobody has
/// slid.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'locked.';

  static String _key(String forme) => '$_prefix$forme';

  int? slidesFor(String forme) => _prefs.getInt(_key(forme));

  bool has(String forme) => slidesFor(forme) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a forme down, and says whether it beat what was there.
  Future<bool> record(String forme, int slides) async {
    final before = slidesFor(forme);
    if (before != null && before <= slides) return false;
    await _prefs.setInt(_key(forme), slides);
    return true;
  }
}
