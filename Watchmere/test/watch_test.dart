import 'package:flutter_test/flutter_test.dart';
import 'package:watchmere/watch/meres.dart';
import 'package:watchmere/watch/play.dart';
import 'package:watchmere/watch/rules.dart';

/// The law of the night, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final mere in Meres.all) {
        expect(
          Rules(mere.lengths)
              .waysTo(mere.pairs, common: mere.common),
          mere.ways,
          reason: mere.name,
        );
      }
    });

    test('Helly holds over every dialling of both walls', () {
      expect(Rules([4, 4, 4]).lawHolds(), isTrue);
      expect(Rules([6, 5, 4, 3]).lawHolds(), isTrue);
    });

    test('the counts split as pinned', () {
      final three = Rules([4, 4, 4]);
      expect(three.waysTo(3), 249);
      expect(three.waysTo(3, common: 1), 108);
      expect(three.waysTo(2, common: 0), 156);
      expect(three.waysTo(3, common: 0), 0);
    });

    test('overlap and the common hours read one dialling', () {
      final rules = Rules([4, 4, 4]);
      expect(rules.pairsOverlapping([0, 2, 3]), 3);
      expect(rules.commonHours([0, 2, 3]), (3, 3));
      expect(rules.pairsOverlapping([0, 4, 8]), 0);
      expect(rules.commonHours([0, 4, 8]), isNull);
    });

    test('no mere opens landed', () {
      for (final mere in Meres.all) {
        final rules = Rules(mere.lengths);
        final pairs = rules.pairsOverlapping(mere.opens);
        expect(pairs == mere.pairs, isFalse, reason: mere.name);
      }
    });
  });

  group('the play', () {
    test('opens spread and unsettled on every mere', () {
      for (final mere in Meres.all) {
        final play = Play.of(mere);
        expect(play.starts, mere.opens, reason: mere.name);
        expect(play.isDone, isFalse, reason: mere.name);
        expect(play.isOver, isFalse, reason: mere.name);
      }
    });

    test('a slide moves one hour and clamps at the wall', () {
      var play = Play.of(Meres.at(0));
      expect(play.slideAt(0, -1), same(play));
      play = play.slideAt(0, 1);
      expect(play.starts[0], 1);
      expect(play.moves, 1);
      for (var push = 0; push < 12; push++) {
        play = play.slideAt(0, 1);
      }
      expect(play.starts[0], 8);
    });

    test('back takes back one slide', () {
      final play = Play.of(Meres.at(0)).slideAt(0, 1).slideAt(1, -1);
      expect(play.back.moves, 1);
      expect(play.back.starts[1], 4);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the pinch lands at nought, two and three', () {
      var play = Play.of(Meres.at(1));
      play = play.slideAt(1, -1).slideAt(1, -1);
      play = play
          .slideAt(2, -1)
          .slideAt(2, -1)
          .slideAt(2, -1)
          .slideAt(2, -1)
          .slideAt(2, -1);
      expect(play.starts, [0, 2, 3]);
      expect(play.isDone, isTrue);
      expect(play.commonWidth, 1);
      expect(play.slideAt(0, 1), same(play));
    });

    test('the pointer dials the four watches home', () {
      var play = Play.of(Meres.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 24) {
        final (watch, later) = play.next!;
        play = play.slideAt(watch, later ? 1 : -1);
      }
      expect(play.isDone, isTrue);
      expect(play.pairs, 6);
    });

    test('the hopeless mere admits it at sixteen slides', () {
      var play = Play.of(Meres.at(4));
      for (var dither = 0; dither < 8; dither++) {
        play = play.slideAt(0, 1).slideAt(0, -1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable mere never gives up', () {
      var play = Play.of(Meres.at(0));
      for (var dither = 0; dither < 8; dither++) {
        play = play.slideAt(0, 1).slideAt(0, -1);
      }
      expect(play.moves, 16);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands dialled home', () {
      final mark = Play.standing(Meres.at(1), const [0, 2, 3]);
      expect(mark.isDone, isTrue);
      expect(mark.commonWidth, 1);
    });
  });
}
