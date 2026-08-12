import 'package:flutter_test/flutter_test.dart';
import 'package:scoreham/score/play.dart';
import 'package:scoreham/score/rings.dart';
import 'package:scoreham/score/rules.dart';

void main() {
  group('the three voices', () {
    test('a walk tallies round and knows the ground', () {
      expect(Rules.walkFrom([1, 1, -1], 0), [1, 2, 1]);
      expect(Rules.staysAhead([1, 1, -1], 0), isTrue);
      expect(Rules.staysAhead([1, 1, -1], 2), isFalse);
      expect(Rules.walkFrom([-1, 1, -1, 1, 1], 3), [1, 2, 1, 2, 1]);
    });

    test('good starts count exactly the lead', () {
      expect(Rules.goodStarts([-1, 1, -1, 1, 1]), [3]);
      expect(Rules.goodStarts([-1, 1, 1, 1, 1, -1]), [1, 2]);
      expect(Rules.goodStarts([1, -1, 1, -1, 1, -1]), isEmpty);
      expect(Rules.ahead([-1, 1, 1, 1, 1, -1]), 2);
    });

    test('the start past the ebb is always good', () {
      expect(Rules.pastTheEbb([-1, 1, -1, 1, 1]), 3);
      expect(Rules.pastTheEbb([-1, -1, -1, 1, -1, 1, 1, 1, 1]), 5);
    });

    test('the walk, the ledger, and the ebb agree to a dozen marks',
        () {
      expect(Rules.allThreeAgree(12), isTrue);
    });

    test('every shipped ring matches its label', () {
      for (final ring in Rings.all) {
        final goods = Rules.goodStarts(ring.marks);
        expect(goods.length, ring.goods, reason: ring.name);
        expect(
          Rules.ahead(ring.marks) > 0
              ? Rules.ahead(ring.marks)
              : 0,
          ring.goods,
          reason: ring.name,
        );
      }
    });
  });

  group('a trying', () {
    test('a tried start shows its walk and keeps a good one', () {
      var play = Play.of(Rings.at(0));
      play = play.tryStart(0);
      expect(play.tried, {0});
      expect(play.found, isEmpty);
      expect(play.shownGood, isFalse);
      play = play.tryStart(3);
      expect(play.found, [3]);
      expect(play.shownGood, isTrue);
      expect(play.isDone, isTrue);
      expect(play.back.found, isEmpty);
    });

    test('the two ahead wants both starts', () {
      var play = Play.of(Rings.at(2));
      play = play.tryStart(1);
      expect(play.found, [1]);
      expect(play.isDone, isFalse);
      play = play.tryStart(2);
      expect(play.found, [1, 2]);
      expect(play.isDone, isTrue);
    });

    test('the pointer offers the ebb first, then the rest', () {
      var play = Play.of(Rings.at(2));
      final ebb = Rules.pastTheEbb(Rings.at(2).marks);
      expect(play.next, ebb);
      play = play.tryStart(ebb);
      expect(play.next, isNot(ebb));
      expect(
        Rules.goodStarts(Rings.at(2).marks),
        contains(play.next),
      );
    });

    test('following the pointer settles every winnable ring', () {
      for (final ring in Rings.all.where((ring) => ring.winnable)) {
        var play = Play.of(ring);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 4) fail('${ring.name} never settled');
          play = play.tryStart(play.next!);
        }
        expect(play.found, hasLength(ring.goods),
            reason: ring.name);
      }
    });

    test('the tied vote gives up once every start is tried', () {
      var play = Play.of(Rings.at(4));
      expect(play.next, isNull);
      for (var start = 0; start < 6; start++) {
        expect(play.isOver, isFalse);
        play = play.tryStart(start);
        expect(play.found, isEmpty);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });
}
