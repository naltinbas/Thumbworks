import 'fewest.dart';
import 'yard.dart';

/// A yard part worked.
class Play {
  Play._(this.yard, this.moves, this.standing, this.made, this.lifted);

  factory Play.of(Yard yard, Moves moves) => Play._(
        yard,
        moves,
        Standing(List.filled(yard.stones, 0)),
        0,
        -1,
      );

  final Yard yard;

  /// The table of distances, kept for as long as the yard is open.
  final Moves moves;

  /// Where every stone stands.
  final Standing standing;

  /// How many moves have been made.
  final int made;

  /// The staddle whose top stone is lifted, waiting to be set down, or -1.
  final int lifted;

  bool get isDone => standing.allOnLast;

  bool get isFewest => isDone && made <= yard.fewest;

  /// The top stone of a staddle, or -1.
  int topOf(int staddle) => standing.topOf(staddle);

  /// Picks up the top stone of a staddle, sets the lifted stone down, or
  /// puts it back where it came from.
  Play touch(int staddle) {
    if (isDone || staddle < 0 || staddle > 2) return this;

    if (lifted < 0) {
      if (standing.topOf(staddle) < 0) return this;
      return Play._(yard, moves, standing, made, staddle);
    }

    if (staddle == lifted) {
      return Play._(yard, moves, standing, made, -1);
    }

    if (!standing.canMove(lifted, staddle)) return this;
    return Play._(
      yard,
      moves,
      standing.move(lifted, staddle),
      made + 1,
      -1,
    );
  }

  Play get again => Play.of(yard, moves);

  /// The fewest moves still to come from here.
  int get left => moves.from(standing);

  /// The best this yard can now be finished in, counting the moves made.
  int get couldFinishIn => made + left;

  /// Asked. The move to make next on a shortest way from where the stones
  /// actually stand.
  (int, int)? get next => moves.nextFrom(standing);

  /// Whether the biggest stone has reached the far staddle, which is the
  /// milestone the doubling argument is about.
  bool get biggestHome => standing.on[yard.stones - 1] == 2;
}
