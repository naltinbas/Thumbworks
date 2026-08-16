import 'package:flutter_test/flutter_test.dart';
import 'package:arrowmere/ways/levels.dart';
import 'package:arrowmere/ways/play.dart';
import 'package:arrowmere/ways/rules.dart';

/// The villages, the arrows, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the villages', () {
    test('five of them, all joined, one with a bridge', () {
      expect(Rules.villages, hasLength(5));
      for (final village in Rules.villages) {
        expect(Rules.joined(village), isTrue, reason: village.name);
        expect(village.opening, hasLength(village.streetCount));
        expect(Rules.strong(village, village.opening), isFalse,
            reason: village.name);
        expect(Rules.bridges(village), Rules.bridgesByWalk(village),
            reason: village.name);
      }
      expect(Rules.bridges(Rules.toll), [6]);
      expect(Rules.toll.streets[6], (2, 3));
      for (final village in [Rules.green, Rules.square, Rules.house, Rules.rings]) {
        expect(Rules.bridges(village), isEmpty, reason: village.name);
      }
    });

    test('the sweep and the polynomial count the same orientations', () {
      const counts = {'the green': 78, 'the square': 2, 'the house': 6, 'the two rings': 426, 'the toll lane': 0};
      for (final village in Rules.villages) {
        expect(Rules.strongCount(village), counts[village.name],
            reason: village.name);
        expect(Rules.strongByTutte(village), counts[village.name],
            reason: village.name);
        // Robbins, both ways about.
        expect(Rules.strongCount(village) > 0, Rules.bridges(village).isEmpty,
            reason: village.name);
      }
    });

    test('a ring goes round two ways, whatever its length', () {
      for (var n = 3; n <= 8; n++) {
        final ring = Village(
          name: 'ring $n',
          places: [for (var k = 0; k < n; k++) (k, 0)],
          streets: [for (var k = 0; k < n; k++) (k, (k + 1) % n)],
          opening: [for (var k = 0; k < n; k++) k == 0],
        );
        expect(Rules.strongCount(ring), 2, reason: 'ring $n');
        expect(Rules.strongByTutte(ring), 2, reason: 'ring $n');
      }
    });

    test('arrows, reach and pairs', () {
      const all = [false, false, false, false];
      expect(Rules.pointed(Rules.square, all, 0), (0, 1));
      expect(Rules.pointed(Rules.square, const [true, false, false, false], 0),
          (1, 0));
      expect(Rules.reaches(Rules.square, all, 0), {0, 1, 2, 3});
      expect(Rules.strong(Rules.square, all), isTrue);
      expect(Rules.pairs(Rules.square, all), 12);
      // Turn one street of the square about and it stops going round: A
      // can be reached from all three and leaves for none.
      const one = [true, false, false, false];
      expect(Rules.pairs(Rules.square, one), 6);
      expect(Rules.reaches(Rules.square, one, 0), {0});
      expect(Rules.reaches(Rules.square, one, 1), {0, 1, 2, 3});
      expect(Rules.strong(Rules.square, one), isFalse);
      expect(Rules.best(Rules.toll), 21);
      expect(Rules.tellPlace(0), 'A');
      expect(Rules.tellStreet(Rules.toll, Rules.toll.opening, 6), 'C to D');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Toll Lane']);
      for (final level in Levels.all) {
        var n = 0;
        for (var mask = 0; mask < level.village.orientations; mask++) {
          if (level.meets(Rules.waysOf(level.village, mask))) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (level.winnable) {
          expect(level.meets(aim!), isTrue, reason: level.name);
        } else {
          expect(aim, isNull, reason: level.name);
        }
      }
      expect(Levels.all.map((l) => l.fewest), [5, 2, 2, 4, null]);
      expect(Levels.all.map((l) => l.village.orientations),
          [4096, 16, 64, 4096, 128]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task,
          'point every street of the green, leaving every place reachable from every other');
      expect(Levels.at(4).task,
          'point every street of the toll lane, leaving every place reachable from every other');
      expect(Levels.at(4).bestPairs, 21);
      expect(Levels.at(4).pairsWanted, 30);
    });
  });

  group('the play', () {
    test('opens on the village opening, with nothing landed', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.arrows, level.village.opening);
        expect((play.moves, play.isOver), (0, false), reason: level.name);
        expect(play.roundabout, isFalse, reason: level.name);
      }
      expect(Play.of(Levels.at(1)).pairs, 5);
      expect(Play.of(Levels.at(4)).pairs, 21);
    });

    test('a tap turns one street about, and back undoes it', () {
      final play = Play.of(Levels.at(1));
      final turned = play.turn(0);
      expect(turned.arrows[0], !play.arrows[0]);
      expect(turned.moves, 1);
      expect(turned.back.arrows, play.arrows);
      expect(play.turn(9), same(play));
      expect(play.back, same(play));
    });

    test('the pointer lands every ask it can, in the fewest turns', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final street = play.next;
          expect(street, isNotNull, reason: level.name);
          final away = play.away!;
          play = play.turn(street!);
          expect(play.away, away - 1, reason: level.name);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
      expect(Play.of(Levels.at(4)).next, isNull);
      expect(Play.of(Levels.at(4)).away, isNull);
      expect(Play.of(Levels.at(1)).pointed(0),
          'Turn the street between A and B about.');
    });

    test('the lost places are named while any are', () {
      final play = Play.of(Levels.at(1));
      // The square opens with C the end of the line: everything reaches
      // it and it reaches nothing.
      expect(play.lost(0), isEmpty);
      expect(play.lost(2), [0, 1, 3]);
      final round = Play.standing(
          Levels.at(1), const [false, false, false, false]);
      expect(round.roundabout, isTrue);
      expect(round.lost(0), isEmpty);
      expect(round.isDone, isTrue);
    });

    test('the toll lane admits it after three best tries, or fourteen turns',
        () {
      var play = Play.of(Levels.at(4));
      expect(play.pairs, play.level.bestPairs);
      play = play.turn(6);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      play = play.turn(0).turn(1).turn(2);
      expect(play.pairs, play.level.bestPairs);
      expect(play.seen, hasLength(2));
      play = play.turn(3).turn(4).turn(5);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.turn(6), same(play));
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.turn(k % 7);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Robbins and both counts', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Robbins'));
      expect(words, contains('1939'));
      expect(words, contains('Tutte polynomial at (0, 2)'));
      expect(words, contains('This is ask 5, The Toll Lane.'));
    });
  });
}
