import 'package:flutter_test/flutter_test.dart';
import 'package:brackenside/hill/hills.dart';
import 'package:brackenside/hill/play.dart';
import 'package:brackenside/hill/rules.dart';

/// The law of the hillside, held to.
void main() {
  group('the rules', () {
    test('the hill counts its spots and patches', () {
      final rules = Rules(3);
      expect(rules.spots, hasLength(10));
      expect(rules.patches3, hasLength(9));
      expect(rules.inner, hasLength(1));
      expect(rules.rim, hasLength(9));
    });

    test('the rim walk finds exactly one bracken-gorse edge', () {
      for (final side in [3, 4, 5]) {
        expect(Rules(side).rimEdges(), 1, reason: '$side');
      }
    });

    test('the law holds over every sweep', () {
      for (final side in [3, 4, 5]) {
        expect(Rules(side).lawHolds(), isTrue, reason: '$side');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final hill in Hills.all) {
        expect(Rules(hill.side).waysTo(hill.asked), hill.ways,
            reason: hill.name);
      }
    });

    test('the odd ladder climbs without an even step', () {
      expect(Rules(5).spread().keys.toList()..sort(),
          [1, 3, 5, 7, 9, 11]);
      expect(Rules(4).spread().keys.toList()..sort(), [1, 3, 5]);
      expect(Rules(5).spread()[11], 1);
    });

    test('a planting lands what it promises', () {
      final planted = Rules(5).planting(11)!;
      expect(Rules(5).census(planted), 11);
      expect(Rules(4).planting(2), isNull);
    });
  });

  group('the play', () {
    test('the hill opens all bracken inside, one patch showing', () {
      final play = Play.of(Hills.at(1));
      for (final spot in play.rules.inner) {
        expect(play.planted[spot], 'A');
      }
      // All-bracken inside on the side-4 hill shows one patch,
      // which is the fewest the law allows.
      expect(play.patches, 1);
      expect(play.isDone, isFalse);
    });

    test('taps swap a spot round the three plants', () {
      // The side-4 hill opens all bracken and unlanded, so its
      // spots swap freely.
      var play = Play.of(Hills.at(1));
      final spot = play.rules.inner.first;
      play = play.tapAt(spot);
      expect(play.planted[spot], 'B');
      expect(play.moves, 1);
      play = play.tapAt(spot).tapAt(spot);
      expect(play.planted[spot], 'A');
      expect(play.moves, 3);
    });

    test('the rim never replants', () {
      final play = Play.of(Hills.at(0));
      expect(play.canPlant((0, 0)), isFalse);
      expect(play.tapAt((0, 0)), same(play));
    });

    test('the first patch opens at three and lands at one', () {
      var play = Play.of(Hills.at(0));
      final spot = play.rules.inner.single;
      // The all-gorse opening shows three patches; one swap
      // brings it to one.
      expect(play.planted[spot], 'B');
      expect(play.patches, 3);
      play = play.tapAt(spot);
      expect(play.patches, 1);
      expect(play.isDone, isTrue);
      expect(play.tapAt(spot), same(play));
    });

    test('back takes back a replanting', () {
      var play = Play.of(Hills.at(1));
      final spot = play.rules.inner.first;
      play = play.tapAt(spot);
      expect(play.moves, 1);
      expect(play.back.moves, 0);
      expect(play.back.planted[spot], 'A');
      expect(Play.of(Hills.at(1)).back.moves, 0);
    });

    test('show me points a spot off a landing planting', () {
      final play = Play.of(Hills.at(3));
      final aim = play.next;
      expect(aim, isNotNull);
      final (spot, plant) = aim!;
      expect(play.planted[spot], isNot(plant));
      expect(play.rules.planting(11)![spot], plant);
    });

    test('the hopeless hill has nothing to point at', () {
      expect(Play.of(Hills.at(4)).next, isNull);
    });

    test('the hopeless hill admits it after twelve replantings', () {
      var play = Play.of(Hills.at(4));
      final spot = play.rules.inner.first;
      for (var replant = 0; replant < Play.gaveUpAt; replant++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(spot);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable hill never gives up', () {
      var play = Play.of(Hills.at(2));
      final spot = play.rules.inner.first;
      for (var replant = 0; replant < Play.gaveUpAt; replant++) {
        play = play.tapAt(spot);
      }
      expect(play.moves, greaterThanOrEqualTo(Play.gaveUpAt));
      expect(play.gaveUp, isFalse);
    });
  });
}
