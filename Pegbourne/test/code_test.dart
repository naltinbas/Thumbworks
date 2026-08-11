import 'package:flutter_test/flutter_test.dart';
import 'package:pegbourne/code/play.dart';
import 'package:pegbourne/code/riddles.dart';
import 'package:pegbourne/code/rules.dart';

void main() {
  group('the marks', () {
    test('blacks for right place, whites for right colour astray', () {
      final code = Rules.packed([1, 0, 2, 3]);
      expect(Rules.marks(code, Rules.packed([1, 0, 2, 3])), (4, 0));
      expect(Rules.marks(code, Rules.packed([0, 1, 2, 3])), (2, 2));
      expect(Rules.marks(code, Rules.packed([3, 2, 0, 1])), (0, 4));
      expect(Rules.marks(code, Rules.packed([2, 2, 2, 2])), (1, 0));
    });

    test('repeats are counted honestly', () {
      // Code BYBR: a guess of RBRB earns no black and three whites.
      final code = Rules.packed([2, 3, 2, 0]);
      expect(Rules.marks(code, Rules.packed([0, 2, 0, 2])), (0, 3));
    });
  });

  group('the sweep', () {
    test('every shipped count is what the sweep says', () {
      for (var number = 0; number < Riddles.count; number++) {
        final riddle = Riddles.at(number);
        expect(Rules.answers(riddle.rows), hasLength(riddle.ways),
            reason: riddle.name);
      }
    });

    test('the liar\'s rows break pairwise, as the counting says', () {
      final pair = Rules.irreconcilable(Riddles.at(4).rows);
      expect(pair, isNotNull);
      // Three reds and three greens cannot share four slots.
      expect(pair!.$1.$2, 3);
      expect(pair.$2.$2, 3);
    });

    test('the two minds really are two', () {
      final answers = Rules.answers(Riddles.at(3).rows);
      expect(answers, hasLength(2));
      for (final code in answers) {
        for (final row in Riddles.at(3).rows) {
          expect(Rules.agrees(code, row), isTrue);
        }
      }
    });
  });

  group('a riddle in play', () {
    test('starts empty', () {
      final play = Play.of(Riddles.at(0));
      expect(play.isComplete, isFalse);
      expect(play.candidate, isNull);
      expect(play.rowStands(0), isNull);
    });

    test('a tap cycles a slot round to empty again', () {
      var play = Play.of(Riddles.at(0));
      for (var turn = 0; turn < Rules.colours; turn++) {
        play = play.cycle(0);
        expect(play.slots[0], turn);
      }
      play = play.cycle(0);
      expect(play.slots[0], -1);
      expect(play.moves, 5);
    });

    test('take back returns the pegs as they stood', () {
      final start = Play.of(Riddles.at(0));
      final cycled = start.cycle(2);
      expect(cycled.back.slots[2], -1);
      expect(identical(start.back, start), isTrue);
    });

    test('a complete wrong candidate breaks its rows', () {
      var play = Play.of(Riddles.at(0));
      for (var slot = 0; slot < 4; slot++) {
        play = play.cycle(slot);
      }
      // RRRR against rows written for RRGB.
      expect(play.isComplete, isTrue);
      expect(play.broken, isNotEmpty);
      expect(play.isDone, isFalse);
    });

    test('following the mend answers every winnable riddle', () {
      for (var number = 0; number < Riddles.count; number++) {
        final riddle = Riddles.at(number);
        if (!riddle.winnable) continue;
        var play = Play.of(riddle);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 30) fail('${riddle.name} never answered');
          final (slot, colour) = play.next!;
          while (play.slots[slot] != colour) {
            play = play.cycle(slot);
          }
        }
        expect(play.broken, isEmpty, reason: riddle.name);
      }
    });

    test('the liar offers no mend and never settles', () {
      var play = Play.of(Riddles.at(4));
      expect(play.next, isNull);
      for (var slot = 0; slot < 4; slot++) {
        play = play.cycle(slot);
      }
      expect(play.isComplete, isTrue);
      expect(play.isDone, isFalse);
      expect(play.broken, isNotEmpty);
    });
  });
}
