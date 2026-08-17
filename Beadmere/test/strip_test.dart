import 'package:flutter_test/flutter_test.dart';
import 'package:beadmere/strip/levels.dart';
import 'package:beadmere/strip/play.dart';
import 'package:beadmere/strip/rules.dart';

/// The beads, the repeats and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the strip', () {
    test('a repeat reads the same both ways round', () {
      var strips = 0;
      for (var beads = Rules.shortest; beads <= 10; beads++) {
        for (final strip in Rules.strips(beads)) {
          strips++;
          for (var p = 1; p <= beads; p++) {
            expect(Rules.repeats(strip, p), Rules.repeatsByBorder(strip, p),
                reason: '${Rules.tellStrip(strip)} at $p');
          }
        }
      }
      expect(strips, 2044);
      expect(Rules.repeats([0, 1, 0, 0, 1, 0], 3), isTrue);
      expect(Rules.repeats([0, 1, 0, 0, 1, 0], 5), isTrue);
      expect(Rules.repeats([0, 1, 0, 0, 1, 0], 1), isFalse);
      expect(Rules.periodsOf([0, 1, 0, 0, 1, 0]), [3, 5, 6]);
      expect(Rules.tellStrip([0, 1]), 'L D');
    });

    test('Fine and Wilf holds at the bound and not before', () {
      var atBound = 0, sharp = 0;
      for (var beads = Rules.shortest; beads <= 11; beads++) {
        for (final strip in Rules.strips(beads)) {
          final periods = Rules.periodsOf(strip);
          for (final p in periods) {
            for (final q in periods) {
              if (q <= p) continue;
              final forced = Rules.gcdOf(p, q);
              if (beads >= Rules.bound(p, q)) {
                atBound++;
                expect(Rules.repeats(strip, forced), isTrue,
                    reason: '${Rules.tellStrip(strip)} with $p and $q');
              } else if (!Rules.repeats(strip, forced)) {
                sharp++;
              }
            }
          }
        }
      }
      expect(atBound, greaterThan(0));
      expect(sharp, greaterThan(0));
      expect(Rules.bound(3, 5), 7);
      expect(Rules.bound(4, 6), 8);
      expect(Rules.bound(5, 8), 12);
      expect(Rules.gcdOf(4, 6), 2);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['One Too Long']);
      for (final level in Levels.all) {
        var n = 0;
        for (final strip in Rules.strips(level.beads)) {
          if (level.meets(strip)) n++;
        }
        expect(n, level.ways, reason: level.name);
        if (level.winnable) {
          expect(level.meets(level.aim), isTrue, reason: level.name);
          expect(level.beads, lessThan(level.bound), reason: level.name);
        } else {
          expect(level.beads, greaterThanOrEqualTo(level.bound),
              reason: level.name);
        }
      }
      expect(Levels.all.map((l) => l.beads), [3, 6, 7, 11, 7]);
      expect(Levels.all.map((l) => l.ways), [2, 2, 4, 2, 0]);
      expect(Levels.all.map((l) => l.fewest), [1, 2, 1, 4, null]);
      expect(Levels.all.map((l) => l.forced), [1, 1, 2, 1, 1]);
      expect(Levels.all.map((l) => l.bound), [4, 7, 8, 12, 7]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(1).task,
          'string 6 beads that repeat every 3 and every 5 without repeating every 1');
      expect(Levels.at(4).task,
          'string 7 beads that repeat every 3 and every 5 without repeating every 1');
    });
  });

  group('the play', () {
    test('opens on a strip of light beads', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.beads, List.filled(level.beads, Rules.light));
        expect(play.moves, 0);
        // Every bead the same colour, so every length is a repeat.
        expect(play.periods,
            [for (var p = 1; p <= level.beads; p++) p]);
        expect(play.hasForced, isTrue);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a bead over, and back turns it again', () {
      var play = Play.of(Levels.at(1));
      play = play.turn(1);
      expect(play.beads, [0, 1, 0, 0, 0, 0]);
      expect(play.moves, 1);
      expect(play.back.beads, [0, 0, 0, 0, 0, 0]);
      expect(play.turn(9), same(play));
    });

    test('the pointer lands every ask it can, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final bead = play.next;
          expect(bead, isNotNull, reason: level.name);
          play = play.turn(bead!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.beads, level.aim, reason: level.name);
      }
      expect(Play.of(Levels.at(1)).pointed(1), 'Turn bead 2 dark.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('one too long admits it after three strips with both repeats', () {
      var play = Play.of(Levels.at(4));
      // All light has both repeats already, and every other one too.
      expect(play.hasFirst && play.hasSecond, isTrue);
      play = play.turn(0);
      expect(play.seen, isEmpty, reason: 'that strip has neither repeat');
      play = play.turn(0);
      expect(play.beads.every((bead) => bead == Rules.light), isTrue);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.turn(k % 7);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Fine and Wilf and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Nathan Fine and Herbert Wilf'));
      expect(words, contains('1965'));
      expect(words, contains('This is ask 5, One Too Long.'));
      expect(words, contains('read in full before the sham'));
    });
  });
}
