import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:carterfen/round/moor.dart';
import 'package:carterfen/round/play.dart';
import 'package:carterfen/round/rounds_list.dart';
import 'package:carterfen/round/shortest.dart';

Moor _scatter(Random dice, int places) => Moor([
      for (var i = 0; i < places; i++)
        Stop('$i', dice.nextDouble(), dice.nextDouble()),
    ]);

void main() {
  group('a map', () {
    test('measures both ways round the same', () {
      final moor = Moor(const [
        Stop('a', 0, 0),
        Stop('b', 1, 0),
        Stop('c', 0, 1),
      ]);
      expect(moor.between(0, 1), moor.between(1, 0));
      expect(moor.between(0, 0), 0);
      expect(moor.between(0, 1), 100, reason: 'a hundred furlongs across');
    });

    test('and adds a round up the whole way round', () {
      final moor = Moor(const [
        Stop('a', 0, 0),
        Stop('b', 1, 0),
        Stop('c', 1, 1),
        Stop('d', 0, 1),
      ]);
      expect(moor.lengthOf([0, 1, 2, 3]), 400);
      expect(moor.lengthOf([0, 2, 1, 3]), 2 * 141 + 2 * 100);
    });
  });

  group('the shortest round', () {
    test('is the same as trying every order there is', () {
      // Two answers with nothing in common but the answer. One works out the
      // shortest way to reach every set of places; the other lists every
      // order and measures it. Nine places is 20160 orders, so this is the
      // last size where the slow way is worth asking.
      final dice = Random(20260805);
      for (var round = 0; round < 25; round++) {
        final moor = _scatter(dice, 4 + dice.nextInt(5));
        final quick = Rounder(moor).work();
        final slow = Rounder(moor).byTryingEverything();

        expect(quick.length, slow.length,
            reason: 'over ${moor.count} places');
        expect(moor.lengthOf(quick.order), quick.length,
            reason: 'the order it gave back is not that long');
      }
    });

    test('and the order it gives back calls at everything once', () {
      final dice = Random(11);
      for (var round = 0; round < 20; round++) {
        final moor = _scatter(dice, 5 + dice.nextInt(7));
        final found = Rounder(moor).work();

        expect(found.order, hasLength(moor.count));
        expect(found.order.toSet(), hasLength(moor.count));
        expect(found.order.first, 0, reason: 'a round starts at the yard');
      }
    });

    test('and it walks far fewer part-rounds than there are orders', () {
      // The whole reason it can be asked at all. Twelve places is nearly
      // forty million orders and eleven thousand part-rounds.
      final moor = _scatter(Random(3), 12);
      final found = Rounder(moor).work();
      expect(found.looked, lessThan(20000));
    });
  });

  group('every round', () {
    test('is as short as it says', () {
      for (var i = 0; i < Rounds.count; i++) {
        final one = Rounds.at(i);
        expect(Rounder(one.moor).work().length, one.shortest, reason: one.name);
      }
    });

    test('and driving to the nearest place every time is not the answer', () {
      // Except on the first one, which is there to show what the buttons do.
      for (var i = 1; i < Rounds.count; i++) {
        final one = Rounds.at(i);
        final moor = one.moor;
        final left = [for (var s = 1; s < moor.count; s++) s];
        final greedy = <int>[0];

        while (left.isNotEmpty) {
          var pick = 0;
          for (var j = 1; j < left.length; j++) {
            if (moor.between(greedy.last, left[j]) <
                moor.between(greedy.last, left[pick])) {
              pick = j;
            }
          }
          greedy.add(left.removeAt(pick));
        }
        expect(moor.lengthOf(greedy), greaterThan(one.shortest),
            reason: '${one.name} is solved by always going to the nearest');
      }
    });

    test('and they get bigger', () {
      var last = 0;
      for (var i = 0; i < Rounds.count; i++) {
        expect(Rounds.at(i).count, greaterThanOrEqualTo(last));
        last = Rounds.at(i).count;
      }
    });
  });

  group('driving one', () {
    Play start([int which = 2]) => Play.of(Rounds.at(which));

    test('begins at the yard with nothing driven', () {
      final play = start();
      expect(play.called, [0]);
      expect(play.at, 0);
      expect(play.gone, 0);
      expect(play.isDone, isFalse);
      expect(play.left, hasLength(play.count - 1));
    });

    test('drives to a place, and not to one it has called at', () {
      var play = start();
      expect(play.canGoTo(2), isTrue);
      play = play.goTo(2);

      expect(play.at, 2);
      expect(play.gone, play.moor.between(0, 2));
      expect(play.canGoTo(2), isFalse);
      expect(play.goTo(2).called, play.called);
      expect(play.canGoTo(0), isFalse, reason: 'the yard is where it began');
    });

    test('takes a call back', () {
      final play = start().goTo(3);
      expect(play.back.at, 0);
      expect(play.back.gone, 0);
      expect(start().back.called, [0], reason: 'and stops at the yard');
    });

    test('and is finished when everywhere has been called at', () {
      for (var which = 0; which < Rounds.count; which++) {
        final one = Rounds.at(which);
        var play = Play.of(one);
        for (final stop in Rounder(one.moor).work().order.skip(1)) {
          play = play.goTo(stop);
        }
        expect(play.isDone, isTrue, reason: one.name);
        expect(play.length, one.shortest, reason: one.name);
        expect(play.isShortest, isTrue, reason: one.name);
        expect(play.over, 0, reason: one.name);
      }
    });

    test('and a longer way round says how much longer', () {
      final one = Rounds.at(4);
      var play = Play.of(one);
      // Straight round the places in the order they are written down, which
      // is not the shortest on any round here.
      for (var stop = 1; stop < one.count; stop++) {
        play = play.goTo(stop);
      }
      expect(play.isDone, isTrue);
      expect(play.over, greaterThan(0));
      expect(play.isShortest, isFalse);
    });
  });

  group('a hint', () {
    test('is about the round being driven, not the one on offer at the start',
        () {
      final one = Rounds.at(4);
      final play = Play.of(one);

      // A first call that really does cost something. Two of them do not,
      // because the shortest round can be driven either way about.
      Play? gone;
      for (var stop = 1; stop < one.count; stop++) {
        final after = play.goTo(stop);
        if (after.gone + after.restOfIt.length > one.shortest) {
          gone = after;
          break;
        }
      }
      expect(gone, isNotNull, reason: 'every first call is on a shortest round');

      expect(gone!.next, isNotNull);
      expect(gone.canGoTo(gone.next!), isTrue);

      // And what is left is still the best that can be made of it.
      final rest = gone.restOfIt;
      expect(rest.order.first, gone.at);
      expect(rest.order.last, 0, reason: 'and it ends at the yard');
      expect(rest.order.toSet(), hasLength(gone.left.length + 2));
    });

    test('and following it from the start drives the shortest round', () {
      for (var which = 0; which < Rounds.count; which++) {
        final one = Rounds.at(which);
        var play = Play.of(one);
        while (!play.isDone) {
          play = play.goTo(play.next!);
        }
        expect(play.length, one.shortest, reason: one.name);
      }
    });

    test('and there is nothing to say once the cart is home', () {
      final one = Rounds.at(0);
      var play = Play.of(one);
      for (final stop in Rounder(one.moor).work().order.skip(1)) {
        play = play.goTo(stop);
      }
      expect(play.next, isNull);
      expect(play.restOfIt.length, play.moor.between(play.at, 0));
    });
  });
}
