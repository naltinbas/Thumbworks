import 'package:flutter_test/flutter_test.dart';
import 'package:cutlassby/deck/level.dart';
import 'package:cutlassby/deck/levels.dart';
import 'package:cutlassby/deck/play.dart';
import 'package:cutlassby/deck/rules.dart';

/// The law of the deck, held to.
void main() {
  const rules = Rules(Level.gold);

  group('the rules', () {
    test('every division of the gold', () {
      expect(rules.divisions(1), [[10]]);
      expect(rules.divisions(2), hasLength(11));
      expect(rules.divisions(2).first, [10, 0]);
      expect(rules.divisions(5), hasLength(1001));
      for (final d in rules.divisions(3)) {
        expect(d.reduce((a, b) => a + b), 10);
      }
    });

    test('what each expects, and how each votes', () {
      expect(rules.expects(2), [0, 10]);
      expect(rules.expects(3), [0, 10, 0]);
      expect(rules.expects(4), [0, 9, 0, 1]);
      expect(rules.expects(5), [0, 9, 0, 1, 0]);
      expect(rules.votes([9, 0, 1]), [true, false, true]);
      expect(rules.votes([10, 0, 0]), [true, false, false]);
      expect(rules.ayes([8, 0, 1, 0, 1]), 3);
      expect(rules.needed(5), 3);
      expect(rules.needed(4), 2);
      expect(rules.passes([9, 0, 1, 0]), isTrue);
      expect(rules.passes([9, 0, 0, 1]), isFalse);
      expect(rules.passes([10, 0]), isTrue);
    });

    test('the best plan for every crew, one alone', () {
      expect(rules.best(1), [10]);
      expect(rules.best(2), [10, 0]);
      expect(rules.best(3), [9, 0, 1]);
      expect(rules.best(4), [9, 0, 1, 0]);
      expect(rules.best(5), [8, 0, 1, 0, 1]);
      expect(rules.best(6), [8, 0, 1, 0, 1, 0]);
      expect(rules.best(7), [7, 0, 1, 0, 1, 0, 1]);
      for (var n = 1; n <= 7; n++) {
        expect(rules.mostKept(n), 10 - (n - 1) ~/ 2, reason: '$n');
        expect(rules.sweep(n, rules.mostKept(n) + 1).$1, 0, reason: '$n');
      }
    });

    test('the sweeps of the crews', () {
      expect(rules.sweep(2, 10), (1, 1));
      expect(rules.sweep(3, 9), (1, 3));
      expect(rules.sweep(4, 9), (1, 4));
      expect(rules.sweep(5, 8), (1, 15));
      expect(rules.sweep(5, 9), (0, 5));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(rules.sweep(level.pirates, level.keep), (level.ways, level.plans), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with the captain holding all ten', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.shares.first, 10, reason: level.name);
        expect(play.given, 0);
        expect(play.voted, isFalse);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap gives a coin, the captain runs dry, and back undoes', () {
      var play = Play.of(Levels.at(3));
      play = play.give(2);
      expect(play.shares, [9, 0, 1, 0, 0]);
      expect(play.moves, 1);
      expect(play.give(0), same(play));
      expect(play.give(5), same(play));
      expect(play.back.shares, [10, 0, 0, 0, 0]);
      for (var k = 0; k < 9; k++) {
        play = play.give(1);
      }
      expect(play.kept, 0);
      expect(play.give(1), same(play));
    });

    test('the crews by hand', () {
      final two = Play.of(Levels.at(0)).vote;
      expect(two.passes, isTrue);
      expect(two.isDone, isTrue);
      final three = Play.of(Levels.at(1)).give(2).vote;
      expect(three.shares, [9, 0, 1]);
      expect(three.isDone, isTrue);
      final five = Play.of(Levels.at(3)).give(2).give(4).vote;
      expect(five.ayes, 3);
      expect(five.isDone, isTrue);
      expect(five.give(1), same(five));
    });

    test('a vote lost, or won too cheap, is a miss', () {
      final lost = Play.of(Levels.at(3)).vote;
      expect(lost.passes, isFalse);
      expect(lost.missed, isTrue);
      expect(lost.isDone, isFalse);
      expect(lost.isOver, isTrue);
      final poor = Play.of(Levels.at(1)).give(2).give(2).vote;
      expect(poor.passes, isTrue);
      expect(poor.kept, 8);
      expect(poor.missed, isTrue);
    });

    test('the pointer pays every winnable crew', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isOver && guard++ < 20) {
          final (what, i) = play.next!;
          play = what == 'give' ? play.give(i) : what == 'take' ? play.back : play.vote;
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says give, take, then vote', () {
      final play = Play.of(Levels.at(3));
      expect(play.next, ('give', 2));
      expect(play.give(2).next, ('give', 4));
      expect(play.give(2).give(4).next, ('vote', 0));
      expect(play.give(1).next, ('take', 1));
    });

    test('the hopeless crew admits it at the vote', () {
      final play = Play.of(Levels.at(4)).give(2).vote;
      expect(play.shares, [9, 0, 1, 0, 0]);
      expect(play.passes, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.give(2), same(play));
      final poor = Play.of(Levels.at(4)).give(2).give(4).vote;
      expect(poor.passes, isTrue);
      expect(poor.gaveUp, isTrue);
    });

    test('the mark stands paid and passed', () {
      final mark = Play.standing(Levels.at(3), Play.aimFor(Levels.at(3)));
      expect(mark.isDone, isTrue);
      expect(mark.ayes, 3);
    });
  });
}
