import 'package:flutter_test/flutter_test.dart';
import 'package:posygarth/garden/garths.dart';
import 'package:posygarth/garden/play.dart';
import 'package:posygarth/garden/rules.dart';

void main() {
  group('the plantings', () {
    test('hold at every odd size and at four', () {
      // The anchor. The two-line arithmetic and the doubled square are
      // constructions; sound checks rows, columns and pairings and
      // knows nothing of how they were made.
      for (final size in const [3, 5, 7, 9, 11]) {
        expect(Rules.sound(size, Rules.planted(size)!), isTrue,
            reason: '$size');
      }
      expect(Rules.sound(4, Rules.planted(4)!), isTrue);
    });

    test('there is no planting of two, by exhausting every attempt', () {
      expect(Rules.anyExists(2), isFalse);
    });

    test('sound really checks what it says', () {
      // Break a sound planting one way at a time.
      final good = Rules.planted(3)!;
      expect(Rules.sound(3, good), isTrue);
      final swapped = [...good];
      final hold = swapped[0];
      swapped[0] = swapped[1];
      swapped[1] = hold;
      expect(Rules.sound(3, swapped), isFalse);
    });
  });

  group('every garth that ships', () {
    for (var number = 0; number < Garths.count; number++) {
      final garth = Garths.at(number);

      test('${garth.name} says what the search says', () {
        expect(Rules.anyExists(garth.size), garth.possible);
      });
    }

    test('the seeded five is seeded from the planting, and finishable', () {
      final seeded = Play.of(Garths.at(4));
      expect(seeded.planted, 5);
      expect(seeded.canStill, isTrue);
    });
  });

  group('a garth being planted', () {
    test('starts as the gardener left it', () {
      final play = Play.of(Garths.at(0));
      expect(play.planted, 0);
      expect(play.canStill, isTrue);
      expect(play.next, isNotNull);
    });

    test('a posy goes in only where nothing clashes', () {
      var play = Play.of(Garths.at(0)).plant(0, 0, 0);
      expect(play.planted, 1);
      expect(play.clashAt(1, 0, 1), 'that flower is in this row');
      expect(play.clashAt(1, 1, 0), 'that colour is in this row');
      expect(play.clashAt(3, 0, 1), 'that flower is in this column');
      expect(play.clashAt(4, 0, 0), 'that very posy is planted already');
      expect(identical(play.plant(1, 0, 1), play), isTrue);
    });

    test('following next blooms every garth that can bloom', () {
      for (var number = 0; number < Garths.count; number++) {
        final garth = Garths.at(number);
        if (!garth.possible) continue;
        var play = Play.of(garth);
        var guard = 0;
        while (!play.isBloomed) {
          if (guard++ > garth.beds + 1) fail('${garth.name} never bloomed');
          final posy = play.next!;
          play = play.plant(posy.$1, posy.$2, posy.$3);
        }
        expect(
            Rules.sound(garth.size,
                [for (final bed in play.beds) (bed.$1, bed.$2)]),
            isTrue,
            reason: garth.name);
      }
    });

    test('the pair of pairs can never start', () {
      final play = Play.of(Garths.at(2));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('a stranding posy shows in the live answer at once', () {
      // On four, plenty of legal posies strand the garth.
      var play = Play.of(Garths.at(1));
      play = play.plant(play.next!.$1, play.next!.$2, play.next!.$3);
      var strander = (-1, -1, -1);
      outer:
      for (var bed = 0; bed < 16; bed++) {
        if (!play.isEmpty(bed)) continue;
        for (var flower = 0; flower < 4; flower++) {
          for (var colour = 0; colour < 4; colour++) {
            if (play.clashAt(bed, flower, colour) != null) continue;
            final tried = play.plant(bed, flower, colour);
            if (!tried.canStill) {
              strander = (bed, flower, colour);
              break outer;
            }
          }
        }
      }
      if (strander.$1 >= 0) {
        expect(
            play
                .plant(strander.$1, strander.$2, strander.$3)
                .canStill,
            isFalse);
      }
      expect(play.canStill, isTrue);
    });

    test('back digs the last posy up', () {
      final start = Play.of(Garths.at(0));
      final planted = start.plant(0, 1, 2);
      expect(planted.planted, 1);
      expect(planted.back.planted, 0);
      expect(identical(start.back, start), isTrue);
    });
  });
}
