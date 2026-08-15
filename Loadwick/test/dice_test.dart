import 'package:flutter_test/flutter_test.dart';
import 'package:loadwick/dice/levels.dart';
import 'package:loadwick/dice/play.dart';
import 'package:loadwick/dice/rules.dart';

/// The law of the dice, held to.
void main() {
  group('the rules', () {
    test('the rolls counted, thirty-six a pair', () {
      expect(Rules.wins(Rules.dice[0], Rules.dice[1]), 24);
      expect(Rules.wins(Rules.dice[1], Rules.dice[2]), 24);
      expect(Rules.wins(Rules.dice[2], Rules.dice[3]), 24);
      expect(Rules.wins(Rules.dice[3], Rules.dice[0]), 24);
      expect(Rules.wins(Rules.dice[2], Rules.dice[0]), 20);
      expect(Rules.wins(Rules.dice[1], Rules.dice[3]), 18);
      expect(Rules.ties(Rules.dice[1], Rules.dice[1]), 36);
      for (var x = 0; x < 4; x++) {
        for (var y = 0; y < 4; y++) {
          if (x != y) {
            expect(Rules.wins(Rules.dice[x], Rules.dice[y]) + Rules.ties(Rules.dice[x], Rules.dice[y]) + Rules.wins(Rules.dice[y], Rules.dice[x]), 36);
          }
        }
      }
    });

    test('the ring, and no champion', () {
      expect(Rules.beaters(0), [2, 3]);
      expect(Rules.beaters(1), [0]);
      expect(Rules.beaters(2), [1]);
      expect(Rules.beaters(3), [2]);
      expect(Rules.champions, isEmpty);
      expect(Rules.beats(Rules.dice[1], Rules.dice[3]), isFalse);
    });

    test('every die of faces up to six swept', () {
      final (all, beatingAll, beatingNone, each) = Rules.sweep();
      expect(all, 924);
      expect(beatingAll, 96);
      expect(beatingNone, 451);
      expect(each, [353, 262, 252, 211]);
    });

    test('every label\'s ways is what the count finds', () {
      for (final level in Levels.all) {
        expect(level.choices.where(level.lands).length, level.ways, reason: level.name);
        expect(level.choices.length, level.picks, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with nothing picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.picked, isNull, reason: level.name);
        expect(play.isDone, isFalse);
        expect(play.winsNow, 0);
      }
    });

    test('a pick is made and counted; the house cannot be picked; back undoes', () {
      var play = Play.of(Levels.at(0));
      expect(play.pick(0), same(play));
      play = play.pick(1);
      expect(play.picked, 1);
      expect(play.winsNow, 12);
      expect(play.isDone, isFalse);
      expect(play.moves, 1);
      play = play.pick(3);
      expect(play.isDone, isTrue);
      expect(play.winsNow, 24);
      expect(play.tried, [1, 3]);
      expect(play.back.picked, 1);
      expect(play.pick(2), same(play));
    });

    test('the stalls by hand', () {
      expect(Play.of(Levels.at(0)).pick(2).isDone, isTrue);
      expect(Play.of(Levels.at(1)).pick(0).isDone, isTrue);
      expect(Play.of(Levels.at(2)).pick(1).isDone, isTrue);
      expect(Play.of(Levels.at(3)).pick(2).isDone, isTrue);
      expect(Play.of(Levels.at(3)).pick(1).winsNow, 18);
      expect(Play.of(Levels.at(3)).pick(1).isDone, isFalse);
    });

    test('the pointer picks every winnable stall', () {
      for (final number in [0, 1, 2, 3]) {
        final play = Play.of(Levels.at(number));
        expect(play.pick(play.next!).isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the champion\'s stall admits it after every die', () {
      var play = Play.of(Levels.at(4));
      for (final x in [0, 1, 2, 3]) {
        play = play.pick(x);
        expect(play.isDone, isFalse);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.against, isNotNull);
      expect(play.pick(0), same(play));
    });

    test('the mark stands beaten', () {
      final mark = Play.standing(Levels.at(0), 3);
      expect(mark.isDone, isTrue);
      expect(mark.winsNow, 24);
    });
  });
}
