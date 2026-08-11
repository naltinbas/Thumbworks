import 'package:flutter_test/flutter_test.dart';
import 'package:withyshaw/hedge/hedges.dart';
import 'package:withyshaw/hedge/play.dart';
import 'package:withyshaw/hedge/rules.dart';
import 'package:withyshaw/hedge/worth.dart';

List<(int, int)> _kinds(int longest) => [
      for (var length = 1; length <= longest; length++)
        for (var bits = 0; bits < (1 << length); bits++) (bits, length),
    ];

void main() {
  group('the worth of a stalk', () {
    test('is whole while the colour holds, then halves', () {
      expect(Rules.worthOf(0x1, 1), Worth(1, 1));
      expect(Rules.worthOf(0x3, 2), Worth(2, 1));
      expect(Rules.worthOf(0x0, 1), Worth(-1, 1));
      expect(Rules.worthOf(0x1, 2), Worth(1, 2));
      expect(Rules.worthOf(0x5, 3), Worth(3, 4));
      expect(Rules.worthOf(0x2, 2), Worth(-1, 2));
      expect(Rules.worthOf(0x6, 3), Worth(-1, 4));
    });

    test('and the famous nought sums to nought', () {
      expect(
        Rules.worthOfHedge(const [(0x1, 2), (0x1, 2), (0x0, 1)]),
        Worth.nought,
      );
    });

    test('worths ease themselves and say themselves', () {
      expect(Worth(2, 4), Worth(1, 2));
      expect(Worth(1, 2).said, '1/2');
      expect(Worth(7, 4).said, '1 3/4');
      expect(Worth(-1, 4).said, '-1/4');
      expect(Worth(3, 1).said, '3');
    });
  });

  group('the worth and the search', () {
    test('agree on every two-stalk hedge of up to four withies', () {
      // The anchor. The worth is arithmetic; the search cuts. 465
      // hedges, and the sign of the sum is exactly who holds it.
      final kinds = _kinds(4);
      for (var a = 0; a < kinds.length; a++) {
        for (var b = a; b < kinds.length; b++) {
          final hedge = [kinds[a], kinds[b]];
          expect(Rules.isLoss(hedge, true),
              !Rules.worthOfHedge(hedge).isPositive,
              reason: '$hedge');
        }
      }
    });

    test('and on a sweep of three-stalk hedges of up to three withies', () {
      final kinds = _kinds(3);
      for (var a = 0; a < kinds.length; a++) {
        for (var b = a; b < kinds.length; b++) {
          for (var c = b; c < kinds.length; c++) {
            final hedge = [kinds[a], kinds[b], kinds[c]];
            expect(Rules.isLoss(hedge, true),
                !Rules.worthOfHedge(hedge).isPositive,
                reason: '$hedge');
          }
        }
      }
    });

    test('at nought the second cutter holds it, from either side', () {
      const nought = [(0x1, 2), (0x1, 2), (0x0, 1)];
      expect(Rules.isLoss(nought, true), isTrue);
      expect(Rules.isLoss(nought, false), isTrue);
    });

    test('a positive hedge is yours whoever cuts first', () {
      const yours = [(0x5, 3), (0x2, 2)];
      expect(Rules.worthOfHedge(yours), Worth(1, 4));
      expect(Rules.isLoss(yours, true), isFalse);
      expect(Rules.isLoss(yours, false), isTrue);
    });
  });

  group('every hedge that ships', () {
    for (var number = 0; number < Hedges.count; number++) {
      final hedge = Hedges.at(number);

      test('${hedge.name} says what the worth and the search say', () {
        final worth = Rules.worthOfHedge(hedge.stalks);
        expect(worth.isPositive, hedge.winnable);
        expect(!Rules.isLoss(hedge.stalks, true), hedge.winnable);
      });
    }

    test('the shipped worths are the shipped worths', () {
      expect(Rules.worthOfHedge(Hedges.at(0).stalks).said, '1/2');
      expect(Rules.worthOfHedge(Hedges.at(2).stalks).said, '1/4');
      expect(Rules.worthOfHedge(Hedges.at(3).stalks).said, '0');
      expect(Rules.worthOfHedge(Hedges.at(4).stalks).said, '3/4');
    });
  });

  group('a hedge in play', () {
    test('opens as the hedger left it', () {
      final play = Play.of(Hedges.at(2));
      expect(play.worth, Worth(1, 4));
      expect(play.winnable, isTrue);
      expect(play.next, isNotNull);
    });

    test('only your withies answer the bill', () {
      final play = Play.of(Hedges.at(0));
      expect(play.mayCut(0, 0), isTrue);
      expect(play.mayCut(0, 1), isFalse);
      expect(identical(play.cut(0, 1), play), isTrue);
    });

    test('a cut drops everything above it', () {
      // The first withy: cutting your ground withy fells the stalk and
      // the hedger has nothing left: the hedge is yours.
      final play = Play.of(Hedges.at(0)).cut(0, 0);
      expect(play.isOver, isTrue);
      expect(play.won, isTrue);
    });

    test('following the search holds every winnable hedge', () {
      for (var number = 0; number < Hedges.count; number++) {
        final hedge = Hedges.at(number);
        if (!hedge.winnable) continue;
        var play = Play.of(hedge);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 20) fail('${hedge.name} never ended');
          expect(play.winnable, isTrue, reason: hedge.name);
          final cut = play.next!;
          play = play.cut(cut.$1, cut.$2);
        }
        expect(play.won, isTrue, reason: hedge.name);
      }
    });

    test('every first cut of the even hedge loses it', () {
      final start = Play.of(Hedges.at(3));
      for (var stalk = 0; stalk < start.stalks.length; stalk++) {
        final (bits, length) = start.stalks[stalk];
        for (var at = 0; at < length; at++) {
          if ((bits >> at) & 1 == 0) continue;
          final cutOnce = start.cut(stalk, at);
          expect(cutOnce.winnable, isFalse, reason: 'cut $stalk $at');
        }
      }
    });

    test('a careless cut on the last quarter is called by the worth', () {
      // Cutting your withy atop the hedger's stalk fells only your own
      // and gifts the hedger a whole one: the quarter margin is spent.
      final play = Play.of(Hedges.at(2)).cut(1, 1);
      expect(play.winnable, isFalse);
    });

    test('take back returns the whole exchange', () {
      final start = Play.of(Hedges.at(2));
      final cutOnce = start.cut(start.next!.$1, start.next!.$2);
      expect(cutOnce.back.stalks, Hedges.at(2).stalks);
      expect(identical(start.back, start), isTrue);
    });
  });
}
