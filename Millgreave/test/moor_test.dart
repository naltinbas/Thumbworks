import 'package:flutter_test/flutter_test.dart';
import 'package:millgreave/moor/moors.dart';
import 'package:millgreave/moor/play.dart';
import 'package:millgreave/moor/rules.dart';

void main() {
  group('the wind', () {
    test('is stolen along rows, files and slants, and nowhere else', () {
      expect(Rules.steals(0, 0, 3, 0), isTrue);
      expect(Rules.steals(2, 1, 2, 4), isTrue);
      expect(Rules.steals(1, 1, 4, 4), isTrue);
      expect(Rules.steals(1, 4, 4, 1), isTrue);
      expect(Rules.steals(0, 0, 1, 2), isFalse);
      expect(Rules.steals(0, 0, 2, 1), isFalse);
    });
  });

  group('the counts and the build', () {
    test('the counts are the counts', () {
      expect(Rules.ways(2), 0);
      expect(Rules.ways(3), 0);
      expect(Rules.ways(4), 2);
      expect(Rules.ways(5), 10);
      expect(Rules.ways(6), 4);
      expect(Rules.ways(7), 40);
      expect(Rules.ways(8), 92);
      expect(Rules.ways(9), 352);
    });

    test('the built rows keep the wind at every size to twelve', () {
      // The anchor. The build writes rows straight down by the remainder
      // rules; the wind check knows nothing of them.
      for (var size = 4; size <= 12; size++) {
        final built = Rules.built(size)!;
        expect(built, hasLength(size));
        expect(built.toSet(), hasLength(size), reason: 'size $size');
        for (var a = 0; a < size; a++) {
          for (var b = a + 1; b < size; b++) {
            expect(Rules.steals(a, built[a], b, built[b]), isFalse,
                reason: 'size $size files $a and $b');
          }
        }
      }
    });

    test('and there is no build for two or three, because there is '
        'nothing to build', () {
      expect(Rules.built(2), isNull);
      expect(Rules.built(3), isNull);
      expect(Rules.ways(2, most: 1), 0);
      expect(Rules.ways(3, most: 1), 0);
    });
  });

  group('every moor that ships', () {
    for (var number = 0; number < Moors.count; number++) {
      final moor = Moors.at(number);

      test('${moor.name} says what the search says', () {
        expect(Rules.ways(moor.size), moor.ways);
      });
    }
  });

  group('a moor being set', () {
    test('starts empty and settable', () {
      final play = Play.of(Moors.at(0));
      expect(play.standing, 0);
      expect(play.canStill, isTrue);
      expect(play.next, isNotNull);
    });

    test('a mill goes up only where the wind is clear', () {
      var play = Play.of(Moors.at(0)).raise(0, 1);
      expect(play.standing, 1);
      expect(play.mayRaise(1, 1), isFalse);
      expect(play.thiefAt(1, 0), (0, 1));
      expect(play.mayRaise(1, 3), isTrue);
      expect(identical(play.raise(1, 0), play), isTrue);
    });

    test('following next sets every possible moor', () {
      for (var number = 0; number < Moors.count; number++) {
        final moor = Moors.at(number);
        if (!moor.possible) continue;
        var play = Play.of(moor);
        var guard = 0;
        while (!play.isSet) {
          if (guard++ > moor.size + 1) fail('${moor.name} never set');
          final plot = play.next!;
          play = play.raise(plot.$1, plot.$2);
        }
        for (var a = 0; a < moor.size; a++) {
          for (var b = a + 1; b < moor.size; b++) {
            expect(Rules.steals(a, play.rows[a], b, play.rows[b]),
                isFalse,
                reason: '${moor.name} files $a and $b');
          }
        }
      }
    });

    test('the three mills can never even start well', () {
      final play = Play.of(Moors.at(2));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('a stranding mill shows in the live answer at once', () {
      // On six, the spiky moor, plenty of clear plots strand the rest.
      var play = Play.of(Moors.at(3));
      var strander = (-1, -1);
      for (var row = 0; row < 6 && strander.$1 < 0; row++) {
        if (!play.mayRaise(0, row)) continue;
        final tried = play.raise(0, row);
        if (!tried.canStill) strander = (0, row);
      }
      expect(strander.$1, isNot(-1),
          reason: 'no first mill on six ever strands');
      expect(play.raise(strander.$1, strander.$2).canStill, isFalse);
    });

    test('back takes the last mill down', () {
      final start = Play.of(Moors.at(0));
      final raised = start.raise(0, 1);
      expect(raised.standing, 1);
      expect(raised.back.standing, 0);
      expect(identical(start.back, start), isTrue);
    });
  });
}
