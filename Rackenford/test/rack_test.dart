import 'package:flutter_test/flutter_test.dart';
import 'package:rackenford/rack/pantries.dart';
import 'package:rackenford/rack/play.dart';
import 'package:rackenford/rack/rules.dart';

/// The law of the pantry, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final pantry in Pantries.all) {
        expect(
          Rules(pantry.top).waysTo(pantry.racks),
          pantry.ways,
          reason: pantry.name,
        );
      }
    });

    test('one rack fewer lands nothing anywhere', () {
      for (final pantry in Pantries.all) {
        if (!pantry.winnable) continue;
        expect(Rules(pantry.top).waysTo(pantry.racks - 1), 0,
            reason: pantry.name);
      }
    });

    test('the chain names the racks', () {
      expect(Rules(6).longestChain, 3);
      expect(Rules(8).longestChain, 4);
      expect(Rules(10).longestChain, 4);
      expect(Rules(12).longestChain, 4);
    });

    test('the height racking lands at every size', () {
      for (final top in [6, 8, 10, 12]) {
        final rules = Rules(top);
        expect(rules.lands(rules.byHeights()), isTrue,
            reason: '$top');
      }
    });

    test('the heights read as pinned for the dozen', () {
      expect(Rules(12).byHeights(),
          [1, 2, 2, 3, 2, 3, 2, 4, 3, 3, 2, 4]);
    });

    test('quarrels read the racking, rack by rack', () {
      final rules = Rules(6);
      // One divides everything it shares a rack with, and two
      // divides four and six: four quarrels on two racks.
      expect(rules.quarrels([1, 2, 1, 2, 1, 2]),
          [(0, 2), (0, 4), (1, 3), (1, 5)]);
      expect(rules.quarrels([1, 2, 2, 3, 2, 3]), isEmpty);
      expect(rules.lands([1, 2, 2, 3, 2, 3]), isTrue);
      expect(rules.lands([1, 2, 2, 3, 2, 0]), isFalse);
    });
  });

  group('the play', () {
    test('opens on the tray, unsettled', () {
      for (final pantry in Pantries.all) {
        final play = Play.of(pantry);
        expect(play.racked, 0, reason: pantry.name);
        expect(play.isDone, isFalse, reason: pantry.name);
        expect(play.isOver, isFalse, reason: pantry.name);
      }
    });

    test('a lift climbs the racks and rounds to the tray', () {
      var play = Play.of(Pantries.at(0));
      play = play.liftAt(0);
      expect(play.racking[0], 1);
      play = play.liftAt(0).liftAt(0);
      expect(play.racking[0], 3);
      play = play.liftAt(0);
      expect(play.racking[0], 0);
      expect(play.moves, 4);
    });

    test('back takes back one lift', () {
      final play = Play.of(Pantries.at(0)).liftAt(0).liftAt(3);
      expect(play.back.moves, 1);
      expect(play.back.racking[3], 0);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the height racking lands the six by hand', () {
      var play = Play.of(Pantries.at(0));
      final aim = Rules(6).byHeights();
      for (var jar = 0; jar < 6; jar++) {
        for (var lift = 0; lift < aim[jar]; lift++) {
          play = play.liftAt(jar);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.quarrels, isEmpty);
      expect(play.liftAt(0), same(play));
    });

    test('the pointer racks the eight home', () {
      var play = Play.of(Pantries.at(1));
      var guard = 0;
      while (!play.isDone && guard++ < 40) {
        play = play.liftAt(play.next!);
      }
      expect(play.isDone, isTrue);
    });

    test('the hopeless pantry admits it at twenty-four lifts', () {
      var play = Play.of(Pantries.at(4));
      for (var dither = 0; dither < 24; dither++) {
        play = play.liftAt(dither % 12);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable pantry never gives up', () {
      var play = Play.of(Pantries.at(3));
      for (var dither = 0; dither < 24; dither++) {
        play = play.liftAt(0);
      }
      expect(play.moves, 24);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands racked home', () {
      final mark =
          Play.standing(Pantries.at(3), Rules(12).byHeights());
      expect(mark.isDone, isTrue);
      expect(mark.quarrels, isEmpty);
    });
  });
}
