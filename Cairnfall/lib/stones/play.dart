import 'cairn.dart';
import 'worth.dart';

/// Whose turn it is.
enum Who { you, them }

/// One move: which cairn, and how many stones came off it.
class Take {
  const Take(this.cairn, this.stones);

  /// Which cairn, by its place in the row.
  final int cairn;
  final int stones;

  @override
  bool operator ==(Object other) =>
      other is Take && other.cairn == cairn && other.stones == stones;

  @override
  int get hashCode => Object.hash(cairn, stones);

  @override
  String toString() => '$stones off cairn $cairn';
}

/// A game: some cairns, and whose turn it is.
///
/// Immutable. Every move gives a new one, which is what lets a test play a
/// whole game as an expression and lets a search walk ahead without
/// disturbing anything.
class Play {
  const Play({
    required this.cairns,
    required this.toMove,
    this.last,
  });

  final List<Cairn> cairns;
  final Who toMove;

  /// The move that led here, if one did.
  final Take? last;

  /// Whoever takes the last stone wins, so a position with nothing on it is
  /// a position whose owner has already lost.
  bool get isOver => cairns.every((cairn) => cairn.isGone);

  Who? get won => isOver ? (toMove == Who.you ? Who.them : Who.you) : null;

  int get stones => cairns.fold(0, (all, cairn) => all + cairn.stones);

  Who get waiting => toMove == Who.you ? Who.them : Who.you;

  /// Every move there is from here.
  List<Take> get moves => [
        for (var at = 0; at < cairns.length; at++)
          for (final take in cairns[at].takes) Take(at, take),
      ];

  /// This position after a move, or the same one if that move cannot be made.
  Play after(Take take) {
    if (isOver) return this;
    if (take.cairn < 0 || take.cairn >= cairns.length) return this;
    if (!cairns[take.cairn].takes.contains(take.stones)) return this;

    return Play(
      cairns: [
        for (var at = 0; at < cairns.length; at++)
          at == take.cairn ? cairns[at].less(take.stones) : cairns[at],
      ],
      toMove: waiting,
      last: take,
    );
  }

  /// A move that wins, if there is one.
  ///
  /// There is one exactly when the position is worth something other than
  /// nothing, and it is the move that leaves nothing. Nothing here searches:
  /// the arithmetic already knows.
  Take? winningMove(Worth worth) {
    if (isOver) return null;
    for (final move in moves) {
      if (worth.ofAll(after(move).cairns) == 0) return move;
    }
    return null;
  }

  /// The move to play: the one that wins if there is one, and otherwise the
  /// smallest take there is.
  ///
  /// Losing positions have no good move by definition, so what is left is to
  /// take as little as possible and give the other player the most chances to
  /// go wrong.
  Take bestMove(Worth worth) => winningMove(worth) ?? moves.first;
}
