import 'package:shared_preferences/shared_preferences.dart';

/// The furthest anybody has got.
///
/// One number. A runner does not need a save file: the whole of what a player
/// has to show for an hour of it is how far they got once.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'best.tiles';

  int get tiles => _prefs.getInt(_key) ?? 0;

  /// Writes down a run, and says whether it beat what was there.
  Future<bool> record(int got) async {
    if (got <= tiles) return false;
    await _prefs.setInt(_key, got);
    return true;
  }
}
