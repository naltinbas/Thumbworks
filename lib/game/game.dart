import 'table.dart';

/// A game being played: the position, and every position before it.
///
/// The table is a position and knows nothing about how it was reached, so undo
/// lives here. It is a list of tables rather than a list of moves undone,
/// because a table is small and undoing a move by playing it backwards is a
/// second implementation of the rules waiting to disagree with the first.
class Game {
  const Game._({
    required this.number,
    required this.table,
    required this.past,
    required this.moves,
  });

  factory Game.deal(int number) {
    // Tidied on the way in, so the aces sitting on the ends of columns are
    // already up before the player has to look at them.
    final table = Table.deal(number).tidied;
    return Game._(number: number, table: table, past: const [], moves: 0);
  }

  /// A game from a position, for tests and screenshots.
  factory Game.at(Table table, {int number = 0}) =>
      Game._(number: number, table: table, past: const [], moves: 0);

  /// Which deal this is, so it can be named and dealt again.
  final int number;

  final Table table;

  /// Every position before this one, oldest first.
  final List<Table> past;

  /// How many moves the player has made. Cards that went home on their own
  /// are not among them: a move is a thing somebody decided.
  final int moves;

  bool get isWon => table.isWon;
  bool get canUndo => past.isNotEmpty;

  /// The game after a move, with anything that can safely go home sent up.
  Game play(Move move) {
    if (!table.allows(move)) return this;
    return Game._(
      number: number,
      table: table.play(move).tidied,
      past: [...past, table],
      moves: moves + 1,
    );
  }

  Game get back {
    if (past.isEmpty) return this;
    return Game._(
      number: number,
      table: past.last,
      past: past.sublist(0, past.length - 1),
      moves: moves + 1,
    );
  }

  /// Back to the deal, keeping the number.
  Game get again => Game.deal(number);
}
