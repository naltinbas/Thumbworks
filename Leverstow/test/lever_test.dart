import 'package:flutter_test/flutter_test.dart';
import 'package:leverstow/lever/frac.dart';
import 'package:leverstow/lever/level.dart';
import 'package:leverstow/lever/levels.dart';
import 'package:leverstow/lever/play.dart';
import 'package:leverstow/lever/rules.dart';

/// The levers, the loops and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the levers', () {
    test('both are fair on their own, for different reasons', () {
      expect(Rules.odds('A', 0), Frac.of(1, 2));
      expect(Rules.odds('A', 2), Frac.of(1, 2));
      expect(Rules.odds('B', 0), Frac.of(1, 10));
      expect(Rules.odds('B', 1), Frac.of(3, 4));
      expect(Rules.resting('A'), [Frac.of(1, 3), Frac.of(1, 3), Frac.of(1, 3)]);
      expect(Rules.resting('B'), [Frac.of(5, 13), Frac.of(2, 13), Frac.of(6, 13)]);
      expect(Rules.climb('A'), Frac.zero);
      expect(Rules.climb('B'), Frac.zero);
      // The two sides of B's fairness, as the tile tells them.
      expect(Frac.of(5) * Frac.of(4, 5), Frac.of(4));
      expect(Frac.of(8) * Frac.of(1, 2), Frac.of(4));
    });

    test('the purse is carried as a spread, and every run agrees', () {
      expect(Rules.purse('ABB', 4).last, Frac.of(7, 20));
      for (final loop in ['A', 'B', 'ABB', 'ABABB']) {
        for (final rounds in [1, 5, 10]) {
          expect(Rules.purse(loop, rounds).last, Rules.purseByEveryRun(loop, rounds),
              reason: '$loop after $rounds');
        }
      }
      expect(Rules.purse('B', 1).last, Frac.of(-4, 5));
      expect(Rules.purse('A', 40).last, Frac.zero);
    });

    test('the fold and the long chain give the same climb', () {
      for (final loop in ['ABB', 'AABB', 'ABABB', 'BBABA', 'AB', 'BBB']) {
        expect(Rules.climbByChain(loop), Rules.climb(loop), reason: loop);
      }
      expect(Rules.climb('ABB'), Frac.of(2416, 35601));
      expect(Rules.climb('BBA'), Frac.of(2416, 35601));
      expect(Rules.climb('AABB'), Frac.of(4, 163));
      expect(Rules.climb('BBABA'), Frac.of(3613392, 47747645));
      expect(Rules.climb('ABAB'), Frac.zero);
      expect(Rules.climb('ABBABB'), Rules.climb('ABB'));
    });

    test('a loop is a loop of levers, and taps count', () {
      expect(Rules.valid('ABBA'), isTrue);
      expect(Rules.valid(''), isFalse);
      expect(Rules.valid('ABC'), isFalse);
      expect(Rules.valid('A' * 13), isFalse);
      expect(Rules.oneLever('BBB'), isTrue);
      expect(Rules.oneLever('BBA'), isFalse);
      expect(Rules.cost('A', 'AAB'), 3);
      expect(Rules.cost('A', 'ABB'), 4);
      expect(Rules.cost('ABB', 'A'), 2);
      expect(Rules.cost('ABB', 'ABB'), 0);
      expect(Rules.loops().length, 8190);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless, counted to eight slots', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['One Lever Forever']);
      // The whole sweep is the checker's; here it runs to eight slots,
      // which is 510 of the 8,190 loops.
      final climbs = <String, Frac>{};
      for (final loop in Rules.loops()) {
        if (loop.length > 8) break;
        climbs[loop] = Rules.climb(loop);
      }
      expect(climbs, hasLength(510));
      expect(climbs.values.where((c) => c < Frac.zero), isEmpty);
      final still = climbs.entries.where((e) => e.value == Frac.zero).map((e) => e.key);
      for (final loop in still) {
        final swap = loop[0] == 'A' ? 'B' : 'A';
        final alternating = [
          for (var i = 0; i < loop.length; i++) i.isEven ? loop[0] : swap,
        ].join();
        expect(Rules.oneLever(loop) || loop == alternating, isTrue, reason: loop);
      }
      expect(still, hasLength(24));
      expect(Levels.all.map((l) => l.ways), [8154, 12, 4, 10, 0]);
      expect(Levels.all.map((l) => l.fewest), [3, 4, 5, 7, null]);
      expect(Levels.all.map((l) => l.aim), ['AAB', 'ABB', 'AABB', 'ABABB', '']);
      for (final level in Levels.all.where((l) => l.winnable)) {
        expect(level.meets(level.aim), isTrue, reason: level.name);
      }
    });

    test('an ask knows what it wants of a loop', () {
      expect(Levels.at(0).meets('AAB'), isTrue);
      expect(Levels.at(0).meets('ABAB'), isFalse);
      expect(Levels.at(1).meets('BBA'), isTrue);
      expect(Levels.at(1).meets('AABB'), isFalse);
      expect(Levels.at(2).meets('AABB'), isTrue);
      expect(Levels.at(2).meets('AABBAABB'), isFalse);
      expect(Levels.at(3).meets('BBABA'), isTrue);
      expect(Levels.at(3).meets('ABB'), isFalse);
      expect(Levels.at(4).meets('BBBB'), isFalse);
      expect(Levels.at(4).meets('AAAA'), isFalse);
      expect(Level.famous, Frac.of(2416, 35601));
      expect(Level.best, Frac.of(3613392, 47747645));
      expect(Level.bestFour, Frac.of(4, 163));
      expect(Level.bestFour < Level.famous, isTrue);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'build a loop whose purse climbs in the long run');
      expect(Levels.at(4).task, 'fill the loop with one lever and come out ahead');
    });
  });

  group('the play', () {
    test('opens on one slot holding the plain lever', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.loop, 'A');
        expect((play.moves, play.isOver), (0, false), reason: level.name);
        expect(play.climb, Frac.zero);
        expect(play.seen, {'A'});
      }
    });

    test('taps turn levers over and slots on and off', () {
      var play = Play.of(Levels.at(0));
      play = play.longer;
      expect(play.loop, 'AA');
      play = play.flip(1);
      expect(play.loop, 'AB');
      expect(play.moves, 2);
      play = play.shorter;
      expect(play.loop, 'A');
      expect(play.back.loop, 'AB');
      expect(play.flip(5), same(play));
      final short = Play.of(Levels.at(0));
      expect(short.shorter, same(short));
      var long = Play.standing(Levels.at(0), 'A' * Rules.most);
      expect(long.longer, same(long));
      long = long.flip(0);
      expect(long.loop.startsWith('B'), isTrue);
    });

    test('the pointer lands every ask it can, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final aim = play.next;
          expect(aim, isNotNull, reason: level.name);
          final was = play.away!;
          play = switch (aim!.$1) {
            'add' => play.longer,
            'drop' => play.shorter,
            _ => play.flip(aim.$2),
          };
          expect(play.away, was - 1, reason: level.name);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
      expect(Play.pointed(('add', 0)), 'Put another slot on the loop.');
      expect(Play.pointed(('drop', 0)), 'Take the last slot off the loop.');
      expect(Play.pointed(('flip', 2)), 'Turn the lever in slot 3 over.');
      expect(Play.of(Levels.at(4)).next, isNull);
      expect(Play.of(Levels.at(4)).away, isNull);
    });

    test('one lever forever admits it once both have been run alone', () {
      final play = Play.of(Levels.at(4));
      expect(play.gaveUp, isFalse);
      final both = play.flip(0);
      expect(both.loop, 'B');
      expect(both.seen, {'A', 'B'});
      expect(both.gaveUp, isTrue);
      expect(both.isOver, isTrue);
      expect(both.flip(0), same(both));
      var wander = Play.of(Levels.at(4)).longer.flip(1);
      expect(wander.loop, 'AB');
      expect(wander.gaveUp, isFalse);
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.longer;
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Parrondo and both counts', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Juan Parrondo'));
      expect(words, contains('1996'));
      expect(words, contains('8,190'));
      expect(words, contains('This is ask 5, One Lever Forever.'));
      expect(words, contains('run in full'));
    });
  });
}
