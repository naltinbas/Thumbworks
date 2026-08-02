import 'dart:math';

import 'rules.dart';

/// Whose turn it is.
enum Who { you, them }

/// One throw of the dice.
class Rolled {
  const Rolled(this.faces);

  /// What came up. One die or two.
  final List<int> faces;

  /// Whether a one came up, which ends the turn.
  bool get bust => faces.contains(1);

  /// Whether both dice were ones, which ends the turn and takes the score
  /// with it.
  bool get wipes => faces.length == 2 && faces.every((face) => face == 1);

  /// What this pays, which is nothing at all if it busted.
  int get paid {
    if (bust) return 0;
    if (faces.length == 1) return faces.single;
    return Rules.paidFor(faces[0], faces[1]);
  }

  /// Whether both dice matched, which is what pays double.
  bool get doubled => faces.length == 2 && faces[0] == faces[1] && !bust;

  static Rolled from(Move move, Random dice) => Rolled([
        for (var i = 0; i < (move == Move.two ? 2 : 1); i++)
          dice.nextInt(Rules.faces) + 1,
      ]);

  @override
  String toString() => faces.join(' and ');
}

/// A game: two scores, whatever this turn has made, and whose turn it is.
///
/// Immutable. Every move gives a new one, which is what lets a test play a
/// whole game as an expression and lets the review look back over a list of
/// positions that nothing has been able to change.
class Play {
  const Play({
    required this.yours,
    required this.theirs,
    required this.turn,
    required this.toMove,
    this.last,
    this.lastMove,
  });

  const Play.start()
      : yours = 0,
        theirs = 0,
        turn = 0,
        toMove = Who.you,
        last = null,
        lastMove = null;

  /// What each player has banked.
  final int yours;
  final int theirs;

  /// What the turn has made and has not banked.
  final int turn;

  final Who toMove;

  /// The throw that led here, if one did.
  final Rolled? last;

  /// The move that led here.
  final Move? lastMove;

  int get mine => toMove == Who.you ? yours : theirs;
  int get others => toMove == Who.you ? theirs : yours;

  bool get isOver => yours >= Rules.target || theirs >= Rules.target;

  Who? get won => yours >= Rules.target
      ? Who.you
      : theirs >= Rules.target
          ? Who.them
          : null;

  Who get waiting => toMove == Who.you ? Who.them : Who.you;

  Play _with({int? yours, int? theirs, int? turn, Who? toMove, Rolled? last,
      Move? lastMove}) =>
      Play(
        yours: yours ?? this.yours,
        theirs: theirs ?? this.theirs,
        turn: turn ?? this.turn,
        toMove: toMove ?? this.toMove,
        last: last,
        lastMove: lastMove,
      );

  /// Banks what the turn has made and hands over.
  Play bank() {
    if (isOver) return this;
    final banked = mine + turn;
    return _with(
      yours: toMove == Who.you ? banked : yours,
      theirs: toMove == Who.them ? banked : theirs,
      turn: 0,
      toMove: banked >= Rules.target ? toMove : waiting,
      lastMove: Move.bank,
    );
  }

  /// Takes a throw. The dice are handed in rather than drawn here, so a test
  /// can play the game it means to play.
  Play took(Move move, Rolled rolled) {
    if (isOver || move == Move.bank) return this;

    if (rolled.wipes) {
      return _with(
        yours: toMove == Who.you ? 0 : yours,
        theirs: toMove == Who.them ? 0 : theirs,
        turn: 0,
        toMove: waiting,
        last: rolled,
        lastMove: move,
      );
    }
    if (rolled.bust) {
      return _with(
        turn: 0,
        toMove: waiting,
        last: rolled,
        lastMove: move,
      );
    }
    return _with(turn: turn + rolled.paid, last: rolled, lastMove: move);
  }
}
