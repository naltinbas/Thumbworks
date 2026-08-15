import 'package:flutter_test/flutter_test.dart';
import 'package:brickholme/yard/levels.dart';
import 'package:brickholme/yard/play.dart';
import 'package:brickholme/yard/rules.dart';

/// The law of the yard, held to.
void main() {
  group('the rules', () {
    test('bricks cover three flags, across or down, on the yard', () {
      const r = Rules(4, 0);
      expect(r.flagsOf((1, true)), [1, 2, 3]);
      expect(r.flagsOf((2, true)), isNull);
      expect(r.flagsOf((7, false)), [7, 11, 15]);
      expect(r.flagsOf((8, false)), isNull);
      expect(r.fits((0, true), const []), isFalse);
      expect(r.fits((1, true), const []), isTrue);
      expect(r.fits((1, true), const [(2, false)]), isFalse);
      expect(r.covered(const [(1, true), (7, false)]), {1, 2, 3, 7, 11, 15});
      expect(r.clashes(const [(1, true), (2, false)]), hasLength(1));
      expect(r.paved(const [(1, true), (4, true), (7, false), (8, true), (12, true)]), isTrue);
      expect(r.paved(const [(1, true), (4, true), (7, false), (8, true)]), isFalse);
      expect(r.openings(const []), hasLength(14));
    });

    test('the walk counts the pavings, and the colouring says which drains', () {
      expect(const Rules(4, 0).pavings(), 4);
      expect(const Rules(4, 5).pavings(), 0);
      expect(const Rules(5, 12).pavings(), 2);
      expect(const Rules(8, 18).pavings(), 356);
      expect(const Rules(8, 0).pavings(), 0);
      const eight = Rules(8, 18);
      expect(eight.counts(sum: true), [21, 22, 21]);
      expect(eight.counts(sum: false), [22, 21, 21]);
      expect(eight.oddColour(sum: true), 1);
      expect(eight.oddColour(sum: false), 0);
      expect(eight.colouringAllows, isTrue);
      expect(const Rules(8, 0).colouringAllows, isFalse);
      expect(const Rules(6, 0).colouringAllows, isFalse);
    });

    test('every drain of the four, five, seven and eight yards: walk and colouring agree', () {
      for (final n in [4, 5, 7, 8]) {
        for (var d = 0; d < n * n; d++) {
          final r = Rules(n, d);
          final walked = r.pavings();
          expect(walked > 0, r.colouringAllows, reason: '$n by $n, drain $d');
          final paving = r.paving();
          expect(paving != null, walked > 0, reason: '$n by $n, drain $d');
          if (paving != null) expect(r.paved(paving), isTrue, reason: '$n by $n, drain $d');
        }
      }
    });

    test('every brick covers one flag of each colour, both slants', () {
      const r = Rules(8, 0);
      for (var c = 0; c < 64; c++) {
        for (final across in [true, false]) {
          final f = r.flagsOf((c, across));
          if (f == null) continue;
          expect(f.map((x) => r.colour(x, sum: true)).toSet(), hasLength(3), reason: '$c $across');
          expect(f.map((x) => r.colour(x, sum: false)).toSet(), hasLength(3), reason: '$c $across');
        }
      }
    });

    test('every label\'s ways is what the walk counts', () {
      for (final level in Levels.all) {
        expect(level.rules.pavings(), level.ways, reason: level.name);
        expect(level.rules.colouringAllows, level.winnable, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens bare, facing across', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.bricks, isEmpty, reason: level.name);
        expect(play.across, isTrue);
        expect(play.bare, level.side * level.side - 1);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap lays, a tap on a brick lifts, the drain and the edge refuse; back undoes', () {
      var play = Play.of(Levels.at(0));
      expect(play.tap(0), same(play));
      expect(play.tap(2), same(play));
      play = play.tap(1);
      expect(play.bricks, [(1, true)]);
      expect(play.moves, 1);
      expect(play.brickOn(3), (1, true));
      final lifted = play.tap(2);
      expect(lifted.bricks, isEmpty);
      expect(lifted.moves, 1);
      expect(lifted.back.bricks, [(1, true)]);
      final down = play.turn;
      expect(down.across, isFalse);
      expect(down.tap(4).bricks, [(1, true), (4, false)]);
      expect(down.facing(false), same(down));
      expect(down.facing(true).across, isTrue);
    });

    test('the four yard by hand', () {
      var play = Play.of(Levels.at(0)).tap(1).tap(4).tap(8).tap(12);
      expect(play.bare, 3);
      expect(play.openings, [(7, false)]);
      play = play.turn.tap(7);
      expect(play.isDone, isTrue);
      expect(play.moves, 5);
      expect(play.tap(1), same(play));
    });

    test('the pointer paves every winnable yard', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (what, brick) = play.next!;
          if (what == 'lift') {
            play = play.tap(brick.$1);
            continue;
          }
          play = play.facing(brick.$2).tap(brick.$1);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).bricks, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says lift when a brick is off the paving', () {
      final aim = Play.aimFor(Levels.at(1))!;
      final play = Play.of(Levels.at(1)).tap(0);
      expect(aim.contains((0, true)) ? play.next!.$1 : play.next!.$1, isIn(['lay', 'lift']));
      final off = Play.of(Levels.at(1)).turn.tap(0);
      expect(off.next, aim.contains((0, false)) ? isNot(('lift', (0, false))) : ('lift', (0, false)));
    });

    test('the hopeless yard sticks, and admits it', () {
      var play = Play.of(Levels.at(4));
      var guard = 0;
      while (!play.isOver && guard++ < 40) {
        final brick = play.openings.first;
        play = play.facing(brick.$2).tap(brick.$1);
      }
      expect(play.stuck, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isDone, isFalse);
      expect(play.bare, greaterThan(0));
      expect(play.tap(63), same(play));
    });

    test('the hopeless yard also admits it at thirty layings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        play = play.tap(1).tap(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
    });

    test('a winnable yard never gives up', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 32; k++) {
        play = play.tap(0).tap(0);
      }
      expect(play.moves, 32);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands paved', () {
      final mark = Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!);
      expect(mark.isDone, isTrue);
      expect(mark.bricks, hasLength(21));
    });
  });
}
