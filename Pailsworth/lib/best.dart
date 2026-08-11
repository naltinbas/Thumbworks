import 'package:shared_preferences/shared_preferences.dart';

/// The fewest pours each errand has been run with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to an errand
/// nobody has fetched. The third pint writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'fetched.';

  static String _key(String errand) => '$_prefix$errand';

  int? poursFor(String errand) => _prefs.getInt(_key(errand));

  bool has(String errand) => poursFor(errand) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes an errand down, and says whether it beat what was there.
  Future<bool> record(String errand, int pours) async {
    final before = poursFor(errand);
    if (before != null && before <= pours) return false;
    await _prefs.setInt(_key(errand), pours);
    return true;
  }
}
