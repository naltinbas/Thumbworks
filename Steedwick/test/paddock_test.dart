import 'package:flutter_test/flutter_test.dart';
import 'package:steedwick/paddock/errands.dart';
import 'package:steedwick/paddock/play.dart';
import 'package:steedwick/paddock/rules.dart';

/// The law of the paddock, held to.
void main() {
  group('the rules', () {
    test('every label\'s fewest and rides are what the ride finds', () {
      final walk = Rules.walk();
      for (final errand in Errands.all) {
        var fewest = 1 << 20;
        var rides = 0;
        for (final entry in walk.fewest.entries) {
          if (!errand.meets(walk.standings[entry.key]!)) continue;
          if (entry.value < fewest) {
            fewest = entry.value;
            rides = walk.rides[entry.key]!;
          } else if (entry.value == fewest) {
            rides += walk.rides[entry.key]!;
          }
        }
        expect(rides, errand.rides, reason: errand.name);
        if (rides > 0) expect(fewest, errand.fewest, reason: errand.name);
      }
    });

    test('the knight\'s moves run round in one ring', () {
      expect(Rules.ringHolds(), isTrue);
      expect(Rules.movesFrom(4), isEmpty);
      expect(Rules.movesFrom(0)..sort(), [5, 7]);
      expect(Rules.movesFrom(1)..sort(), [6, 8]);
    });

    test('the ride reaches the 280 standings with home\'s order', () {
      final walk = Rules.walk();
      expect(walk.fewest, hasLength(280));
      final homeOrder = Rules.orderRound(Rules.home);
      expect(homeOrder, [0, 2, 3, 1]);
      var all = 0;
      Rules.allStandings((s) {
        all++;
        expect(walk.fewest.containsKey(Rules.key(s)), '${Rules.orderRound(s)}' == '$homeOrder', reason: '$s');
      });
      expect(all, 1680);
      expect(walk.fewest.values.reduce((a, b) => a > b ? a : b), 16);
      expect(walk.fewest[Rules.key([8, 6, 2, 0])], 16);
      expect(walk.fewest.containsKey(Rules.key([6, 8, 2, 0])), isFalse);
      expect(walk.fewest.containsKey(Rules.key([2, 0, 6, 8])), isFalse);
    });

    test('every move keeps the order round the ring', () {
      final walk = Rules.walk();
      final homeOrder = Rules.orderRound(Rules.home);
      for (final s in walk.standings.values) {
        for (final n in Rules.nextStandings(s)) {
          expect(Rules.orderRound(n), homeOrder);
        }
      }
    });
  });

  group('the play', () {
    test('opens at home, nothing picked', () {
      for (final errand in Errands.all) {
        final play = Play.of(errand);
        expect(play.standing, Rules.home, reason: errand.name);
        expect(play.picked, isNull);
        expect(play.isDone, isFalse);
      }
    });

    test('a pick, an unpick, and a move', () {
      var play = Play.of(Errands.at(0));
      play = play.tap(0);
      expect(play.picked, 0);
      expect(play.openTo..sort(), [5, 7]);
      play = play.tap(0);
      expect(play.picked, isNull);
      play = play.tap(0).tap(5);
      expect(play.standing, [5, 2, 6, 8]);
      expect(play.moves, 1);
      expect(play.back.standing, Rules.home);
    });

    test('a bad stall is refused', () {
      final play = Play.of(Errands.at(0)).tap(0);
      expect(play.tap(4), same(play));
      expect(play.tap(1), same(play));
      expect(play.tap(6).picked, 2);
      expect(play.tap(9), same(play));
    });

    test('the errand rides in three by hand', () {
      // Dark three steps aside, pale one rides round: 6 -> 1, 0 -> 5, 5 -> 6.
      final play = Play.of(Errands.at(0)).tap(6).tap(1).tap(0).tap(5).tap(5).tap(6);
      expect(play.standing[0], 6);
      expect(play.isDone, isTrue);
      expect(play.moves, 3);
    });

    test('the pointer rides the quarter turn and the pales down', () {
      for (final number in [1, 2]) {
        var play = Play.of(Errands.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final (steed, to) = play.next!;
          play = play.tap(play.standing[steed]).tap(to);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Errands.at(number).fewest, reason: '$number');
      }
    });

    test('the pointer rides the colour swap in sixteen', () {
      var play = Play.of(Errands.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        final (steed, to) = play.next!;
        play = play.tap(play.standing[steed]).tap(to);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 16);
      expect(play.standing, [8, 6, 2, 0]);
    });

    test('the hopeless errand admits it at twelve moves', () {
      var play = Play.of(Errands.at(4));
      for (var i = 0; i < 6; i++) {
        play = play.tap(0).tap(5).tap(5).tap(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      expect(play.tap(0), same(play));
    });

    test('a winnable errand never gives up', () {
      var play = Play.of(Errands.at(3));
      for (var i = 0; i < 7; i++) {
        play = play.tap(0).tap(5).tap(5).tap(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands swapped', () {
      final mark = Play.standing(Errands.at(3), const [8, 6, 2, 0]);
      expect(mark.isDone, isTrue);
      expect(mark.orderRound, [0, 2, 3, 1]);
    });
  });
}
