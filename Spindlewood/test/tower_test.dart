import 'package:flutter_test/flutter_test.dart';
import 'package:spindlewood/tower/play.dart';
import 'package:spindlewood/tower/rules.dart';
import 'package:spindlewood/tower/spindles.dart';

void main() {
  group('the board', () {
    test('knows where every round sits, and each spindle\'s top', () {
      final rules = Rules(3, 3);
      expect(rules.spindleOf(rules.start, 0), 0);
      expect(rules.topOf(rules.start, 0), 0);
      expect(rules.topOf(rules.start, 1), isNull);
      expect(rules.spindleOf(rules.home, 2), 2);
    });

    test('a round moves only bare and onto larger', () {
      final rules = Rules(3, 3);
      expect(rules.mayMove(rules.start, 0, 1), isTrue);
      expect(rules.mayMove(rules.start, 1, 1), isFalse);
      final lifted = rules.moved(rules.start, 0, 2);
      expect(rules.mayMove(lifted, 1, 1), isTrue);
      expect(rules.mayMove(lifted, 1, 2), isFalse);
      expect(rules.moved(lifted, 1, 2), lifted);
    });
  });

  group('the three ways of knowing', () {
    test('the walk and the doubling rule agree on three spindles', () {
      // The anchor. The walk knows nothing of doubling; the rule
      // knows nothing of boards.
      for (final rounds in [3, 4, 5]) {
        final rules = Rules(3, rounds);
        expect(rules.fewest(rules.start), Rules.doubling(rounds),
            reason: '$rounds rounds');
      }
    });

    test('the walk and the leapfrog reckoning agree on four', () {
      for (final rounds in [5, 6, 8]) {
        final rules = Rules(4, rounds);
        expect(rules.fewest(rules.start), Rules.leapfrog(rounds),
            reason: '$rounds rounds');
      }
    });

    test('the iteration lands home in exactly the fewest', () {
      // The third voice: a rule of thumb from the last century,
      // executed move by legal move.
      for (final rounds in [3, 4, 5]) {
        final rules = Rules(3, rounds);
        final moves = rules.iterated();
        var board = rules.start;
        for (final (round, to) in moves) {
          final before = board;
          board = rules.moved(board, round, to);
          expect(board, isNot(before), reason: 'an illegal iteration');
        }
        expect(board, rules.home, reason: '$rounds rounds');
        expect(moves.length, Rules.doubling(rounds),
            reason: '$rounds rounds');
      }
    });
  });

  group('every job that ships', () {
    for (var number = 0; number < Spindles.count; number++) {
      final spindle = Spindles.at(number);

      test('${spindle.name} is what it says it is', () {
        final rules = Rules(spindle.spindles, spindle.rounds);
        expect(rules.fewest(rules.start), spindle.fewest);
        final wager = spindle.wager;
        if (wager != null) {
          // The whole point of the wager: the floor stands above it.
          expect(wager, lessThan(spindle.fewest));
        }
      });
    }
  });

  group('a tower in play', () {
    test('starts stacked on the first spindle', () {
      final play = Play.of(Spindles.at(0));
      expect(play.board, play.rules.start);
      expect(play.made, 0);
      expect(play.isHome, isFalse);
      expect(play.fewestFromHere, 7);
    });

    test('a move lifts the top and counts; a bad landing is refused', () {
      final play = Play.of(Spindles.at(0)).move(0, 1);
      expect(play.made, 1);
      expect(play.topOf(1), 0);
      expect(identical(play.move(0, 1), play), isTrue);
      expect(play.mayMove(0, 1), isFalse);
    });

    test('a wandering move shows in the live number at once', () {
      final play = Play.of(Spindles.at(0));
      final went = play.next!;
      final toward = play.move(went.$1, went.$2);
      expect(toward.fewestFromHere, 6);
      // Straight back where it came from: two moves gone for nothing.
      final undone = toward.move(went.$2, went.$1);
      expect(undone.fewestFromHere, 7);
    });

    test('take back returns the tower as it stood', () {
      final start = Play.of(Spindles.at(0));
      final moved = start.move(0, 2);
      expect(moved.back.board, start.board);
      expect(identical(start.back, start), isTrue);
    });

    test('following next brings every tower home at its fewest', () {
      for (var number = 0; number < Spindles.count; number++) {
        final spindle = Spindles.at(number);
        var play = Play.of(spindle);
        var guard = 0;
        while (!play.isHome) {
          if (guard++ > 35) fail('${spindle.name} never came home');
          expect(play.fewestFromHere, spindle.fewest - play.made,
              reason: spindle.name);
          final move = play.next!;
          play = play.move(move.$1, move.$2);
        }
        expect(play.made, spindle.fewest, reason: spindle.name);
      }
    });

    test('the wager cannot be met however the tower is played', () {
      // Its floor is its fewest: even the perfect play pays fifteen.
      final play = Play.of(Spindles.at(5));
      expect(play.fewestFromHere, 15);
      expect(play.spindle.wager, 14);
    });
  });
}
