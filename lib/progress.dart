import 'package:shared_preferences/shared_preferences.dart';

/// Which puzzles have been solved, and how long each took.
///
/// The book itself is not stored — a puzzle number is its own seed, so there
/// is nothing to keep but the numbers that have been done. That is also why
/// this can be a handful of integers rather than a save file: a phone that has
/// solved forty puzzles is holding forty small numbers.
class Progress {
  Progress(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int number) => 'took.$number';

  bool solved(int number) => _prefs.containsKey(_key(number));

  /// How long a solved puzzle took, or null if it has not been done.
  Duration? took(int number) {
    final seconds = _prefs.getInt(_key(number));
    return seconds == null ? null : Duration(seconds: seconds);
  }

  /// The first puzzle not yet solved, which is the one Play opens.
  ///
  /// Counted from the front rather than remembered, so a player who goes back
  /// and does a puzzle they had skipped is offered the right next one without
  /// anything having to be kept in step.
  int get next {
    var number = 1;
    while (solved(number)) {
      number++;
    }
    return number;
  }

  /// How many have been solved, which is not the same as [next] minus one: a
  /// player can skip ahead.
  int get count => _prefs.getKeys().where((key) => key.startsWith('took.')).length;

  /// Writes down a solve, keeping the better time if there was one before.
  ///
  /// Returns whether this beat a previous time, because that is worth saying
  /// on the card and is only true if there was a previous time to beat.
  Future<bool> record(int number, Duration took) async {
    final before = _prefs.getInt(_key(number));
    if (before != null && before <= took.inSeconds) return false;
    await _prefs.setInt(_key(number), took.inSeconds);
    return before != null;
  }
}
