import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:staplemere/yard/deal.dart';
import 'package:staplemere/yard/deals.dart';
import 'package:staplemere/yard/fewest.dart';
import 'package:staplemere/yard/play.dart';

/// A morning made up at random: so many distinct weights, shuffled.
List<int> _madeUp(Random random, int bales) {
  final all = [for (var tod = 2; tod <= 40; tod++) tod]..shuffle(random);
  return all.take(bales).toList();
}

/// Every ordering of 1..n, for the exhaustive anchors.
Iterable<List<int>> _orderings(int n) sync* {
  final tods = [for (var tod = 1; tod <= n; tod++) tod];
  yield* _permuted(tods, 0);
}

Iterable<List<int>> _permuted(List<int> tods, int from) sync* {
  if (from == tods.length) {
    yield [...tods];
    return;
  }
  for (var at = from; at < tods.length; at++) {
    var swap = tods[from]; tods[from] = tods[at]; tods[at] = swap;
    yield* _permuted(tods, from + 1);
    swap = tods[from]; tods[from] = tods[at]; tods[at] = swap;
  }
}

/// Plays a whole morning with each bale set down at random among the legal
/// places, leaning toward piles over the ground so mornings stay plural.
Play _anyOldHow(Random random, Deal deal) {
  var play = Play.of(deal);
  while (!play.isDone) {
    final legal = [
      for (var pile = 0; pile <= play.standing; pile++)
        if (play.mayRest(pile)) pile,
    ];
    final onPiles = legal.where((pile) => pile < play.standing).toList();
    final from = onPiles.isNotEmpty && random.nextInt(4) > 0 ? onPiles : legal;
    play = play.put(from[random.nextInt(from.length)]);
  }
  return play;
}

