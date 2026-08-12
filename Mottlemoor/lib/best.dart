import 'package:shared_preferences/shared_preferences.dart';

/// The fewest meetings each moor has settled with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a moor
/// nobody has herded. The mismatches write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'settled.';

  static String _key(String moor) => '$_prefix$moor';

  int? meetingsFor(String moor) => _prefs.getInt(_key(moor));

  bool has(String moor) => meetingsFor(moor) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a settling down, and says whether it beat what was there.
  Future<bool> record(String moor, int meetings) async {
    final before = meetingsFor(moor);
    if (before != null && before <= meetings) return false;
    await _prefs.setInt(_key(moor), meetings);
    return true;
  }
}
