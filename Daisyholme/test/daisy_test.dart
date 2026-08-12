import 'package:daisyholme/daisy/circles.dart';
import 'package:daisyholme/daisy/play.dart';
import 'package:daisyholme/daisy/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the circle, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final circle in Circles.all) {
        final rules = Rules(circle.people);
        final given = {
          for (final pair in circle.given)
            rules.pairs.indexOf(pair),
        };
        expect(
          rules.waysBySweep(given: given.isEmpty ? null : given),
          circle.ways,
          reason: circle.name,
        );
      }
    });

    test('the sweep and the daisy count agree', () {
      for (final people in [3, 4, 5]) {
        final rules = Rules(people);
        expect(rules.waysBySweep(), rules.waysByDaisies(),
            reason: '$people');
      }
      expect(Rules(7).waysByDaisies(), 105);
    });

    test('the laws hold on every landing', () {
      expect(Rules(3).lawsHold(), isTrue);
      expect(Rules(4).lawsHold(), isTrue);
      expect(Rules(5).lawsHold(), isTrue);
    });

    test('commons read the wiring, pair by pair', () {
      final rules = Rules(3);
      // The triangle: every pair's common friend is the third.
      expect(rules.commons([true, true, true]), [1, 1, 1]);
      expect(rules.lands([true, true, true]), isTrue);
      expect(rules.lands([true, true, false]), isFalse);
    });

    test('the built daisy lands at every shipped size', () {
      for (final people in [3, 5, 7]) {
        final rules = Rules(people);
        expect(rules.lands(rules.daisy()), isTrue,
            reason: '$people');
        expect(rules.friendsPairOff(rules.daisy()), isTrue);
      }
    });
  });

  group('the play', () {
    test('opens on the givens alone, unsettled', () {
      for (final circle in Circles.all) {
        final play = Play.of(circle);
        expect(
          play.wired.where((wire) => wire).length,
          circle.given.length,
          reason: circle.name,
        );
        expect(play.isDone, isFalse, reason: circle.name);
      }
    });

    test('a tap befriends and a second parts, counted gross', () {
      var play = Play.of(Circles.at(4));
      play = play.flipAt(0);
      expect(play.wired[0], isTrue);
      expect(play.moves, 1);
      play = play.flipAt(0);
      expect(play.wired[0], isFalse);
      expect(play.moves, 2);
    });

    test('a given friendship refuses the tap', () {
      final play = Play.of(Circles.at(1));
      expect(play.turns(0), isFalse);
      expect(play.flipAt(0), same(play));
    });

    test('back takes back one move', () {
      final play = Play.of(Circles.at(4)).flipAt(1).flipAt(3);
      expect(play.back.moves, 1);
      expect(play.back.wired[3], isFalse);
      expect(play.back.back.back, same(play.back.back));
    });

    test('three wires settle the three friends', () {
      var play = Play.of(Circles.at(0));
      play = play.flipAt(0).flipAt(1).flipAt(2);
      expect(play.isDone, isTrue);
      expect(play.moves, 3);
      expect(play.flipAt(0), same(play));
    });

    test('the pointer settles the given hub in two moves', () {
      var play = Play.of(Circles.at(1));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        play = play.flipAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
    });

    test('the pointer parts a stray wire first', () {
      // Wire two petal-people to a third: the nearest daisy
      // does without one of those wires.
      var play = Play.of(Circles.at(2));
      play = play.flipAt(play.rules.pairs.indexOf((1, 2)));
      expect(play.isDone, isFalse);
      final pointed = play.next;
      expect(pointed, isNotNull);
    });

    test('the hopeless circle admits it at twelve moves', () {
      var play = Play.of(Circles.at(4));
      for (var dither = 0; dither < 12; dither++) {
        play = play.flipAt(dither % 3);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable circle never gives up', () {
      var play = Play.of(Circles.at(2));
      for (var dither = 0; dither < 12; dither++) {
        play = play.flipAt(dither % 3);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands settled', () {
      final mark = Play.standing(Circles.at(3), Rules(7).daisy());
      expect(mark.isDone, isTrue);
      expect(mark.settled, mark.rules.pairs.length);
    });
  });
}
