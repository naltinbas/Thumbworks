import 'package:flutter_test/flutter_test.dart';
import 'package:skeinwell/skein/frac.dart';
import 'package:skeinwell/skein/levels.dart';
import 'package:skeinwell/skein/play.dart';
import 'package:skeinwell/skein/rules.dart';

/// The village itself: the stringings, the shares, and the asks.
void main() {
  final four = Frac.of(4);

  group('the lanes', () {
    test('are every pair of greens, once each', () {
      expect(Rules.howManyLanes, 10);
      expect(Rules.lanes.toSet().length, 10);
      for (final (a, b) in Rules.lanes) {
        expect(a, lessThan(b));
        expect(b, lessThanOrEqualTo(Rules.greens));
      }
    });

    test('join the greens up, or leave one cut off', () {
      expect(Rules.joinedUp(Rules.opening), isTrue);
      expect(Rules.joinedUp(Rules.laid(const [0, 1, 4])), isFalse);
      expect(Rules.joinedUp(0), isFalse);
      expect(Rules.joinedUp((1 << 10) - 1), isTrue);
    });

    test('728 villages of the 1,024 join every green up', () {
      expect(Rules.villages().length, 728);
      expect(
          [for (var m = 0; m < 1024; m++) if (!Rules.joinedUp(m)) m].length,
          296);
    });
  });

  group('the stringings', () {
    test('take four lanes each and leave no green out', () {
      for (final village in Rules.villages()) {
        for (final stringing in Rules.stringings(village)) {
          expect(Rules.howMany(stringing), Rules.inAStringing);
          expect(Rules.joinedUp(stringing), isTrue);
        }
      }
    });

    test('the smallest village strings one way and the full skein 125', () {
      expect(Rules.stringings(Rules.opening).length, 1);
      expect(Rules.stringings((1 << 10) - 1).length, 125);
      expect(Rules.stringings(Rules.laid(const [0, 3, 4, 7, 9])).length, 5);
    });
  });

  group('the shares', () {
    test('come out the same counted and carried, on every village', () {
      for (final village in Rules.villages()) {
        final shares = Rules.shares(village);
        for (final lane in Rules.laidLanes(village)) {
          expect(shares[lane], Rules.resistance(village, lane),
              reason: '${Rules.tellLane(lane)} of ${Rules.tellVillage(village)}');
        }
      }
    });

    test('add to four on every village, and never to anything else', () {
      for (final village in Rules.villages()) {
        expect(Rules.total(village), four,
            reason: Rules.tellVillage(village));
      }
    });

    test('reach a whole one exactly when lifting the lane cuts a green off',
        () {
      for (final village in Rules.villages()) {
        final shares = Rules.shares(village);
        for (final lane in Rules.laidLanes(village)) {
          expect(shares[lane] == Frac.one,
              !Rules.joinedUp(Rules.toggle(village, lane)),
              reason: '${Rules.tellLane(lane)} of ${Rules.tellVillage(village)}');
        }
      }
    });

    test('the shapes the asks name', () {
      final ring = Rules.laid(const [0, 3, 4, 7, 9]);
      expect(Rules.shares(ring).values.toSet(), {Frac.of(4, 5)});
      final full = (1 << 10) - 1;
      expect(Rules.shares(full).values.toSet(), {Frac.of(2, 5)});
      final six = Rules.laid(const [2, 3, 4, 6, 8, 9]);
      expect(Rules.shares(six).values.toSet(), {Frac.of(2, 3)});
      expect(Rules.shares(Rules.opening).values.toSet(), {Frac.one});
    });
  });

  group('the asks', () {
    test('are landed by as many villages as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final village in Rules.villages()) {
          if (level.meets(village)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('name the cheapest village that lands them', () {
      for (final level in Levels.all) {
        if (!level.winnable) {
          expect(level.aim, isNull, reason: level.name);
          continue;
        }
        expect(level.meets(level.aimMask!), isTrue, reason: level.name);
        for (final village in Rules.villages()) {
          if (!level.meets(village)) continue;
          expect(Rules.taps(Rules.opening, village),
              greaterThanOrEqualTo(level.fewest!),
              reason: '${Rules.tellVillage(village)} against ${level.name}');
        }
      }
    });

    test('the fewest taps each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [2, 2, 3, 6, null]);
    });

    test('none of them is landed before a tap is taken', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens on the smallest village that joins every green', () {
      final play = Play.of(Levels.at(0));
      expect(Rules.laidLanes(play.village), [3, 6, 8, 9]);
      expect(play.lanes, 4);
      expect(play.stringings, 1);
      expect(play.total, four);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a tap lays a lane, and another lifts it', () {
      var play = Play.of(Levels.at(3)).tap(0);
      expect(play.has(0), isTrue);
      expect(play.moves, 1);
      play = play.tap(0);
      expect(play.has(0), isFalse);
      expect(play.moves, 2);
    });

    test('refuses a lift that would cut a green off', () {
      final play = Play.of(Levels.at(3));
      expect(play.wouldCut(3), isTrue);
      expect(identical(play.tap(3), play), isTrue);
      expect(play.wouldCut(0), isFalse);
      expect(identical(play.tap(11), play), isTrue);
    });

    test('back undoes the last tap', () {
      final play = Play.of(Levels.at(3)).tap(0).tap(1);
      expect(Rules.laidLanes(play.village), [0, 1, 3, 6, 8, 9]);
      expect(play.moves, 2);
      expect(Rules.laidLanes(play.back.village), [0, 3, 6, 8, 9]);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lays before it lifts, and lands the ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final aim = play.next!;
          expect(aim.$2, !play.has(aim.$1), reason: level.name);
          if (!aim.$2) {
            expect(play.wouldCut(aim.$1), isFalse, reason: level.name);
          }
          play = play.tap(aim.$1);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer never wanders further from an aim', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.nearest!.$2;
          play = play.tap(play.next!.$1);
          expect(play.nearest!.$2, was - 1, reason: level.name);
        }
      }
    });

    test('the pointer says which lane and which way', () {
      expect(Play.pointed((0, true)), 'Lay the lane from 1 to 2.');
      expect(Play.pointed((9, false)), 'Lift the lane from 4 to 5.');
    });

    test('the hopeless ask admits it after four villages', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final lane in [0, 1, 4, 5]) {
        play = play.tap(lane);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(play.total, four);
      expect(identical(play.tap(2), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final lane in [0, 1, 4, 5]) {
        play = play.tap(lane);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names Foster and the four lanes', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('Ronald Foster published this in 1949'));
      expect(words, contains('it always takes four lanes'));
      expect(words, contains('More Than Four'));
    });
  });
}
