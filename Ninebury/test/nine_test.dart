import 'package:flutter_test/flutter_test.dart';
import 'package:ninebury/nine/levels.dart';
import 'package:ninebury/nine/play.dart';
import 'package:ninebury/nine/rules.dart';

/// The roots, the nines, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the roots', () {
    test('digits added down agree with the remainder by nine, on every number', () {
      expect(Rules.chain(738), [738, 18, 9]);
      expect(Rules.chain(9), [9]);
      expect(Rules.chain(0), [0]);
      expect(Rules.chain(199), [199, 19, 10, 1]);
      expect(Rules.rootByDigits(451), 1);
      expect(Rules.rootByNines(451), 1);
      expect(Rules.rootByNines(738), 9);
      expect(Rules.rootByNines(0), 0);
      expect(Rules.cast(738), (82, 0));
      expect(Rules.cast(451), (50, 1));
      expect(Rules.digits(738), [7, 3, 8]);
      expect(Rules.digits(18), [0, 1, 8]);
      expect(Rules.digitSum(999), 27);
      expect(Rules.told(738), '7 + 3 + 8 = 18, 1 + 8 = 9');
      expect(Rules.told(9), '9 stands alone');
      for (var n = 0; n <= 999; n++) {
        expect(Rules.rootByDigits(n), Rules.rootByNines(n), reason: '$n');
      }
    });

    test('the root of a sum and of a product, on a slice of the pairs', () {
      for (var a = 0; a <= 999; a += 7) {
        for (var b = 0; b <= 999; b += 11) {
          final ra = Rules.rootByDigits(a), rb = Rules.rootByDigits(b);
          expect(Rules.rootByNines(a + b), Rules.rootByNines(ra + rb), reason: '$a + $b');
          expect(Rules.rootByNines(a * b), Rules.rootByNines(ra * rb), reason: '$a times $b');
        }
      }
    });

    test('squares, cubes and different digits', () {
      expect(Rules.isSquare(961), isTrue);
      expect(Rules.isSquare(960), isFalse);
      expect(Rules.isSquare(0), isTrue);
      expect(Rules.isCube(512), isTrue);
      expect(Rules.isCube(500), isFalse);
      expect(Rules.allDifferent(738), isTrue);
      expect(Rules.allDifferent(733), isFalse);
      expect(Rules.allDifferent(18), isTrue);
      expect(Rules.product, 846);
      final squareRoots = {for (var k = 0; k * k <= 999; k++) Rules.rootByDigits(k * k)};
      expect(squareRoots, {0, 1, 4, 7, 9});
      final cubeRoots = {for (var k = 0; k * k * k <= 999; k++) Rules.rootByDigits(k * k * k)};
      expect(cubeRoots, {0, 1, 8, 9});
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Square Five']);
      for (final level in Levels.all) {
        var n = 0;
        for (var k = 0; k <= 999; k++) {
          if (level.meets(k)) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, 18);
      expect(Levels.at(1).aim, 16);
      expect(Levels.at(2).aim, 8);
      expect(Levels.at(3).aim, 9);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial three different digits whose number has root nine');
      expect(Levels.at(3).task, 'dial a wrong answer to 47 times 18 that casting out nines lets through');
      expect(Levels.at(4).task, 'dial a square whose root is five');
    });

    test('an ask is met by the number alone', () {
      expect(Levels.at(0).meets(738), isTrue);
      expect(Levels.at(0).meets(333), isFalse);
      expect(Levels.at(0).meets(737), isFalse);
      expect(Levels.at(1).meets(16), isTrue);
      expect(Levels.at(1).meets(961), isTrue);
      expect(Levels.at(1).meets(25), isTrue);
      expect(Levels.at(1).meets(36), isFalse);
      expect(Levels.at(1).meets(7), isFalse);
      expect(Levels.at(2).meets(125), isTrue);
      expect(Levels.at(2).meets(729), isFalse);
      expect(Levels.at(3).meets(864), isTrue);
      expect(Levels.at(3).meets(846), isFalse);
      expect(Levels.at(3).meets(845), isFalse);
      expect(Levels.at(4).meets(25), isFalse);
      expect(Levels.at(4).meets(5), isFalse);
    });
  });

  group('the play', () {
    test('opens at nought on every dial', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.digits, [0, 0, 0]);
        expect((play.number, play.root, play.moves), (0, 0, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the dials turn a step a tap and stop at their ends', () {
      var play = Play.of(Levels.at(3)).set(0, 1).set(1, 1).set(2, 1);
      expect((play.number, play.moves), (111, 3));
      expect(play.chain, [111, 3]);
      expect(play.root, 3);
      expect(play.rootByNines, 3);
      final low = play.set(0, -1);
      expect(low.set(0, -1), same(low));
      var high = Play.of(Levels.at(3));
      for (var k = 0; k < 9; k++) {
        high = high.set(0, 1);
      }
      expect(high.set(0, 1), same(high));
      expect(high.number, 900);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(2, 1).set(2, 1);
      expect(play.number, 2);
      expect(play.back.number, 1);
      expect(play.back.back.number, 0);
    });

    test('the pointer turns the hundreds first, then the tens, then the units', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (1, 1));
      play = play.set(1, 1);
      expect(play.next, (2, 1));
      for (var k = 0; k < 8; k++) {
        play = play.set(2, 1);
      }
      expect(play.number, 18);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, 1)), 'Turn the hundreds up.');
      expect(Play.pointed((2, -1)), 'Turn the units down.');
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

    test('the square five admits it at a square of root 4 or 7, or after fifteen taps', () {
      var play = Play.of(Levels.at(4));
      play = play.set(2, 1);
      expect(play.number, 1);
      expect(play.gaveUp, isFalse);
      play = play.set(2, 1).set(2, 1).set(2, 1);
      expect(play.number, 4);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 15; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect(wander.number, 100);
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells the nines and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('one more than a multiple of nine'));
      expect(words, contains('This is ask 5, The Square Five.'));
      expect(words, contains('rooted both ways'));
    });
  });
}
