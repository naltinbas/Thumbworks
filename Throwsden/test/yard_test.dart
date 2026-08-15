import 'package:flutter_test/flutter_test.dart';
import 'package:throwsden/fair/levels.dart';
import 'package:throwsden/fair/play.dart';
import 'package:throwsden/fair/rules.dart';

/// The law of the yard, held to.
void main() {
  group('the rules', () {
    test('every level\'s yard is sound and its label is what the walk finds', () {
      for (final level in Levels.all) {
        final yard = Yard(level.wrestlers, level.bouts);
        expect(yard.sound, isTrue, reason: level.name);
        var orderings = 0, ways = 0;
        yard.orderings((line) {
          orderings++;
          if (level.ring ? yard.ringHolds(line) : yard.chainHolds(line)) ways++;
        });
        expect(orderings, level.orderings, reason: level.name);
        expect(ways, level.ways, reason: level.name);
      }
    });

    test('the four and the five read as told', () {
      final four = Yard(4, Levels.at(0).bouts);
      expect(four.scores, [2, 0, 2, 2]);
      expect(four.count(), (3, 0));
      expect(four.champion, isNull);
      final five = Yard(5, Levels.at(1).bouts);
      expect(five.champion, 4);
      expect(five.count(), (5, 0));
      expect(five.strong, isFalse);
      expect(five.insertion(), [4, 3, 2, 1, 0]);
      expect(five.chainHolds([4, 3, 2, 1, 0]), isTrue);
      expect(five.chainHolds([0, 4, 3, 2, 1]), isFalse);
    });

    test('the ring and the six read as told', () {
      final ring = Yard(5, Levels.at(2).bouts);
      expect(ring.strong, isTrue);
      expect(ring.count(), (13, 10));
      expect(ring.ringHolds([0, 4, 1, 3, 2]), isTrue);
      final six = Yard(6, Levels.at(3).bouts);
      expect(six.count().$1, 23);
    });

    test('Redei on every yard of three, four and five: a chain, and an odd count', () {
      for (final size in [3, 4, 5]) {
        for (var bits = 0; bits < (1 << Yard.pairs(size)); bits++) {
          final yard = Yard.fromBits(size, bits);
          expect(yard.sound, isTrue);
          final slotted = yard.insertion();
          expect(slotted.toSet(), hasLength(size), reason: '$size $bits');
          expect(yard.chainHolds(slotted), isTrue, reason: '$size $bits');
          final (chains, rings) = yard.count();
          expect(chains.isOdd, isTrue, reason: '$size $bits');
          expect(rings > 0, yard.strong, reason: '$size $bits');
          if (yard.champion != null) expect(rings, 0, reason: '$size $bits');
        }
      }
    });

    test('the counts of five are quantised', () {
      final seen = <int>{};
      for (var bits = 0; bits < 1024; bits++) {
        seen.add(Yard.fromBits(5, bits).count().$1);
      }
      expect(seen.toList()..sort(), [1, 3, 5, 9, 11, 13, 15]);
    });

    test('bits round-trip through the pairs', () {
      expect(Yard.pairs(5), 10);
      expect(Yard.pairIndex(0, 1), 0);
      expect(Yard.pairIndex(3, 4), 9);
      final yard = Yard.fromBits(4, 9);
      expect(yard.threw, Yard(4, Levels.at(0).bouts).threw);
    });
  });

  group('the play', () {
    test('opens with an empty line and a full bench', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.line, isEmpty, reason: level.name);
        expect(play.bench, hasLength(level.wrestlers));
        expect(play.isDone, isFalse);
      }
    });

    test('a tap steps in, a tap on the last steps out, counted both ways, and back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.line, [0]);
      expect(play.moves, 1);
      play = play.tap(3);
      expect(play.line, [0, 3]);
      expect(play.tap(0), same(play));
      play = play.tap(3);
      expect(play.line, [0]);
      expect(play.moves, 3);
      expect(play.back.line, [0, 3]);
      expect(play.tap(9), same(play));
    });

    test('links read as they stand', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(1).tap(3);
      expect(play.linkHolds(0), isTrue);
      expect(play.linkHolds(1), isFalse);
      expect(play.broken, 1);
      expect(play.linksHolding, 1);
      expect(play.chainHolds, isFalse);
    });

    test('the yards by hand', () {
      expect(Play.of(Levels.at(0)).tap(0).tap(3).tap(2).tap(1).isDone, isTrue);
      expect(Play.of(Levels.at(1)).tap(4).tap(3).tap(2).tap(1).tap(0).isDone, isTrue);
      final ring = Play.of(Levels.at(2)).tap(0).tap(4).tap(1).tap(3).tap(2);
      expect(ring.chainHolds, isTrue);
      expect(ring.ringCloses, isTrue);
      expect(ring.isDone, isTrue);
      final open = Play.of(Levels.at(2)).tap(4).tap(3).tap(2).tap(0).tap(1);
      expect(open.chainHolds, isTrue);
      expect(open.ringCloses, isFalse);
      expect(open.isDone, isFalse);
      expect(Play.of(Levels.at(3)).tap(0).tap(5).tap(4).tap(1).tap(3).tap(2).isDone, isTrue);
    });

    test('the pointer lands every winnable yard', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 14) {
          final (_, w) = play.next!;
          play = play.tap(w);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).wrestlers, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer steps a strayed line out first', () {
      final play = Play.of(Levels.at(1)).tap(0);
      expect(play.next, ('out', 0));
      expect(Play.of(Levels.at(1)).next, ('in', 4));
    });

    test('the hopeless yard admits it at thirteen moves', () {
      var play = Play.of(Levels.at(4)).tap(4).tap(3).tap(2).tap(1).tap(0);
      expect(play.chainHolds, isTrue);
      expect(play.ringCloses, isFalse);
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap(0).tap(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.full, isTrue);
      expect(play.tap(0), same(play));
    });

    test('a winnable yard never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var dither = 0; dither < 7; dither++) {
        play = play.tap(1).tap(1);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands lined up', () {
      final mark = Play.standing(Levels.at(0), const [0, 3, 2, 1]);
      expect(mark.isDone, isTrue);
    });
  });
}
