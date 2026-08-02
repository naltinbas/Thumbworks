import 'package:shared_preferences/shared_preferences.dart';

/// What has happened over all the games played.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _won = 'games.won';
  static const _lost = 'games.lost';
  static const _sharpest = 'games.sharpest';

  int get won => _prefs.getInt(_won) ?? 0;
  int get lost => _prefs.getInt(_lost) ?? 0;
  int get played => won + lost;

  /// The largest share of one game's decisions that were the best ones.
  double get sharpest => _prefs.getDouble(_sharpest) ?? 0;

  /// Writes down a game, and says whether it was the sharpest yet.
  ///
  /// Sharpness rather than the result, because the result is mostly the dice
  /// — you can play a game perfectly and lose it, and being told you played
  /// it perfectly is the only thing worth keeping.
  Future<bool> record({required bool win, required double sharpness}) async {
    await _prefs.setInt(win ? _won : _lost, (win ? won : lost) + 1);
    if (sharpness <= sharpest) return false;
    await _prefs.setDouble(_sharpest, sharpness);
    return true;
  }
}
