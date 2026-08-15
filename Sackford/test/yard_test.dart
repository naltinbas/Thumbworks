import 'package:flutter_test/flutter_test.dart';
import 'package:sackford/yard/levels.dart';
import 'package:sackford/yard/play.dart';
import 'package:sackford/yard/rules.dart';

/// The search, the floor, the carrier's rule and the play, checked at
/// the domain: nothing here touches a widget.
void main() {
  group('the search', () {
    test('loadings by weights and by sacks told apart', () {
      expect(Rules.loadings([6, 4, 3, 3, 2, 2], 2).$1, 2);
      expect(Rules.loadings([6, 5, 5, 4, 4, 4, 2], 3).$1, 1);
      expect(Rules.loadings([6, 5, 5, 4, 4, 4, 2], 3, labelled: true).$1, 3);
      expect(Rules.loadings([7, 6, 5, 4, 3, 2, 1, 1, 1], 3).$1, 5);
      expect(Rules.loadings([7, 6, 5, 4, 3, 2, 1, 1, 1], 3, labelled: true).$1, 14);
      expect(Rules.loadings([7, 5, 4, 4, 3, 3, 2, 2], 3).$1, 1);
      expect(Rules.loadings([8, 7, 6, 5, 3, 2], 3).$1, 0);
      expect(Rules.loadings([8, 7, 6, 5, 3, 2], 4).$1, 10);
      expect(Rules.loadings([6, 4, 3, 3, 2, 2], 2).$2, [0, 0, 1, 1, 1, 1]);
    });

    test('patterns and soundness', () {
      expect(Rules.pattern([6, 4, 3, 3, 2, 2], [0, 0, 1, 1, 1, 1]), '3,3,2,2|6,4');
      expect(Rules.sound([6, 4, 3, 3, 2, 2], [0, 0, 1, 1, 1, 1], 2), isTrue);
      expect(Rules.sound([6, 4, 3, 3, 2, 2], [0, 0, 0, 1, 1, 1], 2), isFalse);
      expect(Rules.sound([6, 4, 3, 3, 2, 2], [0, 0, 1, 1, 1, null], 2), isFalse);
    });

    test('the fewest, the floor and the carrier', () {
      expect(Rules.fewest([7, 5, 4, 4, 3, 3, 2, 2]), 3);
      expect(Rules.floor([7, 5, 4, 4, 3, 3, 2, 2]), 3);
      expect(Rules.firstFitDecreasing([7, 5, 4, 4, 3, 3, 2, 2]), [[7, 3], [5, 4], [4, 3, 2], [2]]);
      expect(Rules.firstFitDecreasing([6, 5, 5, 4, 4, 4, 2]), [[6, 4], [5, 5], [4, 4, 2]]);
      expect(Rules.floor([8, 7, 6, 5, 3, 2]), 4);
      expect(Rules.fewest([8, 7, 6, 5, 3, 2]), 4);
    });

    test('over the loads of six sacks of one to five: floor and bound hold', () {
      var loads = 0;
      void sweep(List<int> so, int from) {
        if (so.length == 6) {
          loads++;
          final few = Rules.fewest(so);
          expect(few, greaterThanOrEqualTo(Rules.floor(so)), reason: '$so');
          expect(9 * Rules.firstFitDecreasing(so).length, lessThanOrEqualTo(11 * few + 6), reason: '$so');
          return;
        }
        for (var v = from; v <= 5; v++) {
          sweep([...so, v], v);
        }
      }

      sweep([], 1);
      expect(loads, 210);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Thirty-One']);
      expect(Levels.at(4).weight, 31);
      for (final level in Levels.all) {
        expect(Rules.loadings(level.sacks, level.carts).$1, level.ways, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'load the sacks of 6, 4, 3, 3, 2 and 2 stone into two carts of ten');
      expect(Levels.at(4).task, 'load the sacks of 8, 7, 6, 5, 3 and 2 stone into three carts of ten');
    });

    test('an ask is met by a sound loading', () {
      expect(Levels.at(0).meets([0, 0, 1, 1, 1, 1]), isTrue);
      expect(Levels.at(0).meets([0, 1, 1, 1, 1, 1]), isFalse);
      expect(Levels.at(1).meets([0, 1, 1, 0, 2, 2, 2]), isTrue);
    });
  });

  group('the play', () {
    test('opens with every sack on the ground', () {
      final play = Play.of(Levels.at(0));
      expect(play.loaded, 0);
      expect(play.loads, [0, 0]);
      expect(play.isDone, isFalse);
    });

    test('a tap moves a sack to the next cart and off the last', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.cartOf[0], 0);
      expect(play.loads, [6, 0]);
      play = play.tap(0);
      expect(play.cartOf[0], 1);
      play = play.tap(0);
      expect(play.cartOf[0], isNull);
      expect(play.moves, 3);
    });

    test('a cart past ten shows over', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(1).tap(2);
      expect(play.loads, [13, 0]);
      expect(play.over, [true, false]);
      expect(play.isDone, isFalse);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(2);
      expect(play.back.cartOf[2], isNull);
    });

    test('the two carts land by hand', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0).tap(1).tap(2).tap(2).tap(3).tap(3).tap(4).tap(4).tap(5).tap(5);
      expect(play.loads, [10, 10]);
      expect(play.isDone, isTrue);
      expect(play.moves, 10);
    });

    test('the thirty-one give up after forty taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        expect(play.isOver, isFalse);
        play = play.tap(k % 6);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer names the sack and the taps', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (0, 1));
      play = play.tap(0);
      expect(play.next, (1, 1));
      play = play.tap(1);
      expect(play.next, (2, 2));
    });

    test('following the pointer loads every winnable yard', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final (i, taps) = play.next!;
          for (var k = 0; k < taps; k++) {
            play = play.tap(i);
          }
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
