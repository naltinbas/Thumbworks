import 'table.dart';

/// Where a tap on a card should send it.
///
/// A phone is not a table. Dragging a card between two columns forty points
/// wide means a thumb covering both of them, so the gesture that has to work
/// is a tap — and a tap only works if the game can guess right nearly every
/// time.
///
/// The order below is the guess, and it is the order a player would try
/// themselves: home if it can go home, then onto another card, then into an
/// empty column, and a cell only if there is nothing else. Onto another card
/// before an empty column matters — an empty column is the most valuable thing
/// on the table and filling one with a card that had somewhere else to go is
/// the mistake this saves.
Move? tapMove(Table table, {required Where from, required int at, int? card}) {
  if (from == Where.cell) {
    final held = table.cell(at);
    if (held == null) return null;
    return _bestFor(
      table,
      moves: table.moves.where(
        (move) => move.from == Where.cell && move.fromAt == at,
      ),
    );
  }

  final column = table.column(at);
  if (column.isEmpty) return null;

  // Which card was tapped, counting from the end. Tapping part way up a
  // column means the run from there down, which is what a player means by it.
  final take = card == null ? 1 : column.length - card;
  return _bestFor(
    table,
    moves: table.moves.where(
      (move) =>
          move.from == Where.column &&
          move.fromAt == at &&
          move.cards == take,
    ),
  );
}

Move? _bestFor(Table table, {required Iterable<Move> moves}) {
  Move? best;
  var bestRank = 99;
  for (final move in moves) {
    final rank = switch (move.to) {
      Where.home => 0,
      Where.column => table.column(move.toAt).isEmpty ? 2 : 1,
      Where.cell => 3,
    };
    if (rank < bestRank) {
      bestRank = rank;
      best = move;
    }
  }
  return best;
}
