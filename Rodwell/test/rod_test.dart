import 'package:flutter_test/flutter_test.dart';
import 'package:rodwell/rod/levels.dart';
import 'package:rodwell/rod/play.dart';
import 'package:rodwell/rod/rules.dart';

/// The rod, the cuts and the products, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the rod', () {
    test('cuts leave parts, and the parts multiply', () {
      expect(Rules.partsOf(12, {}), [12]);
      expect(Rules.partsOf(12, {2, 5, 8}), [3, 3, 3, 3]);
      expect(Rules.partsOf(10, {2, 5}), [3, 3, 4]);
      expect(Rules.product([3, 3, 3, 3]), BigInt.from(81));
      expect(Rules.places(12), 11);
      expect(Rules.howManyCuttings(12), 2048);
      expect(Rules.tellParts([3, 3, 4]), '3 + 3 + 4');
      expect(Rules.tellProduct(BigInt.from(1458)), '1,458');
    });

    test('the sweep, the rule and the working up all agree', () {
      final workingUp = Rules.bestByWorkingUp(Rules.longest);
      for (var hands = Rules.shortest; hands <= Rules.longest; hands++) {
        expect(Rules.bestByRule(hands), workingUp[hands], reason: '$hands');
        if (hands <= 12) {
          expect(Rules.bestBySweep(hands), Rules.bestByRule(hands),
              reason: '$hands');
        }
      }
      expect(Rules.bestByRule(10), BigInt.from(36));
      expect(Rules.bestByRule(11), BigInt.from(54));
      expect(Rules.bestByRule(12), BigInt.from(81));
      expect(Rules.bestByRule(16), BigInt.from(324));
      expect(Rules.bestByRule(20), BigInt.from(1458));
    });

    test('the best parts are threes with a four or a two over', () {
      for (var hands = 5; hands <= Rules.longest; hands++) {
        final parts = Rules.bestParts(hands);
        expect(parts.reduce((a, b) => a + b), hands, reason: '$hands');
        expect(Rules.product(parts), Rules.bestByRule(hands), reason: '$hands');
        expect(parts.where((part) => part == 3).length,
            greaterThanOrEqualTo(parts.length - 1),
            reason: '$hands');
        expect(parts.every((part) => part >= 2 && part <= 4), isTrue,
            reason: '$hands');
      }
      expect(Rules.bestParts(12), [3, 3, 3, 3]);
      expect(Rules.bestParts(10), [3, 3, 4]);
      expect(Rules.bestParts(11), [2, 3, 3, 3]);
      expect(Rules.bestCuts(12), {2, 5, 8});
    });

    test('the cuttings that reach the best, counted', () {
      expect(Rules.cuttingsAt(10, BigInt.from(36)), 9);
      expect(Rules.cuttingsAt(11, BigInt.from(54)), 4);
      expect(Rules.cuttingsAt(12, BigInt.from(81)), 1);
      expect(Rules.cuttingsAt(12, BigInt.from(82)), 0);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['Beat the Threes']);
      for (final level in Levels.all) {
        var n = 0;
        for (final cuts in Rules.cuttings(level.hands)) {
          if (level.meets(cuts)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.hands), [10, 11, 12, 16, 16]);
      expect(Levels.all.map((l) => l.want), [36, 54, 81, 324, 324]);
      expect(Levels.all.map((l) => l.fewest), [2, 3, 3, 4, null]);
      expect(Levels.all.map((l) => l.cuttings), [512, 1024, 2048, 32768, 32768]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(2).task,
          'cut the rod of 12 so that the parts multiply to 81');
      expect(Levels.at(4).task,
          'cut the rod of 16 so that the parts multiply past 324');
    });
  });

  group('the play', () {
    test('opens on an uncut rod', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.cuts, isEmpty);
        expect(play.parts, [level.hands]);
        expect(play.product, BigInt.from(level.hands));
        expect((play.moves, play.isOver), (0, false), reason: level.name);
      }
    });

    test('a tap cuts and a second mends', () {
      var play = Play.of(Levels.at(2));
      play = play.cut(2);
      expect(play.cuts, {2});
      expect(play.parts, [3, 9]);
      play = play.cut(2);
      expect(play.cuts, isEmpty);
      expect(play.moves, 2);
      expect(play.cut(99), same(play));
      expect(play.back.cuts, {2});
    });

    test('the pointer lands every ask it can, in the fewest cuts', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final place = play.next;
          expect(place, isNotNull, reason: level.name);
          play = play.cut(place!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
      }
      expect(Play.of(Levels.at(2)).pointed(2), 'Cut after hand 3.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('beat the threes admits it after three best cuttings', () {
      var play = Play.of(Levels.at(4));
      // Four threes and a four.
      play = play.cut(2).cut(5).cut(8).cut(11);
      expect(play.product, BigInt.from(324));
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      // The four at the other end.
      play = play.cut(2).cut(5).cut(8).cut(11);
      expect(play.cuts, isEmpty);
      play = play.cut(3).cut(6).cut(9).cut(12);
      expect(play.product, BigInt.from(324));
      expect(play.seen, hasLength(2));
      expect(play.gaveUp, isFalse);
      // And the four cut into two twos.
      play = play.cut(1);
      expect(play.parts, [2, 2, 3, 3, 3, 3]);
      expect(play.product, BigInt.from(324));
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.cut(k % 15);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells the threes and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('three times what is left'));
      expect(words, contains('nine beats eight'));
      expect(words, contains('This is ask 5, Beat the Threes.'));
      expect(words, contains('tried in full before the sham'));
    });
  });
}
