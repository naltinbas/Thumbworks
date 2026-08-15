import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rimsbury/roll/levels.dart';
import 'package:rimsbury/roll/play.dart';
import 'package:rimsbury/roll/rules.dart';

/// The turns, the asks and the play, checked at the domain: nothing here
/// touches a widget.
void main() {
  group('the turns', () {
    test('by the formula: hoop over roller, and one on or off for the trip', () {
      expect(Rules.turns(3, 3, false), (2, 1));
      expect(Rules.turns(2, 1, false), (3, 1));
      expect(Rules.turns(1, 2, false), (3, 2));
      expect(Rules.turns(6, 1, false), (7, 1));
      expect(Rules.turns(1, 6, false), (7, 6));
      expect(Rules.turns(4, 2, true), (1, 1));
      expect(Rules.turns(6, 2, true), (2, 1));
      expect(Rules.turns(6, 4, true), (1, 2));
      expect(Rules.turns(3, 3, true), isNull);
      expect(Rules.turns(2, 5, true), isNull);
      expect(Rules.fits(2, 5, false), isTrue);
      expect(Rules.settings, 72);
    });

    test('by the roll: pivots about the point of contact add up to the same', () {
      expect(Rules.turnsRolled(3, 3, false), closeTo(2, 1e-5));
      expect(Rules.turnsRolled(2, 1, false), closeTo(3, 1e-5));
      expect(Rules.turnsRolled(1, 2, false), closeTo(1.5, 1e-5));
      expect(Rules.turnsRolled(4, 2, true), closeTo(-1, 1e-5));
      expect(Rules.turnsRolled(6, 4, true), closeTo(-0.5, 1e-5));
      expect(Rules.turnsRolled(3, 3, true).isNaN, isTrue);
    });

    test('the mark starts on the hoop and, inside a hoop of twice the roller, runs a diameter', () {
      final (cx, cy, mx, my) = Rules.place(3, 1, false, 0);
      expect(cx, closeTo(4, 1e-12));
      expect(cy, closeTo(0, 1e-12));
      expect(mx, closeTo(3, 1e-12));
      expect(my, closeTo(0, 1e-12));
      for (var k = 0; k < 360; k++) {
        final (_, _, x, y) = Rules.place(4, 2, true, 2 * pi * k / 360);
        expect(y.abs(), lessThan(1e-9));
        expect(x.abs(), lessThanOrEqualTo(4 + 1e-9));
      }
      // The equal coins: after half a trip the mark is at the far outside.
      final (_, _, fx, fy) = Rules.place(2, 2, false, pi);
      expect(fx, closeTo(-6, 1e-9));
      expect(fy.abs(), lessThan(1e-9));
    });

    test('the words', () {
      expect(Rules.told(3, 1), 'a hoop of three and a roller of one');
      expect(Rules.rim(3, 3), (1, 1));
      expect(Rules.rim(6, 4), (3, 2));
      expect(Rules.fraction((3, 2)), '3/2');
      expect(Rules.fraction((2, 1)), '2');
      expect(Rules.turnsTold((2, 1)), 'two turns');
      expect(Rules.turnsTold((1, 1)), 'one turn');
      expect(Rules.turnsTold((3, 2)), 'three halves of a turn');
      expect(Rules.turnsTold((7, 6)), 'seven sixths of a turn');
      expect(Rules.turnsTold((1, 2)), 'half a turn');
      expect(Rules.turnsTold((1, 3)), 'a third of a turn');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Once']);
      for (final level in Levels.all) {
        var met = 0;
        for (final inside in [false, true]) {
          for (var hoop = 1; hoop <= 6; hoop++) {
            for (var coin = 1; coin <= 6; coin++) {
              if (level.meets(hoop, coin, inside)) met++;
            }
          }
        }
        expect(met, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2, level.inside), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the hoop and the roller so the roller turns exactly twice going round the outside');
      expect(Levels.at(2).task, 'set the hoop and the roller so the roller turns exactly one and a half times going round the outside');
      expect(Levels.at(3).task, 'set the hoop and the roller so the roller turns exactly once going round the inside');
      expect(Levels.at(4).task, 'set the hoop and the roller so the roller turns exactly once going round the outside');
    });

    test('an ask is met by the sizes on its side', () {
      expect(Levels.at(0).meets(3, 3, false), isTrue);
      expect(Levels.at(0).meets(3, 3, true), isFalse);
      expect(Levels.at(1).meets(6, 3, false), isTrue);
      expect(Levels.at(3).meets(6, 3, true), isTrue);
      expect(Levels.at(3).meets(6, 3, false), isFalse);
      expect(Levels.at(4).meets(1, 6, false), isFalse);
    });
  });

  group('the play', () {
    test('opens on a hoop of three and a roller of one, outside, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.hoop, play.coin, play.inside, play.moves), (3, 1, false, 0));
        expect(play.turns, (4, 1));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a dial a step, a dial at its end stays, and a flip changes the side', () {
      var play = Play.of(Levels.at(0)).set(0, 1);
      expect((play.hoop, play.coin, play.moves), (4, 1, 1));
      play = play.set(1, -1);
      expect(play, same(play.set(1, -1)));
      expect(play.moves, 1);
      play = play.flip();
      expect((play.inside, play.moves), (true, 2));
      expect(play.turns, (3, 1));
      final atEnd = Play.standing(Levels.at(1), 6, 6, false);
      expect(atEnd.set(0, 1), same(atEnd));
      expect(atEnd.set(1, 1), same(atEnd));
      expect(atEnd.set(0, -1).hoop, 5);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(1, 1).flip();
      expect(play.back.inside, isFalse);
      expect(play.back.back.coin, 1);
    });

    test('the twice lands with equal coins, and a misfit is told', () {
      final play = Play.of(Levels.at(0)).set(1, 1).set(1, 1);
      expect(play.turns, (2, 1));
      expect(play.isDone, isTrue);
      expect(play.set(0, 1), same(play));
      final misfit = Play.of(Levels.at(3)).flip().set(1, 1).set(1, 1);
      expect(misfit.fits, isFalse);
      expect(misfit.turns, isNull);
      expect(misfit.isDone, isFalse);
    });

    test('the pointer names the side, the dial and the way', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (2, 0));
      play = play.flip();
      expect(play.next, (0, -1));
      play = play.set(0, -1);
      expect(play.next, isNull);
      expect(play.isDone, isTrue);
      expect(Play.pointed((2, 0)), 'Send it round the other side.');
      expect(Play.pointed((0, 1)), 'Widen the hoop.');
      expect(Play.pointed((1, -1)), 'Narrow the roller.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer rolls every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final (which, by) = play.next!;
          play = which == 2 ? play.flip() : play.set(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the once admits it at the nearest setting, or after thirty taps', () {
      var play = Play.of(Levels.at(4)).set(0, -1).set(0, -1);
      for (var k = 0; k < 4; k++) {
        play = play.set(1, 1);
      }
      expect((play.hoop, play.coin), (1, 5));
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      expect(play.gaveUp, isTrue);
      expect(play.moves, 7);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.flip();
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells the trip and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Roll a coin once round another of the same size and it turns twice'));
      expect(words, contains('This is ask 5, The Once.'));
      expect(words, contains('seven sixths of a turn'));
      expect(words, contains('72 settings, tried in full'));
    });
  });
}
