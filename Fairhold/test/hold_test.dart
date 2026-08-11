import 'package:flutter_test/flutter_test.dart';
import 'package:fairhold/hold/consignments.dart';
import 'package:fairhold/hold/play.dart';
import 'package:fairhold/hold/rules.dart';

void main() {
  group('a fair line', () {
    test('is exactly two ends per paint', () {
      expect(Rules.fair(const [(0, 1), (1, 2), (2, 3), (3, 0)]), isTrue);
      expect(Rules.fair(const [(0, 1), (0, 1), (2, 3), (2, 3)]), isTrue);
      expect(Rules.fair(const [(0, 0), (1, 1), (2, 2), (3, 3)]), isTrue);
      expect(Rules.fair(const [(0, 1), (0, 1), (0, 1), (2, 3)]), isFalse);
    });

    test('and a fair line always orients to all four each way', () {
      // Sweep every fair line of four ropes: the orientation never
      // fails, and each way shows all four paints.
      var swept = 0;
      for (var a = 0; a < 16; a++) {
        for (var b = 0; b < 16; b++) {
          for (var c = 0; c < 16; c++) {
            for (var d = 0; d < 16; d++) {
              final pairs = [
                (a ~/ 4, a % 4),
                (b ~/ 4, b % 4),
                (c ~/ 4, c % 4),
                (d ~/ 4, d % 4),
              ];
              if (!Rules.fair(pairs)) continue;
              swept++;
              final facing = Rules.orient(pairs)!;
              expect(facing.map((f) => f.$1).toSet(), hasLength(4),
                  reason: '$pairs north');
              expect(facing.map((f) => f.$2).toSet(), hasLength(4),
                  reason: '$pairs south');
              for (var at = 0; at < 4; at++) {
                final sorted = [facing[at].$1, facing[at].$2]..sort();
                final given = [pairs[at].$1, pairs[at].$2]..sort();
                expect(sorted, given, reason: '$pairs rope $at');
              }
            }
          }
        }
      }
      expect(swept, greaterThan(1000));
    });
  });

  group('the counting floor', () {
    test('fewer than four ends of a paint means no stacking', () {
      final short = Consignments.at(3);
      expect(Rules.endsInAll(short.crates)[0], lessThan(4));
      expect(Rules.solutions(short.crates), isEmpty);
    });
  });

  group('every consignment that ships', () {
    for (var number = 0; number < Consignments.count; number++) {
      final consignment = Consignments.at(number);

      test('${consignment.name} says what the search says', () {
        expect(Rules.solutions(consignment.crates).length,
            consignment.ways);
      });
    }

    test('the tight pair are each other with the lines swapped', () {
      final sols = Rules.solutions(Consignments.at(2).crates);
      expect(sols, hasLength(2));
      for (var crate = 0; crate < 4; crate++) {
        expect(sols[0][crate].$1, sols[1][crate].$2);
        expect(sols[0][crate].$2, sols[1][crate].$1);
      }
    });
  });

  group('a stacking being chosen', () {
    test('starts unchosen and reachable where it can be', () {
      final play = Play.of(Consignments.at(0));
      expect(play.chosenCount, 0);
      expect(play.canStill, isTrue);
      expect(play.next, isNotNull);
    });

    test('a chip cycles free, north-south, east-west, free', () {
      var play = Play.of(Consignments.at(0));
      play = play.cycle(0, 1);
      expect(play.serves(0, 1), 'ns');
      play = play.cycle(0, 1);
      expect(play.serves(0, 1), 'ew');
      play = play.cycle(0, 1);
      expect(play.serves(0, 1), isNull);
    });

    test('one rope per role: a taken role is skipped', () {
      var play = Play.of(Consignments.at(0)).cycle(0, 0);
      play = play.cycle(0, 1);
      expect(play.serves(0, 0), 'ns');
      expect(play.serves(0, 1), 'ew');
      // The third chip has nowhere to go.
      expect(identical(play.cycle(0, 2), play), isTrue);
    });

    test('following next stacks every consignment that can be stacked',
        () {
      for (var number = 0; number < Consignments.count; number++) {
        final consignment = Consignments.at(number);
        if (!consignment.possible) continue;
        var play = Play.of(consignment);
        var guard = 0;
        while (!play.isStacked) {
          if (guard++ > 12) fail('${consignment.name} never stacked');
          final hint = play.next!;
          var tried = play.cycle(hint.$1, hint.$2);
          if (hint.$3 == 'ew' && tried.serves(hint.$1, hint.$2) == 'ns') {
            tried = tried.cycle(hint.$1, hint.$2);
          }
          play = tried;
        }
        expect(play.isStacked, isTrue, reason: consignment.name);
      }
    });

    test('the short consignment can never start', () {
      final play = Play.of(Consignments.at(3));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('a stranding choice shows in the live answer at once', () {
      // On the tight consignment most early choices strand.
      final play = Play.of(Consignments.at(2));
      var strander = (-1, -1);
      outer:
      for (var crate = 0; crate < 4; crate++) {
        for (var pair = 0; pair < 3; pair++) {
          final tried = play.cycle(crate, pair);
          if (!tried.canStill) {
            strander = (crate, pair);
            break outer;
          }
        }
      }
      if (strander.$1 >= 0) {
        expect(play.cycle(strander.$1, strander.$2).canStill, isFalse);
      }
      expect(play.canStill, isTrue);
    });

    test('back returns the last choice', () {
      final start = Play.of(Consignments.at(0));
      final chosen = start.cycle(0, 0);
      expect(chosen.chosenCount, 1);
      expect(chosen.back.chosenCount, 0);
      expect(identical(start.back, start), isTrue);
    });
  });
}
