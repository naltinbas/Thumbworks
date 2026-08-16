import 'package:flutter_test/flutter_test.dart';
import 'package:halfstead/step/frac.dart';
import 'package:halfstead/step/levels.dart';
import 'package:halfstead/step/play.dart';
import 'package:halfstead/step/rules.dart';

/// The steps, the two sums, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  final half = Frac.of(1, 2), tenths = Frac.of(9, 10), quarters = Frac.of(3, 4);

  group('the steps', () {
    test('halvings add up to one less a power of two', () {
      expect(Rules.steps(half, 4).map(Rules.tell).toList(), ['1/2', '1/4', '1/8', '1/16']);
      expect(Rules.coveredBySum(half, 7), Frac.of(127, 128));
      expect(Rules.coveredByForm(half, 7), Frac.of(127, 128));
      expect(Rules.left(half, 7), Frac.of(1, 128));
      expect(Rules.tell(Rules.left(half, 20)), '1/1,048,576');
      expect(Rules.steps(Frac.of(2, 3), 3).map(Rules.tell).toList(), ['2/3', '2/9', '2/27']);
      expect(Rules.left(tenths, 3), Frac.of(1, 1000));
      expect(Rules.left(quarters, 3), Frac.of(1, 64));
      expect(Rules.fewestWithin(half, Frac.of(1, 100)), 7);
      expect(Rules.fewestWithin(tenths, Frac.of(1, 1000)), 3);
      expect(Rules.tellShare(half), 'half');
      expect(Rules.tellShare(tenths), 'nine tenths');
      expect(Rules.tell(Frac.of(999, 1000)), '999/1,000');
      expect(Rules.settings, 200);
    });

    test('the sum and the form agree on every setting, and something is always left', () {
      for (final s in Rules.shares) {
        for (var n = 1; n <= 40; n++) {
          expect(Rules.coveredBySum(s, n), Rules.coveredByForm(s, n), reason: '${Rules.tellShare(s)} x $n');
          expect(Rules.left(s, n).compareTo(Frac.zero), greaterThan(0));
          expect(Rules.coveredBySum(s, n) + Rules.left(s, n), Frac.one);
        }
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Wall']);
      for (final level in Levels.all) {
        var n = 0;
        for (final s in Rules.shares) {
          for (var k = 1; k <= 40; k++) {
            if (level.meets(s, k)) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (half, 7));
      expect(Levels.at(1).aim, (half, 2));
      expect(Levels.at(2).aim, (tenths, 3));
      expect(Levels.at(3).aim, (half, 6));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'get within a hundredth of the wall, covering half of what is left at every step');
      expect(Levels.at(1).task, 'stop with exactly a quarter of the way left');
      expect(Levels.at(3).task, 'stop with exactly one part in sixty-four of the way left');
      expect(Levels.at(4).task, 'reach the wall');
    });

    test('an ask is met by the share and the steps', () {
      expect(Levels.at(0).meets(half, 7), isTrue);
      expect(Levels.at(0).meets(half, 6), isFalse);
      expect(Levels.at(0).meets(tenths, 7), isFalse);
      expect(Levels.at(1).meets(quarters, 1), isTrue);
      expect(Levels.at(1).meets(half, 3), isFalse);
      expect(Levels.at(2).meets(tenths, 3), isTrue);
      expect(Levels.at(2).meets(tenths, 2), isFalse);
      expect(Levels.at(3).meets(quarters, 3), isTrue);
      expect(Levels.at(4).meets(half, 40), isFalse);
      expect(Levels.at(0).meets(half, 41), isFalse);
      expect(Levels.at(0).meets(Frac.of(1, 5), 7), isFalse);
    });
  });

  group('the play', () {
    test('opens at one halving', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.shareIndex, play.steps, play.moves), (0, 1, 0));
        expect(play.share, half);
        expect(play.covered, half);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the dials turn a step a tap and stop at their ends', () {
      var play = Play.of(Levels.at(4)).set(1, 1);
      expect((play.steps, play.moves), (2, 1));
      expect(play.covered, Frac.of(3, 4));
      play = play.set(0, 1);
      expect(play.share, Frac.of(1, 3));
      final low = Play.of(Levels.at(4));
      expect(low.set(0, -1), same(low));
      expect(low.set(1, -1), same(low));
      var high = Play.of(Levels.at(4));
      while (high.shareIndex < 4) {
        high = high.set(0, 1);
      }
      expect(high.set(0, 1), same(high));
      expect(high.share, tenths);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(1, 1).set(1, 1);
      expect(play.steps, 3);
      expect(play.back.steps, 2);
      expect(play.back.back.steps, 1);
    });

    test('the pointer turns the share first, then the steps', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, (0, 1));
      while (play.shareIndex < 4) {
        play = play.set(0, 1);
      }
      expect(play.next, (1, 1));
      play = play.set(1, 1).set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, 1)), 'Turn the share up.');
      expect(Play.pointed((1, 1)), 'Add a step.');
      expect(Play.pointed((1, -1)), 'Take off a step.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 60) {
          final (which, way) = play.next!;
          play = play.set(which, way);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the wall admits it at twenty steps, or after twenty taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 18; k++) {
        play = play.set(1, 1);
      }
      expect(play.steps, 19);
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      expect(play.steps, 20);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      expect(Rules.tell(play.left), '1/1,048,576');
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Zeno and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Zeno set it as a paradox'));
      expect(words, contains('200 settings'));
      expect(words, contains('This is ask 5, The Wall.'));
      expect(words, contains('added out in full'));
    });
  });
}
