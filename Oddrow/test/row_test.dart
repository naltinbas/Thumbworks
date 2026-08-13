import 'package:flutter_test/flutter_test.dart';
import 'package:oddrow/row/askings.dart';
import 'package:oddrow/row/play.dart';
import 'package:oddrow/row/rules.dart';

/// The law of the wall, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the wall holds', () {
      for (final asking in Askings.all) {
        expect(Rules.waysTo(asking.odds), asking.ways,
            reason: asking.name);
      }
    });

    test('the three counts agree on every row', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('the rows behind the notes stand pinned', () {
      expect(Rules.rowsWith(2), [1, 2, 4, 8]);
      expect(Rules.rowsWith(4), [3, 5, 6, 9, 10, 12]);
      expect(Rules.rowsWith(8), [7, 11, 13, 14]);
      expect(Rules.rowsWith(16), [15]);
      expect(Rules.rowsWith(3), isEmpty);
    });

    test('a row reads as Pascal wrote it', () {
      expect(Rules.row(4), [1, 4, 6, 4, 1]);
      expect(Rules.oddPlaces(4), [0, 4]);
      expect(Rules.oddPlaces(3), [0, 1, 2, 3]);
    });
  });

  group('the play', () {
    test('opens at row nought, unsettled', () {
      for (final asking in Askings.all) {
        final play = Play.of(asking);
        expect(play.at, 0, reason: asking.name);
        expect(play.isDone, isFalse, reason: asking.name);
        expect(play.isOver, isFalse, reason: asking.name);
      }
    });

    test('the wind climbs and clamps, counted gross', () {
      var play = Play.of(Askings.at(4));
      expect(play.windBy(-1), same(play));
      play = play.windBy(1).windBy(1);
      expect(play.at, 2);
      expect(play.moves, 2);
      // The top clamps too, checked from a standing play.
      final topmost = Play.standing(Askings.at(4), Rules.top);
      expect(topmost.windBy(1), same(topmost));
    });

    test('back takes back one wind', () {
      final play = Play.of(Askings.at(4)).windBy(1).windBy(1);
      expect(play.back.at, 1);
      expect(play.back.back.back, same(play.back.back));
    });

    test('one wind lands the two odds', () {
      final play = Play.of(Askings.at(0)).windBy(1);
      expect(play.isDone, isTrue);
      expect(play.at, 1);
      expect(play.odds, 2);
      expect(play.windBy(1), same(play));
    });

    test('the pointer winds the eight odds home', () {
      var play = Play.of(Askings.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        play = play.windBy(play.next! ? 1 : -1);
      }
      expect(play.isDone, isTrue);
      expect(play.odds, 8);
    });

    test('the hopeless asking admits it at twelve winds', () {
      var play = Play.of(Askings.at(4));
      for (var dither = 0; dither < 12; dither++) {
        play = dither.isEven ? play.windBy(1) : play.windBy(-1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable asking never gives up', () {
      var play = Play.of(Askings.at(3));
      for (var dither = 0; dither < 12; dither++) {
        play = dither.isEven ? play.windBy(1) : play.windBy(-1);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands wound home', () {
      final mark = Play.standing(Askings.at(3), 15);
      expect(mark.isDone, isTrue);
      expect(mark.odds, 16);
    });
  });
}
