import 'package:flutter_test/flutter_test.dart';
import 'package:rootley/root/levels.dart';
import 'package:rootley/root/play.dart';
import 'package:rootley/root/rules.dart';

/// The walks, the two reckonings, the asks and the play, checked at
/// the domain: nothing here touches a widget.
void main() {
  group('the walks', () {
    test('a walk steps by the base and comes home, or falls astray', () {
      expect(Rules.walk(3, 7), [1, 3, 2, 6, 4, 5]);
      expect(Rules.walk(2, 7), [1, 2, 4]);
      expect(Rules.walk(1, 7), [1]);
      expect(Rules.walk(2, 12), [1, 2, 4, 8]);
      expect(Rules.fallsTo(2, 12), 4);
      expect(Rules.comesHome(2, 12), isFalse);
      expect(Rules.comesHome(3, 7), isTrue);
      expect(Rules.orderByWalk(3, 7), 6);
      expect(Rules.orderByWalk(2, 7), 3);
      expect(Rules.orderByWalk(2, 12), isNull);
      expect(Rules.walk(2, 11), [1, 2, 4, 8, 5, 10, 9, 7, 3, 6]);
      expect(Rules.walk(2, 5), [1, 2, 4, 3]);
      expect(Rules.told([1, 2, 4]), '1, 2 and 4');
      expect(Rules.told([1]), '1');
    });

    test('the second reckoning agrees with the walk on every clock to a hundred', () {
      for (var c = 3; c <= 100; c++) {
        for (var b = 1; b < c; b++) {
          expect(Rules.orderByLambda(b, c), Rules.orderByWalk(b, c), reason: '$b on $c');
        }
        expect(Rules.hasFullByGauss(c), Rules.hasFullByWalk(c), reason: '$c');
      }
      expect(Rules.lambda(8), 2);
      expect(Rules.lambda(15), 4);
      expect(Rules.lambda(17), 16);
      expect(Rules.lambda(24), 2);
      expect(Rules.phi(9), 6);
      expect(Rules.units(9), [1, 2, 4, 5, 7, 8]);
      expect(Rules.units(8), [1, 3, 5, 7]);
      expect(Rules.factors(24), [(2, 3), (3, 1)]);
      expect(Rules.powMod(3, 6, 7), 1);
      expect(Rules.powMod(3, 3, 7), 6);
    });

    test('full bases and the clocks with none', () {
      expect(Rules.isFull(3, 7), isTrue);
      expect(Rules.isFull(2, 7), isFalse);
      expect(Rules.isFull(2, 9), isTrue);
      expect(Rules.isFull(5, 9), isTrue);
      expect([for (var b = 1; b < 8; b++) if (Rules.isFull(b, 8)) b], isEmpty);
      expect([for (var c = 3; c <= 24; c++) if (!Rules.hasFullByWalk(c)) c], [8, 12, 15, 16, 20, 21, 24]);
      expect(Rules.settings, 275);
      expect(Rules.name(24), 'twenty-four');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Eight']);
      for (final level in Levels.all) {
        var n = 0;
        for (var c = 3; c <= 24; c++) {
          for (var b = 1; b < c; b++) {
            if (level.meets(c, b)) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (7, 3));
      expect(Levels.at(1).aim, (5, 2));
      expect(Levels.at(2).aim, (11, 2));
      expect(Levels.at(3).aim, (9, 2));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the base so its walk touches every hour of the seven-hour clock but 0');
      expect(Levels.at(1).task, 'find a clock and a base whose fourth power is the first to come home to 1');
      expect(Levels.at(2).task, 'find a clock of ten hours or more and a base whose walk touches every hour but 0');
      expect(Levels.at(4).task, 'set the base so its walk touches every hour of the eight-hour clock that shares no factor with eight, 1, 3, 5 and 7');
      expect(Levels.at(0).settings, 6);
      expect(Levels.at(1).settings, 275);
    });

    test('an ask is met on its own clock, or on any clock big enough', () {
      expect(Levels.at(0).meets(7, 3), isTrue);
      expect(Levels.at(0).meets(7, 5), isTrue);
      expect(Levels.at(0).meets(7, 2), isFalse);
      expect(Levels.at(0).meets(11, 2), isFalse);
      expect(Levels.at(1).meets(5, 2), isTrue);
      expect(Levels.at(1).meets(15, 2), isTrue);
      expect(Levels.at(1).meets(5, 4), isFalse);
      expect(Levels.at(2).meets(7, 3), isFalse);
      expect(Levels.at(2).meets(11, 2), isTrue);
      expect(Levels.at(2).meets(12, 5), isFalse);
      expect(Levels.at(3).meets(9, 2), isTrue);
      expect(Levels.at(3).meets(9, 4), isFalse);
      expect(Levels.at(4).meets(8, 3), isFalse);
    });
  });

  group('the play', () {
    test('opens at base 1, the clock locked or at twelve', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.base, 1);
        expect(play.clock, level.clock ?? 12);
        expect((play.moves, play.order), (0, 1));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the dials turn a step a tap and stop at their ends', () {
      var play = Play.of(Levels.at(1)).set(1, 1);
      expect((play.clock, play.base, play.moves), (12, 2, 1));
      expect(play.walk, [1, 2, 4, 8]);
      play = play.set(0, -1);
      expect((play.clock, play.base), (11, 2));
      final one = play.set(1, -1);
      expect(one.base, 1);
      expect(one.set(1, -1), same(one));
      // Base 1 lands nothing, so the clock can run to either end.
      var low = Play.of(Levels.at(2));
      while (low.clock > 3) {
        low = low.set(0, -1);
      }
      expect(low.set(0, -1), same(low));
      expect((low.clock, low.base, low.moves), (3, 1, 9));
      var high = Play.of(Levels.at(2));
      while (high.clock < 24) {
        high = high.set(0, 1);
      }
      expect(high.set(0, 1), same(high));
      expect(high.clock, 24);
    });

    test('a clock turned down past the base drags the base down', () {
      var play = Play.of(Levels.at(1));
      for (var k = 0; k < 10; k++) {
        play = play.set(1, 1);
      }
      expect((play.clock, play.base), (12, 11));
      expect(play.set(1, 1), same(play));
      play = play.set(0, -1);
      expect((play.clock, play.base), (11, 10));
    });

    test('a locked clock does not turn', () {
      final play = Play.of(Levels.at(0));
      expect(play.set(0, 1), same(play));
      expect(play.set(1, 1).base, 2);
      expect(play.set(1, -1), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(1, 1).set(1, 1);
      expect(play.base, 3);
      expect(play.back.base, 2);
      expect(play.back.back.base, 1);
    });

    test('the pointer turns the clock first, then the base', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (0, -1));
      while (play.clock > 5) {
        play = play.set(0, -1);
      }
      expect(play.next, (1, 1));
      play = play.set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, -1)), 'Turn the clock down.');
      expect(Play.pointed((1, 1)), 'Turn the base up.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final (which, way) = play.next!;
          play = play.set(which, way);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the eight admits it once every base is tried, or after twelve taps', () {
      var play = Play.of(Levels.at(4));
      for (var b = 2; b <= 7; b++) {
        play = play.set(1, 1);
        expect(play.gaveUp, b == 7, reason: 'base $b');
      }
      expect(play.tried, {1, 2, 3, 4, 5, 6, 7});
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.set(1, k.isEven ? 1 : -1);
      }
      expect(wander.tried, {1, 2});
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Euler, Gauss and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Gauss proved in 1801'));
      expect(words, contains('275 settings'));
      expect(words, contains('This is ask 5, The Eight.'));
      expect(words, contains('walked in full'));
    });
  });
}
