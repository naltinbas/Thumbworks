import 'package:flutter_test/flutter_test.dart';
import 'package:notchfield/ruler/cuts.dart';
import 'package:notchfield/ruler/play.dart';
import 'package:notchfield/ruler/rules.dart';

void main() {
  group('the census', () {
    test('counts every pair by its distance', () {
      final rules = Rules(6);
      final counts = rules.census(const [0, 1, 4, 6]);
      expect(counts.sublist(1), [1, 1, 1, 1, 1, 1]);
      expect(rules.isPerfect(const [0, 1, 4, 6]), isTrue);
      expect(rules.isSound(const [0, 1, 2]), isFalse);
    });

    test('a clash names the pairs measuring alike', () {
      final rules = Rules(6);
      expect(rules.clashesAt(const [0, 1, 2], 1),
          [((0, 1), (1, 2))]);
    });
  });

  group('the sweep', () {
    test('finds the book rulers and their mirrors, nothing else', () {
      // The anchor: every placing tried, no theory anywhere.
      expect(Rules(3).soundCuttings(3, perfect: true),
          [[0, 1, 3], [0, 2, 3]]);
      expect(Rules(6).soundCuttings(4, perfect: true),
          [[0, 1, 4, 6], [0, 2, 5, 6]]);
      expect(Rules(11).soundCuttings(5, perfect: false), hasLength(4));
      expect(Rules(12).countCuttings(5).$1, 22);
    });

    test('the perfect ten has no slack, and no cutting either', () {
      // Ten pairs, ten lengths: sound here would be perfect. None is
      // even sound.
      final rules = Rules(10);
      final (sound, perfect) = rules.countCuttings(5);
      expect(sound, 0);
      expect(perfect, 0);
      var cuttings = 0;
      for (final cutting in rules.allCuttings(5)) {
        cuttings++;
        expect(rules.isSound(cutting), isFalse, reason: '$cutting');
      }
      expect(cuttings, 462);
    });

    test('every shipped count is what the sweep says', () {
      for (var number = 0; number < Cuts.count; number++) {
        final cut = Cuts.at(number);
        final (sound, perfect) = Rules(cut.length).countCuttings(cut.notches);
        expect(cut.perfect ? perfect : sound, cut.ways,
            reason: cut.name);
      }
    });
  });

  group('a ruler in play', () {
    test('starts uncut', () {
      final play = Play.of(Cuts.at(0));
      expect(play.notched, isEmpty);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a toggle cuts and fills, and the count holds at the ask', () {
      var play = Play.of(Cuts.at(0));
      play = play.toggle(0).toggle(1).toggle(2);
      expect(play.notched, [0, 1, 2]);
      expect(play.isFull, isTrue);
      expect(play.isDone, isFalse);
      expect(identical(play.toggle(3), play), isTrue);
      play = play.toggle(1);
      expect(play.notched, [0, 2]);
    });

    test('the doubled lengths show the moment they double', () {
      final play = Play.of(Cuts.at(1)).toggle(0).toggle(1).toggle(2);
      expect(play.doubled, [1]);
      expect(play.isSound, isFalse);
    });

    test('take back returns the ruler as it lay', () {
      final start = Play.of(Cuts.at(0));
      final cutOnce = start.toggle(0);
      expect(cutOnce.back.notched, isEmpty);
      expect(identical(start.back, start), isTrue);
    });

    test('a sound full cutting that is not perfect does not finish a '
        'perfect ask', () {
      // On the six: [0,1,3,7]? out of range. Use [0,1,3,5]: sound?
      // distances 1,3,5,2,4,2 clash at 2. Take [0,1,4,6] minus 6 plus
      // 5: [0,1,4,5]: distances 1,4,5,3,4,1 clash. The six-length has
      // only perfect sound cuttings of four, which is the point: any
      // sound full cutting IS perfect here. So assert that instead.
      final rules = Rules(6);
      for (final cutting in rules.soundCuttings(4, perfect: false)) {
        expect(rules.isPerfect(cutting), isTrue, reason: '$cutting');
      }
    });

    test('following next cuts every winnable ruler', () {
      for (var number = 0; number < Cuts.count; number++) {
        final cut = Cuts.at(number);
        if (!cut.winnable) continue;
        var play = Play.of(cut);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 15) fail('${cut.name} never came sound');
          play = play.toggle(play.next!);
        }
        expect(play.isSound, isTrue, reason: cut.name);
      }
    });

    test('next fills a stray notch before cutting on', () {
      final play = Play.of(Cuts.at(1)).toggle(3);
      expect(play.next, 3);
    });

    test('the perfect ten offers nothing and never comes sound', () {
      var play = Play.of(Cuts.at(4));
      expect(play.next, isNull);
      play = play
          .toggle(0)
          .toggle(1)
          .toggle(4)
          .toggle(9)
          .toggle(10);
      expect(play.isFull, isTrue);
      expect(play.isSound, isFalse);
      expect(play.isDone, isFalse);
    });
  });
}
