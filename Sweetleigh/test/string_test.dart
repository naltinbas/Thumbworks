import 'package:flutter_test/flutter_test.dart';
import 'package:sweetleigh/string/play.dart';
import 'package:sweetleigh/string/rules.dart';
import 'package:sweetleigh/string/shares.dart';

/// The law of the string, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final share in Shares.all) {
        expect(Rules(share.sweets).waysBySweep(share.cuts), share.ways,
            reason: share.name);
      }
    });

    test('pieces and shares are handed out in turn', () {
      final rules = Rules('RRRRBBBB');
      expect(rules.pieces([2, 6]), ['RR', 'RRBB', 'BB']);
      final (first, second) = rules.shares([2, 6]);
      expect(first, {'R': 2, 'B': 2});
      expect(second, {'R': 2, 'B': 2});
      expect(rules.fair([2, 6]), isTrue);
      expect(rules.fair([4]), isFalse);
      expect(rules.fair([]), isFalse);
      expect(Rules('RRBBBBRR').fair([4]), isTrue);
    });

    test('the window is built and shares, on every string of four and four', () {
      var seen = 0;
      Rules.strings({'R': 4, 'B': 4}, (sweets) {
        seen++;
        final rules = Rules(sweets);
        final built = rules.window()!;
        expect(built.length, lessThanOrEqualTo(2));
        expect(rules.fair(built), isTrue, reason: sweets);
      });
      expect(seen, 70);
      expect(Rules('RRRRBBBB').window(), [2, 6]);
      expect(Rules('RRGGBB').window(), isNull);
    });

    test('the fewest cuts fall as counted', () {
      expect(Rules('RRBBBBRR').fewest(), 1);
      expect(Rules('RRRRBBBB').fewest(), 2);
      expect(Rules('RRGGBB').fewest(), 3);
      expect(Rules('RGBRGB').fewest(), 1);
      var one = 0, two = 0, three = 0;
      Rules.strings({'R': 2, 'G': 2, 'B': 2}, (sweets) {
        switch (Rules(sweets).fewest()) {
          case 1:
            one++;
          case 2:
            two++;
          case 3:
            three++;
          default:
            fail('$sweets needs more than three');
        }
      });
      expect([one, two, three], [36, 42, 12]);
    });

    test('the single cut is refused seven times over', () {
      final rules = Rules('RRRRBBBB');
      for (var gap = 1; gap < 8; gap++) {
        expect(rules.fair([gap]), isFalse, reason: '$gap');
      }
      expect(rules.landing(1), isNull);
      expect(rules.landing(2), [2, 6]);
    });
  });

  group('the play', () {
    test('opens uncut', () {
      for (final share in Shares.all) {
        final play = Play.of(share);
        expect(play.cuts, isEmpty, reason: share.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap cuts, a tap mends, counted both ways', () {
      var play = Play.of(Shares.at(1));
      play = play.tap(3);
      expect(play.cuts, [3]);
      expect(play.moves, 1);
      play = play.tap(3);
      expect(play.cuts, isEmpty);
      expect(play.moves, 2);
      expect(play.back.cuts, [3]);
    });

    test('no more cuts than allowed, and never off the string', () {
      final play = Play.of(Shares.at(0)).tap(3);
      expect(play.tap(5), same(play));
      expect(play.tap(0), same(play));
      expect(play.tap(8), same(play));
      expect(play.touches(3), isTrue);
    });

    test('the one cut lands by hand, the two cuts too', () {
      final one = Play.of(Shares.at(0)).tap(4);
      expect(one.isDone, isTrue);
      expect(one.tap(2), same(one));
      final two = Play.of(Shares.at(1)).tap(2).tap(6);
      expect(two.isDone, isTrue);
      expect(two.moves, 2);
    });

    test('the pointer lands the three kinds and the long string', () {
      for (final number in [2, 3]) {
        var play = Play.of(Shares.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, gap) = play.next!;
          play = play.tap(gap);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
    });

    test('the pointer mends a cut off the share first', () {
      final play = Play.of(Shares.at(1)).tap(3);
      expect(play.next, ('mend', 3));
      expect(play.tap(3).next, ('cut', 2));
    });

    test('the hopeless share admits it at nine moves', () {
      var play = Play.of(Shares.at(4)).tap(4);
      expect(play.isDone, isFalse);
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap(4).tap(4);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.cuts, [4]);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable share never gives up', () {
      var play = Play.of(Shares.at(1));
      for (var dither = 0; dither < 5; dither++) {
        play = play.tap(3).tap(3);
      }
      expect(play.moves, 10);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands shared', () {
      final mark = Play.standing(Shares.at(1), Rules('RRRRBBBB').window()!);
      expect(mark.isDone, isTrue);
      expect(mark.pieces, ['RR', 'RRBB', 'BB']);
    });
  });
}
