import 'package:flutter_test/flutter_test.dart';
import 'package:ellwick/rung/levels.dart';
import 'package:ellwick/rung/play.dart';
import 'package:ellwick/rung/rules.dart';

/// The ladder, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the ladder', () {
    test('the rungs, their misses turning over, and the algebra', () {
      expect(Rules.rungs, [(1, 1), (2, 3), (5, 7), (12, 17), (29, 41), (70, 99)]);
      expect(Rules.climb(70, 99), (169, 239));
      expect([for (final (s, d) in Rules.rungs) Rules.miss(s, d)], [-1, 1, -1, 1, -1, 1]);
      for (var s = 1; s <= 30; s++) {
        for (var d = 1; d <= 30; d++) {
          final (s2, d2) = Rules.climb(s, d);
          expect(Rules.miss(s2, d2), -Rules.miss(s, d), reason: '$s, $d');
        }
      }
      expect(Rules.miss(1, 2), 2);
      expect(Rules.miss(70, 99), 1);
      expect(Rules.settings, 14400);
    });

    test('the offs, the nearest diagonals and the records', () {
      expect(Rules.off(12, 17), closeTo(0.00245, 0.00001));
      expect(Rules.off(29, 41), closeTo(0.00042, 0.00001));
      expect(Rules.slack(1, 1), closeTo(0.41421, 0.00001));
      expect(Rules.nearest(12), 17);
      expect(Rules.nearest(29), 41);
      expect(Rules.nearest(1), 1);
      expect(Rules.isRecord(12, 17), isTrue);
      expect(Rules.isRecord(12, 16), isFalse);
      expect(Rules.isRecord(17, 24), isFalse);
      expect(Rules.isRecord(1, 2), isFalse);
      expect(Rules.records, Rules.rungs);
    });

    test('the sweep', () {
      expect(Rules.sweep((s, d) => Rules.miss(s, d) == 1), (3, 14400, (2, 3)));
      expect(Rules.sweep((s, d) => Rules.miss(s, d) == 0), (0, 14400, null));
      expect(Rules.sweep((s, d) => Rules.off(s, d) < 0.001).$1, 7);
      expect(Rules.commas(14400), '14,400');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The True Diagonal']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 14400), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the side and the diagonal so the diagonal squared is one over twice the side squared');
      expect(Levels.at(2).task, 'set the side and the diagonal so the diagonal over the side is within a thousandth of the true diagonal');
      expect(Levels.at(4).task, 'set the side and the diagonal so the diagonal squared is exactly twice the side squared');
    });

    test('an ask is met by the miss, the thousandth or the record', () {
      expect(Levels.at(0).meets(12, 17), isTrue);
      expect(Levels.at(0).meets(5, 7), isFalse);
      expect(Levels.at(1).meets(5, 7), isTrue);
      expect(Levels.at(2).meets(41, 58), isTrue);
      expect(Levels.at(2).meets(12, 17), isFalse);
      expect(Levels.at(3).meets(29, 41), isTrue);
      expect(Levels.at(3).meets(41, 58), isFalse);
      expect(Levels.at(4).meets(70, 99), isFalse);
    });
  });

  group('the play', () {
    test('opens on a side of one and a diagonal of two, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.side, play.diagonal, play.moves), (1, 2, 0));
        expect(play.miss, 2);
        expect(play.onLadder, isFalse);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a dial a step, a dial at its end stays, and the ladder climbs', () {
      var play = Play.of(Levels.at(0)).set(1, -1);
      expect((play.side, play.diagonal, play.moves), (1, 1, 1));
      expect(play.onLadder, isTrue);
      play = play.climb();
      expect((play.side, play.diagonal, play.moves), (2, 3, 2));
      expect(play.isDone, isTrue);
      expect(play.climb(), same(play));
      final low = Play.standing(Levels.at(2), 1, 1);
      expect(low.set(0, -1), same(low));
      expect(low.set(1, -1), same(low));
      final top = Play.standing(Levels.at(2), 70, 99);
      expect(top.climb(), same(top));
      final high = Play.standing(Levels.at(4), 120, 120);
      expect(high.set(0, 1), same(high));
      expect(high.set(1, 1), same(high));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(1, -1).climb();
      expect(play.back.side, 1);
      expect(play.back.back.diagonal, 2);
    });

    test('the pointer walks to the ladder and climbs it', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, (1, -1));
      play = play.set(1, -1);
      expect(play.next, (2, 0));
      for (var k = 0; k < 4; k++) {
        play = play.climb();
      }
      expect((play.side, play.diagonal), (29, 41));
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((2, 0)), 'Climb the ladder a rung.');
      expect(Play.pointed((0, 1)), 'Lengthen the side.');
      expect(Play.pointed((1, -1)), 'Shorten the diagonal.');
      expect(Play.of(Levels.at(4)).next, isNull);
      final off = Play.standing(Levels.at(3), 3, 4);
      expect(off.next, (0, -1));
    });

    test('following the pointer measures every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final (which, by) = play.next!;
          play = which == 2 ? play.climb() : play.set(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the true diagonal admits it at the top rung, or after forty taps', () {
      var play = Play.of(Levels.at(4)).set(1, -1);
      for (var k = 0; k < 4; k++) {
        play = play.climb();
      }
      expect((play.side, play.diagonal), (29, 41));
      expect(play.gaveUp, isFalse);
      play = play.climb();
      expect((play.side, play.diagonal), (70, 99));
      expect(play.gaveUp, isTrue);
      expect(play.moves, 6);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (40, true));
    });

    test('the why tells the halving and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('which cannot go on for ever'));
      expect(words, contains('This is ask 5, The True Diagonal.'));
      expect(words, contains('14,400 pairs, tried in full'));
    });
  });
}
