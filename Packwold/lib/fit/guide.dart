import 'boxes.dart';
import 'cover.dart';
import 'play.dart';

/// A piece, and where it should be.
class Step {
  const Step({required this.where, required this.wrong});

  /// Where the piece belongs — or, when it is [wrong], where it is lying
  /// instead.
  final Placement where;

  /// Whether this is a piece to pick up rather than one to put down.
  final bool wrong;

  int get piece => where.piece;
  String get letter => where.letter;
  List<int> get cells => where.cells;
}

/// Knows the one packing, and can say what to do next from wherever a player
/// has got to.
///
/// It is worked out once, when the puzzle opens, and then only looked at. A
/// hint is not a fresh search from a half-packed box — it is the packing,
/// which is the same one it was at the start, because there is only one.
class Guide {
  Guide(this.answer);

  factory Guide.of(Puzzle puzzle) {
    final found =
        Cover(puzzle.box, letters: puzzle.letters).solve(enough: 1).first!;
    // The search hands them back in the order it laid them, which is its
    // order and not the tray's.
    final byPiece = List<Placement?>.filled(puzzle.letters.length, null);
    for (final one in found) {
      byPiece[one.piece] = one;
    }
    return Guide([for (final one in byPiece) one!]);
  }

  /// Where each piece goes, in the tray's order.
  final List<Placement> answer;

  /// Whether a piece is where the answer has it. A piece still in the tray is
  /// not wrong — it is not anywhere yet.
  bool isRight(Play play, int piece) {
    final laid = play.placed(piece);
    if (laid == null) return true;
    return laid.cells.toSet().containsAll(answer[piece].cells) &&
        laid.cells.length == answer[piece].cells.length;
  }

  /// What to do next, or null when the box is packed.
  ///
  /// Pieces in the wrong place come first, because they are on ground
  /// somebody else needs and no amount of laying pieces elsewhere will help.
  Step? next(Play play) {
    for (var piece = 0; piece < answer.length; piece++) {
      if (isRight(play, piece)) continue;
      return Step(where: play.placed(piece)!, wrong: true);
    }
    for (var piece = 0; piece < answer.length; piece++) {
      if (play.isLaid(piece)) continue;
      return Step(where: answer[piece], wrong: false);
    }
    return null;
  }

  /// How many pieces are not yet where they belong.
  int left(Play play) {
    var over = 0;
    for (var piece = 0; piece < answer.length; piece++) {
      if (!play.isLaid(piece) || !isRight(play, piece)) over++;
    }
    return over;
  }
}
