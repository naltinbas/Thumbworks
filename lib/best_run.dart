import 'package:shared_preferences/shared_preferences.dart';

/// The best run the player has had, kept across launches.
///
/// The seed is kept beside the score because a run is a pure function of its
/// seed: the two together are the whole of a best run, so a player can see,
/// and play again, the world their record happened in.
///
/// Reads are synchronous. The values are in memory before the first frame is
/// built, so no screen has to be drawn without them and the number never
/// appears a moment after the screen it belongs to. Only writes go to disk.
class BestRun {
  BestRun(this._prefs);

  /// Loads what was saved. Called once, before the game goes on screen.
  static Future<BestRun> open() async =>
      BestRun(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _scoreKey = 'best.score';
  static const _seedKey = 'best.seed';

  /// Wells caught in the best run, or zero if there has not been one worth
  /// keeping.
  int get score => _whole(_scoreKey) ?? 0;

  /// The seed that run was played on, or null if there is no best run or the
  /// seed was lost.
  int? get seed => hasRun ? _whole(_seedKey) : null;

  bool get hasRun => score > 0;

  /// Keeps [score] if it beats what is already there, and answers whether it
  /// did, which is the one thing the end of a run wants to say out loud.
  ///
  /// A tie is not a new best: a player who matches their record should be told
  /// they matched it, not that they beat it.
  Future<bool> record({required int score, required int seed}) async {
    if (score <= 0 || score <= this.score) return false;
    await _prefs.setInt(_scoreKey, score);
    await _prefs.setInt(_seedKey, seed);
    return true;
  }

  /// A whole number under this key, or null.
  ///
  /// Read through get rather than getInt because getInt casts, so a key
  /// holding anything else throws instead of reading as absent. Saved values
  /// outlive the code that wrote them, and opening with no best score is
  /// better than opening on a crash.
  int? _whole(String key) {
    final saved = _prefs.get(key);
    return saved is int ? saved : null;
  }
}
