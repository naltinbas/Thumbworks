import 'package:almsford/alms/levels.dart';
import 'package:almsford/alms/play.dart';
import 'package:almsford/alms/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The almshouse itself: the shares and the running totals.
void main() {
  group('the bins', () {
    test('hold ten measures in 1,001 arrangements and 30 shapes', () {
      expect(Rules.arrangements().length, 1001);
      expect(Rules.howManyArrangements, 1001);
      expect(Rules.shapes().length, 30);
      for (final at in Rules.arrangements()) {
        expect(Rules.valid(at), isTrue);
      }
    });

    test('a share wants the giver two ahead', () {
      expect(Rules.canShare([3, 1, 0, 0, 6], 0, 1), isTrue);
      expect(Rules.canShare([3, 2, 0, 0, 5], 0, 1), isFalse);
      expect(Rules.canShare([3, 1, 0, 0, 6], 1, 0), isFalse);
      expect(Rules.canShare([3, 1, 0, 0, 6], 0, 0), isFalse);
      expect(Rules.share([3, 1, 0, 0, 6], 0, 1), [2, 2, 0, 0, 6]);
    });

    test('the shape and its running totals', () {
      expect(Rules.shape([0, 0, 0, 1, 9]), [9, 1, 0, 0, 0]);
      expect(Rules.running([9, 1, 0, 0, 0]), [9, 10, 10, 10, 10]);
      expect(Rules.running([2, 2, 2, 2, 2]), [2, 4, 6, 8, 10]);
    });
  });

  group('the two voices', () {
    test('a share never raises a running total', () {
      for (final at in Rules.arrangements()) {
        final before = Rules.running(Rules.shape(at));
        for (var give = 0; give < Rules.bins; give++) {
          for (var take = 0; take < Rules.bins; take++) {
            if (!Rules.canShare(at, give, take)) continue;
            final after = Rules.running(Rules.shape(Rules.share(at, give, take)));
            for (var i = 0; i < Rules.bins; i++) {
              expect(after[i], lessThanOrEqualTo(before[i]),
                  reason: '$at, $give to $take');
            }
          }
        }
      }
    });

    test('the shapes a walk reaches are the ones the totals allow', () {
      for (final from in Rules.arrangements()) {
        final walked = <String>{Rules.shape(from).join(',')};
        final seen = <String>{from.join(',')};
        final queue = <List<int>>[from];
        for (var head = 0; head < queue.length; head++) {
          final at = queue[head];
          for (var give = 0; give < Rules.bins; give++) {
            for (var take = 0; take < Rules.bins; take++) {
              if (!Rules.canShare(at, give, take)) continue;
              final next = Rules.share(at, give, take);
              if (!seen.add(next.join(','))) continue;
              walked.add(Rules.shape(next).join(','));
              queue.add(next);
            }
          }
        }
        final allowed = <String>{
          for (final shape in Rules.shapes())
            if (Rules.covers(from, shape)) shape.join(','),
        };
        expect(walked, allowed, reason: Rules.tellBins(from));
      }
    });

    test('the level field is under every shape and cannot be left', () {
      const level = [2, 2, 2, 2, 2];
      for (final at in Rules.arrangements()) {
        expect(Rules.covers(at, level), isTrue, reason: '$at');
      }
      expect(Play.standing(Levels.at(3), level).settled, isTrue);
      var settled = 0;
      for (final at in Rules.arrangements()) {
        if (Play.standing(Levels.at(0), at).settled) settled++;
      }
      expect(settled, 1);
    });

    test('the one heap is over every shape, so only itself reaches it', () {
      const heap = [10, 0, 0, 0, 0];
      for (final at in Rules.arrangements()) {
        expect(Rules.covers(heap, at), isTrue);
        expect(Rules.covers(at, heap), Rules.shape(at).first == 10,
            reason: '$at');
      }
    });
  });

  group('the asks', () {
    test('are stood in by as many arrangements as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final at in Rules.arrangements()) {
          if (level.meets(at)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('the fewest shares each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [2, 4, 5, 7, null]);
      for (final level in Levels.all) {
        expect(Rules.covers(Rules.opening, level.shape), level.winnable,
            reason: level.name);
      }
    });

    test('none of them is stood in before a share is made', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens with nine in one bin and one in another', () {
      final play = Play.of(Levels.at(0));
      expect(play.bins, [0, 0, 0, 1, 9]);
      expect(play.shape, [9, 1, 0, 0, 0]);
      expect(play.running, [9, 10, 10, 10, 10]);
      expect(play.holding, isNull);
      expect(play.moves, 0);
      expect(play.settled, isFalse);
    });

    test('a lift and a drop make one share', () {
      var play = Play.of(Levels.at(0)).tap(4);
      expect(play.holding, 4);
      expect(play.moves, 0);
      play = play.tap(0);
      expect(play.bins, [1, 0, 0, 1, 8]);
      expect(play.holding, isNull);
      expect(play.moves, 1);
    });

    test('a lift can be put back where it came from', () {
      final play = Play.of(Levels.at(0)).tap(4).tap(4);
      expect(play.holding, isNull);
      expect(play.bins, [0, 0, 0, 1, 9]);
      expect(play.moves, 0);
    });

    test('a bin with nothing to give cannot be lifted from', () {
      final play = Play.of(Levels.at(0));
      expect(play.canTake(3), isFalse);
      expect(identical(play.tap(3), play), isTrue);
      expect(play.canTake(4), isTrue);
    });

    test('a drop into a bin less than two behind is refused', () {
      final play = Play.standing(Levels.at(0), const [3, 2, 2, 2, 1]).tap(0);
      expect(play.holding, 0);
      expect(identical(play.tap(1), play), isTrue);
      expect(play.tap(4).bins, [2, 2, 2, 2, 2]);
    });

    test('back undoes the last share', () {
      final play = Play.of(Levels.at(0)).tap(4).tap(0).tap(4).tap(1);
      expect(play.bins, [1, 1, 0, 1, 7]);
      expect(play.moves, 2);
      expect(play.back.bins, [1, 0, 0, 1, 8]);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(0));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lands every ask, in the fewest shares', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        expect(play.toGo!.$1, level.fewest, reason: level.name);
        while (!play.isDone) {
          final was = play.toGo!.$1;
          final aim = play.next!;
          play = play.tap(aim.$1).tap(aim.$2);
          expect(play.isDone || play.toGo!.$1 == was - 1, isTrue,
              reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says what to do with the hand it has', () {
      expect(Play.pointed((4, 0), null), 'Take a measure out of bin 5.');
      expect(Play.pointed((4, 0), 4), 'Put the measure in bin 1.');
      expect(Play.pointed((4, 0), 3), 'Put the measure back in bin 4.');
    });

    test('the hopeless ask admits it after four arrangements', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final (give, take) in [(4, 0), (4, 1), (4, 2), (4, 3)]) {
        play = play.tap(give).tap(take);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(identical(play.tap(4), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final (give, take) in [(4, 0), (4, 1), (4, 2)]) {
        play = play.tap(give).tap(take);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names majorization and the running totals', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('This is majorization'));
      expect(words, contains('the fullest bin never rises'));
      expect(words, contains('The One Heap'));
    });
  });
}
