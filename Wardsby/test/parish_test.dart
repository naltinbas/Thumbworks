import 'package:flutter_test/flutter_test.dart';
import 'package:wardsby/parish/levels.dart';
import 'package:wardsby/parish/play.dart';
import 'package:wardsby/parish/rules.dart';

/// The walk, the wards and the play, checked at the domain: nothing here
/// touches a widget.
void main() {
  group('the walk', () {
    test('4,006 drawings, all sound, none twice, the same turned', () {
      final drawings = Rules.drawings;
      expect(drawings, hasLength(4006));
      expect(drawings.map((d) => d.join(',')).toSet(), hasLength(4006));
      expect(drawings.every(Rules.sound), isTrue);
      expect(Rules.countTurned(), 4006);
      expect(drawings.first, [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4]);
    });

    test('soundness: five in one piece, or not', () {
      expect(Rules.sound([for (var c = 0; c < 25; c++) c % 5]), isTrue);
      expect(Rules.sound(List.filled(25, 0)), isFalse);
      // Two pieces of ward 0.
      final split = [for (var c = 0; c < 25; c++) c ~/ 5];
      split[0] = 4;
      split[24] = 0;
      expect(Rules.sound(split), isFalse);
      expect(Rules.sound([...List.filled(24, 0), null]), isFalse);
    });

    test('wins and tallies', () {
      final rows = Levels.at(1).blue;
      final columns = [for (var c = 0; c < 25; c++) c % 5];
      expect(Rules.blueWins(columns, rows), 5);
      expect(Rules.tally(columns, rows), [3, 3, 3, 3, 3]);
      final byRows = [for (var c = 0; c < 25; c++) c ~/ 5];
      expect(Rules.blueWins(byRows, rows), 3);
      expect(Rules.mostWards(8), 2);
      expect(Rules.mostWards(9), 3);
      expect(Rules.mostWards(25), 5);
    });

    test('the spreads', () {
      expect(Rules.spread(Levels.at(0).blue), [1, 696, 3033, 276, 0, 0]);
      expect(Rules.spread(Levels.at(1).blue), [0, 0, 276, 3033, 696, 1]);
      expect(Rules.spread(Levels.at(3).blue), [1382, 2124, 490, 10, 0, 0]);
      expect(Rules.spread(Levels.at(4).blue), [18, 2072, 1916, 0, 0, 0]);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Eight']);
      expect(Levels.at(4).blues, 8);
      expect(Levels.at(0).blues, 10);
      for (final level in Levels.all) {
        expect(Rules.drawings.where(level.meets).length, level.ways, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'draw the five wards so the Blues win three of the five, the parish being 10 Blue and 15 Red');
      expect(Levels.at(1).task, 'draw the five wards so the Blues win all five, the parish being 15 Blue and 10 Red');
      expect(Levels.at(2).task, 'draw the five wards so the Reds win three of the five, the parish being 15 Blue and 10 Red');
    });

    test('an ask is met by a sound drawing that wins enough', () {
      final columns = [for (var c = 0; c < 25; c++) c % 5];
      expect(Levels.at(1).meets(columns), isTrue);
      expect(Levels.at(2).meets(columns), isFalse);
      final byRows = [for (var c = 0; c < 25; c++) c ~/ 5];
      expect(Levels.at(3).meets(byRows), isTrue);
      expect(Levels.at(4).meets(byRows), isFalse);
      expect(Levels.at(1).meets(List.filled(25, 0)), isFalse);
    });
  });

  group('the play', () {
    test('opens bare', () {
      final play = Play.of(Levels.at(0));
      expect(play.assigned, 0);
      expect(play.sound, isFalse);
      expect(play.blueWins, 0);
      expect(play.isDone, isFalse);
    });

    test('a tap moves a household round the wards and back to bare', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.wards[0], 0);
      for (var k = 0; k < 4; k++) {
        play = play.tap(0);
      }
      expect(play.wards[0], 4);
      play = play.tap(0);
      expect(play.wards[0], isNull);
      expect(play.moves, 6);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(3);
      expect(play.back.wards[3], isNull);
    });

    test('the sweep lands by the columns', () {
      var play = Play.of(Levels.at(1));
      for (var c = 0; c < 25; c++) {
        for (var k = 0; k <= c % 5; k++) {
          play = play.tap(c);
        }
      }
      expect(play.sound, isTrue);
      expect(play.blueWins, 5);
      expect(play.isDone, isTrue);
    });

    test('the eight admit it once a sound drawing is down', () {
      var play = Play.of(Levels.at(4));
      for (var c = 0; c < 25; c++) {
        for (var k = 0; k <= c ~/ 5; k++) {
          play = play.tap(c);
        }
      }
      expect(play.sound, isTrue);
      expect(play.blueWins, 2);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer names the household and the taps', () {
      var play = Play.of(Levels.at(1));
      // The first drawing of the sweep is the columns: household 0 to
      // ward 0, one tap; household 1 to ward 1, two taps.
      expect(play.next, (0, 1));
      play = play.tap(0);
      expect(play.next, (1, 2));
      play = play.tap(1);
      expect(play.next, (1, 1));
    });

    test('following the pointer draws every winnable parish', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (c, taps) = play.next!;
          for (var k = 0; k < taps; k++) {
            play = play.tap(c);
          }
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
