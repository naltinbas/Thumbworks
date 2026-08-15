import 'package:flutter_test/flutter_test.dart';
import 'package:cornerstow/yard/levels.dart';
import 'package:cornerstow/yard/play.dart';
import 'package:cornerstow/yard/rules.dart';

/// The identity, the search, the gnomons and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the identity', () {
    test('the cubes summed are the square of the sum', () {
      for (var n = 1; n <= 30; n++) {
        expect(Rules.cubes(n), Rules.side(n) * Rules.side(n), reason: '$n');
      }
      expect(Rules.side(4), 10);
      expect(Rules.cubes(4), 100);
    });

    test('the flags of a yard, halves for the even sizes', () {
      expect(Rules.flags(2), [(1, 1, 1, 1), (2, 2, 2, 1), (2, 1, 2, 2)]);
      expect(Rules.flags(3), [(1, 1, 1, 1), (2, 2, 2, 1), (2, 1, 2, 2), (3, 3, 3, 3)]);
      expect(Rules.flags(4).last, (4, 2, 4, 2));
      expect(Rules.flags(2, whole: true), [(1, 1, 1, 1), (2, 2, 2, 2)]);
      for (var n = 1; n <= 8; n++) {
        final cells = Rules.flags(n).fold(0, (sum, f) => sum + f.$1 * f.$2 * f.$4);
        expect(cells, Rules.side(n) * Rules.side(n), reason: '$n');
      }
    });
  });

  group('the search', () {
    test('finds every paving of the three and the six, both ways', () {
      expect(Rules.pavings(3, Rules.flags(2)).$1, 12);
      expect(Rules.pavings(3, Rules.flags(2), byColumns: true).$1, 12);
      expect(Rules.pavings(6, Rules.flags(3)).$1, 80);
      expect(Rules.pavings(6, Rules.flags(3), byColumns: true).$1, 80);
    });

    test('the ten, 6,892 ways', () {
      expect(Rules.pavings(10, Rules.flags(4)).$1, 6892);
    });

    test('whole flags never pave the three or the six', () {
      expect(Rules.pavings(3, Rules.flags(2, whole: true)).$1, 0);
      expect(Rules.pavings(6, Rules.flags(3, whole: true)).$1, 0);
    });

    test('the first paving of the three, and that it paves', () {
      final (count, first) = Rules.pavings(3, Rules.flags(2));
      expect(count, 12);
      expect(first, [(0, 1, 1, 0, 0), (1, 2, 2, 1, 0), (2, 1, 2, 0, 1), (2, 2, 1, 1, 2)]);
      expect(Rules.paves(3, first!), isTrue);
      expect(Rules.paves(3, first.sublist(1)), isFalse);
    });

    test('Nicomachus\'s gnomons pave every yard to eight with exactly the flags', () {
      for (var n = 1; n <= 8; n++) {
        final g = Rules.gnomons(n);
        expect(Rules.paves(Rules.side(n), g), isTrue, reason: '$n');
        final kinds = Rules.flags(n);
        for (var i = 0; i < kinds.length; i++) {
          expect(g.where((p) => p.$1 == i).length, kinds[i].$4, reason: 'n $n kind $i');
        }
      }
      expect(Rules.gnomons(2), [(0, 1, 1, 0, 0), (1, 2, 2, 1, 1), (2, 1, 2, 0, 1), (2, 2, 1, 1, 0)]);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Three, Whole']);
      expect(Levels.at(4).whole, isTrue);
      expect(Levels.at(3).flagCount, 17);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'pave the three-by-three yard with one flag of one and two of two, the second two cut in halves');
      expect(Levels.at(4).task, 'pave the three-by-three yard with one flag of one and two whole flags of two');
    });

    test('an ask is met by a paving and by nothing less', () {
      final first = Rules.pavings(3, Rules.flags(2)).$2!;
      expect(Levels.at(0).meets(first), isTrue);
      expect(Levels.at(0).meets(first.sublist(0, 3)), isFalse);
      expect(Levels.at(1).meets(Rules.gnomons(3)), isTrue);
    });
  });

  group('the play', () {
    test('opens bare with the tray full', () {
      final play = Play.of(Levels.at(0));
      expect(play.laid, isEmpty);
      expect(play.left(2), 2);
      expect(play.bareCells, 9);
      expect(play.isDone, isFalse);
    });

    test('a flag is taken, laid where it fits, and lifted again', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(1);
      expect(play.held, 1);
      expect(play.heldShape, (2, 2));
      play = play.tap(2, 0);
      expect(play.refused, isTrue);
      play = play.tap(1, 0);
      expect(play.laid, [(1, 2, 2, 1, 0)]);
      expect(play.held, isNull);
      expect(play.moves, 1);
      play = play.tap(2, 1);
      expect(play.laid, isEmpty);
      expect(play.moves, 1);
    });

    test('a half turns upright and back', () {
      var play = Play.of(Levels.at(0)).hold(2);
      expect(play.heldShape, (2, 1));
      play = play.turn();
      expect(play.heldShape, (1, 2));
      play = play.tap(0, 1);
      expect(play.laid, [(2, 1, 2, 0, 1)]);
      expect(play.left(2), 1);
      // The whole two does not turn.
      expect(Play.of(Levels.at(0)).hold(1).turn().heldShape, (2, 2));
    });

    test('back undoes one action', () {
      final play = Play.of(Levels.at(0)).hold(0).tap(0, 0);
      expect(play.back.laid, isEmpty);
      expect(play.back.held, 0);
    });

    test('the three lands by hand', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(0).tap(0, 0).hold(1).tap(1, 0).hold(2).turn().tap(0, 1).hold(2).turn().tap(1, 2);
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
      expect(play.bareCells, 0);
    });

    test('the whole twos are stuck at once', () {
      var play = Play.of(Levels.at(4));
      expect(play.stuck, isFalse);
      play = play.hold(1).tap(0, 0);
      expect(play.stuck, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer walks the search\'s first paving, turning and lifting as needed', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (Aim.tray, 0, 0));
      play = play.hold(0);
      expect(play.next, (Aim.cell, 0, 0));
      play = play.tap(0, 0);
      // The whole two where the first paving has the halves: lifted first.
      play = play.hold(1).tap(0, 1);
      expect(play.next, (Aim.lift, 0, 1));
      play = play.tap(0, 1);
      play = play.hold(1).tap(1, 0).hold(2);
      expect(play.next, (Aim.turn, 0, 0));
      play = play.turn();
      expect(play.next, (Aim.cell, 0, 1));
    });

    test('following the pointer paves every winnable yard', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 80) {
          final (aim, a, b) = play.next!;
          play = switch (aim) {
            Aim.tray => play.hold(a),
            Aim.turn => play.turn(),
            Aim.cell || Aim.lift => play.tap(a, b),
          };
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.flagCount);
      }
    });
  });
}
