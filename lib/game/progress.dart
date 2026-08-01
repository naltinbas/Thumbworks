import 'package:shared_preferences/shared_preferences.dart';

/// What the player has got through, kept across launches.
///
/// Two things are worth remembering: the level to open on next time, and the
/// fewest moves each level has been solved in. Boards are not among them,
/// because a level number builds its own board.
///
/// Reads are synchronous because the values are already in memory by the time
/// a screen is built; only writes go to disk.
class Progress {
  Progress(this._prefs);

  /// Loads what was saved. Called once, before the app is put on screen.
  static Future<Progress> open() async =>
      Progress(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _reachedKey = 'reached';
  static const _bestPrefix = 'best.';

  /// The furthest level the player has been given, which is the one to open
  /// on. A player who has solved nothing is on level one.
  int get reached => _positive(_reachedKey) ?? 1;

  /// The fewest moves this level has been solved in, or null if it has not.
  int? bestMoves(int level) => _positive('$_bestPrefix$level');

  /// A whole number of at least one under this key, or null.
  ///
  /// Read through [SharedPreferences.get] rather than getInt because getInt
  /// casts, so a key holding anything else throws rather than reading as
  /// absent. Nothing but this app writes these keys today, but a value on
  /// disk outlives the code that wrote it, and losing a level to a bad read
  /// is better than opening on a crash. Zero and below are treated the same
  /// way, so a saved level number always names a level that exists.
  int? _positive(String key) {
    final saved = _prefs.get(key);
    return saved is int && saved > 0 ? saved : null;
  }

  /// Records a win. The reached level only ever moves forward, so replaying
  /// an early level does not send the player back to it on the next launch.
  Future<void> recordSolved(int level, int moves) async {
    final best = bestMoves(level);
    if (best == null || moves < best) {
      await _prefs.setInt('$_bestPrefix$level', moves);
    }
    if (level + 1 > reached) {
      await _prefs.setInt(_reachedKey, level + 1);
    }
  }
}
