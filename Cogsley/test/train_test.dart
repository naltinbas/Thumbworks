import 'package:flutter_test/flutter_test.dart';
import 'package:cogsley/train/levels.dart';
import 'package:cogsley/train/play.dart';
import 'package:cogsley/train/rules.dart';

/// The mesh law, the sweep and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the mesh', () {
    test('gears mesh at the sum of their radii and overlap under it', () {
      expect(Rules.mesh((0, 0, 1), (2, 0, 1)), isTrue);
      expect(Rules.mesh((0, 0, 1), (3, 0, 2)), isTrue);
      expect(Rules.mesh((0, 0, 1), (0, 4, 3)), isTrue);
      expect(Rules.mesh((3, 0, 2), (0, 4, 3)), isTrue);
      expect(Rules.mesh((0, 0, 1), (3, 0, 1)), isFalse);
      expect(Rules.overlap((0, 0, 1), (1, 0, 1)), isTrue);
      expect(Rules.overlap((0, 0, 2), (3, 0, 2)), isTrue);
      expect(Rules.apart([(0, 0, 1), (2, 0, 1), (4, 0, 1)]), isTrue);
      expect(Rules.apart([(0, 0, 1), (1, 0, 1)]), isFalse);
    });

    test('the turning walks mesh by mesh, reversing', () {
      final chain = [(0, 0, 1), (6, 0, 1), (2, 0, 1), (4, 0, 1)];
      expect(Rules.turning(chain, 0).toString(), '([1, -1, -1, 1], false)');
      final idle = [(0, 2, 2), (6, 2, 2), (3, 2, 1)];
      expect(Rules.turning(idle, 0).toString(), '([1, 1, -1], false)');
      final still = [(0, 0, 1), (6, 0, 1)];
      expect(Rules.turning(still, 0).toString(), '([1, 0], false)');
    });

    test('a ring of three jams and a ring of four turns', () {
      final three = [(0, 0, 1), (3, 0, 2), (0, 4, 3)];
      expect(Rules.inRing(three, 0), isTrue);
      expect(Rules.turning(three, 0).$2, isTrue);
      final four = [(1, 1, 1), (3, 1, 1), (1, 3, 1), (3, 3, 1)];
      expect(Rules.inRing(four, 0), isTrue);
      expect(Rules.turning(four, 0).toString(), '([1, -1, -1, 1], false)');
      expect(Rules.inRing([(0, 0, 1), (2, 0, 1), (4, 0, 1)], 0), isFalse);
    });

    test('speeds: the crank\'s radius over the gear\'s, walked or not', () {
      expect(Rules.speed((0, 2, 2), (5, 2, 1)), (2, 1));
      expect(Rules.speed((0, 2, 2), (6, 2, 2)), (1, 1));
      expect(Rules.speed((0, 0, 1), (3, 0, 2)), (1, 2));
      final twice = [(0, 2, 2), (5, 2, 1), (3, 2, 1)];
      expect(Rules.speedWalked(twice, 0, 1), (2, 1));
      expect(Rules.speedWalked(twice, 0, 2), (2, 1));
      final idle = [(0, 2, 2), (6, 2, 2), (3, 2, 1)];
      expect(Rules.speedWalked(idle, 0, 1), (1, 1));
    });
  });

  group('the sweep', () {
    test('every level\'s count', () {
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.width, level.height, level.fixed, level.tray, level.meets);
        expect((met, all), (level.ways, level.settings), reason: level.name);
      }
    });

    test('the first placings', () {
      expect(Play.aimFor(Levels.at(0)), [(0, 2, 2), (6, 2, 2), (3, 2, 1)]);
      expect(Play.aimFor(Levels.at(1)), [(0, 0, 1), (6, 0, 1), (2, 0, 1), (4, 0, 1)]);
      expect(Play.aimFor(Levels.at(2)), [(0, 2, 2), (5, 2, 1), (3, 2, 1)]);
      expect(Play.aimFor(Levels.at(3)), [(1, 1, 1), (3, 1, 1), (1, 3, 1), (3, 3, 1)]);
      expect(Play.aimFor(Levels.at(4)), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Ring of Three']);
      expect(Levels.at(4).hasMill, isFalse);
      expect(Levels.at(0).hasMill, isTrue);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the gear of one so the crank turns the mill');
      expect(Levels.at(3).task, 'set the gears of one, one and one round the crank in a ring that turns');
      expect(Levels.at(4).task, 'set the gears of two and three round the crank in a ring that turns');
    });
  });

  group('the play', () {
    test('opens with the fixed gears alone', () {
      final play = Play.of(Levels.at(0));
      expect(play.gears, [(0, 2, 2), (6, 2, 2)]);
      expect(play.ways, [1, 0]);
      expect(play.jam, isFalse);
      expect(play.isDone, isFalse);
    });

    test('a gear is held, set where it fits, and lifted', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(0);
      expect(play.heldRadius, 1);
      play = play.tap(1, 2);
      expect(play.refused, isTrue);
      play = play.tap(3, 2);
      expect(play.placed, [(3, 2, 1)]);
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
      play = Play.of(Levels.at(1)).hold(0).tap(2, 0);
      expect(play.slotPlaced, [true, false]);
      play = play.tap(2, 0);
      expect(play.placed, isEmpty);
      expect(play.moves, 1);
      // The crank is not lifted.
      expect(play.tap(0, 0).placed, isEmpty);
    });

    test('back undoes one action', () {
      final play = Play.of(Levels.at(0)).hold(0).tap(3, 2);
      expect(play.back.placed, isEmpty);
      expect(play.back.held, 0);
    });

    test('the turn against lands by hand', () {
      var play = Play.of(Levels.at(1));
      play = play.hold(0).tap(2, 0).hold(1).tap(4, 0);
      expect(play.ways, [1, -1, -1, 1]);
      expect(play.isDone, isTrue);
    });

    test('the ring of three jams and admits it', () {
      var play = Play.of(Levels.at(4));
      play = play.hold(0).tap(3, 0).hold(1).tap(0, 4);
      expect(play.jam, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer walks the sweep\'s first placing', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (Aim.tray, 0, 0));
      play = play.hold(0);
      expect(play.next, (Aim.peg, 2, 0));
      play = play.tap(2, 0);
      // A gear in the wrong place is lifted first.
      play = play.hold(1).tap(4, 2);
      expect(play.next, (Aim.lift, 4, 2));
    });

    test('following the pointer gears every winnable train', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final (aim, a, b) = play.next!;
          play = aim == Aim.tray ? play.hold(a) : play.tap(a, b);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.tray.length);
      }
    });
  });
}
