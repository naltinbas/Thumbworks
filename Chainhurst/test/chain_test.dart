import 'package:flutter_test/flutter_test.dart';
import 'package:chainhurst/chain/fields.dart';
import 'package:chainhurst/chain/play.dart';
import 'package:chainhurst/chain/rules.dart';

/// The law of the field, held to.
void main() {
  group('the rules', () {
    test('chains string every stone on a line', () {
      // A row of three and one stone off it: one laden chain and
      // three bare ones.
      const stones = [(0, 0), (1, 0), (2, 0), (1, 2)];
      final chains = Rules.chains(stones);
      expect(chains, hasLength(4));
      expect(chains.where((c) => c.length == 3), hasLength(1));
      expect(Rules.bareByChains(stones), 3);
      expect(Rules.bareByThirds(stones), 3);
    });

    test('a slant row is one chain too', () {
      const stones = [(0, 0), (1, 1), (2, 2)];
      expect(Rules.chains(stones), hasLength(1));
      expect(Rules.allInOneRow(stones), isTrue);
      // A steep slant: knight-step spacing still shares a line.
      const steep = [(0, 0), (1, 2), (2, 4)];
      expect(Rules.chains(steep), hasLength(1));
      expect(Rules.allInOneRow(steep), isTrue);
    });

    test('the two counts agree over the whole sweep', () {
      for (final count in [3, 4, 5]) {
        expect(Rules.lawHolds(count), isTrue, reason: '$count');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final field in Fields.all) {
        expect(
          Rules.waysTo(field.stones, field.asked,
              inRow: field.offRow ? false : null),
          field.ways,
          reason: field.name,
        );
      }
    });

    test('four stones only ever show nought, three or six', () {
      for (final bare in [1, 2, 4, 5]) {
        expect(Rules.waysTo(4, bare), 0, reason: '$bare');
      }
    });

    test('five stones off one row never go under four bare', () {
      for (final bare in [0, 1, 2, 3]) {
        expect(Rules.waysTo(5, bare, inRow: false), 0,
            reason: '$bare');
      }
      expect(Rules.waysTo(5, 0, inRow: true), 12);
    });
  });

  group('the play', () {
    test('taps set stones, tap again lifts them', () {
      var play = Play.of(Fields.at(0)).tapAt((1, 1));
      expect(play.stones, [(1, 1)]);
      expect(play.moves, 1);
      play = play.tapAt((1, 1));
      expect(play.stones, isEmpty);
      expect(play.moves, 2);
    });

    test('a full field refuses another stone', () {
      final play = Play.of(Fields.at(0))
          .tapAt((0, 0))
          .tapAt((1, 1))
          .tapAt((2, 3));
      expect(play.allSet, isTrue);
      expect(play.tapAt((4, 4)), same(play));
      // Lifting still works.
      expect(play.tapAt((0, 0)).stones, hasLength(2));
    });

    test('the one chain lands on any row of three', () {
      final play = Play.of(Fields.at(0))
          .tapAt((0, 0))
          .tapAt((1, 1))
          .tapAt((2, 2));
      expect(play.bare, 0);
      expect(play.laden, 1);
      expect(play.isDone, isTrue);
      expect(play.tapAt((3, 3)), same(play));
    });

    test('the row bar holds the fewest of five open', () {
      final play = Play.standing(
          Fields.at(3), const [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]);
      expect(play.rowBarred, isTrue);
      expect(play.isDone, isFalse);
    });

    test('the mark\'s placing lands the fewest of five', () {
      final play = Play.standing(
          Fields.at(3), const [(0, 2), (1, 2), (2, 2), (3, 2), (2, 0)]);
      expect(play.bare, 4);
      expect(play.laden, 1);
      expect(play.isDone, isTrue);
    });

    test('back takes back one touch', () {
      final play = Play.of(Fields.at(0)).tapAt((0, 0)).tapAt((1, 1));
      expect(play.back.stones, [(0, 0)]);
      expect(play.back.moves, 1);
      expect(Play.of(Fields.at(0)).back.moves, 0);
    });

    test('show me walks to a landing', () {
      var play = Play.of(Fields.at(0));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        play = play.tapAt(aim!);
      }
      expect(play.isDone, isTrue);
    });

    test('show me lifts a stray stone first', () {
      // Three stones already down, not in a row: something must
      // come up before the landing.
      final play = Play.of(Fields.at(0))
          .tapAt((0, 0))
          .tapAt((1, 2))
          .tapAt((4, 1));
      final aim = play.next;
      expect(aim, isNotNull);
      expect(play.stones, contains(aim));
    });

    test('the hopeless field has nothing to point at', () {
      expect(Play.of(Fields.at(4)).next, isNull);
    });

    test('the hopeless field admits it after sixteen touches', () {
      var play = Play.of(Fields.at(4));
      // Five stones down, not in a row, then shuffle one corner
      // stone back and forth.
      for (final spot in const [(0, 0), (1, 0), (2, 0), (3, 0), (0, 1)]) {
        play = play.tapAt(spot);
      }
      expect(play.bare, greaterThan(0));
      // A full field refuses a sixth stone, so the shuffle must
      // lift and reset one that is down.
      while (play.moves < Play.gaveUpAt) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt((0, 1));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable field never gives up', () {
      // Sixteen touches of dithering on one crossing, and the
      // field stays open: giving up is for the hopeless only.
      var play = Play.of(Fields.at(0));
      for (var touch = 0; touch < Play.gaveUpAt; touch++) {
        play = play.tapAt((0, 0));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
