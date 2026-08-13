import 'package:clinkfield/clink/feasts.dart';
import 'package:clinkfield/clink/play.dart';
import 'package:clinkfield/clink/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the feast, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final feast in Feasts.all) {
        expect(Rules(feast.guests).waysTo(feast.asked), feast.ways,
            reason: feast.name);
      }
    });

    test('the spreads stand where they were pinned', () {
      expect(Rules(4).spread(), {1: 8, 2: 32, 3: 24});
      expect(Rules(5).spread(), {1: 14, 2: 310, 3: 580, 4: 120});
    });

    test('the laws hold over both tables', () {
      expect(Rules(4).lawsHold(), isTrue);
      expect(Rules(5).lawsHold(), isTrue);
    });

    test('counts read the feast, wire by wire', () {
      final rules = Rules(5);
      final ring = [
        for (final (a, b) in rules.pairs)
          (b - a == 1) || (a == 0 && b == 4),
      ];
      expect(rules.counts(ring), [2, 2, 2, 2, 2]);
      expect(rules.distinct(ring), 1);
    });

    test('the wallflower argument reads a feast', () {
      final rules = Rules(5);
      expect(
        rules.wallflowerHolds(List.filled(10, false)),
        isTrue,
      );
    });
  });

  group('the play', () {
    test('opens bare and unsettled on every feast', () {
      for (final feast in Feasts.all) {
        final play = Play.of(feast);
        expect(play.raised, 0, reason: feast.name);
        expect(play.isDone, isFalse, reason: feast.name);
        expect(play.isOver, isFalse, reason: feast.name);
      }
    });

    test('the bare table never lands the one count unraised', () {
      final play = Play.of(Feasts.at(0));
      expect(play.distinct, 1);
      expect(play.isDone, isFalse);
    });

    test('a clink and its taking-back, counted gross', () {
      var play = Play.of(Feasts.at(4));
      play = play.flipAt(0);
      expect(play.clinked[0], isTrue);
      expect(play.moves, 1);
      play = play.flipAt(0);
      expect(play.clinked[0], isFalse);
      expect(play.moves, 2);
    });

    test('back takes back one move', () {
      final play = Play.of(Feasts.at(4)).flipAt(1).flipAt(3);
      expect(play.back.moves, 1);
      expect(play.back.clinked[3], isFalse);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the ring lands the one count', () {
      var play = Play.of(Feasts.at(0));
      final rules = Rules(5);
      for (var pair = 0; pair < rules.pairs.length; pair++) {
        final (a, b) = rules.pairs[pair];
        if ((b - a == 1) || (a == 0 && b == 4)) {
          play = play.flipAt(pair);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.distinct, 1);
      expect(play.moves, 5);
      expect(play.flipAt(0), same(play));
    });

    test('the pointer feasts the four counts home', () {
      var play = Play.of(Feasts.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 14) {
        play = play.flipAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.distinct, 4);
    });

    test('the hopeless feast admits it at fourteen moves', () {
      var play = Play.of(Feasts.at(4));
      for (var dither = 0; dither < 14; dither++) {
        play = play.flipAt(dither % 3);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable feast never gives up', () {
      // The one count needs likeness; a lone clink dithered
      // never levels five guests.
      var play = Play.of(Feasts.at(0));
      for (var dither = 0; dither < 14; dither++) {
        play = play.flipAt(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands feasted', () {
      final mark = Play.standing(
        Feasts.at(2),
        const [true, true, true, true, true, true, false, false, false, false],
      );
      expect(mark.isDone, isTrue);
      expect(mark.counts, [4, 3, 2, 2, 1]);
    });
  });
}
