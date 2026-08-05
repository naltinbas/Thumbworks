import 'chart.dart';
import 'maps.dart';
import 'tablebase.dart';

/// Why a move cannot be made.
enum Refusal {
  /// Not a place on this map.
  nowhere,

  /// No path goes there from where the seeker is standing.
  noPath,

  /// The chase is over.
  over;

  String get says => switch (this) {
        Refusal.nowhere => 'That is not a place on this map.',
        Refusal.noPath => 'There is no path from here to there.',
        Refusal.over => 'The chase is over.',
      };
}

/// A chase being played.
///
/// The player is the seeker. The runner is the table next door, which knows
/// every position of the chase and always takes the one that keeps it out of
/// reach the longest — so there is no luck in this and no bad day: a chase
/// lost is a chase that was lost by a move.
class Play {
  Play._(
    this.warren,
    this.chart,
    this.table,
    this.seeker,
    this.runner,
    this.moves,
    this.been,
  );

  factory Play.of(Warren warren, Tablebase table) => Play._(
        warren,
        table.chart,
        table,
        warren.seeker,
        warren.runner,
        0,
        const [],
      );

  final Warren warren;
  final Chart chart;
  final Tablebase table;

  final int seeker;
  final int runner;

  /// How many moves the seeker has made.
  final int moves;

  /// Where the two of them have been, in order, as pairs.
  final List<(int, int)> been;

  bool get isCaught => seeker == runner;
  bool get isDone => isCaught;

  /// How many more moves the seeker needs from here, or [Tablebase.never].
  int get left => table.movesFrom(seeker, runner, seekersTurn: true);

  bool get canStillWin => left != Tablebase.never;

  /// Whether the chase is still on course for the fewest moves there are.
  bool get onShortest {
    final par = warren.par;
    if (par == null || !canStillWin) return false;
    return moves + left <= par;
  }

  /// How many moves have been thrown away.
  int get wasted {
    final par = warren.par;
    if (par == null || !canStillWin) return 0;
    return moves + left - par;
  }

  /// Where the seeker could go: the paths from here, and standing still.
  List<int> get canGo => isDone ? const [] : chart.beside[seeker];

  Refusal? whyNot(int place) {
    if (isDone) return Refusal.over;
    if (place < 0 || place >= chart.count) return Refusal.nowhere;
    if (!chart.beside[seeker].contains(place)) return Refusal.noPath;
    return null;
  }

  bool canMoveTo(int place) => whyNot(place) == null;

  /// This chase after the seeker moves, and the runner answers.
  ///
  /// Both halves happen at once because a player who has moved has nothing
  /// left to decide: the runner's reply is the table's, not a choice.
  Play move(int place) {
    if (!canMoveTo(place)) return this;
    final went = [...been, (seeker, runner)];

    if (place == runner) {
      return Play._(warren, chart, table, place, runner, moves + 1, went);
    }
    final away = table.bestForRunner(place, runner) ?? runner;
    return Play._(warren, chart, table, place, away, moves + 1, went);
  }

  /// This chase with the last move taken back.
  Play get back {
    if (been.isEmpty) return this;
    final (was, awayWas) = been.last;
    return Play._(
      warren,
      chart,
      table,
      was,
      awayWas,
      moves - 1,
      been.sublist(0, been.length - 1),
    );
  }

  Play get again => Play.of(warren, table);

  /// The move that catches the runner soonest, or null when there is none.
  int? get next => table.bestForSeeker(seeker, runner);
}
