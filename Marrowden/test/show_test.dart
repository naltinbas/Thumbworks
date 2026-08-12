import 'package:flutter_test/flutter_test.dart';
import 'package:marrowden/show/play.dart';
import 'package:marrowden/show/rules.dart';
import 'package:marrowden/show/show.dart';
import 'package:marrowden/show/shows.dart';

void main() {
  group('the rule and the sweep', () {
    test('the rule waves, then takes the best yet, and must take '
        'the last', () {
      expect(Rules.takes(1, 1, true, 4), isFalse);
      expect(Rules.takes(1, 2, true, 4), isTrue);
      expect(Rules.takes(1, 2, false, 4), isFalse);
      expect(Rules.takes(1, 4, false, 4), isTrue);
    });

    test('every sitting of the bench, told once each', () {
      final sittings = Rules.allSittings(4);
      expect(sittings, hasLength(24));
      expect(
        sittings.map((sitting) => sitting.join()).toSet(),
        hasLength(24),
      );
    });

    test('the rule\'s counts over every sitting', () {
      expect(Rules.winsOfCutoff(4, 1), 11);
      expect(Rules.winsOfCutoff(5, 2), 52);
      expect(Rules.winsOfCutoff(6, 2), 308);
      expect(Rules.winsOfCutoff(7, 2), 2088);
    });

    test('the waved-by count that wins most', () {
      expect(Rules.bestSkip(4), 1);
      expect(Rules.bestSkip(5), 2);
      expect(Rules.bestSkip(6), 2);
      expect(Rules.bestSkip(7), 2);
    });

    test('no rule of the sweep beats the rule', () {
      expect(Rules.rulesOf(4), 64);
      expect(Rules.rulesOf(5), 1024);
      expect(Rules.ceiling(4), 11);
      expect(Rules.ceiling(5), 52);
    });

    test('the notes\' own numbers', () {
      expect(
        Rules.allSittings(4)
            .where((sitting) => sitting.first == 3)
            .length,
        6,
      );
      expect(Rules.winsOfCutoff(5, 1), 50);
      expect(Rules.winsOfCutoff(6, 3), 282);
      expect(Rules.winsOfCutoff(7, 3), 2052);
    });

    test('the fork: two sittings open alike and split every rule',
        () {
      const forkA = [3, 2, 1, 0];
      const forkB = [2, 3, 1, 0];
      // Both open on a best-yet; the best sits first in one and
      // second in the other, so taking loses B and waving loses A.
      expect(forkA.indexOf(3), 0);
      expect(forkB.indexOf(3), 1);
      final takeWinsA = forkA[0] == 3;
      final takeWinsB = forkB[0] == 3;
      expect(takeWinsA, isTrue);
      expect(takeWinsB, isFalse);
      // Waving loses whichever sitting had the best first.
      expect(forkA.sublist(1).contains(3), isFalse);
    });
  });

  group('the benches that ship', () {
    for (final show in Shows.all) {
      test(show.name, () {
        expect(Rules.factorial(show.marrows), show.of);
        expect(Rules.bestSkip(show.marrows), show.skip);
        expect(
            Rules.winsOfCutoff(show.marrows, show.skip), show.wins);
        final swept = show.swept;
        if (swept != null) {
          expect(Rules.rulesOf(show.marrows), swept);
          expect(Rules.ceiling(show.marrows), show.wins);
        }
      });
    }
  });

  group('a sitting', () {
    test('marrows come up, ranks against the seen only', () {
      var play = Play.of(Shows.at(0), const [
        [1, 3, 0, 2],
      ]);
      expect(play.shown, 1);
      expect(play.record, isTrue);
      expect(play.rank, 1);
      play = play.wave();
      expect(play.shown, 2);
      expect(play.record, isTrue);
      play = play.take();
      expect(play.judging, isFalse);
      expect(play.sittingWon, isTrue);
      expect(play.won, 1);
      expect(play.played, 1);
    });

    test('the last marrow cannot be waved', () {
      var play = Play.of(Shows.at(0), const [
        [0, 1, 2, 3],
      ]);
      for (var waves = 0; waves < 3; waves++) {
        expect(play.mayWave, isTrue);
        play = play.wave();
      }
      expect(play.mayWave, isFalse);
      expect(play.wave(), same(play));
      play = play.take();
      expect(play.sittingWon, isTrue);
    });

    test('following the rule through the play wins exactly the '
        'written count, on every bench', () {
      for (final show in Shows.all.where((show) => !show.sure)) {
        var wins = 0;
        for (final sitting in Rules.allSittings(show.marrows)) {
          var play = Play.of(show, [sitting]);
          while (play.judging) {
            play = play.ruleTakes ? play.take() : play.wave();
          }
          if (play.sittingWon) wins++;
        }
        expect(wins, show.wins, reason: show.name);
      }
    });

    test('five wins close a winnable bench', () {
      var play = Play.of(Shows.at(0), Rules.allSittings(4));
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 200) fail('the bench never closed');
        while (play.judging) {
          play = play.ruleTakes ? play.take() : play.wave();
        }
        if (play.isOver) break;
        play = play.nextDeal();
      }
      expect(play.benchWon, isTrue);
      expect(play.won, Show.asked);
      expect(play.played, lessThanOrEqualTo(24));
    });

    test('the sure pick falls at the first miss', () {
      // A sitting the rule loses: the best comes first and is waved.
      var play = Play.of(Shows.at(4), const [
        [3, 2, 1, 0],
      ]);
      while (play.judging) {
        play = play.ruleTakes ? play.take() : play.wave();
      }
      expect(play.sittingWon, isFalse);
      expect(play.benchLost, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a clean sweep of every dealt sitting closes it won, for '
        'what luck is worth', () {
      // Only sittings the rule wins, dealt as the whole bench.
      final lucky = Rules.allSittings(4).where((sitting) {
        var play = Play.of(Shows.at(4), [sitting]);
        while (play.judging) {
          play = play.ruleTakes ? play.take() : play.wave();
        }
        return play.sittingWon;
      }).toList();
      expect(lucky, hasLength(11));
      var play = Play.of(Shows.at(4), lucky);
      while (!play.isOver) {
        while (play.judging) {
          play = play.ruleTakes ? play.take() : play.wave();
        }
        if (play.benchWon) break;
        play = play.nextDeal();
      }
      expect(play.benchWon, isTrue);
      expect(play.won, 11);
    });

    test('the next sitting resets the bench and keeps the tally', () {
      var play = Play.of(Shows.at(0), const [
        [1, 3, 0, 2],
        [0, 1, 2, 3],
      ]);
      play = play.wave().take();
      expect(play.won, 1);
      play = play.nextDeal();
      expect(play.shown, 1);
      expect(play.judging, isTrue);
      expect(play.won, 1);
      expect(play.deal, [0, 1, 2, 3]);
    });
  });
}
