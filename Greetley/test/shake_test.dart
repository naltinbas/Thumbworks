import 'package:flutter_test/flutter_test.dart';
import 'package:greetley/shake/lawns.dart';
import 'package:greetley/shake/play.dart';
import 'package:greetley/shake/rules.dart';

/// The law of the lawn, held to.
void main() {
  group('the rules', () {
    test('hands count both ends of every shake', () {
      final rules = Rules(4);
      expect(rules.hands(const [(0, 1), (1, 2)]), [1, 2, 1, 0]);
      expect(rules.oddHanded(const [(0, 1), (1, 2)]), [0, 2]);
      expect(rules.oddHanded(const [(0, 1), (2, 3)]),
          [0, 1, 2, 3]);
    });

    test('the law holds over every lawn', () {
      for (final guests in [4, 5]) {
        expect(Rules(guests).lawHolds(), isTrue, reason: '$guests');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final fete in Lawns.all) {
        expect(Rules(fete.guests).waysTo(fete.asked), fete.ways,
            reason: fete.name);
      }
    });

    test('the spread of four runs eight, none, 48, none, eight', () {
      final four = Rules(4);
      expect(
        [for (final odd in [0, 1, 2, 3, 4]) four.waysTo(odd)],
        [8, 0, 48, 0, 8],
      );
    });

    test('the all-even lawns come to a power of two', () {
      for (final guests in [4, 5]) {
        final spare =
            guests * (guests - 1) ~/ 2 - (guests - 1);
        expect(Rules(guests).waysTo(0), 1 << spare,
            reason: '$guests');
      }
    });

    test('a busy lawn lands what it promises', () {
      final found = Rules(5).busyLawn(0)!;
      expect(found, isNotEmpty);
      expect(Rules(5).oddHanded(found), isEmpty);
      expect(Rules(4).busyLawn(1), isNull);
    });
  });

  group('the play', () {
    test('two picks make a shake', () {
      var play = Play.of(Lawns.at(0));
      play = play.tapAt(0);
      expect(play.picked, 0);
      play = play.tapAt(1);
      expect(play.shakes, [(0, 1)]);
      expect(play.moves, 1);
    });

    test('the same two guests unshake', () {
      // On the quiet lawn one shake lands nothing, so the taps
      // stay live.
      var play = Play.of(Lawns.at(1)).tapAt(0).tapAt(1);
      play = play.tapAt(1).tapAt(0);
      expect(play.shakes, isEmpty);
      expect(play.moves, 2);
    });

    test('one shake lands the two odd', () {
      final play = Play.of(Lawns.at(0)).tapAt(0).tapAt(1);
      expect(play.oddHanded, [0, 1]);
      expect(play.isDone, isTrue);
      expect(play.tapAt(2), same(play));
    });

    test('the empty lawn does not land the quiet lawn', () {
      final play = Play.of(Lawns.at(1));
      expect(play.oddHanded, isEmpty);
      expect(play.isDone, isFalse);
      // A triangle of shakes does.
      final round = play
          .tapAt(0)
          .tapAt(1)
          .tapAt(1)
          .tapAt(2)
          .tapAt(2)
          .tapAt(0);
      expect(round.oddHanded, isEmpty);
      expect(round.isDone, isTrue);
    });

    test('back takes back the last greeting', () {
      var play = Play.of(Lawns.at(1)).tapAt(0).tapAt(1);
      play = play.tapAt(1).tapAt(2);
      expect(play.moves, 2);
      expect(play.back.shakes, [(0, 1)]);
      expect(play.back.moves, 1);
    });

    test('show me shakes a real lawn home', () {
      var play = Play.of(Lawns.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final ((a, b), wants) = aim!;
        expect(wants, isTrue);
        play = play.tapAt(a).tapAt(b);
      }
      expect(play.isDone, isTrue);
      expect(play.oddHanded, isEmpty);
    });

    test('the hopeless lawn has nothing to point at', () {
      expect(Play.of(Lawns.at(4)).next, isNull);
    });

    test('the hopeless lawn admits it after twelve greetings', () {
      var play = Play.of(Lawns.at(4));
      for (var round = 0; round < 6; round++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable lawn never gives up', () {
      var play = Play.of(Lawns.at(1));
      for (var round = 0; round < 6; round++) {
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
