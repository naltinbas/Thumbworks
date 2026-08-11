import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lockhithe/quay/berths.dart';
import 'package:lockhithe/quay/odds.dart';
import 'package:lockhithe/quay/play.dart';
import 'package:lockhithe/quay/stow.dart';

Stow _shuffled(Random random, int lockers) {
  final chits = [for (var chit = 0; chit < lockers; chit++) chit];
  chits.shuffle(random);
  return Stow(chits);
}

void main() {
  group('the loops', () {
    test('close, cover every locker once, and are found longest first', () {
      final random = Random(9);
      for (var go = 0; go < 60; go++) {
        final stow = _shuffled(random, 4 + random.nextInt(7));
        final loops = stow.loops;
        final seen = <int>{};
        for (final loop in loops) {
          for (final locker in loop) {
            expect(seen.add(locker), isTrue);
          }
          // The loop really closes: the chit in the last locker names
          // the first.
          expect(stow.chits[loop.last], loop.first);
        }
        expect(seen, hasLength(stow.lockers));
        for (var at = 1; at < loops.length; at++) {
          expect(loops[at].length, lessThanOrEqualTo(loops[at - 1].length));
        }
      }
    });
  });

  group('the theorem', () {
    test('a sailor following the chits walks exactly their own loop, and '
        'meets their chit on its last step', () {
      final random = Random(28);
      for (var go = 0; go < 60; go++) {
        final stow = _shuffled(random, 8);
        var play = Play.of(Berths.at(2), stow);
        while (!play.isOver && play.next != null) {
          play = play.open(play.next!);
        }
        final loop = stow.loopThrough(0);
        if (loop.length <= Berths.at(2).looks) {
          expect(play.found, isTrue, reason: '$loop');
          expect(play.opened, loop, reason: 'walked something else');
        } else {
          expect(play.found, isFalse, reason: '$loop');
        }
      }
    });

    test('so the crew comes through exactly when no loop outruns the '
        'looks', () {
      final random = Random(56);
      for (var go = 0; go < 80; go++) {
        final stow = _shuffled(random, 8);
        var play = Play.of(Berths.at(2), stow);
        while (!play.isOver && play.next != null) {
          play = play.open(play.next!);
        }
        expect(play.found && play.through,
            stow.longestLoop <= Berths.at(2).looks,
            reason: '${stow.chits}');
      }
    });
  });

  group('the three reckonings', () {
    test('the counting and the sweep agree wherever the sweep can reach', () {
      for (final lockers in const [4, 6, 8]) {
        expect(Odds.bySweep(lockers, lockers ~/ 2),
            Odds.byCounting(lockers, lockers ~/ 2),
            reason: '$lockers lockers');
      }
    });

    test('the numbers are the numbers', () {
      expect(Odds.byCounting(4, 2), (BigInt.from(5), BigInt.from(12)));
      expect(Odds.byCounting(8, 4), (BigInt.from(307), BigInt.from(840)));
      expect(Odds.byCounting(10, 5), (BigInt.from(893), BigInt.from(2520)));
      expect(Odds.byLuck(10, 5), (BigInt.one, BigInt.from(1024)));
    });

    test('following holds above a third while guessing collapses', () {
      for (var lockers = 4; lockers <= 12; lockers += 2) {
        final follow = Odds.byCounting(lockers, lockers ~/ 2);
        expect(follow.$1.toDouble() / follow.$2.toDouble(),
            greaterThan(0.34),
            reason: '$lockers following');
        final luck = Odds.byLuck(lockers, lockers ~/ 2);
        expect(luck.$1.toDouble() / luck.$2.toDouble(),
            lessThan(0.07),
            reason: '$lockers guessing');
      }
    });
  });

  group('a round on the quay', () {
    // A stow of eight with loops (0 4 2)(1 5)(3 6 7): longest three.
    final stow = Stow(const [4, 5, 0, 6, 2, 1, 7, 3]);

    test('opening your own locker starts your loop', () {
      var play = Play.of(Berths.at(2), stow);
      expect(play.next, 0);
      play = play.open(0);
      expect(play.opened, [0]);
      expect(play.found, isFalse);
      expect(play.next, 4);
    });

    test('the walk finds the chit inside the looks and the crew comes '
        'through', () {
      var play = Play.of(Berths.at(2), stow);
      play = play.open(0).open(4).open(2);
      expect(play.found, isTrue);
      expect(play.isOver, isTrue);
      expect(play.through, isTrue);
      expect(play.sunkBy, -1);
    });

    test('wandering spends looks and can fail where following would not',
        () {
      var play = Play.of(Berths.at(2), stow);
      play = play.open(1).open(3).open(5).open(6);
      expect(play.isOver, isTrue);
      expect(play.found, isFalse);
      expect(play.sunkBy, 0);
    });

    test('a long loop sinks the crew whoever walks first', () {
      // Loops (0 1 2 3 4)(5): the five-loop outruns three looks.
      final long = Stow(const [1, 2, 3, 4, 0, 5]);
      var play = Play.of(Berths.at(1), long);
      while (!play.isOver && play.next != null) {
        play = play.open(play.next!);
      }
      expect(play.found, isFalse);
      expect(long.longestLoop, 5);
    });

    test('an opened locker cannot be opened again', () {
      final play = Play.of(Berths.at(2), stow).open(0);
      expect(identical(play.open(0), play), isTrue);
    });
  });
}
