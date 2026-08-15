import 'package:flutter_test/flutter_test.dart';
import 'package:laneford/green/levels.dart';
import 'package:laneford/green/play.dart';
import 'package:laneford/green/rules.dart';

/// The geometry, the sweep and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the geometry', () {
    test('turns and points on segments', () {
      expect(Rules.turn((0, 0), (2, 0), (1, 1)), 1);
      expect(Rules.turn((0, 0), (2, 0), (1, -1)), -1);
      expect(Rules.turn((0, 0), (2, 0), (3, 0)), 0);
      expect(Rules.onSegment((0, 0), (2, 2), (1, 1)), isTrue);
      expect(Rules.onSegment((0, 0), (2, 2), (3, 3)), isFalse);
      expect(Rules.onSegment((0, 0), (2, 2), (1, 0)), isFalse);
    });

    test('lanes cross, touch, or keep apart', () {
      expect(Rules.cross((0, 0), (2, 2), (2, 0), (0, 2)), isTrue);
      expect(Rules.cross((0, 0), (1, 0), (0, 1), (1, 1)), isFalse);
      // A lane ending on another lane's middle counts as a crossing.
      expect(Rules.cross((0, 0), (2, 0), (1, 0), (1, 2)), isTrue);
      // Lanes out of one hamlet: apart unless they run along each other.
      expect(Rules.cross((0, 0), (2, 0), (0, 0), (0, 2)), isFalse);
      expect(Rules.cross((0, 0), (2, 0), (0, 0), (1, 0)), isTrue);
      expect(Rules.cross((0, 0), (2, 0), (0, 0), (-1, 0)), isFalse);
    });

    test('a hamlet on a lane is caught', () {
      expect(Rules.throughs([(0, 1)], [(0, 0), (2, 2), (1, 1)]), [(0, 2)]);
      expect(Rules.throughs([(0, 1)], [(0, 0), (2, 2), (1, 0)]), isEmpty);
      expect(Rules.clear([(0, 1)], [(0, 0), (2, 2), (1, 1)]), isFalse);
    });
  });

  group('the sweep', () {
    test('the four hamlets on the three-by-three: 192 of 3,024 clear', () {
      final (clear, all, first) = Rules.sweep(4, Levels.at(0).lanes, 3);
      expect((clear, all), (192, 3024));
      expect(first, [(0, 0), (2, 0), (1, 1), (1, 2)]);
      expect(Rules.clear(Levels.at(0).lanes, first!), isTrue);
    });

    test('the two and the three: 912 of 15,120', () {
      final (clear, all, _) = Rules.sweep(5, Levels.at(1).lanes, 3);
      expect((clear, all), (912, 15120));
    });

    test('the five, ten lanes, never on the four-by-four; nine lanes 1,200 ways', () {
      final k5 = [for (var i = 0; i < 5; i++) for (var j = i + 1; j < 5; j++) (i, j)];
      expect(Rules.sweep(5, k5, 4).$1, 0);
      expect(Rules.sweep(5, Levels.at(2).lanes, 4).$1, 1200);
    });

    test('Euler\'s ceilings', () {
      expect(Rules.ceiling(4, twoKinds: false), 6);
      expect(Rules.ceiling(5, twoKinds: false), 9);
      expect(Rules.ceiling(5, twoKinds: true), 6);
      expect(Rules.ceiling(6, twoKinds: true), 8);
      for (final level in Levels.all) {
        expect(level.lanes.length > level.ceiling, !level.winnable, reason: level.name);
      }
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Three and the Three']);
      expect(Levels.at(4).lanes, hasLength(9));
      expect(Levels.at(4).twoKinds, isTrue);
      expect(Levels.at(0).twoKinds, isFalse);
    });

    test('no ask opens clear, and every opening stands the hamlets apart', () {
      for (final level in Levels.all) {
        expect(level.meets(level.start), isFalse, reason: level.name);
        expect(level.start.toSet().length, level.hamlets, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'lay the six lanes between four hamlets, each to each, so no two cross');
      expect(Levels.at(4).task, 'lay the nine lanes from each of three hamlets to each of three so no two cross');
    });
  });

  group('the play', () {
    test('opens on its start, crossed', () {
      final play = Play.of(Levels.at(0));
      expect(play.at, [(0, 0), (2, 2), (2, 0), (0, 2)]);
      expect(play.crossings, [(0, 5)]);
      expect(play.isDone, isFalse);
      expect(play.moves, 0);
    });

    test('a hamlet is taken up and stood on a bare point, not on another', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(3);
      expect(play.held, 3);
      play = play.move((2, 2));
      expect(play.refused, isTrue);
      expect(play.held, 3);
      expect(play.moves, 0);
      play = play.move((1, 1));
      expect(play.at[3], (1, 1));
      expect(play.held, isNull);
      expect(play.moves, 1);
      // The lane A-B now runs through D, and D's lanes touch it: not clear.
      expect(play.throughs, [(0, 3)]);
      expect(play.crossings, [(0, 2), (0, 4), (0, 5)]);
      expect(play.isDone, isFalse);
    });

    test('the four hamlets land by hand in two moves', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(1).move((1, 1)).hold(3).move((1, 2));
      expect(play.at, [(0, 0), (1, 1), (2, 0), (1, 2)]);
      expect(play.crossings, isEmpty);
      expect(play.throughs, isEmpty);
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
    });

    test('a tap on the held hamlet lets it go, and a point with nothing held does nothing', () {
      final play = Play.of(Levels.at(1)).hold(2).hold(2);
      expect(play.held, isNull);
      expect(play.move((1, 1)).at, play.at);
    });

    test('back undoes one action', () {
      final play = Play.of(Levels.at(0)).hold(3).move((1, 1));
      expect(play.back.at[3], (0, 2));
      expect(play.back.held, 3);
    });

    test('the two and the three land by hand', () {
      var play = Play.of(Levels.at(1));
      play = play.hold(4).move((1, 1));
      expect(play.crossings, isEmpty);
      expect(play.throughs, isEmpty);
      expect(play.isDone, isTrue);
    });

    test('the three and the three give up after twenty-four moves', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        final h = k % 6;
        play = play.hold(h).move((3, h < 3 ? 1 : 2)).hold(h).move(Levels.at(4).start[h]);
        // Two moves each: out and back.
        k++;
      }
      expect(play.moves, 24);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer walks the sweep\'s first placing, blockers moved first', () {
      var play = Play.of(Levels.at(0));
      // Aim: [(0,0),(2,0),(1,1),(1,2)]; hamlet 1 wants (2,0), where hamlet 2 stands.
      expect(play.next, (2, (1, 1)));
      final (h, p) = play.next!;
      play = play.hold(h).move(p);
      expect(play.next, (1, (2, 0)));
    });

    test('following the pointer lays every winnable green clear', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final (h, p) = play.next!;
          play = play.hold(h).move(p);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
