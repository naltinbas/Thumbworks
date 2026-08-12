import 'package:beamsworth/beam/play.dart';
import 'package:beamsworth/beam/rules.dart';
import 'package:beamsworth/beam/worths.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the yard, held to.
void main() {
  group('the rules', () {
    test('a balance is found and stripped of shared weights', () {
      final clash = Rules.balance([1, 2, 3]);
      expect(clash, isNotNull);
      final (left, right) = clash!;
      expect(left.fold(0, (a, b) => a + b),
          right.fold(0, (a, b) => a + b));
      expect(left.any(right.contains), isFalse);
    });

    test('a clean choice has no balance at all', () {
      expect(Rules.balance([1, 2, 4]), isNull);
      expect(Rules.balance([11, 17, 20, 22, 23, 24]), isNull);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final worth in Worths.all) {
        expect(Rules.waysTo(worth.choose), worth.ways,
            reason: worth.name);
      }
    });

    test('the one six is the built set', () {
      expect(Rules.choice(6), [11, 17, 20, 22, 23, 24]);
      expect(Rules.waysTo(6), 1);
      expect(Rules.choice(7), isNull);
    });

    test('seven weights never outgrow the counting', () {
      expect(Rules.heaviest(7), lessThanOrEqualTo(125));
    });
  });

  group('the play', () {
    test('taps choose and put back', () {
      var play = Play.of(Worths.at(0));
      play = play.tapAt(5);
      expect(play.chosen, [5]);
      expect(play.moves, 1);
      play = play.tapAt(5);
      expect(play.chosen, isEmpty);
      expect(play.moves, 2);
    });

    test('a full choice refuses another weight', () {
      var play = Play.of(Worths.at(0)).tapAt(1).tapAt(2).tapAt(3);
      expect(play.chosen, hasLength(3));
      expect(play.isDone, isFalse);
      expect(play.tapAt(20), same(play));
      expect(play.tapAt(1).chosen, [2, 3]);
    });

    test('a clean three lands', () {
      final play = Play.of(Worths.at(0)).tapAt(1).tapAt(2).tapAt(4);
      expect(play.balanced, isNull);
      expect(play.isDone, isTrue);
      expect(play.tapAt(8), same(play));
    });

    test('a balance blocks the landing', () {
      final play = Play.of(Worths.at(0)).tapAt(1).tapAt(2).tapAt(3);
      expect(play.balanced, isNotNull);
      expect(play.isDone, isFalse);
    });

    test('back takes back a choosing', () {
      var play = Play.of(Worths.at(0)).tapAt(5);
      expect(play.back.chosen, isEmpty);
      expect(play.back.moves, 0);
      expect(Play.of(Worths.at(0)).back.moves, 0);
    });

    test('show me weighs the yard home', () {
      var play = Play.of(Worths.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        expect(aim!.$2, isTrue);
        play = play.tapAt(aim.$1);
      }
      expect(play.isDone, isTrue);
      expect(play.chosen.toSet(), {11, 17, 20, 22, 23, 24});
    });

    test('show me puts a stray back first', () {
      final play = Play.of(Worths.at(3)).tapAt(1);
      final aim = play.next;
      expect(aim, isNotNull);
      expect(aim!.$1, 1);
      expect(aim.$2, isFalse);
    });

    test('the hopeless worth has nothing to point at', () {
      expect(Play.of(Worths.at(4)).next, isNull);
    });

    test('the hopeless worth admits it after fourteen choosings',
        () {
      var play = Play.of(Worths.at(4));
      for (var choosing = 0;
          choosing < Play.gaveUpAt;
          choosing++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable worth never gives up', () {
      var play = Play.of(Worths.at(1));
      for (var choosing = 0;
          choosing < Play.gaveUpAt;
          choosing++) {
        play = play.tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
