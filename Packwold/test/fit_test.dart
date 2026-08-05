import 'package:flutter_test/flutter_test.dart';
import 'package:packwold/fit/boxes.dart';
import 'package:packwold/fit/cover.dart';
import 'package:packwold/fit/guide.dart';
import 'package:packwold/fit/pieces.dart';
import 'package:packwold/fit/play.dart';

void main() {
  group('the twelve pieces', () {
    test('are all five squares, and all different', () {
      expect(Piece.count, 12);
      final pictures = <String>{};
      for (final piece in Piece.all) {
        expect(piece.cells, hasLength(5), reason: piece.letter);
        expect(pictures.add(Shape(piece.letter, piece.cells).picture), isTrue,
            reason: '${piece.letter} is the same shape as another');
      }
    });

    test('and each is joined up, not five loose squares', () {
      for (final piece in Piece.all) {
        final todo = [piece.cells.first];
        final seen = {piece.cells.first};
        while (todo.isNotEmpty) {
          final (row, column) = todo.removeLast();
          for (final beside in [
            (row - 1, column),
            (row + 1, column),
            (row, column - 1),
            (row, column + 1),
          ]) {
            if (!piece.cells.contains(beside) || !seen.add(beside)) continue;
            todo.add(beside);
          }
        }
        expect(seen, hasLength(5), reason: '${piece.letter} is in two parts');
      }
    });

    test('and lie the number of ways their symmetry allows', () {
      // Every pentomino is one of five symmetries, and each says how many of
      // the eight turns and flips give something new. Counting them by hand
      // is how a game ships an F that cannot be flipped.
      const ways = <String, int>{
        'F': 8, 'L': 8, 'N': 8, 'P': 8, 'Y': 8, // no symmetry at all
        'T': 4, 'U': 4, 'V': 4, 'W': 4, // one mirror
        'Z': 4, // turns onto itself twice
        'I': 2, // two mirrors
        'X': 1, // every symmetry there is
      };
      for (final piece in Piece.all) {
        expect(piece.ways, hasLength(ways[piece.letter]),
            reason: piece.letter);
      }
    });

    test('and every way of lying is still the same five squares', () {
      for (final piece in Piece.all) {
        for (final shape in piece.ways) {
          expect(shape.cells, hasLength(5));
          expect(shape.cells.toSet(), hasLength(5), reason: 'two in one place');
          expect(shape.cells.first.$1, 0, reason: 'not pulled to the top');
          expect(shape.cells.map((cell) => cell.$2).reduce((a, b) => a < b ? a : b),
              0,
              reason: 'not pulled to the left');
        }
      }
    });
  });

  group('the rectangles everybody has counted', () {
    // The one thing here checked against somebody else's work rather than
    // against itself. These four numbers were worked out decades ago and are
    // in every book on the subject; each packing has three more like it,
    // turned round and flipped over, so the search finds four times as many.
    test('3x20 has two packings, and 4x15 has 368', () {
      for (final known in const [(3, 20, 2), (4, 15, 368)]) {
        final box = Box.plain(known.$2, known.$1);
        expect(box.cells, 60);
        final found = Cover(box).solve(enough: 1 << 30);
        expect(found.count, known.$3 * 4,
            reason: '${known.$1}x${known.$2} came out at ${found.count ~/ 4}');
      }
    });

    test('and a rectangle nothing fits in has none', () {
      // Sixty squares are needed and 4x14 has fifty six of them.
      final found = Cover(Box.plain(14, 4)).solve();
      expect(found.canBeDone, isFalse);
    });
  });

  group('packing a box', () {
    test('covers every cell once, with each piece used once', () {
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        final box = puzzle.box;
        final packing =
            Cover(box, letters: puzzle.letters).solve().first!;

        expect(packing, hasLength(puzzle.pieces), reason: puzzle.name);
        final covered = <int>[];
        for (final one in packing) {
          expect(one.cells, hasLength(5), reason: puzzle.name);
          covered.addAll(one.cells);
        }
        expect(covered.toSet(), hasLength(box.cells),
            reason: '${puzzle.name}: two pieces on one cell');
        expect(
          packing.map((one) => one.letter).toSet(),
          puzzle.letters.toSet(),
          reason: puzzle.name,
        );
      }
    });

    test('and every shape it uses is a way that piece can lie', () {
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        for (final one in Cover(puzzle.box, letters: puzzle.letters)
            .solve()
            .first!) {
          final ways = Piece.of(one.letter).ways.map((way) => way.picture);
          expect(ways, contains(one.shape.picture), reason: puzzle.name);
        }
      }
    });
  });

  group('every puzzle', () {
    test('has exactly one packing', () {
      // The whole design. Two packings and a guess can be as right as a
      // reason.
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        final found =
            Cover(puzzle.box, letters: puzzle.letters).solve(enough: 3);
        expect(found.count, 1,
            reason: '${puzzle.name} has ${found.count} packings');
      }
    });

    test('has room for its pieces and no more', () {
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        expect(puzzle.box.cells, puzzle.pieces * 5, reason: puzzle.name);
        expect(puzzle.letters.toSet(), hasLength(puzzle.pieces),
            reason: '${puzzle.name} asks for a piece twice');
        expect(puzzle.rows.every((row) => row.length == puzzle.wide), isTrue,
            reason: '${puzzle.name} is ragged');
      }
    });

    test('and is one piece of ground rather than two', () {
      // A box in two halves is two puzzles, and an easier one than it looks.
      for (var i = 0; i < Puzzles.count; i++) {
        final puzzle = Puzzles.at(i);
        final box = puzzle.box;
        var from = -1;
        for (var row = 0; row < box.deep && from < 0; row++) {
          for (var column = 0; column < box.wide && from < 0; column++) {
            if (!box.isHole(row, column)) from = row * box.wide + column;
          }
        }

        final seen = {from};
        final todo = [from];
        while (todo.isNotEmpty) {
          final here = todo.removeLast();
          final row = here ~/ box.wide;
          final column = here % box.wide;
          for (final (r, c) in [
            (row - 1, column),
            (row + 1, column),
            (row, column - 1),
            (row, column + 1),
          ]) {
            if (box.isHole(r, c) || !seen.add(r * box.wide + c)) continue;
            todo.add(r * box.wide + c);
          }
        }
        expect(seen, hasLength(box.cells), reason: '${puzzle.name} is in two');
      }
    });
  });

  group('laying pieces', () {
    Play start([int which = 0]) => Play.of(Puzzles.at(which));

    test('starts with everything in the tray', () {
      final play = start();
      expect(play.laid, 0);
      expect(play.empty, play.box.cells);
      expect(play.isDone, isFalse);
      for (var piece = 0; piece < play.pieces; piece++) {
        expect(play.isLaid(piece), isFalse);
      }
    });

    test('puts a piece down with its first square where it was asked', () {
      final play = start();
      final want = Guide.of(Puzzles.at(0)).answer.first;
      final laid = play.layAs(want);

      expect(laid.isLaid(0), isTrue);
      expect(laid.placed(0)!.cells.toSet(), want.cells.toSet());
      expect(laid.laid, 1);
      expect(laid.empty, play.box.cells - 5);
    });

    test('and refuses one that hangs over the edge, or lies on a hole, or on '
        'something else', () {
      var play = start();
      // The top left of Smallholding is a hole, and the row above the box is
      // not there at all.
      expect(play.whyNot(0, 0, 0), Refusal.onAHole);

      final want = Guide.of(Puzzles.at(0)).answer;
      play = play.layAs(want[0]);
      final on = want[0].cells.first;
      final row = _rowOf(play, on);
      final column = _columnOf(play, on);
      expect(play.whyNot(1, row, column), Refusal.onAnother);

      expect(play.whyNot(1, play.box.deep - 1, play.box.wide - 1),
          isNot(isNull));
      expect(Refusal.overTheEdge.says, contains('over the edge'));
    });

    test('turns a piece a quarter turn, and back round in four', () {
      var play = start();
      final piece = play.letters.indexOf('L');
      expect(play.waysFor(piece), 8);

      final seen = <String>{};
      for (var turn = 0; turn < 4; turn++) {
        seen.add(play.shapeOf(piece).picture);
        play = play.turn(piece);
      }
      expect(seen, hasLength(4), reason: 'a turn that changed nothing');
      expect(play.shapeOf(piece).picture, Piece.of('L').ways.first.picture,
          reason: 'and round to where it started');
    });

    test('and flips it over, and back in two', () {
      var play = start();
      final piece = play.letters.indexOf('L');
      final first = play.shapeOf(piece).picture;

      play = play.flip(piece);
      expect(play.shapeOf(piece).picture, isNot(first));
      expect(play.flip(piece).shapeOf(piece).picture, first);
    });

    test('and turning and flipping together reach every way it can lie', () {
      var play = start();
      final piece = play.letters.indexOf('L');
      final seen = <String>{};
      for (var flip = 0; flip < 2; flip++) {
        for (var turn = 0; turn < 4; turn++) {
          seen.add(play.shapeOf(piece).picture);
          play = play.turn(piece);
        }
        play = play.flip(piece);
      }
      expect(seen, hasLength(play.waysFor(piece)));
    });

    test('and a piece that turns onto itself stays as it was', () {
      // The X is the same shape whatever is done to it, so the button is
      // honest rather than broken.
      final play = Play.of(Puzzles.at(3));
      final piece = play.letters.indexOf('X');
      expect(play.waysFor(piece), 1);
      expect(play.turn(piece).shapeOf(piece).picture,
          play.shapeOf(piece).picture);
    });

    test('and turning a piece that is lying somewhere picks it up first', () {
      final want = Guide.of(Puzzles.at(0)).answer;
      final play = start().layAs(want[0]);
      expect(play.isLaid(0), isTrue);

      final turned = play.turn(0);
      expect(turned.isLaid(0), isFalse);
      expect(turned.empty, turned.box.cells);
    });

    test('takes a piece back off the box', () {
      final want = Guide.of(Puzzles.at(0)).answer;
      final play = start().layAs(want[0]);

      expect(play.take(0).isLaid(0), isFalse);
      expect(play.take(0).ownerOf(want[0].cells.first), -1);
      expect(play.take(0).take(0).laid, 0, reason: 'and again does nothing');
    });

    test('and is finished when every piece is down', () {
      var play = start();
      for (final want in Guide.of(Puzzles.at(0)).answer) {
        expect(play.isDone, isFalse);
        play = play.layAs(want);
      }
      expect(play.isDone, isTrue);
      expect(play.empty, 0);
      expect(play.packing, hasLength(play.pieces));
    });

    test('and every puzzle can be packed by laying the answer out',
        () {
      for (var which = 0; which < Puzzles.count; which++) {
        final puzzle = Puzzles.at(which);
        final guide = Guide.of(puzzle);
        var play = Play.of(puzzle);

        for (var step = guide.next(play); step != null; step = guide.next(play)) {
          expect(step.wrong, isFalse, reason: puzzle.name);
          play = play.layAs(step.where);
        }
        expect(play.isDone, isTrue, reason: puzzle.name);
      }
    });
  });

  group('a hint', () {
    test('names a piece and where it goes', () {
      final puzzle = Puzzles.at(0);
      final guide = Guide.of(puzzle);
      final play = Play.of(puzzle);

      final step = guide.next(play)!;
      expect(step.wrong, isFalse);
      expect(step.letter, puzzle.letters[step.piece]);
      expect(step.cells, hasLength(5));
      expect(guide.left(play), puzzle.pieces);
    });

    test('and points at a piece in the wrong place first', () {
      final puzzle = Puzzles.at(0);
      final guide = Guide.of(puzzle);
      var play = Play.of(puzzle);

      // Somewhere that piece really fits, and that the answer does not use.
      final want = guide.answer[0];
      var wrong = -1;
      for (var cell = 0; cell < play.box.cells && wrong < 0; cell++) {
        final row = _rowOf(play, cell);
        final column = _columnOf(play, cell);
        if (!play.canLay(0, row, column)) continue;
        final laid = play.lay(0, row, column);
        if (laid.placed(0)!.cells.toSet().containsAll(want.cells)) continue;
        wrong = cell;
        play = laid;
      }
      expect(wrong, isNonNegative, reason: 'nowhere wrong to put it');
      expect(guide.isRight(play, 0), isFalse);

      final step = guide.next(play)!;
      expect(step.wrong, isTrue);
      expect(step.piece, 0);
      expect(step.cells.toSet(), play.placed(0)!.cells.toSet());
    });

    test('and has nothing to say once the box is packed', () {
      final puzzle = Puzzles.at(0);
      final guide = Guide.of(puzzle);
      var play = Play.of(puzzle);
      for (final want in guide.answer) {
        play = play.layAs(want);
      }
      expect(guide.next(play), isNull);
      expect(guide.left(play), 0);
    });
  });
}

int _rowOf(Play play, int cell) {
  for (var row = 0; row < play.box.deep; row++) {
    for (var column = 0; column < play.box.wide; column++) {
      if (play.box.at(row, column) == cell) return row;
    }
  }
  return -1;
}

int _columnOf(Play play, int cell) {
  for (var row = 0; row < play.box.deep; row++) {
    for (var column = 0; column < play.box.wide; column++) {
      if (play.box.at(row, column) == cell) return column;
    }
  }
  return -1;
}
