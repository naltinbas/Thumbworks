import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each party has been settled with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a party
/// nobody has wed. The odd house writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'settled.';

  static String _key(String party) => '$_prefix$party';

  int? askingsFor(String party) => _prefs.getInt(_key(party));

  bool has(String party) => askingsFor(party) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a settling down, and says whether it beat what was there.
  Future<bool> record(String party, int askings) async {
    final before = askingsFor(party);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(party), askings);
    return true;
  }
}
