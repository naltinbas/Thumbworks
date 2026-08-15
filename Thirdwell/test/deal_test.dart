import 'package:flutter_test/flutter_test.dart';
import 'package:thirdwell/deal/play.dart';
import 'package:thirdwell/deal/rules.dart';
import 'package:thirdwell/deal/walks.dart';

/// The law of the deal, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final walk in Walks.all) {
        expect(Rules(deals: walk.deals).waysBySweep(walk.chosen, walk.place), walk.ways, reason: walk.name);
      }
    });

    test('dealing out and gathering', () {
      final stack = [for (var i = 0; i < 27; i++) i];
      final columns = Rules.dealOut(stack);
      expect(columns[0].take(3), [0, 3, 6]);
      expect(columns[1].take(3), [1, 4, 7]);
      expect(columns[2].last, 26);
      final gathered = Rules.gather(columns, 16, 0);
      expect(gathered.take(9), columns[1]);
      expect(gathered.sublist(9, 18), columns[0]);
      final bottom = Rules.gather(columns, 16, 2);
      expect(bottom.sublist(18), columns[1]);
    });

    test('the dealing and the arithmetic agree for every counter and run', () {
      final rules = Rules();
      for (var chosen = 0; chosen < 27; chosen++) {
        final reached = <int>[];
        rules.runs((placings) {
          final dealt = Rules.placeBySimulation(chosen, placings);
          expect(dealt, Rules.placeByArithmetic(placings), reason: '$chosen $placings');
          reached.add(dealt);
        });
        expect(reached..sort(), [for (var p = 0; p < 27; p++) p]);
      }
      expect(Rules.placingsFor(19), [1, 0, 2]);
      expect(Rules.placeBySimulation(16, [1, 0, 2]), 19);
      expect(Rules.placeByArithmetic([1, 0]), isNull);
    });

    test('two deals reach nine places, the units the start in nines', () {
      final two = Rules(deals: 2);
      expect(two.reachable(16), [1, 4, 7, 10, 13, 16, 19, 22, 25]);
      for (var chosen = 0; chosen < 27; chosen++) {
        final reach = two.reachable(chosen);
        expect(reach, hasLength(9), reason: '$chosen');
        for (final place in reach) {
          expect(place % 3, chosen ~/ 9, reason: '$chosen $place');
        }
      }
      expect(two.landing(16, 0), isNull);
      expect(two.landing(16, 13), isNotNull);
    });
  });

  group('the play', () {
    test('opens undealt, the counter where it started', () {
      for (final walk in Walks.all) {
        final play = Play.of(walk);
        expect(play.placings, isEmpty, reason: walk.name);
        expect(play.place, walk.chosen);
        expect(play.isDone, isFalse);
      }
    });

    test('a gathering counts, and back undoes', () {
      var play = Play.of(Walks.at(0));
      expect(play.holding, 1);
      play = play.gather(0);
      expect(play.placings, [0]);
      expect(play.moves, 1);
      expect(play.stack.take(9).contains(16), isTrue);
      expect(play.back.placings, isEmpty);
      expect(play.gather(3), same(play));
    });

    test('no placing past the deals allowed', () {
      final play = Play.of(Walks.at(0)).gather(0).gather(0).gather(0);
      expect(play.dealsDone, isTrue);
      expect(play.isDone, isTrue);
      expect(play.gather(1), same(play));
    });

    test('the middle and the twentieth walk by hand', () {
      final middle = Play.of(Walks.at(1)).gather(1).gather(1).gather(1);
      expect(middle.place, 13);
      expect(middle.isDone, isTrue);
      final twentieth = Play.of(Walks.at(3)).gather(1).gather(0).gather(2);
      expect(twentieth.place, 19);
      expect(twentieth.isDone, isTrue);
      final wrong = Play.of(Walks.at(3)).gather(2).gather(0).gather(1);
      expect(wrong.dealsDone, isTrue);
      expect(wrong.isDone, isFalse);
      expect(wrong.place, 11);
    });

    test('the pointer walks the bottom, and strays return null', () {
      var play = Play.of(Walks.at(2));
      while (!play.isDone) {
        play = play.gather(play.next!);
      }
      expect(play.moves, 3);
      expect(Play.of(Walks.at(2)).gather(0).next, isNull);
    });

    test('the hopeless walk admits it once its two deals are made', () {
      var play = Play.of(Walks.at(4)).gather(0).gather(0);
      expect(play.moves, play.gaveUpAt);
      expect(play.place, 1);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      Rules(deals: 2).runs((placings) {
        var run = Play.of(Walks.at(4));
        for (final p in placings) {
          run = run.gather(p);
        }
        expect(run.gaveUp, isTrue, reason: '$placings');
        expect(run.place % 3, 1);
      });
    });

    test('a winnable walk dealt wrong is not given up', () {
      final play = Play.of(Walks.at(0)).gather(2).gather(2).gather(2);
      expect(play.dealsDone, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands walked', () {
      final mark = Play.standing(Walks.at(3), const [1, 0, 2]);
      expect(mark.isDone, isTrue);
      expect(mark.place, 19);
    });
  });
}
