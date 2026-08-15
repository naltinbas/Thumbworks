import 'package:flutter_test/flutter_test.dart';
import 'package:capwick/line/levels.dart';
import 'package:capwick/line/play.dart';
import 'package:capwick/line/rules.dart';

/// The law of the line, held to.
void main() {
  group('the rules', () {
    test('caps deal from bits, and the man behind sees ahead', () {
      expect(Rules.deal(5, 0x16), [false, true, true, false, true]);
      expect(Rules.blackAhead(Rules.deal(5, 0x16), 0), 3);
      expect(Rules.blackAhead(Rules.deal(5, 0x16), 3), 1);
      expect(Rules.blackAhead(Rules.deal(5, 0x16), 4), 0);
    });

    test('the plan calls and is right for all but the first', () {
      final caps = Rules.deal(5, 0x16);
      final (calls, ok) = Rules.plan(caps);
      expect(calls, [true, true, true, false, true]);
      expect(ok, [false, true, true, true, true]);
      // On the three, caps white, white, black: the first man sees one
      // black cap, calls black, and is wrong himself; the two ahead are
      // right.
      final three = Rules.deal(3, 0x4);
      final (c3, ok3) = Rules.plan(three);
      expect(c3, [true, false, true]);
      expect(ok3, [false, true, true]);
    });

    test('the plan on every deal, two to six men', () {
      for (var n = 2; n <= 6; n++) {
        expect(Rules.sweep(n), (1 << n, 1 << (n - 1), (n - 1) * (1 << n) + (1 << (n - 1))), reason: '$n');
      }
    });

    test('every plan of the first man is right on half the deals', () {
      for (var n = 2; n <= 4; n++) {
        final (fewest, most, plans) = Rules.firstManEveryPlan(n);
        expect(fewest, 1 << (n - 1), reason: '$n');
        expect(most, 1 << (n - 1), reason: '$n');
        expect(plans, 1 << (1 << (n - 1)), reason: '$n');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final (allBut, _, _) = Rules.sweep(level.prisoners);
        expect(level.warden ? 0 : allBut, level.ways, reason: level.name);
        expect(1 << level.prisoners, level.deals, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens at the back with nothing called', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.calls, isEmpty, reason: level.name);
        expect(play.current, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('a call moves down the line, and back undoes', () {
      var play = Play.of(Levels.at(2));
      expect(play.blackAhead, 3);
      play = play.tap(true);
      expect(play.calls, [true]);
      expect(play.current, 1);
      expect(play.right(0), isFalse);
      expect(play.moves, 1);
      expect(play.back.calls, isEmpty);
    });

    test('the plan lands the five, and a slip misses it', () {
      var play = Play.of(Levels.at(2));
      while (!play.allCalled) {
        play = play.tap(Rules.planCall(play.caps, play.current, play.calls));
      }
      expect(play.calls, [true, true, true, false, true]);
      expect(play.rightCount, 4);
      expect(play.isDone, isTrue);
      expect(play.tap(true), same(play));
      final slip = Play.of(Levels.at(2)).tap(true).tap(false).tap(true).tap(false).tap(true);
      expect(slip.allCalled, isTrue);
      expect(slip.isDone, isFalse);
      expect(slip.missed, isTrue);
      expect(slip.gaveUp, isFalse);
    });

    test('the pointer lands every winnable line', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isOver && guard++ < 8) {
          final (what, _) = play.next!;
          play = play.tap(what == 'black');
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.rightCount, greaterThanOrEqualTo(play.n - 1), reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the warden caps the first man against his word', () {
      var play = Play.of(Levels.at(4));
      expect(play.caps, [false, true, true, false, true]);
      // The plan's first call is black, three black caps ahead being
      // odd; the warden then caps him white.
      play = play.tap(true);
      expect(play.caps[0], isFalse);
      expect(play.right(0), isFalse);
      final other = Play.of(Levels.at(4)).tap(false);
      expect(other.caps[0], isTrue);
      expect(other.right(0), isFalse);
      // The rest are still saved by the plan.
      while (!play.allCalled) {
        play = play.tap(Rules.planCall(play.caps, play.current, play.calls));
      }
      expect(play.rightCount, 4);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('the mark stands called', () {
      final mark = Play.standing(Levels.at(2), const [true, true, true, false, true]);
      expect(mark.isDone, isTrue);
      expect(mark.rightCount, 4);
    });
  });
}
