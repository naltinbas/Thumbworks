import 'package:flutter_test/flutter_test.dart';
import 'package:stillmere/mere/lightings.dart';
import 'package:stillmere/mere/play.dart';
import 'package:stillmere/mere/rules.dart';

/// The law of the mere, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways and shapes are what the sweep finds', () {
      final rules = Rules();
      for (final lighting in Lightings.all) {
        if (lighting.count > 6) continue; // the seven is the checker's, slow
        final (ways, shapes) = rules.sweep(lighting.count);
        expect(ways, lighting.ways, reason: lighting.name);
        expect(shapes, lighting.shapes, reason: lighting.name);
      }
    });

    test('the rule on the block, the tub, the boat, the blinker', () {
      const block = {(1, 1), (2, 1), (1, 2), (2, 2)};
      const tub = {(1, 0), (0, 1), (2, 1), (1, 2)};
      const boat = {(1, 0), (0, 1), (2, 1), (1, 2), (2, 2)};
      const blinker = {(1, 0), (1, 1), (1, 2)};
      expect(Rules.still(block), isTrue);
      expect(Rules.still(tub), isTrue);
      expect(Rules.still(boat), isTrue);
      expect(Rules.still(blinker), isFalse);
      expect(Rules.next(blinker), {(0, 1), (1, 1), (2, 1)});
      expect(Rules.births(blinker), {(0, 1), (2, 1)});
      expect(Rules.deaths(blinker), {(1, 0), (1, 2)});
      expect(Rules.litRound(block, (1, 1)), 3);
      expect(Rules.still(const <Spot>{}), isFalse);
    });

    test('a light at the edge wakes a spot beyond the mere', () {
      // Three in the corner of the mere: the fourth corner is off it.
      const corner = {(0, 0), (1, 0), (0, 1)};
      expect(Rules.births(corner), {(1, 1)});
      const edge = {(0, 0), (1, 0), (2, 0)};
      expect(Rules.births(edge), contains((1, -1)));
      expect(Rules.still(edge), isFalse);
    });

    test('three lights: 64 touching threes, all corners of a square, all light the fourth', () {
      final rules = Rules();
      var touching = 0;
      rules.lightings(3, (lit) {
        if (lit.any((s) => Rules.litRound(lit, s) < 2)) return;
        touching++;
        expect(Rules.births(lit), hasLength(1));
      });
      expect(touching, 64);
    });
  });

  group('the play', () {
    test('opens dark', () {
      for (final lighting in Lightings.all) {
        final play = Play.of(lighting);
        expect(play.lit, isEmpty, reason: lighting.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap lights, a tap douses, counted both ways', () {
      var play = Play.of(Lightings.at(0));
      play = play.tap((1, 1));
      expect(play.lit, {(1, 1)});
      expect(play.moves, 1);
      expect(play.deaths, {(1, 1)});
      play = play.tap((1, 1));
      expect(play.lit, isEmpty);
      expect(play.moves, 2);
      expect(play.back.lit, {(1, 1)});
    });

    test('no more lanterns than asked, none off the mere', () {
      final play = Play.of(Lightings.at(0)).tap((1, 1)).tap((2, 1)).tap((1, 2)).tap((2, 2));
      expect(play.isDone, isTrue);
      expect(play.tap((3, 3)), same(play));
      final bare = Play.of(Lightings.at(0));
      expect(bare.tap((5, 5)), same(bare));
    });

    test('the block and the tub lie still by hand', () {
      final block = Play.of(Lightings.at(0)).tap((1, 1)).tap((2, 1)).tap((1, 2)).tap((2, 2));
      expect(block.still, isTrue);
      expect(block.isDone, isTrue);
      final tub = Play.of(Lightings.at(0)).tap((2, 1)).tap((1, 2)).tap((3, 2)).tap((2, 3));
      expect(tub.isDone, isTrue);
      final line = Play.of(Lightings.at(0)).tap((1, 2)).tap((2, 2)).tap((3, 2)).tap((4, 2));
      expect(line.isDone, isFalse);
    });

    test('the pointer stills the five and the six', () {
      for (final number in [1, 2]) {
        var play = Play.of(Lightings.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 16) {
          final (_, spot) = play.next!;
          play = play.tap(spot);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
    });

    test('the pointer douses a stray light first', () {
      final aim = Play.aimFor(Lightings.at(1))!;
      final stray = Rules().spots.firstWhere((s) => !aim.contains(s));
      final play = Play.of(Lightings.at(1)).tap(stray);
      expect(play.next, ('douse', stray));
    });

    test('the hopeless lighting admits it at twelve moves', () {
      var play = Play.of(Lightings.at(4)).tap((1, 1)).tap((2, 1)).tap((1, 2));
      expect(play.births, {(2, 2)});
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap((1, 2)).tap((1, 2));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.lit, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable lighting never gives up', () {
      var play = Play.of(Lightings.at(0));
      for (var dither = 0; dither < 6; dither++) {
        play = play.tap((1, 1)).tap((1, 1));
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands still', () {
      final mark = Play.standing(Lightings.at(1), const {(2, 1), (1, 2), (3, 2), (2, 3), (3, 3)});
      expect(mark.isDone, isTrue);
    });
  });
}
