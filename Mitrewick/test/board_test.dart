import 'package:flutter_test/flutter_test.dart';
import 'package:mitrewick/board/levels.dart';
import 'package:mitrewick/board/play.dart';
import 'package:mitrewick/board/rules.dart';

/// The law of the board, held to.
void main() {
  group('the rules', () {
    test('bishops clash along diagonals either way, and not otherwise', () {
      expect(Rules.clash((0, 0), (2, 2)), isTrue);
      expect(Rules.clash((0, 2), (2, 0)), isTrue);
      expect(Rules.clash((0, 0), (0, 2)), isFalse);
      expect(Rules.clash((1, 1), (3, 2)), isFalse);
      expect(Rules.clashes(const [(0, 0), (1, 1), (0, 2)]), [(0, 1), (1, 2)]);
      expect(Rules.peaceful(const [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2)]), isTrue);
    });

    test('the diagonals are numbered, and the corners share the long one', () {
      for (var n = 2; n <= 5; n++) {
        final rules = Rules(n);
        expect(rules.cornersShareFalling, isTrue);
        expect(Rules.rising((0, 0)), 0);
        expect(Rules.rising((n - 1, n - 1)), 2 * n - 2);
        expect(rules.most, 2 * n - 2);
      }
    });

    test('the sweep and the diagonals agree on the small boards', () {
      for (var n = 2; n <= 4; n++) {
        final rules = Rules(n);
        for (var k = 1; k <= 2 * n - 1; k++) {
          final (peace, all) = rules.sweep(k);
          expect(peace, rules.peacefulByDiagonals(k), reason: '$n $k');
          expect(all, Rules.choose(n * n, k), reason: '$n $k');
        }
      }
    });

    test('two less than twice the side stand 2^n ways, one less never', () {
      for (var n = 2; n <= 6; n++) {
        final rules = Rules(n);
        expect(rules.peacefulByDiagonals(2 * n - 2), 1 << n, reason: '$n');
        expect(rules.peacefulByDiagonals(2 * n - 1), 0, reason: '$n');
      }
      expect(Rules(4).sweep(7), (0, 11440));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final rules = Rules(level.side);
        var all = 0, ways = 0;
        rules.settings(level.bishops, (b) {
          if (!level.given.every(b.contains)) return;
          all++;
          if (Rules.peaceful(b)) ways++;
        });
        expect(all, level.settings, reason: level.name);
        expect(ways, level.ways, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with the given bishops only', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.bishops, level.given, reason: level.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap sets, a tap lifts, counted both ways, and back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.tap((0, 0));
      expect(play.bishops, [(0, 0)]);
      expect(play.moves, 1);
      play = play.tap((0, 0));
      expect(play.bishops, isEmpty);
      expect(play.moves, 2);
      expect(play.back.bishops, [(0, 0)]);
      expect(play.tap((4, 4)), same(play));
    });

    test('a given bishop never lifts, and no bishop past the count', () {
      final held = Play.of(Levels.at(3));
      expect(held.tap((0, 0)), same(held));
      final full = Play.of(Levels.at(0)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((2, 1));
      expect(full.isDone, isTrue);
      expect(full.tap((1, 0)), same(full));
    });

    test('the boards by hand', () {
      final three = Play.of(Levels.at(0)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((2, 1));
      expect(three.peaceful, isTrue);
      expect(three.isDone, isTrue);
      final four = Play.of(Levels.at(1)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((0, 3)).tap((3, 1)).tap((3, 2));
      expect(four.isDone, isTrue);
      expect(four.risingUsed, 6);
      final clash = Play.of(Levels.at(1)).tap((0, 0)).tap((1, 1));
      expect(clash.clashes, [(0, 1)]);
      expect(clash.peaceful, isFalse);
      final heldFull = Play.of(Levels.at(3)).tap((0, 1)).tap((0, 2)).tap((0, 3)).tap((3, 1)).tap((3, 2));
      expect(heldFull.isDone, isTrue);
    });

    test('the pointer lands every winnable board', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, s) = play.next!;
          play = play.tap(s);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer lifts a bishop off the aim first', () {
      final play = Play.of(Levels.at(1)).tap((1, 1));
      expect(play.next!.$1, 'lift');
      expect(play.next!.$2, (1, 1));
    });

    test('the hopeless board admits it at thirteen moves', () {
      var play = Play.of(Levels.at(4)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((0, 3)).tap((3, 1)).tap((3, 2)).tap((3, 3));
      expect(play.full, isTrue);
      expect(play.clashes, [(0, 6)]);
      for (var dither = 0; dither < 3; dither++) {
        play = play.tap((3, 3)).tap((3, 3));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap((3, 3)), same(play));
    });

    test('a winnable board never gives up', () {
      var play = Play.of(Levels.at(1));
      for (var dither = 0; dither < 7; dither++) {
        play = play.tap((1, 1)).tap((1, 1));
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands at peace', () {
      final mark = Play.standing(Levels.at(1), const [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2)]);
      expect(mark.isDone, isTrue);
      expect(mark.moves, 6);
    });
  });
}
