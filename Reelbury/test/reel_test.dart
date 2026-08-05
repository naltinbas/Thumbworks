import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:reelbury/reel/hall.dart';
import 'package:reelbury/reel/play.dart';
import 'package:reelbury/reel/rounds.dart';
import 'package:reelbury/reel/stable.dart';

/// A hall of a size, with everybody's list shuffled.
Hall _scatter(Random dice, int size) => Hall(
      callers: [
        for (var who = 0; who < size; who++)
          ([for (var other = 0; other < size; other++) other]..shuffle(dice)),
      ],
      dancers: [
        for (var who = 0; who < size; who++)
          ([for (var other = 0; other < size; other++) other]..shuffle(dice)),
      ],
    );

void main() {
  group('a hall', () {
    test('knows who is liked more than whom', () {
      final hall = Hall(
        callers: const [
          [1, 0],
          [0, 1],
        ],
        dancers: const [
          [0, 1],
          [1, 0],
        ],
      );
      expect(hall.isWhole, isTrue);
      expect(hall.callerRank(0, 1), 0);
      expect(hall.callerRank(0, 0), 1);
      expect(hall.callerPrefers(0, 1, 0), isTrue);
      expect(hall.callerPrefers(0, 0, 1), isFalse);
      expect(hall.dancerPrefers(1, 1, 0), isTrue);
    });

    test('and says when a list is not a list of everybody', () {
      expect(
        Hall(
          callers: const [
            [0, 0],
            [0, 1],
          ],
          dancers: const [
            [0, 1],
            [1, 0],
          ],
        ).isWhole,
        isFalse,
      );
    });
  });

  group('asking in turn', () {
    test('always ends with everybody paired and nobody wanting to swap', () {
      // Gale and Shapley, 1962: it cannot go round for ever, because every
      // ask is one that caller never makes again, and it cannot end with
      // anybody spare, because a dancer who has been asked never goes back to
      // nobody. So a pairing that holds always exists — which is the reason
      // this game can promise every round has an answer.
      final dice = Random(20260805);
      for (var round = 0; round < 400; round++) {
        final hall = _scatter(dice, 2 + dice.nextInt(6));
        final pairing = Stable.byAsking(hall);

        expect(pairing, isNot(contains(-1)), reason: 'somebody was left out');
        expect(pairing.toSet(), hasLength(hall.count),
            reason: 'somebody was in two couples');
        expect(Stable.holds(hall, pairing), isTrue,
            reason: 'a pair would rather have each other');
      }
    });

    test('and either side may ask, and both answers hold', () {
      final dice = Random(7);
      for (var round = 0; round < 200; round++) {
        final hall = _scatter(dice, 2 + dice.nextInt(5));
        expect(Stable.holds(hall, Stable.byAsking(hall)), isTrue);
        expect(
          Stable.holds(hall, Stable.byAsking(hall, callersAsk: false)),
          isTrue,
        );
      }
    });

    test('and the side that asks does at least as well as the side that does '
        'not', () {
      // The other half of what Gale and Shapley proved: asking gets each
      // asker the best partner any pairing that holds could give them. So no
      // caller is worse off in the pairing they asked for than in the one
      // they were asked for.
      final dice = Random(99);
      for (var round = 0; round < 200; round++) {
        final hall = _scatter(dice, 2 + dice.nextInt(5));
        final asked = Stable.byAsking(hall);
        final answered = Stable.byAsking(hall, callersAsk: false);

        for (var caller = 0; caller < hall.count; caller++) {
          expect(
            hall.callerRank(caller, asked[caller]),
            lessThanOrEqualTo(hall.callerRank(caller, answered[caller])),
            reason: 'caller $caller did better by being asked',
          );
        }
      }
    });

    test('and it is the best of all of them, held against every one', () {
      final dice = Random(4242);
      for (var round = 0; round < 120; round++) {
        final hall = _scatter(dice, 2 + dice.nextInt(4));
        final asked = Stable.byAsking(hall);
        final all = Stable.allThatHold(hall);

        expect(all, isNotEmpty);
        expect(all.any((one) => _same(one, asked)), isTrue,
            reason: 'asking gave a pairing that does not hold');

        for (final other in all) {
          for (var caller = 0; caller < hall.count; caller++) {
            expect(
              hall.callerRank(caller, asked[caller]),
              lessThanOrEqualTo(hall.callerRank(caller, other[caller])),
              reason: 'a pairing that holds beats the one asking gave',
            );
          }
        }
      }
    });
  });

  group('one pairing or several', () {
    test('both sides agreeing is the same as there being only one', () {
      // A theorem and a search, and they have nothing in common but the
      // answer: the pairings that hold have a best one for each side, and
      // there is one of them exactly when those two are the same.
      final dice = Random(31415);
      var only = 0;
      var several = 0;

      for (var round = 0; round < 300; round++) {
        final hall = _scatter(dice, 2 + dice.nextInt(4));
        final counted = Stable.allThatHold(hall).length;
        expect(Stable.isOnlyOne(hall), counted == 1,
            reason: 'counted $counted');
        if (counted == 1) {
          only++;
        } else {
          several++;
        }
      }
      // Both answers agreeing three hundred times would prove nothing if
      // they were all the same answer.
      expect(only, greaterThan(20));
      expect(several, greaterThan(20));
    });
  });

  group('every round', () {
    test('has lists with everybody on them, once', () {
      for (var i = 0; i < Rounds.count; i++) {
        final round = Rounds.at(i);
        expect(round.hall.isWhole, isTrue, reason: round.name);
        expect(round.dancers, hasLength(round.count), reason: round.name);
        expect(round.count, lessThanOrEqualTo(Round.callerNames.length));
      }
    });

    test('has exactly one pairing that holds', () {
      // The whole design, checked by trying every way of pairing the sides
      // up rather than by asking the algorithm about itself.
      for (var i = 0; i < Rounds.count; i++) {
        final round = Rounds.at(i);
        final all = Stable.allThatHold(round.hall);
        expect(all, hasLength(1),
            reason: '${round.name} has ${all.length} pairings that hold');
      }
    });

    test('and it is not the one where everybody gets their first choice', () {
      // A round that hands everybody what they asked for first is a queue,
      // not a puzzle.
      for (var i = 0; i < Rounds.count; i++) {
        final round = Rounds.at(i);
        final answer = Stable.byAsking(round.hall);
        var firsts = 0;
        for (var caller = 0; caller < round.count; caller++) {
          if (round.callers[caller].first == answer[caller]) firsts++;
        }
        expect(firsts, lessThanOrEqualTo(round.count ~/ 3), reason: round.name);
      }
    });

    test('and they get bigger', () {
      var last = 0;
      for (var i = 0; i < Rounds.count; i++) {
        expect(Rounds.at(i).count, greaterThanOrEqualTo(last));
        last = Rounds.at(i).count;
      }
    });
  });

  group('pairing them up', () {
    Play start([int which = 0]) => Play.of(Rounds.at(which));

    test('begins with nobody paired', () {
      final play = start();
      expect(play.paired, 0);
      expect(play.isFull, isFalse);
      expect(play.isDone, isFalse);
      expect(play.dancerOf(0), -1);
    });

    test('puts two together, and breaks whatever they were in', () {
      var play = start().pair(0, 1);
      expect(play.dancerOf(0), 1);
      expect(play.callerOf(1), 0);
      expect(play.paired, 1);

      // The same dancer, a different caller: the first couple goes.
      play = play.pair(1, 1);
      expect(play.dancerOf(0), -1);
      expect(play.dancerOf(1), 1);
      expect(play.paired, 1);

      // The same caller, a different dancer.
      play = play.pair(1, 0);
      expect(play.dancerOf(1), 0);
      expect(play.callerOf(1), -1);
    });

    test('and parts a couple', () {
      final play = start().pair(0, 1);
      expect(play.part(0).paired, 0);
      expect(play.part(0).part(0).changes, play.part(0).changes,
          reason: 'and parting nobody changes nothing');
    });

    test('says who would rather have whom, while it is half done', () {
      // A half-finished pairing shows its own gaps: anybody unpaired would
      // rather have somebody than nobody.
      final play = start();
      expect(play.blocking, isNotEmpty);
      expect(play.isDone, isFalse);
    });

    test('and holds when the answer is laid out', () {
      for (var which = 0; which < Rounds.count; which++) {
        final round = Rounds.at(which);
        var play = Play.of(round);
        final answer = Stable.byAsking(round.hall);

        for (var caller = 0; caller < round.count; caller++) {
          play = play.pair(caller, answer[caller]);
        }
        expect(play.isFull, isTrue, reason: round.name);
        expect(play.blocking, isEmpty, reason: round.name);
        expect(play.isDone, isTrue, reason: round.name);
        expect(play.wrong, 0, reason: round.name);
      }
    });

    test('and does not hold when anything else is', () {
      // Every other way of pairing the first round up has somebody who would
      // rather swap — which is what "exactly one holds" means, said from the
      // other end.
      final round = Rounds.at(0);
      final answer = Stable.byAsking(round.hall);

      for (final other in _everyPairing(round.count)) {
        var play = Play.of(round);
        for (var caller = 0; caller < round.count; caller++) {
          play = play.pair(caller, other[caller]);
        }
        final same = _same(other, answer);
        expect(play.isDone, same, reason: 'on $other');
        if (!same) expect(play.blocking, isNotEmpty);
      }
    });
  });
}

bool _same(List<int> one, List<int> other) {
  for (var i = 0; i < one.length; i++) {
    if (one[i] != other[i]) return false;
  }
  return true;
}

/// Every way of pairing a side of this size with the other.
List<List<int>> _everyPairing(int count) {
  final found = <List<int>>[];
  final taken = List<bool>.filled(count, false);
  final pairing = List<int>.filled(count, -1);

  void walk(int caller) {
    if (caller == count) {
      found.add(List.of(pairing));
      return;
    }
    for (var dancer = 0; dancer < count; dancer++) {
      if (taken[dancer]) continue;
      taken[dancer] = true;
      pairing[caller] = dancer;
      walk(caller + 1);
      taken[dancer] = false;
    }
  }

  walk(0);
  return found;
}
