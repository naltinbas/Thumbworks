import 'package:flutter_test/flutter_test.dart';
import 'package:riddlecombe/weave/meshes.dart';
import 'package:riddlecombe/weave/play.dart';
import 'package:riddlecombe/weave/rules.dart';

void main() {
  group('the comb', () {
    test('drops the heavy grain to the lower strand and nothing else', () {
      final rules = Rules(3);
      // Strand 0 heavy, strand 1 light: the one drops.
      expect(rules.combed(0x1, (0, 1)), 0x2);
      expect(rules.combed(0x2, (0, 1)), 0x2);
      expect(rules.combed(0x3, (0, 1)), 0x3);
      expect(rules.combed(0x0, (0, 1)), 0x0);
    });

    test('a settled grist holds its ones at the bottom', () {
      final rules = Rules(4);
      expect(rules.settled(0x5), 0xC);
      expect(rules.settled(0x0), 0x0);
      expect(rules.settled(0xF), 0xF);
    });

    test('the classic three-comb weave riddles three strands', () {
      final rules = Rules(3);
      const weave = [(0, 1), (1, 2), (0, 1)];
      expect(rules.riddles(weave), isTrue);
      expect(rules.riddlesOrderings(weave), isTrue);
      expect(rules.unsettled(weave), isEmpty);
    });

    test('a trace walks a grist comb by comb', () {
      final rules = Rules(3);
      // Heavy on top only: it sinks one comb at a time.
      expect(rules.trace(0x1, const [(0, 1), (1, 2)]), [0x1, 0x2, 0x4]);
    });
  });

  group('the two ways of knowing', () {
    test('meet on every four-comb weave of four strands', () {
      // The anchor, and the nought-one principle earned rather than
      // cited: 1296 weaves, judged by 16 grists and by 24 orderings,
      // and the verdicts never part. None riddles.
      final rules = Rules(4);
      var swept = 0;
      for (final weave in rules.allWeaves(4)) {
        swept++;
        final byGrists = rules.riddles(weave);
        expect(rules.riddlesOrderings(weave), byGrists,
            reason: '$weave');
        expect(byGrists, isFalse, reason: '$weave');
      }
      expect(swept, 1296);
    });

    test('and on the dozen five-comb weaves that riddle', () {
      final rules = Rules(4);
      var fine = 0;
      for (final weave in rules.allWeaves(5)) {
        final byGrists = rules.riddles(weave);
        if (byGrists) {
          fine++;
          expect(rules.riddlesOrderings(weave), isTrue, reason: '$weave');
        }
      }
      expect(fine, 12);
    });

    test('the search agrees with the outright sweep on the short weave',
        () {
      // Two proofs sharing nothing: enumeration above, and the
      // outcome-following search here.
      expect(Rules(4).canStill(const [], 4), isFalse);
    });
  });

  group('every mesh that ships', () {
    for (var number = 0; number < Meshes.count; number++) {
      final mesh = Meshes.at(number);

      test('${mesh.name} is what it says it is', () {
        final rules = Rules(mesh.strands);
        expect(rules.canStill(const [], mesh.combs), mesh.winnable);
        if (mesh.winnable) {
          expect(rules.canStill(const [], mesh.combs - 1), isFalse);
        }
      });
    }
  });

  group('a weave in play', () {
    test('starts empty with the whole frame to fill', () {
      final play = Play.of(Meshes.at(0));
      expect(play.placed, 0);
      expect(play.room, 3);
      expect(play.isClean, isFalse);
      expect(play.canStill, isTrue);
    });

    test('a comb lands between two strands, either order given', () {
      final play = Play.of(Meshes.at(0)).comb(1, 0);
      expect(play.weave, [(0, 1)]);
      expect(play.placed, 1);
      expect(identical(play.comb(1, 1), play), isTrue);
    });

    test('take back lifts the last comb out', () {
      final start = Play.of(Meshes.at(0));
      final combed = start.comb(0, 1);
      expect(combed.back.placed, 0);
      expect(identical(start.back, start), isTrue);
    });

    test('a comb that wastes the frame shows in canStill at once', () {
      // Three strands, three combs: the first comb must not be
      // wasted. A comb between nought and one, twice, wastes one.
      final play = Play.of(Meshes.at(0)).comb(0, 1);
      expect(play.canStill, isTrue);
      final wasted = play.comb(0, 1);
      expect(wasted.canStill, isFalse);
    });

    test('following next riddles every winnable mesh in its combs', () {
      for (var number = 0; number < Meshes.count; number++) {
        final mesh = Meshes.at(number);
        if (!mesh.winnable) continue;
        var play = Play.of(mesh);
        var guard = 0;
        while (!play.isClean) {
          if (guard++ > 14) fail('${mesh.name} never came clean');
          expect(play.canStill, isTrue, reason: mesh.name);
          final comb = play.next;
          expect(comb, isNotNull, reason: mesh.name);
          play = play.comb(comb!.$1, comb.$2);
        }
        expect(play.placed, mesh.combs, reason: mesh.name);
        expect(play.rules.riddlesOrderings(play.weave), isTrue,
            reason: mesh.name);
      }
    });

    test('the short weave runs out of combs still foul', () {
      var play = Play.of(Meshes.at(2));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
      play = play.comb(0, 1).comb(2, 3).comb(0, 2).comb(1, 3);
      expect(play.outOfCombs, isTrue);
      expect(play.foul, isNotNull);
      expect(play.isClean, isFalse);
    });
  });
}
