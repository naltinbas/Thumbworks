import 'package:shared_preferences/shared_preferences.dart';

/// Which rounds have been paired up, and in how few changes.
///
/// A change is a couple made or broken. It is the only thing that varies —
/// the answer is the answer — so it is what the record is: how much fiddling
/// it took to find.
///
/// Keyed on the round's name rather than its place in the list, so putting a
/// new one in the middle does not hand somebody else's record to a round they
/// have never seen.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'paired.';

  static String _key(String round) => '$_prefix$round';

  int? changesFor(String round) => _prefs.getInt(_key(round));

  bool has(String round) => changesFor(round) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes down a round, and says whether it beat what was there.
  Future<bool> record(String round, int changes) async {
    final before = changesFor(round);
    if (before != null && before <= changes) return false;
    await _prefs.setInt(_key(round), changes);
    return true;
  }
}
