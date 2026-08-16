import 'package:flutter_test/flutter_test.dart';
import 'package:oddsworth/odd/levels.dart';
import 'package:oddsworth/odd/play.dart';
import 'package:oddsworth/odd/rules.dart';

/// The runs, the two sums, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the runs', () {
    test('a run added out and by the squares', () {
      expect(Rules.run(5, 3), [5, 7, 9]);
      expect(Rules.sumByAdding(5, 3), 21);
      expect(Rules.sumBySquares(5, 3), 21);
      expect((Rules.inner(5), Rules.outer(5, 3)), (2, 5));
      expect(Rules.sumByAdding(1, 7), 49);
      expect(Rules.sumBySquares(1, 7), 49);
      expect(Rules.sumBySquares(49, 2), 100);
      expect(Rules.told(5, 3), '5 + 7 + 9');
      expect(Rules.runsTo(21), [(21, 1), (5, 3)]);
      expect(Rules.runsTo(64), [(31, 2), (13, 4), (1, 8)]);
      expect(Rules.runsTo(30), isEmpty);
      expect(Rules.settings, 1000);
    });

    test('adding and the squares agree on every run, and never two past a multiple of four', () {
      for (var first = 1; first <= 99; first += 2) {
        for (var count = 1; count <= 20; count++) {
          expect(Rules.sumByAdding(first, count), Rules.sumBySquares(first, count), reason: '$first, $count');
          expect(Rules.sumBySquares(first, count) % 4, isNot(2), reason: '$first, $count');
          if (first == 1) expect(Rules.sumBySquares(1, count), count * count);
        }
      }
      expect([for (var n = 1; n <= 100; n++) if (Rules.runsTo(n).isEmpty) n], [for (var n = 2; n <= 100; n += 4) n]);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Thirty']);
      for (final level in Levels.all) {
        var n = 0;
        for (var first = 1; first <= 99; first += 2) {
          for (var count = 1; count <= 20; count++) {
            if (level.meets(first, count)) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (1, 7));
      expect(Levels.at(1).aim, (5, 3));
      expect(Levels.at(2).aim, (1, 8));
      expect(Levels.at(3).aim, (1, 10));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'add up odd numbers from 1 to make 49');
      expect(Levels.at(1).task, 'add up consecutive odd numbers to make 21');
      expect(Levels.at(4).task, 'add up consecutive odd numbers to make 30');
    });

    test('an ask is met by the run', () {
      expect(Levels.at(0).meets(1, 7), isTrue);
      expect(Levels.at(0).meets(49, 1), isFalse);
      expect(Levels.at(1).meets(21, 1), isTrue);
      expect(Levels.at(1).meets(5, 3), isTrue);
      expect(Levels.at(1).meets(7, 3), isFalse);
      expect(Levels.at(2).meets(13, 4), isTrue);
      expect(Levels.at(3).meets(49, 2), isTrue);
      expect(Levels.at(3).meets(1, 10), isTrue);
      expect(Levels.at(4).meets(13, 2), isFalse);
      expect(Levels.at(0).meets(2, 7), isFalse);
      expect(Levels.at(0).meets(1, 21), isFalse);
    });
  });

  group('the play', () {
    test('opens at 1 alone', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.first, play.count, play.moves), (1, 1, 0));
        expect(play.sum, 1);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the dials turn a step a tap, the first by two, and stop at their ends', () {
      var play = Play.of(Levels.at(4)).set(0, 1);
      expect((play.first, play.moves), (3, 1));
      play = play.set(1, 1);
      expect(play.run, [3, 5]);
      expect(play.sum, 8);
      final low = Play.of(Levels.at(4));
      expect(low.set(0, -1), same(low));
      expect(low.set(1, -1), same(low));
      // A run of one is odd, so it never makes a hundred: the first can
      // run to the end.
      var high = Play.of(Levels.at(3));
      for (var k = 0; k < 49; k++) {
        high = high.set(0, 1);
      }
      expect(high.first, 99);
      expect(high.set(0, 1), same(high));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(1, 1).set(1, 1);
      expect(play.count, 3);
      expect(play.back.count, 2);
      expect(play.back.back.count, 1);
    });

    test('the pointer turns the first odd number first, then the count', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (0, 1));
      play = play.set(0, 1).set(0, 1);
      expect(play.first, 5);
      expect(play.next, (1, 1));
      play = play.set(1, 1).set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, 1)), 'Turn the first up.');
      expect(Play.pointed((1, -1)), 'Turn the count down.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (which, way) = play.next!;
          play = play.set(which, way);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the thirty admits it at 28 or 32, or after twelve taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 6; k++) {
        play = play.set(0, 1);
      }
      expect(play.first, 13);
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      expect(play.sum, 28);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells the squares and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('each new odd number an L of dots'));
      expect(words, contains('1,000 runs'));
      expect(words, contains('This is ask 5, The Thirty.'));
      expect(words, contains('added out in full'));
    });
  });
}
