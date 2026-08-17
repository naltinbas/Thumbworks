import 'package:flutter_test/flutter_test.dart';
import 'package:roostwick/roost/levels.dart';
import 'package:roostwick/roost/play.dart';
import 'package:roostwick/roost/rules.dart';

/// The wood itself, with no screen anywhere near it.
void main() {
  group('the wood', () {
    test('has fifteen tethers, each pair of hollows once', () {
      final tethers = Rules.tethers;
      expect(tethers.length, 15);
      expect(tethers.toSet().length, 15);
      for (final tether in tethers) {
        expect(tether.$1, lessThan(tether.$2));
      }
    });

    test('reads a board off its letters and writes it back', () {
      expect(Rules.read('ABAC'), [(0, 1), (0, 2)]);
      expect(Rules.write(Rules.read('ABAC')), 'AB AC');
    });

    test('seats each bird at one end of its own tether', () {
      final birds = Rules.read('ABAC');
      expect(Rules.seats(birds, 0), [0, 0]);
      expect(Rules.seats(birds, 1), [1, 0]);
      expect(Rules.seats(birds, 3), [1, 2]);
      expect(Rules.across(birds, 0, 0), 1);
      expect(Rules.across(birds, 1, 0), 0);
    });

    test('calls a wood settled when no two birds share a hollow', () {
      final birds = Rules.read('ABAC');
      expect(Rules.settled(birds, 0), isFalse);
      expect(Rules.settled(birds, 1), isTrue);
    });
  });

  group('the two counts', () {
    test('agree on a single bird, which settles two ways', () {
      expect(Rules.tally(Rules.read('AB')), 2);
      expect(Rules.census(Rules.read('AB')), 2);
    });

    test('read a thicket as one way for each hollow left empty', () {
      // Three hollows, two birds: leave A, B or C empty.
      expect(Rules.tally(Rules.read('ABAC')), 3);
      expect(Rules.census(Rules.read('ABAC')), 3);
    });

    test('read a ring as two ways, whichever way it turns', () {
      expect(Rules.tally(Rules.read('ABBCAC')), 2);
      expect(Rules.census(Rules.read('ABBCAC')), 2);
      // A doubled tether is a ring of two, and counts the same.
      expect(Rules.tally(Rules.read('ABAB')), 2);
      expect(Rules.census(Rules.read('ABAB')), 2);
    });

    test('multiply the patches together', () {
      // Two thickets of three hollows: three ways each.
      expect(Rules.census(Rules.read('ABACDEDF')), 9);
      expect(Rules.tally(Rules.read('ABACDEDF')), 9);
    });

    test('agree that three birds on one tether settle no way', () {
      expect(Rules.tally(Rules.read('ABABAB')), 0);
      expect(Rules.census(Rules.read('ABABAB')), 0);
    });

    test('agree on every board of four birds or fewer', () {
      final tethers = Rules.tethers;
      var boards = 0;
      void walk(int from, int left, List<(int, int)> birds) {
        if (left == 0) {
          boards++;
          expect(Rules.census(birds), Rules.tally(birds),
              reason: Rules.write(birds));
          expect(Rules.overfull(birds) == null, Rules.tally(birds) > 0,
              reason: Rules.write(birds));
          expect(Rules.found(birds) != null, Rules.tally(birds) > 0,
              reason: Rules.write(birds));
          return;
        }
        if (from >= tethers.length) return;
        for (var n = 0; n <= left; n++) {
          walk(from + 1, left - n,
              [...birds, ...List.filled(n, tethers[from])]);
        }
      }

      for (var flock = 1; flock <= 4; flock++) {
        walk(0, flock, const []);
      }
      expect(boards, 15 + 120 + 680 + 3060);
    });
  });

  group('the overfull patch', () {
    test('is the set of hollows the penned birds cannot leave', () {
      final birds = Rules.read('ABABAB');
      final set = Rules.overfull(birds);
      expect(set, isNotNull);
      expect(set! & 3, 3);
    });

    test('is nothing at all when the wood settles', () {
      expect(Rules.overfull(Rules.read('ABCD')), isNull);
    });
  });

  group('the shoving', () {
    test('hands back a seating that really settles', () {
      for (final board in ['AB', 'ABAC', 'ABBCAC', 'ABACDEDF', 'ABABACADAEAF']) {
        final birds = Rules.read(board);
        final found = Rules.found(birds);
        expect(found, isNotNull, reason: board);
        expect(Rules.settled(birds, found!), isTrue, reason: board);
      }
    });

    test('gives up on a wood that cannot settle', () {
      expect(Rules.found(Rules.read('ABABAB')), isNull);
    });
  });

  group('the taps', () {
    test('are the birds that have to cross', () {
      expect(Rules.between(0, 0), 0);
      expect(Rules.between(0, 7), 3);
      expect(Rules.between(5, 6), 2);
    });

    test('to the nearest settled seating are counted, not searched for', () {
      final birds = Rules.read('ABACDEDF');
      final near = Rules.nearest(birds, Rules.opening);
      expect(near!.$2, 2);
      expect(Rules.settled(birds, near.$1), isTrue);
    });
  });

  group('every ask', () {
    test('counts the same both ways, and matches what it claims', () {
      for (final level in Levels.all) {
        expect(Rules.tally(level.birds), level.ways, reason: level.name);
        expect(Rules.census(level.birds), level.ways, reason: level.name);
        expect(level.seatings, 1 << level.flock, reason: level.name);
      }
    });

    test('opens unsettled, at the far end of its own board', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
        if (!level.winnable) continue;
        var furthest = 0;
        for (var pick = 0; pick < level.seatings; pick++) {
          final away = Rules.nearest(level.birds, pick)!.$2;
          if (away > furthest) furthest = away;
        }
        expect(furthest, level.fewest, reason: level.name);
      }
    });

    test('is settled by the pointer in the taps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.taps < 12) {
          play = play.tap(play.next!);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.taps, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('counts a tap and can take it back', () {
      final level = Levels.at(0);
      final one = Play.of(level).tap(0);
      expect(one.taps, 1);
      expect(one.at[0], 1);
      expect(one.back.taps, 0);
      expect(one.back.at[0], 0);
    });

    test('names the hollows that are crowded', () {
      final play = Play.of(Levels.at(0));
      expect(play.crowded, [0, 3]);
      expect(play.crowds[0], [0, 1]);
    });

    test('points at a bird and says where it flies', () {
      final play = Play.of(Levels.at(0));
      final bird = play.next!;
      expect(play.pointed(bird), contains('Tap bird ${bird + 1}'));
      expect(play.pointed(bird), contains('flies across to'));
    });

    test('stops counting once the wood is settled', () {
      var play = Play.of(Levels.at(0));
      while (!play.isDone) {
        play = play.tap(play.next!);
      }
      final after = play.tap(0);
      expect(after.taps, play.taps);
      expect(identical(after, play), isTrue);
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('settles at none of its seatings', () {
      for (var pick = 0; pick < dead.seatings; pick++) {
        expect(Rules.settled(dead.birds, pick), isFalse);
      }
    });

    test('crowds hollow A or hollow B at every one of them', () {
      var crowded = 0;
      for (var pick = 0; pick < dead.seatings; pick++) {
        final at = Rules.seats(dead.birds, pick);
        if (at.where((h) => h == 0).length > 1 ||
            at.where((h) => h == 1).length > 1) {
          crowded++;
        }
      }
      expect(crowded, dead.seatings);
    });

    test('hands back A and B and the three birds penned in them', () {
      final play = Play.of(dead);
      expect(play.overfull, [0, 1]);
      expect(play.penned, [0, 1, 2]);
    });

    test('has room to spare everywhere else', () {
      expect(dead.flock, Rules.hollows);
      expect(Rules.tally(Rules.read('CDDEEF')), 4);
    });

    test('admits it after eight seatings', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final bird in [0, 1, 2, 3, 4, 5, 0, 1]) {
        play = play.tap(bird);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('admits it after twenty four taps of going nowhere', () {
      var play = Play.of(dead);
      for (var k = 0; k < Play.gaveUpAt; k++) {
        play = play.tap(k.isEven ? 0 : 1);
      }
      expect(play.seen.length, lessThan(Play.enough));
      expect(play.gaveUp, isTrue);
    });
  });

  group('the why', () {
    test('names the paper and the rule, and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(2)));
      expect(words, contains('Pagh'));
      expect(words, contains('cuckoo graph'));
      expect(words, contains('12,204,240'));
      expect(words, contains('The Two Rings'));
    });
  });
}
