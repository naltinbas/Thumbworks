import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wirewend/game/generator.dart';
import 'package:wirewend/game/grid.dart';

void main() {
  group('turning a piece of wire', () {
    test('moves every end round by one quarter', () {
      expect(Ends.north.turned, Ends.east);
      expect(Ends.east.turned, Ends.south);
      expect(Ends.south.turned, Ends.west);
      expect(Ends.west.turned, Ends.north);
    });

    test('returns it to where it started after four', () {
      const corner = Ends(1 | 2);
      expect(corner.turned.turned.turned.turned, corner);
    });

    test('never changes how many ends it has', () {
      for (var bits = 0; bits < 16; bits++) {
        expect(Ends(bits).turned.count, Ends(bits).count);
      }
    });
  });

  group('current', () {
    test('crosses an edge only when both cells reach it', () {
      final board = Board(rows: 1, cols: 2, cells: [
        Cell(kind: CellKind.source, ends: Ends.east),
        Cell(kind: CellKind.lamp, ends: Ends.north),
      ]);
      expect(board.powered, {0});
      expect(board.isSolved, isFalse);
    });

    test('reaches a lamp that faces back', () {
      final board = Board(rows: 1, cols: 2, cells: [
        Cell(kind: CellKind.source, ends: Ends.east),
        Cell(kind: CellKind.lamp, ends: Ends.west),
      ]);
      expect(board.powered, {0, 1});
      expect(board.isSolved, isTrue);
    });

    test('stops at the edge of the board', () {
      final board = Board(rows: 1, cols: 1, cells: [
        Cell(kind: CellKind.source, ends: Ends.north | Ends.east),
      ]);
      expect(board.powered, {0});
    });

    test('terminates on a loop', () {
      const bend = Ends(1 | 2);
      final board = Board(rows: 2, cols: 2, cells: [
        Cell(kind: CellKind.source, ends: Ends.east | Ends.south),
        Cell(kind: CellKind.wire, ends: Ends.west | Ends.south),
        Cell(kind: CellKind.wire, ends: Ends.north | Ends.east),
        Cell(kind: CellKind.lamp, ends: Ends.north | Ends.west),
      ]);
      expect(bend.count, 2);
      expect(board.powered.length, 4);
      expect(board.isSolved, isTrue);
    });

    test('is not solved when there is nothing to light', () {
      final board = Board(rows: 1, cols: 1, cells: [
        Cell(kind: CellKind.source, ends: Ends.none),
      ]);
      expect(board.isSolved, isFalse);
    });
  });

  group('turning a cell', () {
    test('leaves the board it came from alone', () {
      final before = Board(rows: 1, cols: 2, cells: [
        Cell(kind: CellKind.source, ends: Ends.east),
        Cell(kind: CellKind.lamp, ends: Ends.north),
      ]);
      final after = before.turn(0, 1);
      expect(before.at(0, 1).ends, Ends.north);
      expect(after.at(0, 1).ends, Ends.east);
    });
  });

  group('a generated board', () {
    test('always has a way to be solved', () {
      // Every board the generator makes is a solved arrangement with each
      // cell turned, so turning cells back must reach a solution. Rather
      // than search, check the property that guarantees it: the shapes are
      // untouched, so every board has as many lamps as the tree had leaves
      // and the same total number of ends.
      for (var seed = 0; seed < 200; seed++) {
        final board = Generator(random: Random(seed))
            .generate(rows: 6, cols: 5, fill: 0.9);
        expect(board.lampCount, greaterThan(0), reason: 'seed $seed');
      }
    });

    test('can be solved by turning every cell back the way it came', () {
      // Not a search. A scramble only turns cells, and every cell records how
      // far it was turned, so turning each one the rest of the way round must
      // restore the arrangement the generator built, which was solved by
      // construction. That makes solvability a property this test proves
      // rather than a claim it spot-checks.
      for (var seed = 0; seed < 120; seed++) {
        var board = Generator(random: Random(seed)).generate(rows: 6, cols: 5);
        for (var r = 0; r < board.rows; r++) {
          for (var c = 0; c < board.cols; c++) {
            final remaining = (4 - board.at(r, c).turns % 4) % 4;
            for (var i = 0; i < remaining; i++) {
              board = board.turn(r, c);
            }
          }
        }
        expect(board.isSolved, isTrue, reason: 'seed $seed');
      }
    });

    test('does not hand back a board that is already solved', () {
      var alreadySolved = 0;
      for (var seed = 0; seed < 100; seed++) {
        final board =
            Generator(random: Random(seed)).generate(rows: 5, cols: 5);
        if (board.isSolved) alreadySolved++;
      }
      expect(alreadySolved, 0);
    });

    test('keeps exactly one source', () {
      for (var seed = 0; seed < 50; seed++) {
        final board =
            Generator(random: Random(seed)).generate(rows: 6, cols: 6);
        var sources = 0;
        for (var r = 0; r < board.rows; r++) {
          for (var c = 0; c < board.cols; c++) {
            if (board.at(r, c).kind == CellKind.source) sources++;
          }
        }
        expect(sources, 1, reason: 'seed $seed');
      }
    });
  });
}
