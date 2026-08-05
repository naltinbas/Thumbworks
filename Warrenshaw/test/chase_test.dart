import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:warrenshaw/chase/chart.dart';
import 'package:warrenshaw/chase/dismantle.dart';
import 'package:warrenshaw/chase/maps.dart';
import 'package:warrenshaw/chase/play.dart';
import 'package:warrenshaw/chase/tablebase.dart';

void main() {
  group('a map', () {
    test('joins places both ways, and every place to itself', () {
      final chart = Chart(
        places: const [Place('a', 0, 0), Place('b', 1, 0), Place('c', 0, 1)],
        paths: const [(0, 1)],
      );
      expect(chart.beside[0], containsAll([0, 1]));
      expect(chart.beside[1], containsAll([0, 1]));
      expect(chart.beside[2], [2], reason: 'standing still is always a move');
      expect(chart.joined(0, 2), isFalse);
    });

    test('and says whether it is one piece', () {
      final split = Chart(
        places: const [Place('a', 0, 0), Place('b', 1, 0), Place('c', 0, 1)],
        paths: const [(0, 1)],
      );
      expect(split.isWhole, isFalse);
      expect(
        Chart(places: split.places, paths: const [(0, 1), (1, 2)]).isWhole,
        isTrue,
      );
    });
  });

  group('the table', () {
    test('catches on a lane, one move at a time', () {
      // Five places in a row. The seeker at one end and the runner at the
      // other: the runner backs away until it runs out of lane.
      final chart = Chart(
        places: const [
          Place('0', 0, 0),
          Place('1', 0, 0),
          Place('2', 0, 0),
          Place('3', 0, 0),
          Place('4', 0, 0),
        ],
        paths: const [(0, 1), (1, 2), (2, 3), (3, 4)],
      );
      final table = Tablebase(chart);

      expect(table.movesFrom(0, 4, seekersTurn: true), 4);
      expect(table.movesFrom(3, 4, seekersTurn: true), 1);
      expect(table.movesFrom(4, 4, seekersTurn: true), 0);
      expect(table.isSeekerWin, isTrue);
      expect(table.bestForSeeker(0, 4), 1, reason: 'walk at it');
    });

    test('and never catches anything on a ring of four', () {
      // The runner stands opposite and stays there. This is the smallest map
      // where that works, and it is why the last map in the game exists.
      final chart = Chart(
        places: const [
          Place('0', 0, 0),
          Place('1', 0, 0),
          Place('2', 0, 0),
          Place('3', 0, 0),
        ],
        paths: const [(0, 1), (1, 2), (2, 3), (3, 0)],
      );
      final table = Tablebase(chart);

      expect(table.isSeekerWin, isFalse);
      expect(table.movesFrom(0, 2, seekersTurn: true), Tablebase.never);
      expect(table.capture, Tablebase.never);
      expect(table.bestStart, isNull);
    });

    test('and catches everything at once on a map where all is joined', () {
      final chart = Chart(
        places: const [Place('0', 0, 0), Place('1', 0, 0), Place('2', 0, 0)],
        paths: const [(0, 1), (1, 2), (0, 2)],
      );
      final table = Tablebase(chart);
      expect(table.capture, 1);
    });

    test('and the runner it plays really is the best there is', () {
      // The runner's move is the table's, so this is asking the table about
      // itself — but from the other side: whatever the runner does, the
      // seeker cannot do better than the number the table gave, and the
      // runner cannot do worse.
      for (var which = 0; which < Warrens.count; which++) {
        final warren = Warrens.at(which);
        final chart = warren.chart;
        final table = Tablebase(chart);

        for (var seeker = 0; seeker < chart.count; seeker++) {
          for (var runner = 0; runner < chart.count; runner++) {
            if (seeker == runner) continue;
            final want = table.movesFrom(seeker, runner, seekersTurn: true);
            if (want == Tablebase.never) continue;

            // The best move leaves exactly one fewer to go.
            final best = table.bestForSeeker(seeker, runner)!;
            final after = best == runner
                ? 0
                : table.movesFrom(best, runner, seekersTurn: false);
            expect(after + 1, want, reason: '${warren.name} $seeker vs $runner');

            // And nothing does better.
            for (final other in chart.beside[seeker]) {
              final then = other == runner
                  ? 0
                  : table.movesFrom(other, runner, seekersTurn: false);
              expect(then + 1, greaterThanOrEqualTo(want),
                  reason: '${warren.name}: $other beats the table');
            }
          }
        }
      }
    });
  });

  group('the theorem', () {
    test('agrees with the table on every map that ships', () {
      // Two answers to the same question with nothing in common but the
      // answer. One walks every position of the chase; the other rubs places
      // off the map and never considers a move at all.
      for (var which = 0; which < Warrens.count; which++) {
        final warren = Warrens.at(which);
        final chart = warren.chart;
        expect(
          Dismantle.comesApart(chart),
          Tablebase(chart).isSeekerWin,
          reason: warren.name,
        );
      }
    });

    test('and on three hundred maps made up at random', () {
      final dice = Random(20260805);
      var checked = 0;
      var wins = 0;

      while (checked < 300) {
        final places = 5 + dice.nextInt(4);
        final paths = <(int, int)>[];
        for (var one = 0; one < places; one++) {
          for (var other = one + 1; other < places; other++) {
            if (dice.nextInt(100) < 30) paths.add((one, other));
          }
        }
        final chart = Chart(
          places: [
            for (var place = 0; place < places; place++)
              Place('$place', 0, 0),
          ],
          paths: paths,
        );
        if (!chart.isWhole) continue;
        checked++;

        final table = Tablebase(chart);
        if (table.isSeekerWin) wins++;
        expect(Dismantle.comesApart(chart), table.isSeekerWin,
            reason: 'disagreed on $paths');
      }

      // Both answers agreeing on three hundred maps that are all the same
      // answer would prove nothing, so this checks the sample had both in it.
      expect(wins, greaterThan(20));
      expect(checked - wins, greaterThan(20));
    });

    test('and a place is only covered by one it is joined to', () {
      // What "covered" means, on the smallest map where it means anything: a
      // leaf is covered by the place it hangs off, and the middle of a lane
      // is covered by nothing.
      final chart = Chart(
        places: const [Place('0', 0, 0), Place('1', 0, 0), Place('2', 0, 0)],
        paths: const [(0, 1), (1, 2)],
      );
      final all = {0, 1, 2};
      final covered = Dismantle.covered(chart, all)!;
      expect(covered.$2, 1, reason: 'the middle covers an end');
      expect([0, 2], contains(covered.$1));

      final ring = Chart(
        places: chart.places,
        paths: const [(0, 1), (1, 2), (0, 2)],
      );
      expect(Dismantle.covered(ring, all), isNotNull,
          reason: 'everything covers everything on a triangle');
    });
  });

  group('every map', () {
    test('is one piece, and starts the two of them apart', () {
      for (var which = 0; which < Warrens.count; which++) {
        final warren = Warrens.at(which);
        expect(warren.chart.isWhole, isTrue, reason: warren.name);
        expect(warren.seeker, isNot(warren.runner), reason: warren.name);
        expect(warren.places, hasLength(warren.chart.count));
      }
    });

    test('has the par it says, and the one that cannot be won says so', () {
      // Worked out again from nothing rather than read off the map.
      for (var which = 0; which < Warrens.count; which++) {
        final warren = Warrens.at(which);
        final table = Tablebase(warren.chart);
        final moves =
            table.movesFrom(warren.seeker, warren.runner, seekersTurn: true);

        if (warren.hopeless) {
          expect(warren.par, isNull, reason: warren.name);
          expect(moves, Tablebase.never, reason: warren.name);
          expect(table.isSeekerWin, isFalse, reason: warren.name);
        } else {
          expect(warren.par, moves, reason: warren.name);
          expect(table.isSeekerWin, isTrue, reason: warren.name);
        }
      }
    });

    test('and they get harder', () {
      var last = 0;
      for (var which = 0; which < Warrens.count; which++) {
        final par = Warrens.at(which).par;
        if (par == null) continue;
        expect(par, greaterThanOrEqualTo(last), reason: Warrens.at(which).name);
        last = par;
      }
    });
  });

  group('playing', () {
    Play start([int which = 0]) {
      final warren = Warrens.at(which);
      return Play.of(warren, Tablebase(warren.chart));
    }

    test('begins where the map says, with the par still to go', () {
      final play = start();
      expect(play.seeker, play.warren.seeker);
      expect(play.runner, play.warren.runner);
      expect(play.moves, 0);
      expect(play.left, play.warren.par);
      expect(play.onShortest, isTrue);
      expect(play.isDone, isFalse);
    });

    test('moves along a path, and refuses anything else', () {
      final play = start();
      expect(play.canGo, contains(play.seeker), reason: 'standing still');

      final far = [
        for (var place = 0; place < play.chart.count; place++)
          if (!play.chart.beside[play.seeker].contains(place)) place,
      ];
      expect(play.whyNot(far.first), Refusal.noPath);
      expect(play.whyNot(-1), Refusal.nowhere);
      expect(play.move(far.first).seeker, play.seeker);
    });

    test('and the runner answers at once, as well as it can', () {
      final play = start();
      final after = play.move(play.next!);

      expect(after.moves, 1);
      expect(after.left, play.left - 1, reason: 'a move well spent');
      expect(after.onShortest, isTrue);
      expect(after.been, hasLength(1));
    });

    test('and a move that wastes time says so', () {
      // A move off the shortest way is not a mistake the game hides.
      final play = start(2); // the lane: there is only one way and one wrong
      final wrong = [
        for (final place in play.canGo)
          if (place != play.next) place,
      ];
      expect(wrong, isNotEmpty);

      final after = play.move(wrong.first);
      expect(after.onShortest, isFalse);
      expect(after.wasted, greaterThan(0));
      expect(after.moves + after.left, greaterThan(play.warren.par!));
    });

    test('takes a move back', () {
      final play = start();
      final after = play.move(play.next!);
      expect(after.back.seeker, play.seeker);
      expect(after.back.runner, play.runner);
      expect(after.back.moves, 0);
      expect(play.back.been, isEmpty, reason: 'and stops at the start');
    });

    test('and every map is won in its par by taking the best move', () {
      // The whole promise, played out: the number on the map is reached
      // against a runner that is playing as well as anything can.
      for (var which = 0; which < Warrens.count; which++) {
        final warren = Warrens.at(which);
        if (warren.hopeless) continue;
        var play = Play.of(warren, Tablebase(warren.chart));

        var guard = 0;
        while (!play.isDone && guard++ < 30) {
          play = play.move(play.next!);
        }
        expect(play.isDone, isTrue, reason: warren.name);
        expect(play.moves, warren.par, reason: warren.name);
        expect(play.wasted, 0, reason: warren.name);
      }
    });

    test('and the one that cannot be won is not won', () {
      // Twenty moves of the best play there is, and the runner is still out
      // there. It is not that the game is hard: it is that it cannot be done,
      // and the map says so before anybody starts.
      final warren = Warrens.at(Warrens.count - 1);
      expect(warren.hopeless, isTrue);
      var play = Play.of(warren, Tablebase(warren.chart));

      for (var turn = 0; turn < 20; turn++) {
        expect(play.canStillWin, isFalse);
        expect(play.next, isNull, reason: 'and there is no move to suggest');
        // Anything at all, since nothing helps.
        play = play.move(play.canGo.last);
        expect(play.isCaught, isFalse);
      }
      expect(play.moves, 20);
    });
  });
}
