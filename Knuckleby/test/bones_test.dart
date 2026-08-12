import 'package:flutter_test/flutter_test.dart';
import 'package:knuckleby/bones/benches.dart';
import 'package:knuckleby/bones/play.dart';
import 'package:knuckleby/bones/rules.dart';

void main() {
  group('the tables', () {
    test('a pair\'s table counts every throw', () {
      final table = Rules.table([1, 2], [1, 2]);
      expect(table, {2: 1, 3: 2, 4: 1});
      expect(
        Rules.sameTable(table, Rules.table([1, 2], [2, 1])),
        isTrue,
      );
      expect(
        Rules.sameTable(table, Rules.table([1, 2], [1, 3])),
        isFalse,
      );
    });

    test('the sweep finds the famous pairs and nothing else', () {
      final sixes = Rules.matching(6, 6);
      expect(sixes, hasLength(2));
      expect('${sixes.first.$1}', '[1, 2, 2, 3, 3, 4]');
      expect('${sixes.first.$2}', '[1, 3, 4, 5, 6, 8]');
      expect('${sixes.last.$1}', '[1, 2, 3, 4, 5, 6]');

      final fours = Rules.matching(4, 4);
      expect(fours, hasLength(2));
      expect('${fours.first.$1}', '[1, 2, 2, 3]');
      expect('${fours.first.$2}', '[1, 3, 3, 5]');
    });

    test('the factor-trade builds the same pairs without a roll', () {
      for (final faces in const [4, 6]) {
        final swept = Rules.matching(faces, faces);
        final built = Rules.byFactors(faces);
        expect('$built', '$swept', reason: '$faces sides');
      }
    });

    test('the long and the short fall alike four ways', () {
      final pairs = Rules.matching(4, 6);
      expect(pairs, hasLength(4));
      expect(
        pairs.map((pair) => '${pair.$1}').toSet(),
        {
          '[1, 2, 2, 3]',
          '[1, 2, 3, 4]',
          '[1, 2, 4, 5]',
          '[1, 3, 4, 6]',
        },
      );
    });

    test('every matching die keeps exactly one ace', () {
      for (final (facesOne, facesTwo) in const [(4, 4), (6, 6), (4, 6)]) {
        for (final (one, two) in Rules.matching(facesOne, facesTwo)) {
          expect(one.where((pip) => pip == 1).length, 1);
          expect(two.where((pip) => pip == 1).length, 1);
        }
      }
    });

    test('no even-pipped pair lands the table', () {
      expect(Rules.matching(6, 6, low: 2).where((pair) =>
          pair.$1.every((pip) => pip.isEven) &&
          pair.$2.every((pip) => pip.isEven)), isEmpty);
    });
  });

  group('the benches that ship', () {
    for (final bench in Benches.all) {
      test(bench.name, () {
        final swept = Rules.matching(bench.facesOne, bench.facesTwo,
            low: bench.lowPip);
        final counted = bench.evensOnly
            ? swept
                .where((pair) =>
                    pair.$1.every((pip) => pip.isEven) &&
                    pair.$2.every((pip) => pip.isEven))
                .length
            : bench.lockedOne
                ? swept
                    .where((pair) =>
                        '${pair.$1}' ==
                            '${Rules.standard(bench.facesOne)}' ||
                        '${pair.$2}' ==
                            '${Rules.standard(bench.facesOne)}')
                    .length
                : swept.length;
        expect(counted, bench.ways);
      });
    }
  });

  group('a play', () {
    test('opens blank and cuts pips upward with a wrap', () {
      var play = Play.of(Benches.at(0));
      expect(play.one, [1, 1, 1, 1]);
      expect(play.cuts, 0);
      play = play.cut(0, 2);
      expect(play.one, [1, 1, 2, 1]);
      expect(play.cuts, 1);
      for (var turn = 0; turn < 7; turn++) {
        play = play.cut(0, 2);
      }
      expect(play.one[2], 1);
    });

    test('the locked die refuses the knife', () {
      final play = Play.of(Benches.at(2));
      expect(play.one, [1, 2, 3, 4, 5, 6]);
      expect(play.mayCut(0), isFalse);
      expect(play.cut(0, 0), same(play));
      expect(play.mayCut(1), isTrue);
    });

    test('the even bench cuts by twos', () {
      var play = Play.of(Benches.at(4));
      expect(play.one, [2, 2, 2, 2, 2, 2]);
      play = play.cut(0, 0);
      expect(play.one[0], 4);
      play = play.cut(0, 0).cut(0, 0);
      expect(play.one[0], 8);
      play = play.cut(0, 0);
      expect(play.one[0], 2);
    });

    test('matching the standard is refused where the other pair is '
        'asked', () {
      var play = Play.of(Benches.at(0));
      for (var face = 0; face < 4; face++) {
        while (play.one[face] != face + 1) {
          play = play.cut(0, face);
        }
        while (play.two[face] != face + 1) {
          play = play.cut(1, face);
        }
      }
      expect(play.matches, isTrue);
      expect(play.isStandard, isTrue);
      expect(play.isDone, isFalse);
    });

    test('cutting the other pair settles the bench', () {
      var play = Play.of(Benches.at(0));
      const other = ([1, 2, 2, 3], [1, 3, 3, 5]);
      for (var face = 0; face < 4; face++) {
        while (play.one[face] != other.$1[face]) {
          play = play.cut(0, face);
        }
        while (play.two[face] != other.$2[face]) {
          play = play.cut(1, face);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.apart, 0);
    });

    test('apart falls as the cuts land true', () {
      var play = Play.of(Benches.at(0));
      final before = play.apart;
      expect(before, greaterThan(0));
      // One face cut to a pip the other pair holds.
      play = play.cut(0, 1); // 1 -> 2, which (1,2,2,3) wants
      expect(play.apart, lessThanOrEqualTo(before));
    });

    test('back uncuts', () {
      final play = Play.of(Benches.at(0)).cut(0, 1);
      expect(play.back.one, [1, 1, 1, 1]);
      expect(play.back.cuts, 0);
    });

    test('the even bones never match and give up at the line', () {
      var play = Play.of(Benches.at(4));
      expect(play.apart, -1);
      for (var turn = 0; turn < Play.gaveUpAt; turn++) {
        expect(play.isOver, isFalse);
        play = play.cut(1, turn % 6);
        expect(play.matches, isFalse);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });
}
