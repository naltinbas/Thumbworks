import 'package:flutter_test/flutter_test.dart';
import 'package:tallowfield/garden/code.dart';
import 'package:tallowfield/garden/evenings.dart';
import 'package:tallowfield/garden/play.dart';

void main() {
  group('the beds', () {
    test('a lamp\'s number is exactly which hedges it stands in', () {
      for (var lamp = 1; lamp <= 7; lamp++) {
        expect(Code.inHedge(lamp, 0), lamp & 1 != 0, reason: 'lamp $lamp A');
        expect(Code.inHedge(lamp, 1), lamp & 2 != 0, reason: 'lamp $lamp B');
        expect(Code.inHedge(lamp, 2), lamp & 4 != 0, reason: 'lamp $lamp C');
      }
    });

    test('the seven beds are the seven ways hedges overlap, one lamp each',
        () {
      final beds = <int>{};
      for (var lamp = 1; lamp <= 7; lamp++) {
        var bed = 0;
        for (var hedge = 0; hedge < 3; hedge++) {
          if (Code.inHedge(lamp, hedge)) bed |= 1 << hedge;
        }
        expect(bed, isNot(0));
        expect(beds.add(bed), isTrue, reason: 'lamp $lamp shares a bed');
      }
      expect(beds, hasLength(7));
    });
  });

  group('the gardener\'s plantings', () {
    test('there are sixteen, and no two differ at fewer than three lamps',
        () {
      final sound = Code.soundPlantings();
      expect(sound, hasLength(16));
      for (var one = 0; one < sound.length; one++) {
        for (var other = one + 1; other < sound.length; other++) {
          var differs = sound[one] ^ sound[other];
          var apart = 0;
          while (differs != 0) {
            apart++;
            differs &= differs - 1;
          }
          expect(apart, greaterThanOrEqualTo(3),
              reason: '${sound[one]} vs ${sound[other]}');
        }
      }
    });
  });

  group('the tallies and the trying', () {
    test('agree on every pattern a garden can show', () {
      // The anchor. The tallies read three parities as a number; the
      // trying flips each lamp and looks. All 128 patterns, no parting.
      for (var pattern = 0; pattern < 128; pattern++) {
        expect(Code.named(pattern), Code.namedByTrying(pattern),
            reason: 'pattern $pattern');
      }
    });

    test('and name the changed lantern on every one-draught evening', () {
      for (final planting in Code.soundPlantings()) {
        for (var lamp = 1; lamp <= 7; lamp++) {
          expect(Code.named(planting ^ (1 << (lamp - 1))), lamp,
              reason: 'planting $planting lamp $lamp');
        }
      }
    });

    test('two draughts always mistake the tallies, every pair of every '
        'planting', () {
      // The boundary swept whole: the two changed beds cancel into a
      // third, the tallies point somewhere the draught never was, and
      // relighting the named lamp lands a sound planting that is not the
      // gardener's. The code cannot tell, and that is a fact, not a bug.
      for (final planting in Code.soundPlantings()) {
        for (var one = 1; one <= 7; one++) {
          for (var other = one + 1; other <= 7; other++) {
            final blown =
                planting ^ (1 << (one - 1)) ^ (1 << (other - 1));
            final named = Code.named(blown);
            expect(named, isNot(0));
            expect(named, isNot(one));
            expect(named, isNot(other));
            final mended = blown ^ (1 << (named - 1));
            expect(Code.isSound(mended), isTrue);
            expect(mended, isNot(planting));
          }
        }
      }
    });
  });

  group('every evening that ships', () {
    for (var number = 0; number < Evenings.count; number++) {
      final evening = Evenings.at(number);

      test('${evening.name} is planted sound', () {
        expect(Code.isSound(evening.planted), isTrue);
      });
    }

    test('the four honest evenings point true', () {
      for (final number in const [0, 1, 3]) {
        final evening = Evenings.at(number);
        expect(Code.named(evening.seen), evening.snuffed.single,
            reason: evening.name);
      }
      expect(Code.named(Evenings.at(2).seen), 0);
    });

    test('the double draught points at a lamp it never touched', () {
      final evening = Evenings.at(4);
      final named = Code.named(evening.seen);
      expect(named, 7);
      expect(evening.snuffed, isNot(contains(named)));
    });
  });

  group('an evening being read', () {
    test('the right reading settles it', () {
      final play = Play.of(Evenings.at(0)).read(1);
      expect(play.settled, isTrue);
      expect(play.slips, 0);
      expect(play.talliesTrue, isTrue);
    });

    test('a wrong reading is counted and the evening goes on', () {
      var play = Play.of(Evenings.at(0)).read(4);
      expect(play.settled, isFalse);
      expect(play.slips, 1);
      play = play.read(1);
      expect(play.settled, isTrue);
      expect(play.slips, 1);
    });

    test('the quiet garden settles on all\'s well', () {
      expect(Play.of(Evenings.at(2)).read(0).settled, isTrue);
      expect(Play.of(Evenings.at(2)).read(3).slips, 1);
    });

    test('the double draught settles on the tallies\' word, and owns the '
        'mistake', () {
      final play = Play.of(Evenings.at(4)).read(7);
      expect(play.settled, isTrue);
      expect(play.talliesTrue, isFalse);
    });

    test('lamps read as lit off the seen pattern', () {
      final play = Play.of(Evenings.at(0));
      expect(play.lit(1), isFalse);
      expect(play.lit(2), isTrue);
      expect(play.lit(3), isTrue);
      expect(play.complaints, [true, false, false]);
    });
  });
}
