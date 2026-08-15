import 'package:flutter_test/flutter_test.dart';
import 'package:wedgeworth/wedge/levels.dart';
import 'package:wedgeworth/wedge/play.dart';
import 'package:wedgeworth/wedge/rules.dart';

/// The law of the corner, and the play that sets it, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the angles', () {
    test('a face\'s corner is 180(p - 2)/p degrees, kept exact', () {
      expect(Rules.angle(3), (180, 3));
      expect(Rules.degrees(Rules.angle(3)), '60');
      expect(Rules.degrees(Rules.angle(4)), '90');
      expect(Rules.degrees(Rules.angle(5)), '108');
      expect(Rules.degrees(Rules.angle(6)), '120');
      expect(Rules.degrees(Rules.angle(7)), '128 4/7');
      expect(Rules.degrees(Rules.angle(8)), '135');
    });

    test('the sum and the gap', () {
      expect(Rules.degrees(Rules.sum(3, 5)), '300');
      expect(Rules.degrees(Rules.gap(3, 5)), '60');
      expect(Rules.degrees(Rules.gap(4, 3)), '90');
      expect(Rules.degrees(Rules.gap(5, 3)), '36');
      expect(Rules.degrees(Rules.gap(6, 3)), '0');
      expect(Rules.degrees(Rules.gap(5, 4)), '-72');
      expect(Rules.degrees(Rules.gap(7, 3)), '-25 5/7');
    });

    test('closing, flat and overlapping', () {
      expect(Rules.closes(3, 3), isTrue);
      expect(Rules.closes(3, 5), isTrue);
      expect(Rules.closes(3, 6), isFalse);
      expect(Rules.flat(3, 6), isTrue);
      expect(Rules.flat(4, 4), isTrue);
      expect(Rules.flat(6, 3), isTrue);
      expect(Rules.overlaps(6, 4), isTrue);
      expect(Rules.overlaps(8, 3), isTrue);
      expect(Rules.closes(8, 3), isFalse);
    });
  });

  group('Euler\'s count', () {
    test('names the five solids and no others', () {
      expect(Rules.euler(3, 3), (4, 6, 4));
      expect(Rules.euler(3, 4), (6, 12, 8));
      expect(Rules.euler(3, 5), (12, 30, 20));
      expect(Rules.euler(4, 3), (8, 12, 6));
      expect(Rules.euler(5, 3), (20, 30, 12));
      expect(Rules.euler(3, 6), isNull);
      expect(Rules.euler(4, 4), isNull);
      expect(Rules.euler(6, 3), isNull);
      expect(Rules.euler(5, 4), isNull);
    });

    test('agrees with the angle on every setting to twelve', () {
      for (var p = 3; p <= 12; p++) {
        for (var q = 3; q <= 12; q++) {
          expect(Rules.euler(p, q) != null, Rules.closes(p, q), reason: '$p sides, $q faces');
          expect((p - 2) * (q - 2) < 4, Rules.closes(p, q), reason: '$p sides, $q faces');
        }
      }
    });

    test('adds up to two for each of the five', () {
      for (final (p, q) in [(3, 3), (3, 4), (3, 5), (4, 3), (5, 3)]) {
        final (v, e, f) = Rules.euler(p, q)!;
        expect(v - e + f, 2);
        expect(p * f, 2 * e);
        expect(q * v, 2 * e);
        expect(Rules.solid(p, q), isNotNull);
      }
    });
  });

  group('the sweep', () {
    test('36 settings, five closing, three flat, 28 over', () {
      expect(Rules.sweep((p, q) => true), (36, 36));
      expect(Rules.sweep(Rules.closes), (5, 36));
      expect(Rules.sweep(Rules.flat), (3, 36));
      expect(Rules.sweep(Rules.overlaps), (28, 36));
    });

    test('the levels\' counts', () {
      expect(Rules.sweep(Levels.at(0).meets), (3, 36));
      expect(Rules.sweep(Levels.at(1).meets), (1, 36));
      expect(Rules.sweep(Levels.at(2).meets), (1, 36));
      expect(Rules.sweep(Levels.at(3).meets), (1, 36));
      expect(Rules.sweep(Levels.at(4).meets), (0, 36));
    });

    test('the first setting of each ask', () {
      expect(Rules.first(Levels.at(0).meets), (3, 3));
      expect(Rules.first(Levels.at(1).meets), (4, 3));
      expect(Rules.first(Levels.at(2).meets), (5, 3));
      expect(Rules.first(Levels.at(3).meets), (3, 5));
      expect(Rules.first(Levels.at(4).meets), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Honeycomb Corner']);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'close a corner of triangles');
      expect(Levels.at(1).task, 'close a corner of squares');
      expect(Levels.at(2).task, 'close a corner of pentagons');
      expect(Levels.at(3).task, 'close a corner whose solid has twenty faces');
      expect(Levels.at(4).task, 'close a corner of hexagons');
    });

    test('an ask is met by the corner it names', () {
      expect(Levels.at(0).meets(3, 4), isTrue);
      expect(Levels.at(0).meets(3, 6), isFalse);
      expect(Levels.at(1).meets(4, 3), isTrue);
      expect(Levels.at(1).meets(3, 3), isFalse);
      expect(Levels.at(3).meets(3, 5), isTrue);
      expect(Levels.at(3).meets(3, 4), isFalse);
      expect(Levels.at(4).meets(6, 3), isFalse);
    });
  });

  group('the play', () {
    test('opens on four squares, flat', () {
      final play = Play.of(Levels.at(1));
      expect((play.sides, play.faces), (4, 4));
      expect(play.flat, isTrue);
      expect(play.tiling, 'the square tiling');
      expect(play.isDone, isFalse);
    });

    test('a setting counts, and setting the same again does not', () {
      var play = Play.of(Levels.at(1));
      play = play.setFaces(3);
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
      expect(play.solid, 'the cube');
      final again = Play.of(Levels.at(0)).setSides(4);
      expect(again.moves, 0);
      expect(again.setSides(9).moves, 0);
    });

    test('back undoes one setting', () {
      final play = Play.of(Levels.at(0)).set(0, 3);
      expect(play.sides, 3);
      expect(play.back.sides, 4);
      expect(play.back.back.sides, 4);
    });

    test('the honeycomb gives up after twelve settings', () {
      var play = Play.of(Levels.at(4));
      play = play.setSides(6);
      for (var k = 0; k < 11; k++) {
        expect(play.isOver, isFalse);
        play = play.setFaces(k.isEven ? 3 : 5);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 14; k++) {
        play = play.setSides(3 + k % 6);
        play = play.setFaces(4 + k % 4);
      }
      expect(play.gaveUp, isFalse);
    });

    test('the pointer names the first dial off the sweep\'s first setting', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (0, 3));
      play = play.setSides(3);
      expect(play.next, (1, 5));
      play = play.setFaces(5);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var taps = 0;
        while (!play.isDone && taps < 4) {
          final (dial, value) = play.next!;
          play = play.set(dial, value);
          taps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
