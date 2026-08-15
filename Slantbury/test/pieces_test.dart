import 'package:flutter_test/flutter_test.dart';
import 'package:slantbury/pieces/geometry.dart';
import 'package:slantbury/pieces/levels.dart';
import 'package:slantbury/pieces/play.dart';
import 'package:slantbury/pieces/rules.dart';

/// The law of the pieces, held to.
void main() {
  group('the geometry', () {
    test('fractions add, multiply and say themselves', () {
      expect(Q(2, 4), Q(1, 2));
      expect(Q(1, 2) + Q(1, 3), Q(5, 6));
      expect(Q(3, 8) * Q(2, 5), Q(3, 20));
      expect(Q(11, 8).toString(), '1 3/8');
      expect(Q(2, 5).toString(), '2/5');
      expect(Q(4, 2).toString(), '2');
      expect(Q(1, 2) < Q(2, 3), isTrue);
      expect((-Q(1, 3)).sign, -1);
    });

    test('areas and cuts come out exact', () {
      expect(area2([pt(0, 0), pt(8, 0), pt(8, 3)]), Q(24));
      expect(area2([pt(0, 0), pt(3, 0), pt(5, 5), pt(0, 5)]), Q(40));
      final a = [pt(0, 0), pt(4, 0), pt(4, 4), pt(0, 4)];
      final b = [pt(2, 2), pt(6, 2), pt(6, 6), pt(2, 6)];
      expect(shared2(a, b), Q(8));
      expect(shared2(a, [pt(4, 0), pt(8, 0), pt(8, 4), pt(4, 4)]), Q.zero);
      // The sliver: the two slants across the frame make a parallelogram of one.
      expect(area2([pt(0, 0), pt(8, 3), pt(13, 5), pt(5, 2)]), Q(2));
      // Two slanted pieces sharing a corner of area three tenths.
      final tri = [pt(0, 0), pt(5, 0), pt(5, 2)];
      final trap = [pt(0, 0), pt(3, 1), pt(3, 3), pt(0, 3)];
      expect(shared2(tri, trap), Q(3, 5));
      expect(encloses(tri, pt(4, 1)), isTrue);
      expect(encloses(tri, pt(1, 1)), isFalse);
    });
  });

  group('the rules', () {
    test('the pieces of the eight-square and their ways', () {
      const r = Rules(side: 8, width: 8, height: 8);
      expect(r.pieces.map((p) => p.area2).toList(), [Q(24), Q(24), Q(40), Q(40)]);
      expect(r.pieces2, Q(128));
      expect(r.pieces[0].turned(0, false), [(0, 0), (8, 0), (8, 3)]);
      expect(r.pieces[0].ways, hasLength(8));
      expect(r.boxOf(0, const Laying(1, false, 0, 0)), (3, 8));
      expect(r.layings(0), hasLength(48));
      expect(r.layings(2), hasLength(128));
      expect(r.inside(0, const Laying(0, false, 1, 0)), isFalse);
      expect(r.inside(0, const Laying(0, false, 0, 5)), isTrue);
    });

    test('the frame\'s classic laying shares nothing and leaves one square', () {
      const r = Rules(side: 8, width: 13, height: 5);
      const classic = [Laying(0, false, 0, 0), Laying(2, false, 5, 2), Laying(1, true, 0, 0), Laying(3, true, 8, 0)];
      expect(r.overlapOf(classic), Q.zero);
      expect(r.gapOf(classic), Q(2));
      for (var p = 0; p < 4; p++) {
        expect(r.inside(p, classic[p]), isTrue, reason: '$p');
      }
      expect(r.frame2 - r.pieces2, Q(2));
    });

    test('the small frame\'s classic laying shares exactly one square', () {
      const r = Rules(side: 5, width: 8, height: 3);
      const classic = [Laying(0, false, 0, 0), Laying(2, false, 3, 1), Laying(1, true, 0, 0), Laying(3, true, 5, 0)];
      expect(r.overlapOf(classic), Q(2));
      expect(r.gapOf(classic), Q.zero);
      expect(r.pieces2 - r.frame2, Q(2));
    });

    test('the sweeps of the frames', () {
      const frame = Rules(side: 8, width: 13, height: 5);
      final (landing, all, first) = frame.sweep(overlapAllowed2: Q.zero, mustFill: false);
      expect(landing, 2);
      expect(all, 6533136);
      expect(first, isNotNull);
      expect(frame.sweep(overlapAllowed2: Q.zero, mustFill: true).$1, 0);
      const small = Rules(side: 5, width: 8, height: 3);
      expect(small.sweep(overlapAllowed2: Q(2), mustFill: false).$1, 2);
      expect(small.sweep(overlapAllowed2: Q.zero, mustFill: false).$1, 0);
      const square = Rules(side: 5, width: 5, height: 5);
      final (squareLanding, squareAll, squareFirst) = square.sweep(overlapAllowed2: Q.zero, mustFill: false);
      expect(squareLanding, 16);
      expect(squareAll, 1267776);
      expect(squareFirst, isNotNull);
    });

    test('Cassini to the twentieth', () {
      expect(fibonacci(6), 13);
      for (var n = 2; n <= 20; n++) {
        expect(fibonacci(n - 1) * fibonacci(n + 1) - fibonacci(n) * fibonacci(n), n.isEven ? -1 : 1, reason: '$n');
      }
    });

    test('every label\'s ways is what the sweep finds, on the frames swept here', () {
      for (final level in [Levels.at(1), Levels.at(2), Levels.at(3), Levels.at(4)]) {
        final (landing, all, _) = level.rules.sweep(overlapAllowed2: level.overlapAllowed2, mustFill: level.mustFill);
        expect(landing, level.ways, reason: level.name);
        expect(all, level.layings, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with the tray full and nothing in hand', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.laidCount, 0, reason: level.name);
        expect(play.held, isNull);
        expect(play.isDone, isFalse);
        expect(play.gap, Q(level.width * level.height));
      }
    });

    test('a piece is taken up, turned, flipped, laid, and back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(0);
      expect(play.held, 0);
      play = play.turn;
      expect(play.ways[0], (1, false));
      play = play.flip;
      expect(play.ways[0], (1, true));
      play = play.turn.turn.turn.flip;
      expect(play.ways[0], (0, false));
      expect(play.lay(1, 0), same(play));
      play = play.lay(0, 0);
      expect(play.moves, 1);
      expect(play.held, isNull);
      expect(play.laidDown(0), isTrue);
      expect(play.cornersOf(0), [pt(0, 0), pt(8, 0), pt(8, 3)]);
      final lifted = play.hold(0);
      expect(lifted.laidDown(0), isFalse);
      expect(lifted.held, 0);
      expect(lifted.moves, 1);
      final back = play.hold(1).back;
      expect(back.moves, 0);
      expect(back.laidDown(0), isFalse);
      expect(back.held, isNull);
      expect(play.hold(0).hold(0).held, isNull);
    });

    test('the frame by hand: no overlap, one square bare', () {
      var play = Play.of(Levels.at(1));
      play = play.hold(0).lay(0, 0);
      play = play.hold(1).turn.turn.lay(5, 2);
      play = play.hold(2).turn.flip.lay(0, 0);
      play = play.hold(3).turn.turn.turn.flip.lay(8, 0);
      expect(play.overlaps, isEmpty);
      expect(play.overlap, Q.zero);
      expect(play.gap, Q.one);
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
      expect(play.hold(0), same(play));
    });

    test('two pieces on one spot share their area, in rust', () {
      final play = Play.of(Levels.at(1)).hold(0).lay(0, 0).hold(1).lay(0, 0);
      expect(play.overlaps, hasLength(1));
      expect(play.overlap, Q(12));
      expect(play.gap, Q(65 - 24 + 12));
      // Slid four along, the second triangle's part under the first's slant
      // is a triangle four wide and one and a half tall: three squares.
      final part = Play.of(Levels.at(1)).hold(0).lay(0, 0).hold(1).lay(4, 0);
      expect(part.overlap, Q(3));
    });

    test('the small frame by hand shares exactly one', () {
      var play = Play.of(Levels.at(3));
      play = play.hold(0).lay(0, 0);
      play = play.hold(1).turn.turn.lay(3, 1);
      play = play.hold(2).turn.flip.lay(0, 0);
      play = play.hold(3).turn.turn.turn.flip.lay(5, 0);
      expect(play.overlap, Q.one);
      expect(play.overlaps, hasLength(3));
      expect(play.isDone, isTrue);
    });

    test('the pointer lays every winnable frame', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final (what, p) = play.next!;
          if (what == 'lift') {
            play = play.hold(p);
            continue;
          }
          final target = Play.aimFor(play.level)![p];
          play = play.hold(p).turnTo(p, (target.turn, target.flipped)).lay(target.x, target.y);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, 4, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says lift when a piece is off the laying', () {
      final play = Play.of(Levels.at(1)).hold(0).lay(1, 0);
      expect(play.next, ('lift', 0));
      expect(Play.of(Levels.at(1)).next, ('lay', 0));
      expect(Play.of(Levels.at(1)).hold(2).next, ('lay', 2));
    });

    test('the hopeless frame shows the sliver and admits it', () {
      var play = Play.of(Levels.at(4));
      play = play.hold(0).lay(0, 0);
      play = play.hold(1).turn.turn.lay(5, 2);
      play = play.hold(2).turn.flip.lay(0, 0);
      expect(play.gaveUp, isFalse);
      play = play.hold(3).turn.turn.turn.flip.lay(8, 0);
      expect(play.overlap, Q.zero);
      expect(play.gap, Q.one);
      expect(play.isDone, isFalse);
      expect(play.sliverShown, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.hold(0), same(play));
    });

    test('the hopeless frame also admits it at twenty-four layings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        play = play.hold(0).lay(k % 2, 0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.sliverShown, isFalse);
    });

    test('a winnable frame never gives up', () {
      var play = Play.of(Levels.at(1));
      for (var k = 0; k < 26; k++) {
        play = play.hold(0).lay(k % 2, 0);
      }
      expect(play.moves, 26);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands laid, the sliver bare', () {
      final mark = Play.standing(Levels.at(1), Play.aimFor(Levels.at(1))!);
      expect(mark.isDone, isTrue);
      expect(mark.gap, Q.one);
    });
  });
}
