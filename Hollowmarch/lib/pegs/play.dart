import 'boards.dart';
import 'field.dart';
import 'runs.dart';
import 'solve.dart';

/// Why a jump cannot be made.
enum Refusal {
  /// Nothing to jump with.
  noPeg,

  /// Two hollows away in a line is what a jump is.
  notAJump,

  /// Nothing in between to take.
  nothingToTake,

  /// Something is already there.
  taken,

  /// A move is one peg. This one is in the middle of a run and it is not
  /// the peg being asked to move.
  notThatPeg;

  String get says => switch (this) {
        Refusal.noPeg => 'There is no peg there.',
        Refusal.notAJump =>
          'A peg jumps two hollows, straight along a row or a column.',
        Refusal.nothingToTake => 'There is nothing in between to take.',
        Refusal.taken => 'There is already a peg there.',
        Refusal.notThatPeg =>
          'That peg is in the middle of its move. Carry on with it, or let it '
              'go.',
      };
}

/// A board being played.
///
/// The pegs are one number, a bit for each hollow, because that is what makes
/// the search affordable and there is no reason for the game to hold them any
/// other way.
class Play {
  const Play._(this.board, this.field, this.pegs, this.jumps, this.carrying);

  factory Play.of(Board board) {
    final field = board.field;
    return Play._(board, field, board.start, const [], -1);
  }

  final Board board;
  final Field field;

  /// A bit for every hollow with a peg in it.
  final int pegs;

  /// Every jump made, in order.
  final List<Jump> jumps;

  /// The peg part way through a move, or -1. A move is one peg jumping once
  /// or several times running, so a peg that has just taken something and
  /// could take again is still on the move until it is let go.
  final int carrying;

  int get left => Solver.count(pegs);

  /// How many moves have been made, counting a run of jumps by one peg as
  /// one.
  int get moves => Runs.movesIn(jumps);

  bool has(int hollow) => pegs & (1 << hollow) != 0;

  bool isAt(int row, int column) {
    final hollow = field.at(row, column);
    return hollow >= 0 && has(hollow);
  }

  /// One peg left, which is the whole point.
  bool get isDone => left == 1;

  /// Nothing left that can jump, with more than one peg on the board.
  bool get isStuck => !isDone && Solver.jumpsIn(field, pegs).isEmpty;

  /// The jumps that could be made now.
  ///
  /// Part way through a move it is only the jumps of the peg on the move —
  /// everything else has to wait its turn, which is what makes a move a move.
  List<Jump> get canJump {
    final all = Solver.jumpsIn(field, pegs);
    if (carrying < 0) return all;
    return [for (final jump in all) if (jump.from == carrying) jump];
  }

  /// Why a jump cannot be made, or null if it can.
  ///
  /// The shape of the thing is asked about before the pegs on it: somebody
  /// who taps the square next door has not made a jump that is blocked, they
  /// have not made a jump.
  Refusal? whyNot(int from, int to) {
    if (from < 0 || to < 0) return Refusal.notAJump;
    if (!has(from)) return Refusal.noPeg;
    if (carrying >= 0 && from != carrying) return Refusal.notThatPeg;

    final between = _between(from, to);
    if (between < 0) return Refusal.notAJump;
    if (has(to)) return Refusal.taken;
    if (!has(between)) return Refusal.nothingToTake;
    return null;
  }

  bool canGo(int from, int to) => whyNot(from, to) == null;

  /// The hollow jumped over, or -1 if those two are not a jump apart.
  int _between(int from, int to) {
    for (final jump in field.jumpsFrom(from)) {
      if (jump.to == to) return jump.over;
    }
    return -1;
  }

  /// This board after a jump.
  Play jump(int from, int to) {
    if (!canGo(from, to)) return this;
    final move = Jump(from, _between(from, to), to);
    return Play._(
      board,
      field,
      Solver.after(pegs, move),
      [...jumps, move],
      to,
    );
  }

  /// This board with the peg on the move let go, so somebody else can move.
  ///
  /// Nothing happens to the pegs. It only says that the run is over, which
  /// matters to the count and to nothing else.
  Play get letGo => carrying < 0 ? this : Play._(board, field, pegs, jumps, -1);

  /// This board with the last jump taken back.
  Play get back {
    if (jumps.isEmpty) return this;
    final last = jumps.last;
    final before = (pegs & ~(1 << last.to)) | (1 << last.from) | (1 << last.over);
    final rest = jumps.sublist(0, jumps.length - 1);
    return Play._(
      board,
      field,
      before,
      rest,
      // Back into the middle of the run it came out of, if it was in one.
      rest.isNotEmpty && rest.last.to == last.from ? last.from : -1,
    );
  }

  Play get again => Play.of(board);
}
