import 'package:shared_preferences/shared_preferences.dart';

/// The fewest cuts each bench's trade has been made in.
///
/// Keyed on the name rather than the place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a
/// bench nobody has cut. The even bones write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'traded.';

  static String _key(String bench) => '$_prefix$bench';

  int? cutsFor(String bench) => _prefs.getInt(_key(bench));

  bool has(String bench) => cutsFor(bench) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a trade down, and says whether it beat what was there.
  Future<bool> record(String bench, int cuts) async {
    final before = cutsFor(bench);
    if (before != null && before <= cuts) return false;
    await _prefs.setInt(_key(bench), cuts);
    return true;
  }
}
