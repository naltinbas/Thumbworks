import 'package:shared_preferences/shared_preferences.dart';

/// The shortest round each map has been driven in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a round they have
/// never driven.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'drove.';

  static String _key(String round) => '$_prefix$round';

  int? furlongsFor(String round) => _prefs.getInt(_key(round));

  bool has(String round) => furlongsFor(round) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a round, and says whether it beat what was there.
  Future<bool> record(String round, int furlongs) async {
    final before = furlongsFor(round);
    if (before != null && before <= furlongs) return false;
    await _prefs.setInt(_key(round), furlongs);
    return true;
  }
}
