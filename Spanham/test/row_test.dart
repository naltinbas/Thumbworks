import 'package:flutter_test/flutter_test.dart';
import 'package:spanham/row/fewest.dart';
import 'package:spanham/row/levels.dart';
import 'package:spanham/row/play.dart';

void main() {
  group('the arithmetic and the search', () {
    test('agree on every shelf to twelve pairs', () {
      // The anchor. The arithmetic adds seat numbers; the search places
      // blocks. They point the same way at every size.
      for (var pairs = 1; pairs <= 12; pairs++) {
        expect(Rows.settings(pairs, most: 1).isNotEmpty,
            Rows.parityAllows(pairs),
            reason: '$pairs pairs');
      }
    });

    test('the parity falls odd exactly on one and two past a multiple of '
        'four', () {
      for (var pairs = 1; pairs <= 20; pairs++) {
        expect(Rows.parityAllows(pairs),
            pairs % 4 == 0 || pairs % 4 == 3,
            reason: '$pairs pairs');
      }
    });

    test('every setting found really keeps every pair its span', () {
      for (final setting in Rows.settings(7)) {
        for (var pair = 1; pair <= 7; pair++) {
          final left = setting.indexOf(pair);
          final right = setting.lastIndexOf(pair);
          expect(right - left, pair + 1, reason: '$setting pair $pair');
        }
      }
    });

    test('the counts are the counts', () {
      expect(Rows.ways(3), 2);
      expect(Rows.ways(4), 2);
      expect(Rows.ways(5), 0);
      expect(Rows.ways(7), 52);
      expect(Rows.ways(8), 300);
    });

    test('and the settings come in mirror pairs', () {
      final all = Rows.settings(7).map((s) => s.join(',')).toSet();
      for (final setting in Rows.settings(7)) {
        expect(all, contains(setting.reversed.join(',')));
      }
    });
  });

  group('every shelf that ships', () {
    for (var number = 0; number < Levels.count; number++) {
      final level = Levels.at(number);

      test('${level.name} says what the search says', () {
        expect(Rows.ways(level.pairs), level.ways);
        expect(Rows.parityAllows(level.pairs), level.possible);
      });
    }
  });

  group('a shelf being set', () {
    test('starts empty with the biggest pair in hand', () {
      final play = Play.of(Levels.at(0));
      expect(play.placing, 3);
      expect(play.row.every((seat) => seat == 0), isTrue);
      expect(play.canStill, isTrue);
    });

    test('a pair sits only where both its seats are free', () {
      var play = Play.of(Levels.at(0)).place(0);
      // Three placed at seats 0 and 4; the two in hand wants a seat and
      // the seat three past it, so 1 is blocked by the 3 at seat 4.
      expect(play.placing, 2);
      expect(play.mayPlace(0), isFalse);
      expect(play.mayPlace(1), isFalse);
      expect(play.mayPlace(2), isTrue);
      expect(identical(play.place(0), play), isTrue);
    });

    test('following next sets every shelf that can be set', () {
      for (var number = 0; number < Levels.count; number++) {
        final level = Levels.at(number);
        if (!level.possible) continue;
        var play = Play.of(level);
        var guard = 0;
        while (!play.isSet) {
          if (guard++ > level.pairs + 1) fail('${level.name} never set');
          play = play.place(play.next!);
        }
        for (var pair = 1; pair <= level.pairs; pair++) {
          final left = play.row.indexOf(pair);
          expect(play.row.lastIndexOf(pair) - left, pair + 1,
              reason: '${level.name} pair $pair');
        }
      }
    });

    test('the five-pair shelf can never even start on the right foot', () {
      final play = Play.of(Levels.at(2));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('a stranding placement shows in the live answer at once', () {
      var play = Play.of(Levels.at(3));
      play = play.place(play.next!);
      var strander = -1;
      for (var seat = 0; seat < play.level.seats && strander < 0; seat++) {
        if (!play.mayPlace(seat)) continue;
        if (!play.place(seat).canStill) strander = seat;
      }
      if (strander >= 0) {
        expect(play.place(strander).canStill, isFalse);
      }
      expect(play.canStill, isTrue);
    });

    test('back returns the pair to hand', () {
      final start = Play.of(Levels.at(0));
      final placed = start.place(0);
      expect(placed.placing, 2);
      expect(placed.back.placing, 3);
      expect(identical(start.back, start), isTrue);
    });
  });
}
