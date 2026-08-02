import 'package:shared_preferences/shared_preferences.dart';

/// The best round the player has had, kept across launches.
///
/// The seed is kept beside the score because a round is a pure function of
/// its seed: the two together are the whole of a best round, so the title
/// screen can name the board the record happened on.
///
/// Reads are synchronous. The values are in memory before the first frame is
/// built, so no screen has to be drawn without them and the number never
/// appears a moment after the screen it belongs to. Only writes go to disk.
class BestScore {
  BestScore(this._prefs);

  /// Loads what was saved. Called once, before the game goes on screen.
  static Future<BestScore> open() async =>
      BestScore(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _pointsKey = 'best.points';
  static const _seedKey = 'best.seed';

  /// Points in the best round, or zero if there has not been one worth
  /// keeping.
  int get points => _whole(_pointsKey) ?? 0;

  /// The seed that round was played on, or null if there is no best round or
  /// the seed was lost.
  int? get seed => hasRound ? _whole(_seedKey) : null;

  bool get hasRound => points > 0;

  /// Keeps [points] if they beat what is already there, and answers whether
  /// they did, which is the one thing the end of a round wants to say out
  /// loud.
  ///
  /// A tie is not a new best: a player who matches their record should be told
  /// they matched it, not that they beat it.
  Future<bool> record({required int points, required int seed}) async {
    if (points <= 0 || points <= this.points) return false;
    await _prefs.setInt(_pointsKey, points);
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
