import 'package:flutter_test/flutter_test.dart';
import 'package:cubewick/hex/levels.dart';
import 'package:cubewick/hex/play.dart';
import 'package:cubewick/hex/rules.dart';

/// The law of the hexagon, held to.
void main() {
  group('the rules', () {
    test('a hexagon holds 2(ab + bc + ca) triangles, half up and half down', () {
      for (final (a, b, c) in [(1, 1, 1), (2, 2, 1), (2, 2, 2), (2, 3, 3), (3, 3, 3)]) {
        final h = Hexagon(a, b, c);
        expect(h.ups.length, a * b + b * c + c * a, reason: '$a $b $c');
        expect(h.downs.length, h.ups.length, reason: '$a $b $c');
      }
      expect(Hexagon(1, 1, 1).ups, [(true, -1, 1), (true, 0, 0), (true, 0, 1)]);
      expect(Hexagon(1, 1, 1).downs, [(false, -1, 0), (false, -1, 1), (false, 0, 0)]);
    });

    test('lozenges glue an up to a down across one of three edges', () {
      const up = (true, 0, 1);
      expect(Hexagon.mates(up), [(false, 0, 1), (false, 0, 0), (false, -1, 1)]);
      expect(Hexagon.neighbours(up, (false, 0, 0)), isTrue);
      expect(Hexagon.neighbours(up, (false, 1, 1)), isFalse);
      expect(Hexagon.neighbours(up, (true, 0, 0)), isFalse);
      final h = Hexagon(1, 1, 1);
      expect(h.lozenge((false, 0, 0), up), (up, (false, 0, 0)));
      expect(h.lozenge(up, (false, 1, 1)), isNull);
      expect(Hexagon.lean((up, (false, 0, 1))), 0);
      expect(Hexagon.lean((up, (false, 0, 0))), 1);
      expect(Hexagon.lean((up, (false, -1, 1))), 2);
    });

    test('the sweep, the product and the stacks agree', () {
      for (final (a, b, c) in [(1, 1, 1), (2, 2, 1), (2, 2, 2), (2, 3, 3), (3, 3, 3)]) {
        final swept = Hexagon(a, b, c).count();
        expect(swept, Hexagon.macmahon(a, b, c), reason: '$a $b $c');
        expect(swept, Hexagon.stacks(a, b, c), reason: '$a $b $c');
      }
      expect(Hexagon(2, 2, 2).count(), 20);
      expect(Hexagon.macmahon(4, 4, 4), 232848);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(level.hexagon.count(), level.ways, reason: level.name);
      }
      final chipped = Levels.at(4).hexagon;
      expect(chipped.ups, hasLength(10));
      expect(chipped.downs, hasLength(12));
    });
  });

  group('the play', () {
    test('opens bare', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.laid, isEmpty, reason: level.name);
        expect(play.bare, level.hexagon.triangles.length);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap holds, a second lays, a tap on a lozenge lifts, back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap((true, 0, 0));
      expect(play.held, (true, 0, 0));
      expect(play.moves, 0);
      play = play.tap((true, 0, 0));
      expect(play.held, isNull);
      play = play.tap((true, 0, 0)).tap((false, 0, 0));
      expect(play.laid, [((true, 0, 0), (false, 0, 0))]);
      expect(play.moves, 1);
      expect(play.held, isNull);
      play = play.tap((false, 0, 0));
      expect(play.laid, isEmpty);
      expect(play.moves, 2);
      expect(play.back.laid, hasLength(1));
      // A tap on a triangle not beside the held one moves the hold.
      final moved = Play.of(Levels.at(0)).tap((true, 0, 0)).tap((false, -1, 1));
      expect(moved.held, (false, -1, 1));
      expect(moved.laid, isEmpty);
    });

    test('the one-box tiled by hand, both ways', () {
      final a = Play.of(Levels.at(0))
          .tap((true, -1, 1)).tap((false, -1, 1))
          .tap((true, 0, 0)).tap((false, -1, 0))
          .tap((true, 0, 1)).tap((false, 0, 0));
      expect(a.isDone, isTrue);
      expect(a.moves, 3);
      final b = Play.of(Levels.at(0))
          .tap((true, -1, 1)).tap((false, -1, 0))
          .tap((true, 0, 0)).tap((false, 0, 0))
          .tap((true, 0, 1)).tap((false, -1, 1));
      expect(b.isDone, isTrue);
      expect(a.tap((true, 0, 0)), same(a));
    });

    test('the pointer lands every winnable hexagon', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (what, l) = play.next!;
          play = what == 'lift' ? play.tap(l.$1) : play.tap(l.$1).tap(l.$2);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer lifts a lozenge off the aim first', () {
      final aim = Play.aimFor(Levels.at(2))!;
      final off = Play.of(Levels.at(2)).tap((true, 0, 0)).tap((false, 0, 0));
      expect(aim.contains(((true, 0, 0), (false, 0, 0))), isFalse);
      expect(off.next!.$1, 'lift');
    });

    test('the chipped box sticks with two bare, and admits it', () {
      var play = Play.of(Levels.at(4));
      var guard = 0;
      while (play.canLay && guard++ < 20) {
        Lozenge? next;
        for (final up in play.hexagon.ups) {
          if (play.covered(up)) continue;
          for (final d in Hexagon.mates(up)) {
            if (play.hexagon.holds(d) && !play.covered(d)) {
              next = (up, d);
              break;
            }
          }
          if (next != null) break;
        }
        play = play.tap(next!.$1).tap(next.$2);
      }
      // A greedy laying can strand triangles, but never fewer than two
      // stay bare, and the count bare is always even.
      expect(play.laid.length, lessThanOrEqualTo(10));
      expect(play.bare, greaterThanOrEqualTo(2));
      expect(play.bare.isEven, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap((false, 1, 1)), same(play));
    });

    test('the mark stands tiled', () {
      final mark = Play.standing(Levels.at(2), Play.aimFor(Levels.at(2))!);
      expect(mark.isDone, isTrue);
      expect(mark.laid, hasLength(12));
    });
  });
}
