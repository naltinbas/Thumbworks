import 'package:dealstone/deal/handfuls.dart';
import 'package:dealstone/deal/play.dart';
import 'package:dealstone/deal/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the deal, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final handful in Handfuls.all) {
        expect(Rules.waysTo(handful.stones, handful.asked),
            handful.ways,
            reason: handful.name);
      }
    });

    test('the laws hold over six, eight and ten', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('one deal pays a stone from each pile', () {
      expect(Rules.deal([4, 3, 2, 1]), [4, 3, 2, 1]);
      expect(Rules.deal([10]), [9, 1]);
      expect(Rules.deal([2, 2, 1, 1]), [4, 1, 1]);
    });

    test('the stairs and their counts', () {
      expect(Rules.stairOf(6), [3, 2, 1]);
      expect(Rules.stairOf(10), [4, 3, 2, 1]);
      expect(Rules.stairOf(8), isNull);
    });

    test('the long six is two-two-one-one alone', () {
      expect(Rules.dealsByWalk([2, 2, 1, 1]), 6);
      expect(Rules.waysTo(6, 6), 1);
    });

    test('no handful opens landed', () {
      for (final handful in Handfuls.all) {
        expect(
          Rules.dealsByWalk(handful.opens) == handful.asked,
          isFalse,
          reason: handful.name,
        );
      }
    });
  });

  group('the play', () {
    test('opens on its handful\'s piles, unsettled', () {
      for (final handful in Handfuls.all) {
        final play = Play.of(handful);
        expect(play.pool, 0, reason: handful.name);
        expect(play.isDone, isFalse, reason: handful.name);
        expect(play.isOver, isFalse, reason: handful.name);
      }
    });

    test('a sweep refills the pool and drops rebuild the hand', () {
      var play = Play.of(Handfuls.at(0));
      expect(play.piles, [6]);
      play = play.tapAt(0);
      expect(play.pool, 6);
      expect(play.piles, isEmpty);
      play = play.tapAt(0);
      expect(play.piles, [1]);
      expect(play.pool, 5);
      play = play.tapAt(0).tapAt(0);
      expect(play.piles, [3]);
      expect(play.moves, 4);
    });

    test('piles keep themselves sorted biggest first', () {
      var play = Play.of(Handfuls.at(0)).tapAt(0);
      // Drop, start a second pile, then grow whichever stands
      // second after each sort: the hand stays biggest-first.
      play = play.tapAt(0).tapAt(1).tapAt(1).tapAt(1);
      expect(play.piles, [2, 2]);
    });

    test('back takes back one move', () {
      final play = Play.of(Handfuls.at(0)).tapAt(0).tapAt(0);
      expect(play.back.pool, 6);
      expect(play.back.back.piles, [6]);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the stair of six lands by hand', () {
      var play = Play.of(Handfuls.at(0)).tapAt(0);
      for (var stone = 0; stone < 3; stone++) {
        play = play.tapAt(0);
      }
      play = play.tapAt(1).tapAt(1);
      play = play.tapAt(2);
      expect(play.piles, [3, 2, 1]);
      expect(play.isDone, isTrue);
      expect(play.deals, 0);
      expect(play.tapAt(0), same(play));
    });

    test('the pointer piles the twelve deals home', () {
      var play = Play.of(Handfuls.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 24) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.deals, 12);
      expect(play.piles.first, 3);
    });

    test('the hopeless handful admits it at nineteen moves', () {
      var play = Play.of(Handfuls.at(4));
      for (var dither = 0; dither < 19; dither++) {
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable handful never gives up', () {
      var play = Play.of(Handfuls.at(1));
      for (var dither = 0; dither < 19; dither++) {
        play = play.tapAt(0);
      }
      expect(play.moves, 19);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands dealt home', () {
      final mark =
          Play.standing(Handfuls.at(3), const [4, 3, 2, 1]);
      expect(mark.deals, 0);
      expect(mark.isDone, isFalse);
      expect(Rules.standsStill(mark.piles), isTrue);
    });
  });
}
