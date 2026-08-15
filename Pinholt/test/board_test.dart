import 'package:flutter_test/flutter_test.dart';
import 'package:pinholt/board/play.dart';
import 'package:pinholt/board/plots.dart';
import 'package:pinholt/board/rules.dart';

/// The law of the board, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      final rules = Rules(5);
      for (final plot in Plots.all) {
        final (ways, all) = rules.waysBySweep(plot.pins, plot.asked);
        expect(ways, plot.ways, reason: plot.name);
        expect(all, plot.placings, reason: plot.name);
      }
    });

    test('a frame is four pins all on their own fence', () {
      expect(Rules.isFrame([(0, 0), (4, 0), (4, 4), (0, 4)]), isTrue);
      expect(Rules.isFrame([(0, 0), (4, 0), (2, 4), (2, 1)]), isFalse);
      expect(Rules.fence([(0, 0), (4, 0), (2, 4), (2, 1), (2, 2)]), hasLength(3));
      expect(Rules.frames([(0, 0), (4, 0), (2, 4), (1, 1), (3, 1)]), hasLength(1));
      expect(Rules.frames([(0, 0), (4, 0), (4, 4), (0, 4), (2, 1)]), hasLength(3));
    });

    test('three in a line are caught', () {
      expect(Rules.anyThreeInLine([(0, 0), (1, 1), (2, 2)]), isTrue);
      expect(Rules.anyThreeInLine([(0, 0), (1, 1), (2, 3)]), isFalse);
      expect(Rules.linesUp([(0, 0), (2, 1)], (4, 2)), isTrue);
      expect(Rules.linesUp([(0, 0), (2, 1)], (4, 3)), isFalse);
    });

    test('the fence alone gives the frame count for four and five', () {
      final rules = Rules(5);
      var seen = 0;
      rules.placings(5, (pins) {
        seen++;
        expect(Rules.framesByFence(pins), Rules.frames(pins).length);
      });
      expect(seen, 25052);
      expect(Rules.framesByFence([(0, 0), (1, 0), (0, 1), (1, 1), (2, 2), (3, 4)]), isNull);
    });

    test('the lone frame is built for every fence of three', () {
      final rules = Rules(5);
      var threes = 0;
      rules.placings(5, (pins) {
        if (Rules.fence(pins).length != 3) return;
        threes++;
        final lone = Rules.lonelyFrame(pins)!;
        expect(Rules.isFrame(lone), isTrue);
        expect(Rules.frames(pins), hasLength(1));
      });
      expect(threes, 624);
    });

    test('five pins never go frameless, and hold 1, 3 or 5', () {
      final rules = Rules(5);
      final spread = <int, int>{};
      rules.placings(5, (pins) {
        final n = Rules.frames(pins).length;
        spread[n] = (spread[n] ?? 0) + 1;
      });
      expect(spread.keys.toList()..sort(), [1, 3, 5]);
      expect(spread[1], 624);
    });
  });

  group('the play', () {
    test('opens bare', () {
      for (final plot in Plots.all) {
        final play = Play.of(plot);
        expect(play.pins, isEmpty, reason: plot.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap sets a pin, a tap lifts it, counted both ways', () {
      var play = Play.of(Plots.at(0));
      play = play.tap((1, 1));
      expect(play.pins, [(1, 1)]);
      expect(play.moves, 1);
      play = play.tap((1, 1));
      expect(play.pins, isEmpty);
      expect(play.moves, 2);
      expect(play.back.pins, [(1, 1)]);
    });

    test('a third pin in a line is refused and shown', () {
      var play = Play.of(Plots.at(0)).tap((0, 0)).tap((1, 1));
      final refused = play.tap((2, 2));
      expect(refused.pins, [(0, 0), (1, 1)]);
      expect(refused.moves, 2);
      expect(refused.refused, (2, 2));
      play = refused.tap((2, 3));
      expect(play.refused, isNull);
      expect(play.pins, hasLength(3));
    });

    test('no more pins than the plot asks', () {
      final play = Play.of(Plots.at(0)).tap((0, 0)).tap((4, 0)).tap((4, 4)).tap((0, 4));
      expect(play.isDone, isTrue);
      expect(play.tap((2, 2)), same(play));
    });

    test('the framed four lands by hand, the tucked four too', () {
      final framed = Play.of(Plots.at(0)).tap((0, 0)).tap((4, 0)).tap((4, 4)).tap((0, 4));
      expect(framed.frames, hasLength(1));
      expect(framed.isDone, isTrue);
      final tucked = Play.of(Plots.at(1)).tap((0, 0)).tap((4, 0)).tap((2, 4)).tap((2, 1));
      expect(tucked.frames, isEmpty);
      expect(tucked.fence, hasLength(3));
      expect(tucked.isDone, isTrue);
    });

    test('the pointer lands the lone frame and the three frames', () {
      for (final number in [2, 3]) {
        var play = Play.of(Plots.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final (_, hole) = play.next!;
          play = play.tap(hole);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Plots.at(number).pins);
      }
    });

    test('the pointer lifts a pin off the placing first', () {
      final aim = Rules(5).landing(6, 3)!;
      final stray = [
        for (final hole in Rules(5).holes)
          if (!aim.contains(hole) && !Rules.linesUp([], hole)) hole,
      ].first;
      final play = Play.of(Plots.at(3)).tap(stray);
      expect(play.next, ('lift', stray));
    });

    test('the hopeless plot admits it at eleven moves', () {
      var play = Play.of(Plots.at(4));
      for (final hole in const [(0, 0), (4, 0), (2, 4), (1, 1), (3, 1)]) {
        play = play.tap(hole);
      }
      expect(play.moves, 5);
      expect(play.frames, hasLength(1));
      for (var dither = 0; dither < 3; dither++) {
        play = play.tap((3, 1)).tap((3, 1));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      expect(play.pins, hasLength(5));
    });

    test('a winnable plot never gives up', () {
      var play = Play.of(Plots.at(0));
      for (var dither = 0; dither < 6; dither++) {
        play = play.tap((1, 1)).tap((1, 1));
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands as the theorem builds it', () {
      final pins = [(0, 0), (4, 0), (2, 4), (1, 1), (3, 1)];
      expect(Rules.anyThreeInLine(pins), isFalse);
      expect(Rules.fence(pins), hasLength(3));
      expect(Rules.frames(pins), hasLength(1));
      final lone = Rules.lonelyFrame(pins)!;
      expect(lone.toSet(), {(1, 1), (3, 1), (0, 0), (4, 0)});
    });
  });
}
