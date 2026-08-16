import 'package:flutter_test/flutter_test.dart';
import 'package:ropeford/ford/levels.dart';
import 'package:ropeford/ford/play.dart';
import 'package:ropeford/ford/rules.dart';

/// The stones, the rope, the asks and the crossing, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the ford', () {
    test('the sieve and trial division say the same of every stone', () {
      for (var k = 0; k <= Rules.stones; k++) {
        expect(Rules.dry(k), Rules.dryByTrial(k) && k >= 1, reason: '$k');
      }
      expect(Rules.dryStones, hasLength(30));
      expect(Rules.dryStones.take(6), [2, 3, 5, 7, 11, 13]);
      expect(Rules.dryStones.last, 113);
      expect(Rules.dry(1), isFalse);
      expect(Rules.dry(121), isFalse);
      expect(Rules.mossy(91), isTrue);
      expect(Rules.factorOf(91), 7);
      expect(Rules.tellMoss(91), 'stone 91 is 7 times 13');
      expect(Rules.tellMoss(96), 'stone 96 is even');
      expect(Rules.tellMoss(1), 'stone 1 is the near bank');
    });

    test('the rope reaches double, and covers dry stones every time', () {
      expect(Rules.ropeEnd(23), 46);
      expect(Rules.inReach(23), [29, 31, 37, 41, 43]);
      expect(Rules.inReach(2), [3]);
      expect(Rules.inReach(113), isEmpty);
      expect(Rules.farthest(23), 43);
      expect(Rules.farthest(113), isNull);
      expect(Rules.canHop(23, 29), isTrue);
      expect(Rules.canHop(23, 47), isFalse);
      expect(Rules.canHop(23, 33), isFalse);
      expect(Rules.canHop(23, 19), isFalse);
      for (var n = 1; n < Rules.stones; n++) {
        // Bertrand's promise, on every stone whose rope stays on the ford.
        if (Rules.ropeEnd(n) > Rules.stones) continue;
        expect(Rules.inReach(n), isNotEmpty, reason: 'stone $n');
      }
    });

    test('the greedy crossing and the walk agree on the fewest hops', () {
      expect(Rules.chain, [2, 3, 5, 7, 13, 23, 43, 83, 113]);
      expect(Rules.hops, hasLength(Rules.dryStones.length));
      expect(Rules.hops[3], 1);
      expect(Rules.hops[13], 4);
      expect(Rules.hops[83], 7);
      expect(Rules.hops[89], 8);
      for (final stone in Rules.dryStones) {
        final d = Rules.hops[stone]!;
        // The stones reached in d hops or fewer are exactly the dry ones
        // up to where the greedy chain stands after d hops.
        expect(stone, lessThanOrEqualTo(Rules.chain[d]), reason: '$stone');
        if (d > 0) expect(stone, greaterThan(Rules.chain[d - 1]), reason: '$stone');
      }
    });

    test('the long shallows, and the lonely stones', () {
      for (var k = Rules.shallowsFrom; k <= Rules.shallowsTo; k++) {
        expect(Rules.mossy(k), isTrue, reason: '$k');
      }
      expect(Rules.dry(89), isTrue);
      expect(Rules.dry(97), isTrue);
      expect(Rules.coversShallows(89), isTrue);
      expect(Rules.coversShallows(53), isTrue);
      expect(Rules.coversShallows(47), isFalse);
      expect(Rules.coversShallows(97), isFalse);
      expect([for (final p in Rules.dryStones) if (Rules.lonely(p)) p], [53, 89]);
      expect([for (final p in Rules.dryStones) if (Rules.upperTwin(p)) p],
          [5, 7, 13, 19, 31, 43, 61, 73, 103, 109]);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Long Shallows']);
      for (final level in Levels.all) {
        var n = 0;
        for (var k = 1; k <= Rules.stones; k++) {
          if (level.meets(k)) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull, reason: level.name);
      }
      expect(Levels.at(0).aim, 101);
      expect(Levels.at(1).aim, 5);
      expect(Levels.at(2).aim, 61);
      expect(Levels.at(3).aim, 53);
      expect(Levels.all.map((l) => l.fewest), [8, 2, 7, 7, null]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'cross to a dry stone past the hundredth');
      expect(Levels.at(2).task,
          'cross to a dry stone whose rope reaches past the ford\'s last');
      expect(Levels.at(4).task,
          'cross to a stone between the eighty-ninth and the ninety-seventh');
    });

    test('a mossy stone lands nothing, whatever the ask', () {
      for (final level in Levels.all) {
        for (var k = 1; k <= Rules.stones; k++) {
          if (!Rules.dry(k)) expect(level.meets(k), isFalse, reason: '$k');
        }
      }
    });
  });

  group('the crossing', () {
    test('opens on the first dry stone', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.at, 2);
        expect((play.moves, play.stones.length, play.rope), (0, 1, 4));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a hop needs a dry stone under the rope, and says why not', () {
      var play = Play.of(Levels.at(0));
      expect(play.hop(3).at, 3);
      expect(play.hop(5), same(play));
      expect(play.refusal(5), 'the rope from stone 2 reaches only as far as 4');
      expect(play.refusal(4), 'stone 4 is even, and mossy');
      expect(play.refusal(2), 'you are standing on stone 2');
      expect(play.refusal(121), 'that is off the ford');
      play = play.hop(3).hop(5).hop(7);
      expect(play.refusal(6), 'the crossing goes on, not back');
      expect(play.stones, [2, 3, 5, 7]);
      expect(play.moves, 3);
      expect(play.inReach, [11, 13]);
      expect(play.stuck, isFalse);
      final fresh = Play.of(Levels.at(0));
      expect(fresh.hop(13), same(fresh));
    });

    test('back undoes one hop', () {
      final play = Play.of(Levels.at(0)).hop(3).hop(5);
      expect(play.back.at, 3);
      expect(play.back.back.at, 2);
      expect(play.back.back.back.at, 2);
      expect(play.back.moves, 1);
    });

    test('the pointer names the next stone, and the crossing lands', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final stone = play.next;
          expect(stone, isNotNull, reason: level.name);
          play = play.hop(stone!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
      expect(Play.pointed(29), 'Hop to stone 29.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the ford runs out at its last dry stone', () {
      var play = Play.standing(Levels.at(0), const [113]);
      expect(play.stuck, isTrue);
      expect(play.rope, 226);
      expect(play.inReach, isEmpty);
      play = Play.standing(Levels.at(2), const [61]);
      expect(play.isDone, isTrue);
      expect(play.rope, 122);
    });

    test('the shallows admit it after three ropes over them, or sixteen hops',
        () {
      var play = Play.of(Levels.at(4));
      for (final stone in [3, 5, 7, 13, 23, 43, 83]) {
        play = play.hop(stone);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, {83});
      play = play.hop(89);
      expect(play.seen, {83, 89});
      expect(play.gaveUp, isFalse);
      expect(play.hop(97).seen, {83, 89});
      var wander = Play.of(Levels.at(4));
      for (final stone in [3, 5, 7, 13, 23, 43, 53, 59, 61]) {
        wander = wander.hop(stone);
      }
      expect(wander.seen, {53, 59, 61});
      expect(wander.gaveUp, isTrue);
      expect(wander.isOver, isTrue);
      expect(wander.hop(67), same(wander));
      var far = Play.of(Levels.at(4));
      for (var k = 0; k < 20 && !far.gaveUp; k++) {
        final on = far.inReach;
        far = far.hop(on.isEmpty ? far.at : on.first);
        if (far.stuck) far = far.back;
      }
      expect(far.gaveUp, isTrue);
    });

    test('the why tells Bertrand and the chain', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Bertrand'));
      expect(words, contains('2, 3, 5, 7, 13, 23, 43, 83, 113'));
      expect(words, contains('This is ask 5, The Long Shallows.'));
      expect(words, contains('Chebyshev'));
    });
  });
}
