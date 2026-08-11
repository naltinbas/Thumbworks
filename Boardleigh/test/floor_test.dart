import 'package:boardleigh/floor/play.dart';
import 'package:boardleigh/floor/rooms.dart';
import 'package:boardleigh/floor/rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the counting', () {
    test('runs the book numbers', () {
      expect(Rules(4, 4, Rules.rectangle(4, 4)).tilings(0xFFFF), 36);
      expect(Rules(4, 3, Rules.rectangle(4, 3)).tilings(0xFFF), 11);
      expect(Rules(2, 1, Rules.rectangle(2, 1)).tilings(0x3), 1);
    });

    test('the staircase rule holds along the strips', () {
      // The two voices: the count tries every laying; the rule adds
      // the two before. Met at every length.
      final strip = <int>[];
      for (var boards = 1; boards <= 8; boards++) {
        final rules = Rules(boards, 2, Rules.rectangle(boards, 2));
        strip.add(rules.tilings(rules.cells));
      }
      expect(strip, [1, 2, 3, 5, 8, 13, 21, 34]);
      for (var boards = 3; boards <= 8; boards++) {
        expect(strip[boards - 1],
            strip[boards - 2] + strip[boards - 3]);
      }
    });

    test('the clipped parlour is dead both ways', () {
      final room = Rooms.at(4);
      final rules = Rules(room.wide, room.high, room.cells);
      expect(rules.tilings(room.cells), 0);
      final (dark, light) = rules.colours();
      expect((dark - light).abs(), 2);
    });

    test('the fair clip keeps its colours and lays', () {
      final room = Rooms.at(3);
      final rules = Rules(room.wide, room.high, room.cells);
      expect(rules.colours(), (7, 7));
      expect(rules.tilings(room.cells), 12);
    });
  });

  group('every room that ships', () {
    for (var number = 0; number < Rooms.count; number++) {
      final room = Rooms.at(number);

      test('${room.name} is what it says it is', () {
        final rules = Rules(room.wide, room.high, room.cells);
        expect(rules.tilings(room.cells), room.ways);
      });
    }
  });

  group('a floor in play', () {
    test('starts bare', () {
      final play = Play.of(Rooms.at(0));
      expect(play.planks, isEmpty);
      expect(play.uncovered, Rooms.at(0).cells);
      expect(play.isDone, isFalse);
      expect(play.canStill, isTrue);
    });

    test('a plank lays on two bare neighbours and lifts off', () {
      var play = Play.of(Rooms.at(0)).lay(0, 1);
      expect(play.planks, [(0, 1)]);
      expect(play.isCovered(0), isTrue);
      expect(play.mayLay(1, 2), isFalse);
      expect(play.mayLay(3, 7), isTrue);
      play = play.lift(1);
      expect(play.planks, isEmpty);
      expect(play.moves, 2);
    });

    test('no plank crosses the room edge or a gap', () {
      final play = Play.of(Rooms.at(4));
      // Cell 0 is clipped out of the parlour.
      expect(play.mayLay(0, 1), isFalse);
      // Row ends do not wrap.
      expect(play.mayLay(3, 4), isFalse);
    });

    test('take back returns the floor as it lay', () {
      final start = Play.of(Rooms.at(0));
      final laid = start.lay(0, 4);
      expect(laid.back.planks, isEmpty);
      expect(identical(start.back, start), isTrue);
    });

    test('a laying that strands the rest shows in canStill at once', () {
      // In the square parlour, planking 1-2 strands the corner 0 and
      // 3 unless their mates line up: find a stranding first plank by
      // search.
      var edge = [Play.of(Rooms.at(2))];
      Play? stranded;
      var plies = 0;
      while (stranded == null && plies++ < 4 && edge.isNotEmpty) {
        final next = <Play>[];
        for (final play in edge) {
          for (var one = 0; one < 16 && stranded == null; one++) {
            for (var other = one + 1; other < 16; other++) {
              if (!play.mayLay(one, other)) continue;
              final laid = play.lay(one, other);
              if (!laid.canStill) {
                stranded = laid;
                break;
              }
              next.add(laid);
            }
          }
        }
        edge = next;
      }
      expect(stranded, isNotNull,
          reason: 'no laying anywhere strands the parlour');
      expect(stranded!.canStill, isFalse);
      expect(stranded.back.canStill, isTrue);
    });

    test('following next lays every winnable floor', () {
      for (var number = 0; number < Rooms.count; number++) {
        final room = Rooms.at(number);
        if (!room.winnable) continue;
        var play = Play.of(room);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 12) fail('${room.name} never laid');
          final plank = play.next!;
          play = play.lay(plank.$1, plank.$2);
          expect(play.canStill, isTrue, reason: room.name);
        }
        expect(play.planks.length,
            Rules(room.wide, room.high, room.cells).cellCount ~/ 2,
            reason: room.name);
      }
    });

    test('the clipped parlour offers nothing and never lays', () {
      var play = Play.of(Rooms.at(4));
      expect(play.next, isNull);
      expect(play.canStill, isFalse);
      // Lay greedily until stuck: cells remain uncovered.
      var guard = 0;
      while (guard++ < 10) {
        (int, int)? found;
        for (var one = 0; one < 16 && found == null; one++) {
          for (var other = one + 1; other < 16; other++) {
            if (play.mayLay(one, other)) {
              found = (one, other);
              break;
            }
          }
        }
        if (found == null) break;
        play = play.lay(found.$1, found.$2);
      }
      expect(play.isDone, isFalse);
      expect(play.uncovered, isNot(0));
    });
  });
}
