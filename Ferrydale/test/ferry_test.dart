import 'package:ferrydale/ferry/ferries.dart';
import 'package:ferrydale/ferry/play.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the walk', () {
    test('names the famous fewest', () {
      expect(Ferries.at(0).rules().fewest, 7);
      expect(Ferries.at(1).rules().fewest, 11);
      expect(Ferries.at(2).rules().fewest, 9);
      expect(Ferries.at(3).rules().fewest, 11);
    });

    test('the four and four never land', () {
      final rules = Ferries.at(4).rules();
      expect(rules.fewest, isNull);
      expect(rules.reachableFromStart, 98);
      expect(rules.fewestFrom(rules.goal), 0);
    });

    test('every crossing lands safe by construction', () {
      final rules = Ferries.at(1).rules();
      var edge = [rules.start];
      final seen = <int>{rules.start};
      while (edge.isNotEmpty) {
        final next = <int>[];
        for (final state in edge) {
          for (final there in rules.crossings(state)) {
            expect(rules.stateSafe(there), isTrue);
            if (seen.add(there)) next.add(there);
          }
        }
        edge = next;
      }
      expect(seen.length, 64);
    });
  });

  group('every ferry that ships', () {
    for (var number = 0; number < Ferries.count; number++) {
      final ferry = Ferries.at(number);

      test('${ferry.name} is what it says it is', () {
        final rules = ferry.rules();
        expect(rules.fewest, ferry.fewest);
        expect(rules.reachableFromStart, ferry.reach);
      });
    }
  });

  group('a ferry in play', () {
    test('starts everyone on the near bank', () {
      final play = Play.of(Ferries.at(0));
      expect(play.isDone, isFalse);
      expect(play.boatFar, isFalse);
      expect(play.fewestFromHere, 7);
    });

    test('boarding fills the boat to its capacity', () {
      var play = Play.of(Ferries.at(0)).board(0).board(2);
      expect(play.aboard, [0, 2]);
      expect(play.mayBoard(1), isFalse);
      play = play.disembark(2);
      expect(play.aboard, [0]);
    });

    test('an empty or rowerless boat refuses in words', () {
      final play = Play.of(Ferries.at(0));
      expect(play.refusal, 'Nobody is aboard.');
      expect(play.board(2).refusal, 'Nobody aboard can row.');
    });

    test('a dangerous landing refuses by name', () {
      // The keeper rowing off with the cabbage leaves wolf and goat.
      final play = Play.of(Ferries.at(0)).board(0).board(3);
      expect(play.refusal, 'The wolf would be left with the goat.');
      // Rowing off alone leaves goat with both: wolf and goat named
      // first.
      expect(Play.of(Ferries.at(0)).board(0).refusal,
          'The wolf would be left with the goat.');
    });

    test('the cannibal landing names the bank', () {
      // Two missionaries rowing off leave one against three.
      final play = Play.of(Ferries.at(1)).board(0).board(1);
      expect(play.refusal, contains('outnumber'));
    });

    test('a good crossing rows and counts', () {
      final play = Play.of(Ferries.at(0)).board(0).board(2).row();
      expect(play.crossings, 1);
      expect(play.boatFar, isTrue);
      expect(play.onFar(2), isTrue);
      expect(play.aboard, isEmpty);
    });

    test('take back returns the river as it stood', () {
      final start = Play.of(Ferries.at(0));
      final rowed = start.board(0).board(2).row();
      expect(rowed.back.aboard, [0, 2]);
      expect(rowed.back.back.aboard, [0]);
    });

    test('following the next load rows every winnable ferry at its '
        'fewest', () {
      for (var number = 0; number < Ferries.count; number++) {
        final ferry = Ferries.at(number);
        if (!ferry.winnable) continue;
        var play = Play.of(ferry);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 15) fail('${ferry.name} never landed');
          final load = play.nextLoad!;
          for (final who in load) {
            play = play.board(who);
          }
          expect(play.refusal, isNull, reason: ferry.name);
          play = play.row();
        }
        expect(play.crossings, ferry.fewest, reason: ferry.name);
      }
    });

    test('the four and four offer no load however they stand', () {
      final play = Play.of(Ferries.at(4));
      expect(play.fewestFromHere, isNull);
      expect(play.nextLoad, isNull);
    });
  });
}
