import 'package:flutter_test/flutter_test.dart';
import 'package:trodstow/link/cheapest.dart';
import 'package:trodstow/link/parishes.dart';
import 'package:trodstow/link/play.dart';

void main() {
  group('the parish', () {
    final parish = Rounds.at(0).parish;

    test('knows when a set of paths joins the whole of it', () {
      expect(parish.joinsItAll(const []), isFalse);
      expect(parish.joinsItAll(Cheapests.of(parish).cut), isTrue);
    });

    test('and when adding one would close a loop', () {
      // Coldpiece to Stonepit, Stonepit to Barrow End, Barrow End back to
      // Coldpiece.
      expect(parish.wouldLoop(const [1, 4], 0), isTrue);
      expect(parish.wouldLoop(const [1], 4), isFalse);
    });

    test('and adds up the yards', () {
      expect(parish.yardsOf(const [1, 3]), 198 + 192);
    });
  });

  group('the three ways of working it out', () {
    for (var number = 0; number < Rounds.count; number++) {
      final round = Rounds.at(number);

      test('${round.name} comes out the same cheapest first, by growing, and '
          'by trying every set', () {
        final cheapest = Cheapests.of(round.parish);
        expect(cheapest.yards, Cheapests.byGrowing(round.parish).yards);
        expect(cheapest.yards, Cheapests.byTrying(round.parish));
        expect(cheapest.yards, round.yards);
      });

      test('${round.name} really is joined up by what it gives back', () {
        final cheapest = Cheapests.of(round.parish);
        expect(round.parish.joinsItAll(cheapest.cut), isTrue);
        expect(cheapest.cut, hasLength(round.parish.count - 1));
      });
    }
  });

  group('why a path is in', () {
    test('it is the cheapest across the line it crosses, every time', () {
      // The cut property, on every path of every answer. This is the reason
      // the game gives, so it had better be true and not nearly true.
      for (var number = 0; number < Rounds.count; number++) {
        final parish = Rounds.at(number).parish;
        final network = Cheapests.of(parish).cut;
        for (final trod in network) {
          final why = Cheapests.whyIn(parish, network, trod);
          expect(why.crossing, contains(trod));
          expect(why.thisSide, isNotEmpty);
          expect(why.thatSide, isNotEmpty);
          expect(why.thisSide.length + why.thatSide.length, parish.count);
          for (final other in why.crossing) {
            if (other == trod) continue;
            expect(parish[other].yards, greaterThan(parish[trod].yards),
                reason: '${parish.name}: ${parish[other].yards} crosses the '
                    'same line as ${parish[trod].yards}');
          }
        }
      }
    });

    test('and every path across that line really does cross it', () {
      for (var number = 0; number < Rounds.count; number++) {
        final parish = Rounds.at(number).parish;
        final network = Cheapests.of(parish).cut;
        for (final trod in network) {
          final why = Cheapests.whyIn(parish, network, trod);
          for (final other in why.crossing) {
            final from = why.thisSide.contains(parish[other].from);
            final to = why.thisSide.contains(parish[other].to);
            expect(from, isNot(to), reason: parish.name);
          }
        }
      }
    });
  });

  group('why a path is out', () {
    test('it is the dearest on the loop it closes', () {
      for (var number = 0; number < Rounds.count; number++) {
        final parish = Rounds.at(number).parish;
        final network = Cheapests.of(parish).cut;
        for (var trod = 0; trod < parish.many; trod++) {
          if (network.contains(trod)) continue;
          final why = Cheapests.whyNot(parish, network, trod);
          expect(why, isNotNull, reason: '${parish.name}: path $trod');
          expect(why!.loop, contains(trod));
          for (final other in why.loop) {
            expect(parish[other].yards, lessThanOrEqualTo(parish[trod].yards),
                reason: parish.name);
          }
        }
      }
    });

    test('and the loop really is a loop', () {
      for (var number = 0; number < Rounds.count; number++) {
        final parish = Rounds.at(number).parish;
        final network = Cheapests.of(parish).cut;
        for (var trod = 0; trod < parish.many; trod++) {
          if (network.contains(trod)) continue;
          final loop = Cheapests.whyNot(parish, network, trod)!.loop;
          // Every hamlet on a loop has exactly two of its paths at it.
          final at = <int, int>{};
          for (final other in loop) {
            at[parish[other].from] = (at[parish[other].from] ?? 0) + 1;
            at[parish[other].to] = (at[parish[other].to] ?? 0) + 1;
          }
          for (final many in at.values) {
            expect(many, 2, reason: parish.name);
          }
        }
      }
    });
  });

  group('the two other methods', () {
    test('every hamlet own cheapest path is in the answer', () {
      // Not obvious and worth knowing: take the line with one hamlet on one
      // side and everywhere else on the other, and that hamlet's cheapest path
      // is the cheapest across it, so the cut property puts it in.
      for (var number = 0; number < Rounds.count; number++) {
        final parish = Rounds.at(number).parish;
        final network = Cheapests.of(parish).cut.toSet();
        for (var place = 0; place < parish.count; place++) {
          var best = -1;
          for (var trod = 0; trod < parish.many; trod++) {
            if (!parish[trod].touches(place)) continue;
            if (best < 0 || parish[trod].yards < parish[best].yards) best = trod;
          }
          expect(network, contains(best),
              reason: '${parish.name}: ${parish.places[place].name}');
        }
      }
    });

    test('and the shortest way to one place is dearer on every parish', () {
      for (var number = 0; number < Rounds.count; number++) {
        final parish = Rounds.at(number).parish;
        final cheapest = Cheapests.of(parish).yards;
        final shortest = Cheapests.byShortestWay(parish);
        expect(parish.joinsItAll(shortest.cut), isTrue, reason: parish.name);
        expect(shortest.yards, greaterThan(cheapest), reason: parish.name);
      }
    });
  });

  group('joining one up', () {
    late Play play;

    setUp(() => play = Play.of(Rounds.at(0).parish, Rounds.answerFor(0)));

    test('starts with nothing cut', () {
      expect(play.cut, isEmpty);
      expect(play.yards, 0);
      expect(play.isDone, isFalse);
      expect(play.pieces, 5);
      expect(play.couldStillCost, play.answer.yards);
    });

    test('cutting a path and filling it in again', () {
      expect(play.touch(0).has(0), isTrue);
      expect(play.touch(0).touch(0).has(0), isFalse);
    });

    test('a path that would close a loop cannot be cut', () {
      final walk = play.touch(1).touch(4);
      expect(walk.wouldLoop(0), isTrue);
      expect(identical(walk.touch(0), walk), isTrue);
    });

    test('it is done when every hamlet can be reached from every other', () {
      for (final trod in play.answer.cut) {
        play = play.touch(trod);
      }
      expect(play.isDone, isTrue);
      expect(play.isCheapest, isTrue);
      expect(play.yards, Rounds.at(0).yards);
    });

    test('and it says when the cheapest has been thrown away', () {
      play = play.touch(0);
      expect(play.couldStillCost, greaterThan(play.answer.yards));
      play = play.touch(0);
      expect(play.couldStillCost, play.answer.yards);
    });

    test('show me joins every parish up for the cheapest there is', () {
      for (var number = 0; number < Rounds.count; number++) {
        var walk = Play.of(Rounds.at(number).parish, Rounds.answerFor(number));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 20) fail('it never joined up');
          final next = walk.next;
          expect(next, isNotNull, reason: Rounds.at(number).name);
          walk = walk.touch(next!);
        }
        expect(walk.isCheapest, isTrue, reason: Rounds.at(number).name);
        expect(walk.yards, Rounds.at(number).yards,
            reason: Rounds.at(number).name);
      }
    });

    test('and still does after a bad path', () {
      // Cut the dearest path in the parish first and then ask.
      var dearest = 0;
      for (var trod = 0; trod < play.parish.many; trod++) {
        if (play.parish[trod].yards > play.parish[dearest].yards) dearest = trod;
      }
      play = play.touch(dearest);
      final could = play.couldStillCost;
      var guard = 0;
      while (!play.isDone) {
        if (guard++ > 20) fail('it never joined up');
        play = play.touch(play.next!);
      }
      expect(play.yards, could);
      expect(play.isCheapest, isFalse);
    });
  });
}
