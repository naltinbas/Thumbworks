import 'package:flutter_test/flutter_test.dart';
import 'package:noughtsmill/mill/grinds.dart';
import 'package:noughtsmill/mill/play.dart';
import 'package:noughtsmill/mill/rules.dart';

/// The law of the mill, held to.
void main() {
  group('the rules', () {
    test('the ledger sums the fives and their powers', () {
      expect(Rules.ledger(4), isEmpty);
      expect(Rules.ledger(10), [2]);
      expect(Rules.ledger(100), [20, 4]);
      expect(Rules.noughts(100), 24);
    });

    test('the grindstone agrees with the ledger everywhere', () {
      expect(Rules.lawHolds(), isTrue);
      expect(Rules.ground(10), 2);
      expect(Rules.ground(25), 6);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final grind in Grinds.all) {
        expect(Rules.windings(grind.asked).length, grind.ways,
            reason: grind.name);
      }
    });

    test('the runs and the skips', () {
      expect(Rules.windings(1), [5, 6, 7, 8, 9]);
      expect(Rules.windings(6), [25, 26, 27, 28, 29]);
      expect(Rules.windings(5), isEmpty);
      expect(Rules.skipped(29), [5, 11, 17, 23, 29]);
    });
  });

  group('the play', () {
    test('the mill opens at one, unlanded', () {
      final play = Play.of(Grinds.at(0));
      expect(play.wound, 1);
      expect(play.noughts, 0);
      expect(play.isDone, isFalse);
    });

    test('windings turn and clamp', () {
      var play = Play.of(Grinds.at(0));
      play = play.windBy(-10);
      expect(play.wound, 0);
      expect(play.moves, 1);
      expect(play.windBy(-1), same(play));
      play = play.windBy(10);
      expect(play.wound, 10);
      expect(play.moves, 2);
    });

    test('the first nought lands at five', () {
      var play = Play.of(Grinds.at(0));
      play = play.windBy(1).windBy(1).windBy(1).windBy(1);
      expect(play.wound, 5);
      expect(play.noughts, 1);
      expect(play.isDone, isTrue);
      expect(play.windBy(1), same(play));
    });

    test('back takes back a winding', () {
      var play = Play.of(Grinds.at(1)).windBy(10);
      expect(play.back.wound, 1);
      expect(play.back.moves, 0);
      expect(Play.of(Grinds.at(1)).back.moves, 0);
    });

    test('show me points the nearest landing', () {
      final play = Play.of(Grinds.at(2)).windBy(10).windBy(10);
      expect(play.wound, 21);
      expect(play.next, 25);
    });

    test('the hopeless grind has nothing to point at', () {
      expect(Play.of(Grinds.at(4)).next, isNull);
    });

    test('the hopeless grind admits it after twenty-four windings',
        () {
      var play = Play.of(Grinds.at(4));
      for (var winding = 0;
          winding < Play.gaveUpAt;
          winding++) {
        expect(play.gaveUp, isFalse);
        play = winding.isEven ? play.windBy(1) : play.windBy(-1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable grind never gives up', () {
      var play = Play.of(Grinds.at(3));
      for (var winding = 0;
          winding < Play.gaveUpAt;
          winding++) {
        play = winding.isEven ? play.windBy(1) : play.windBy(-1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
