import 'package:flutter_test/flutter_test.dart';
import 'package:slicebury/slice/cakes.dart';
import 'package:slicebury/slice/play.dart';
import 'package:slicebury/slice/rules.dart';

/// The law of the cake, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final cake in Cakes.all) {
        expect(
          Rules.waysTo(cake.candles, cake.slices),
          cake.ways,
          reason: cake.name,
        );
      }
    });

    test('both counts and the formula hold over the sweep', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('the doubling holds at every pick below six', () {
      expect(Rules.waysTo(3, 4), 220);
      expect(Rules.waysTo(4, 8), 495);
      expect(Rules.waysTo(5, 16), 792);
    });

    test('six candles cut thirty-one or thirty, nothing else', () {
      expect(Rules.waysTo(6, 31), 856);
      expect(Rules.waysTo(6, 30), 68);
      expect(Rules.waysTo(6, 32), 0);
    });

    test('the even hexagon clumps three lines through the middle',
        () {
      final through = Rules.crossings([0, 2, 4, 6, 8, 10]);
      expect(through.values.where((lines) => lines == 3),
          hasLength(1));
      expect(Rules.slicesByEuler([0, 2, 4, 6, 8, 10]), 30);
      expect(Rules.slicesByCuts([0, 2, 4, 6, 8, 10]), 30);
    });

    test('the counts agree on a spread pick too', () {
      expect(Rules.slicesByEuler([0, 2, 4, 5, 8, 9]), 31);
      expect(Rules.slicesByCuts([0, 2, 4, 5, 8, 9]), 31);
      expect(Rules.byFormula(6), 31);
    });
  });

  group('the play', () {
    test('opens bare on one slice, unsettled', () {
      for (final cake in Cakes.all) {
        final play = Play.of(cake);
        expect(play.picked, isEmpty, reason: cake.name);
        expect(play.slices, 1, reason: cake.name);
        expect(play.isDone, isFalse, reason: cake.name);
      }
    });

    test('a tap sets and a second lifts, counted gross', () {
      var play = Play.of(Cakes.at(4));
      play = play.tapAt(3);
      expect(play.picked, [3]);
      expect(play.moves, 1);
      play = play.tapAt(3);
      expect(play.picked, isEmpty);
      expect(play.moves, 2);
    });

    test('a candle past the cap is refused', () {
      var play = Play.of(Cakes.at(0));
      for (final spot in [0, 3, 6, 9]) {
        play = play.tapAt(spot);
      }
      expect(play.isDone, isTrue);
      // The eight lands however four stand; the play freezes.
      expect(play.tapAt(1), same(play));
    });

    test('the cap refuses a seventh on the six-candle cakes', () {
      var play = Play.of(Cakes.at(4));
      for (final spot in [0, 1, 2, 3, 4, 6]) {
        play = play.tapAt(spot);
      }
      expect(play.picked, hasLength(6));
      final held = play;
      play = play.tapAt(8);
      expect(play, same(held));
    });

    test('back takes back one move', () {
      final play = Play.of(Cakes.at(4)).tapAt(0).tapAt(5);
      expect(play.back.moves, 1);
      expect(play.back.picked, [0]);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the pointer cuts the thirty-one', () {
      var play = Play.of(Cakes.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.slices, 31);
      expect(play.moves, 6);
    });

    test('the pointer cuts the thirty through the clump', () {
      var play = Play.of(Cakes.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.slices, 30);
    });

    test('the hopeless cake admits it at sixteen moves', () {
      var play = Play.of(Cakes.at(4));
      for (var dither = 0; dither < 16; dither++) {
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable cake never gives up', () {
      var play = Play.of(Cakes.at(2));
      for (var dither = 0; dither < 16; dither++) {
        play = play.tapAt(0);
      }
      expect(play.moves, 16);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands cut true', () {
      final mark = Play.standing(Cakes.at(2), const [0, 2, 4, 5, 8, 9]);
      expect(mark.isDone, isTrue);
      expect(mark.slices, 31);
    });
  });
}
