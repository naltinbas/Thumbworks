import 'package:flutter_test/flutter_test.dart';
import 'package:foursworth/window/houses.dart';
import 'package:foursworth/window/play.dart';
import 'package:foursworth/window/rules.dart';

/// The law of the house, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final house in Houses.all) {
        expect(Rules.waysTo(house.count, house.asked), house.ways,
            reason: house.name);
      }
    });

    test('the laws hold over every dialling', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('a turn takes neighbour differences round the ring', () {
      expect(Rules.turn([0, 1, 3, 7]), [1, 2, 4, 7]);
      expect(Rules.turn([2, 2, 2, 2]), [0, 0, 0, 0]);
      expect(Rules.turn([0, 1, 1]), [1, 0, 1]);
    });

    test('the classic road runs seven turns whole', () {
      expect(Rules.turnsToDark([0, 1, 3, 7]), 7);
      expect(Rules.walk([0, 1, 3, 7]).last, [0, 0, 0, 0]);
    });

    test('threes circle unless all alike', () {
      expect(Rules.turnsToDark([5, 5, 5]), 1);
      expect(Rules.turnsToDark([0, 1, 1]), -1);
      expect(Rules.turnsToDark([1, 2, 3]), -1);
    });
  });

  group('the play', () {
    test('opens dark at nought, unsettled', () {
      for (final house in Houses.all) {
        final play = Play.of(house);
        expect(play.turns, 0, reason: house.name);
        expect(play.isDone, isFalse, reason: house.name);
        expect(play.isOver, isFalse, reason: house.name);
      }
    });

    test('a tap turns one face and wraps past seven', () {
      var play = Play.of(Houses.at(4));
      play = play.tapAt(0);
      expect(play.windows[0], 1);
      expect(play.moves, 1);
      for (var turn = 0; turn < 7; turn++) {
        play = play.tapAt(0);
      }
      expect(play.windows[0], 0);
      expect(play.moves, 8);
    });

    test('back takes back one tap', () {
      final play = Play.of(Houses.at(4)).tapAt(0).tapAt(2);
      expect(play.back.moves, 1);
      expect(play.back.windows[2], 0);
      expect(play.back.back.back, same(play.back.back));
    });

    test('all alike lands the one turn', () {
      var play = Play.of(Houses.at(0));
      for (var window = 0; window < 4; window++) {
        play = play.tapAt(window);
      }
      expect(play.windows, [1, 1, 1, 1]);
      expect(play.isDone, isTrue);
      expect(play.turns, 1);
      expect(play.tapAt(0), same(play));
    });

    test('the pointer dials the seven turns home', () {
      var play = Play.of(Houses.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 30) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.turns, 7);
    });

    test('the hopeless house admits it at fourteen taps', () {
      var play = Play.of(Houses.at(4));
      for (var dither = 0; dither < 14; dither++) {
        play = play.tapAt(dither % 3);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable house never gives up', () {
      // Dialling one window of the four alone walks counts the
      // asking never lands on.
      var play = Play.of(Houses.at(2));
      for (var dither = 0; dither < 14; dither++) {
        play = play.tapAt(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands on the classic road', () {
      final mark = Play.standing(Houses.at(2), const [0, 1, 3, 7]);
      expect(mark.isDone, isTrue);
      expect(mark.turns, 7);
    });
  });
}
