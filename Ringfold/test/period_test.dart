import 'package:flutter_test/flutter_test.dart';
import 'package:ringfold/period/levels.dart';
import 'package:ringfold/period/play.dart';
import 'package:ringfold/period/rules.dart';

/// The walks, the matrix, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the periods', () {
    test('the small clocks walked and by the matrix', () {
      expect(Rules.cycle(3), [0, 1, 1, 2, 0, 2, 2, 1]);
      expect(Rules.cycle(2), [0, 1, 1]);
      expect(Rules.cycle(4), [0, 1, 1, 2, 3, 1]);
      expect(Rules.periodByWalk(5), 20);
      expect(Rules.periodByMatrix(5), 20);
      expect(Rules.periodByWalk(10), 60);
      expect(Rules.periodByMatrix(10), 60);
      expect(Rules.periodByWalk(24), 24);
      expect(Rules.bound(29), 28);
      expect(Rules.periodByWalk(29), 14);
      expect(Rules.matrixPower(1, 7), (1, 1, 1, 0));
      expect(Rules.matrixPower(16, 7), (1, 0, 0, 1));
      expect(Rules.cassiniHolds(7), isTrue);
      expect(Rules.settings, 39);
    });

    test('the walk and the matrix agree on every clock to a hundred, and the period is even past two', () {
      for (var m = 2; m <= 100; m++) {
        expect(Rules.periodByMatrix(m), Rules.periodByWalk(m), reason: '$m');
        expect(Rules.cassiniHolds(m), isTrue, reason: '$m');
        if (m > 2) expect(Rules.periodByWalk(m).isEven, isTrue, reason: '$m');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Odd Period']);
      for (final level in Levels.all) {
        var n = 0;
        for (var m = 2; m <= 40; m++) {
          if (level.meets(m)) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, 3);
      expect(Levels.at(1).aim, 5);
      expect(Levels.at(2).aim, 10);
      expect(Levels.at(3).aim, 24);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial a clock on which the Fibonacci numbers come round every 8 steps');
      expect(Levels.at(3).task, 'dial a clock whose period is as long as the clock itself');
      expect(Levels.at(4).task, 'dial a clock past two hours whose period is odd');
    });

    test('an ask is met by the clock', () {
      expect(Levels.at(0).meets(3), isTrue);
      expect(Levels.at(0).meets(4), isFalse);
      expect(Levels.at(1).meets(5), isTrue);
      expect(Levels.at(2).meets(20), isTrue);
      expect(Levels.at(2).meets(40), isTrue);
      expect(Levels.at(2).meets(30), isFalse);
      expect(Levels.at(3).meets(24), isTrue);
      expect(Levels.at(3).meets(12), isFalse);
      expect(Levels.at(4).meets(2), isFalse);
      expect(Levels.at(4).meets(3), isFalse);
      expect(Levels.at(0).meets(1), isFalse);
      expect(Levels.at(0).meets(41), isFalse);
    });
  });

  group('the play', () {
    test('opens on the two-hour clock', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.clock, play.moves), (2, 0));
        expect(play.period, 3);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('winds by one or ten, stopping at the ends', () {
      var play = Play.of(Levels.at(3)).wind(10);
      expect((play.clock, play.moves), (12, 1));
      play = play.wind(10);
      expect(play.clock, 22);
      final low = Play.of(Levels.at(1));
      expect(low.wind(-1), same(low));
      var high = Play.of(Levels.at(1));
      for (var k = 0; k < 4; k++) {
        high = high.wind(10);
      }
      expect(high.clock, 40);
      expect(high.wind(1), same(high));
    });

    test('back undoes one wind', () {
      final play = Play.of(Levels.at(1)).wind(1).wind(1);
      expect(play.clock, 4);
      expect(play.back.clock, 3);
      expect(play.back.back.clock, 2);
    });

    test('the pointer winds towards the aim, ten while it can', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, 10);
      play = play.wind(10).wind(10);
      expect(play.next, 1);
      expect(Play.pointed(10), 'Wind up by 10.');
      expect(Play.pointed(-1), 'Wind down by 1.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          play = play.wind(play.next!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the odd period admits it on the four-hour clock, or after twelve taps', () {
      var play = Play.of(Levels.at(4)).wind(1);
      expect(play.clock, 3);
      expect(play.gaveUp, isFalse);
      play = play.wind(1);
      expect(play.clock, 4);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4)).wind(10);
      for (var k = 0; k < 11; k++) {
        wander = wander.wind(k.isEven ? 1 : -1);
      }
      expect(wander.moves, 12);
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Lagrange, Cassini and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Lagrange saw it in 1774'));
      expect(words, contains('Cassini\'s identity'));
      expect(words, contains('This is ask 5, The Odd Period.'));
      expect(words, contains('walked round in full'));
    });
  });
}