void main() {
  group('the thread', () {
    test('is a rising run of the arrivals, and a longest one', () {
      final tods = Deals.at(3).tods;
      final thread = Runs.thread(tods);
      expect(thread.length, 4);
      for (var link = 1; link < thread.length; link++) {
        expect(thread[link], greaterThan(thread[link - 1]));
        expect(tods[thread[link]], greaterThan(tods[thread[link - 1]]));
      }
    });

    test('handles the trivial mornings', () {
      expect(Runs.thread(const []), isEmpty);
      expect(Runs.thread(const [12]), [0]);
      expect(Runs.thread(const [3, 5, 9]).length, 3);
      expect(Runs.thread(const [9, 5, 3]).length, 1);
    });
  });

  group('three answers, one number', () {
    test('thread, best fit and brute force agree on every ordering of six',
        () {
      // The Dilworth anchor, exhaustive. The thread knows nothing about
      // piles, the brute force knows nothing about runs, and best fit is one
      // fixed policy; 720 mornings and they never part.
      for (final tods in _orderings(6)) {
        final thread = Runs.thread(tods).length;
        expect(Runs.byBestFit(const [], tods), thread, reason: '$tods');
        expect(Runs.byBrute(const [], tods), thread, reason: '$tods');
      }
    });

    test('and on three hundred bigger mornings made up at random', () {
      final random = Random(28);
      for (var go = 0; go < 300; go++) {
        final tods = _madeUp(random, 8 + random.nextInt(5));
        final thread = Runs.thread(tods).length;
        expect(Runs.byBestFit(const [], tods), thread, reason: '$tods');
        expect(Runs.byBrute(const [], tods), thread, reason: '$tods');
      }
    });

    test('the live number is exact from part-played mornings too', () {
      // couldStillBe is best fit from wherever the player has got to, and
      // brute force from the same standing agrees, so the number the ledger
      // shows is a fact about the position, not advice.
      final random = Random(56);
      for (var go = 0; go < 200; go++) {
        final tods = _madeUp(random, 6 + random.nextInt(4));
        final deal = Deal(name: 'made up', tods: tods, fewest: 0);
        var play = Play.of(deal);
        final stop = random.nextInt(tods.length);
        while (play.placed < stop) {
          final legal = [
            for (var pile = 0; pile <= play.standing; pile++)
              if (play.mayRest(pile)) pile,
          ];
          play = play.put(legal[random.nextInt(legal.length)]);
        }
        final tops = [
          for (var pile = 0; pile < play.standing; pile++) play.topOf(pile),
        ];
        expect(
          play.couldStillBe,
          Runs.byBrute(tops, tods.sublist(play.placed)),
          reason: '$tods stopped at $stop',
        );
      }
    });
  });

  group('the floor is visible', () {
    test('no two thread bales ever share a pile, however a morning is played',
        () {
      // The certificate the game draws: thread bales arrive later and
      // heavier, a top only lightens, so each needs a pile of its own. Fifty
      // mornings played any old how, and it never once fails.
      final random = Random(9);
      for (var go = 0; go < 50; go++) {
        final tods = _madeUp(random, 7 + random.nextInt(4));
        final deal = Deal(name: 'made up', tods: tods, fewest: 0);
        final done = _anyOldHow(random, deal);
        final thread = Runs.thread(tods);

        final homes = <int>{};
        for (final bale in thread) {
          final home = done.whereIs(bale);
          expect(home, isNotNull);
          expect(homes.add(home!.pile), isTrue,
              reason: '$tods put two thread bales on pile ${home.pile}');
        }
        expect(done.standing, greaterThanOrEqualTo(thread.length));
      }
    });

    test('every pile reads as a falling run from the ground up', () {
      final random = Random(4);
      for (var go = 0; go < 30; go++) {
        final tods = _madeUp(random, 8 + random.nextInt(4));
        final done =
            _anyOldHow(random, Deal(name: 'made up', tods: tods, fewest: 0));
        for (var pile = 0; pile < done.standing; pile++) {
          final weights = [for (final bale in done.piles[pile]) tods[bale]];
          for (var up = 1; up < weights.length; up++) {
            expect(weights[up], lessThan(weights[up - 1]));
          }
        }
      }
    });
  });

  group('nine is the boundary', () {
    test('five bales always hold a rising or a falling run of three', () {
      // The theorem at the size a suite can sweep whole: past two squared,
      // one of the runs reaches three, on all 120 orderings.
      for (final tods in _orderings(5)) {
        final longest = max(Runs.thread(tods).length, Runs.falling(tods));
        expect(longest, greaterThanOrEqualTo(3), reason: '$tods');
      }
    });

    test('and four of nine can be dodged, but never of ten', () {
      expect(Runs.thread(Deals.at(2).tods).length, 3);
      expect(Runs.falling(Deals.at(2).tods), 3);

      final random = Random(81);
      for (var go = 0; go < 500; go++) {
        final tods = _madeUp(random, 10);
        final longest = max(Runs.thread(tods).length, Runs.falling(tods));
        expect(longest, greaterThanOrEqualTo(4), reason: '$tods');
      }
    });
  });

  group('every deal that ships', () {
    for (var number = 0; number < Deals.count; number++) {
      final deal = Deals.at(number);

      test('${deal.name} is what it says it is', () {
        expect(deal.tods.toSet().length, deal.many);
        expect(Runs.thread(deal.tods).length, deal.fewest);
        expect(Runs.byBestFit(const [], deal.tods), deal.fewest);
        expect(Runs.byBrute(const [], deal.tods), deal.fewest);
      });
    }

    test('hoarding the snug tops costs a pile on every deal built for it', () {
      for (final number in const [0, 1, 3, 4]) {
        final deal = Deals.at(number);
        var play = Play.of(deal);
        while (!play.isDone) {
          var loosest = play.standing;
          for (var pile = 0; pile < play.standing; pile++) {
            if (!play.mayRest(pile)) continue;
            if (loosest == play.standing ||
                play.topOf(pile) > play.topOf(loosest)) {
              loosest = pile;
            }
          }
          play = play.put(loosest);
        }
        expect(play.standing, deal.fewest + 1, reason: deal.name);
      }
    });

    test('and the cost shows in the live number before the end', () {
      // The game does not wait for the last bale to say the morning has gone
      // over: somewhere along the hoarder's walk, couldStillBe rises.
      final deal = Deals.at(1);
      var play = Play.of(deal);
      var rose = false;
      while (!play.isDone) {
        var loosest = play.standing;
        for (var pile = 0; pile < play.standing; pile++) {
          if (!play.mayRest(pile)) continue;
          if (loosest == play.standing ||
              play.topOf(pile) > play.topOf(loosest)) {
            loosest = pile;
          }
        }
        play = play.put(loosest);
        if (!play.isDone && play.couldStillBe > deal.fewest) {
          rose = true;
          break;
        }
      }
      expect(rose, isTrue);
    });
  });

  group('a morning in play', () {
    test('starts with the cart full and the yard empty', () {
      final play = Play.of(Deals.at(0));
      expect(play.standing, 0);
      expect(play.arriving, 39);
      expect(play.isDone, isFalse);
      expect(play.couldStillBe, 2);
    });

    test('a bale rests on the ground or on a heavier top, nothing else', () {
      var play = Play.of(Deals.at(0)).put(0);
      expect(play.standing, 1);
      // 22 may rest on 39, or on the ground.
      expect(play.mayRest(0), isTrue);
      expect(play.mayRest(1), isTrue);
      play = play.put(0);
      // 38 may not rest on 22.
      expect(play.mayRest(0), isFalse);
      expect(identical(play.put(0), play), isTrue);
    });

    test('following next ends every deal on its fewest', () {
      for (var number = 0; number < Deals.count; number++) {
        final deal = Deals.at(number);
        var play = Play.of(deal);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 20) fail('${deal.name} never ended');
          expect(play.couldStillBe, deal.fewest, reason: deal.name);
          play = play.put(play.next!);
        }
        expect(play.standing, deal.fewest, reason: deal.name);
        expect(play.isFewest, isTrue, reason: deal.name);
      }
    });

    test('take back puts the bale back on the cart', () {
      final start = Play.of(Deals.at(0));
      final on = start.put(0).put(1);
      expect(on.placed, 2);
      expect(on.back.placed, 1);
      expect(on.back.back.placed, 0);
      expect(identical(start.back, start), isTrue);
    });

    test('whereIs finds a bale or says it is still coming', () {
      final play = Play.of(Deals.at(0)).put(0).put(0);
      expect(play.whereIs(0), (pile: 0, height: 0));
      expect(play.whereIs(1), (pile: 0, height: 1));
      expect(play.whereIs(2), isNull);
    });
  });
}
