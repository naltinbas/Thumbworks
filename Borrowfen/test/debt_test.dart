import 'package:flutter_test/flutter_test.dart';
import 'package:borrowfen/debt/play.dart';
import 'package:borrowfen/debt/rules.dart';
import 'package:borrowfen/debt/villages.dart';

/// The law of the ledger, held to.
void main() {
  group('the rules', () {
    test('a lending sends a pound down every road', () {
      final lane = Rules(3, const [(0, 1), (1, 2)]);
      expect(lane.lend([-1, 2, -1], 1), [0, 0, 0]);
      expect(lane.lend([0, 0, 0], 0), [-1, 1, 0]);
    });

    test('a borrowing pulls a pound up every road', () {
      final lane = Rules(3, const [(0, 1), (1, 2)]);
      expect(lane.borrow([-1, 2, -1], 0), [0, 1, -1]);
    });

    test('every census matches its spanning trees', () {
      for (final village in Villages.all) {
        final rules = Rules(village.houses, village.roads);
        expect(
          rules.superstables().length,
          rules.spanningTrees(),
          reason: village.name,
        );
      }
    });

    test('the burning and the search agree on every level', () {
      for (final village in Villages.all) {
        final rules = Rules(village.houses, village.roads);
        final searched = rules.fewest(village.spread);
        expect(rules.winnable(village.spread), searched != null,
            reason: village.name);
        expect(searched, village.fewest, reason: village.name);
      }
    });

    test('the charity settles every class at its genus', () {
      final rules = Rules(4,
          const [(0, 1), (1, 2), (0, 2), (1, 3), (2, 3)]);
      expect(rules.genus, 2);
      expect(rules.spanningTrees(), 8);
      expect(rules.winnableClasses(2), 8);
      expect(rules.winnableClasses(1), 4);
      expect(rules.winnableClasses(0), 1);
    });

    test('the short pound is refused all three ways', () {
      final round = Rules(3, const [(0, 1), (1, 2), (0, 2)]);
      expect(round.spanningTrees(), 3);
      expect(round.winnableClasses(0), 1);
      expect(round.winnable([-1, 0, 1]), isFalse);
      expect(round.tidy([-1, 0, 1])[0], lessThan(0));
      expect(round.fewest([-1, 0, 1]), isNull);
    });

    test('the first move walks a fewest settlement', () {
      final long = Villages.at(3);
      final rules = Rules(long.houses, long.roads);
      var pounds = List.of(long.spread);
      var left = rules.fewest(pounds)!;
      expect(left, 6);
      while (left > 0) {
        final (house, lends) = rules.firstMove(pounds)!;
        pounds = lends
            ? rules.lend(pounds, house)
            : rules.borrow(pounds, house);
        left -= 1;
        expect(rules.fewest(pounds), left);
      }
      expect(rules.settled(pounds), isTrue);
    });
  });

  group('the play', () {
    test('the lane settles in one lending at the mill', () {
      final play = Play.of(Villages.at(0)).lendAt(1);
      expect(play.pounds, [0, 0, 0]);
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      // A settled village refuses further moves.
      expect(play.lendAt(0), same(play));
    });

    test('back takes back one move', () {
      final play = Play.of(Villages.at(1)).lendAt(2).borrowAt(0);
      expect(play.moves, 2);
      expect(play.back.moves, 1);
      expect(play.back.pounds, Play.of(Villages.at(1)).lendAt(2).pounds);
      expect(Play.of(Villages.at(0)).back.moves, 0);
    });

    test('show me points a move that shortens the settlement', () {
      final play = Play.of(Villages.at(1));
      final aim = play.next;
      expect(aim, isNotNull);
      final (house, lends) = aim!;
      final after = lends ? play.lendAt(house) : play.borrowAt(house);
      expect(after.rules.fewest(after.pounds),
          play.village.fewest! - 1);
    });

    test('the hopeless village has nothing to point at', () {
      expect(Play.of(Villages.at(4)).next, isNull);
    });

    test('the hopeless village admits it after twelve moves', () {
      var play = Play.of(Villages.at(4));
      for (var move = 0; move < Play.gaveUpAt; move++) {
        expect(play.gaveUp, isFalse);
        play = play.lendAt(move % 3);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable village never gives up', () {
      var play = Play.of(Villages.at(3));
      // Twelve moves that go nowhere: lend then borrow, over and
      // over, at the manor.
      for (var move = 0; move < 6; move++) {
        play = play.lendAt(0).borrowAt(0);
      }
      expect(play.moves, greaterThanOrEqualTo(Play.gaveUpAt));
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
