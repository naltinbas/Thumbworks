import 'package:shared_preferences/shared_preferences.dart';

/// The fewest piles each deal has ended in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a deal nobody has
/// played.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'piled.';

  static String _key(String deal) => '$_prefix$deal';

  int? pilesFor(String deal) => _prefs.getInt(_key(deal));

  bool has(String deal) => pilesFor(deal) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a morning down, and says whether it beat what was there.
  Future<bool> record(String deal, int piles) async {
    final before = pilesFor(deal);
    if (before != null && before <= piles) return false;
    await _prefs.setInt(_key(deal), piles);
    return true;
  }
}
