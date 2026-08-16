import 'package:flutter_test/flutter_test.dart';
import 'package:linesby/line/frac.dart';
import 'package:linesby/line/levels.dart';
import 'package:linesby/line/play.dart';
import 'package:linesby/line/rules.dart';

/// The centres, the line, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the centres', () {
    test('worked exactly on the three-peg corner and the opening', () {
      expect(Rules.told(Rules.centroid((0, 0), (1, 0), (0, 1))), '(1/3, 1/3)');
      expect(Rules.told(Rules.circumcentre((0, 0), (1, 0), (0, 1))), '(1/2, 1/2)');
      expect(Rules.told(Rules.orthocentre((0, 0), (1, 0), (0, 1))), '(0, 0)');
      expect(Rules.told(Rules.centroid((1, 1), (5, 2), (2, 4))), '(8/3, 7/3)');
      expect(Rules.told(Rules.circumcentre((1, 1), (5, 2), (2, 4))), '(63/22, 45/22)');
      expect(Rules.told(Rules.orthocentre((1, 1), (5, 2), (2, 4))), '(25/11, 32/11)');
      expect(Rules.orthocentreByO((1, 1), (5, 2), (2, 4)), Rules.orthocentre((1, 1), (5, 2), (2, 4)));
      expect(Rules.told(Rules.ninePoint((0, 0), (4, 0), (0, 3))), '(1, 3/4)');
      expect(Rules.kind((1, 1), (5, 2), (2, 4)), 'acute');
      expect(Rules.kind((0, 0), (1, 0), (0, 1)), 'right');
      expect(Rules.kind((0, 0), (1, 0), (4, 1)), 'obtuse');
      expect(Rules.rightAt((0, 0), (6, 0), (3, 3)), (3, 3));
      expect(Rules.sides((0, 0), (1, 0), (4, 1)), [10, 17, 1]);
      expect(Rules.spread((0, 0), (4, 1), (1, 4)), (18, 17));
      expect(Rules.inLine((0, 0), (2, 1), (4, 2)), isTrue);
      expect(Rules.inLine((0, 0), (2, 1), (4, 3)), isFalse);
      expect(Rules.where(Rules.circumcentre((0, 0), (1, 0), (0, 1)), (0, 0), (1, 0), (0, 1)), 'on the edge');
      expect(Rules.where(Rules.circumcentre((1, 1), (5, 2), (2, 4)), (1, 1), (5, 2), (2, 4)), 'inside');
      expect(Rules.onField(Rules.circumcentre((0, 0), (1, 0), (4, 1))), isFalse);
      expect(Rules.isWhole(Rules.circumcentre((0, 0), (6, 0), (3, 3))), isTrue);
    });

    test('the line holds on every triangle of a small field, both ways', () {
      // The seven-by-seven is the checker's; here the corner of it.
      final pegs = [for (var y = 0; y < 4; y++) for (var x = 0; x < 4; x++) (x, y)];
      var seen = 0;
      for (var i = 0; i < pegs.length; i++) {
        for (var j = i + 1; j < pegs.length; j++) {
          for (var k = j + 1; k < pegs.length; k++) {
            final (a, b, c) = (pegs[i], pegs[j], pegs[k]);
            if (Rules.inLine(a, b, c)) continue;
            seen++;
            final g = Rules.centroid(a, b, c), o = Rules.circumcentre(a, b, c), h = Rules.orthocentre(a, b, c);
            expect(Rules.orthocentreByO(a, b, c), h, reason: '$a $b $c');
            expect(Rules.inLineF(g, o, h), isTrue, reason: '$a $b $c');
            expect(Rules.twiceAsFar(g, o, h), isTrue, reason: '$a $b $c');
            expect(Rules.dist2F(o, Rules.whole(a)), Rules.dist2F(o, Rules.whole(b)));
          }
        }
      }
      expect(seen, 516);
      expect(Frac.of(2, 4), Frac.of(1, 2));
    });

    test('the field: 49 pegs, 17,600 triangles', () {
      expect(Rules.pegs, hasLength(49));
      expect(Rules.triangles, hasLength(17600));
      expect(Rules.triangles.first, ((0, 0), (1, 0), (0, 1)));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The One Point']);
      expect(Levels.at(0).aim, ((0, 0), (1, 0), (0, 1)));
      expect(Levels.at(1).aim, ((0, 0), (4, 0), (1, 3)));
      expect(Levels.at(2).aim, ((0, 0), (1, 0), (4, 1)));
      expect(Levels.at(3).aim, ((0, 0), (6, 0), (3, 3)));
      expect(Levels.at(4).aim, isNull);
      for (final level in Levels.all.where((l) => l.winnable)) {
        final (a, b, c) = level.aim!;
        expect(level.meets(a, b, c), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the pegs so the orthocentre sits on a corner of the triangle');
      expect(Levels.at(2).task, 'set the pegs so the circumcentre falls off the field altogether');
      expect(Levels.at(4).task, 'set the pegs so the three centres are one point');
    });

    test('an ask is met by the triangle, in any order of its pegs', () {
      expect(Levels.at(0).meets((0, 1), (0, 0), (1, 0)), isTrue);
      expect(Levels.at(0).meets((1, 1), (5, 2), (2, 4)), isFalse);
      expect(Levels.at(1).meets((4, 0), (1, 3), (0, 0)), isTrue);
      expect(Levels.at(1).meets((0, 0), (1, 0), (0, 1)), isFalse);
      expect(Levels.at(2).meets((0, 0), (1, 0), (4, 1)), isTrue);
      expect(Levels.at(2).meets((0, 0), (6, 0), (3, 3)), isFalse);
      expect(Levels.at(3).meets((0, 0), (6, 0), (0, 6)), isTrue);
      expect(Levels.at(3).meets((0, 0), (1, 0), (0, 1)), isFalse);
      expect(Levels.at(4).meets((0, 0), (4, 1), (1, 4)), isFalse);
      expect(Levels.at(0).meets((0, 0), (2, 1), (4, 2)), isFalse);
    });
  });

  group('the play', () {
    test('opens on the same acute triangle for every ask, nothing lifted', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.pegs, [(1, 1), (5, 2), (2, 4)]);
        expect(play.held, isNull);
        expect((play.moves, play.kind, play.whereO), (0, 'acute', 'inside'));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap lifts a peg, another sets it down, and a line of three is refused', () {
      var play = Play.of(Levels.at(0));
      expect(play.tap((3, 3)), same(play));
      play = play.tap((1, 1));
      expect(play.held, 0);
      expect(play.moves, 0);
      play = play.tap((5, 2));
      expect(play.held, 1);
      play = play.tap((5, 2));
      expect(play.held, isNull);
      play = play.tap((1, 1)).tap((0, 0));
      expect(play.pegs, [(0, 0), (5, 2), (2, 4)]);
      expect((play.held, play.moves), (null, 1));
      // B to (4, 8)? Off the field; B to (1, 2) lines up with A and C.
      final lifted = play.tap((5, 2));
      expect(lifted.tap((1, 2)), same(lifted));
      expect(lifted.held, 1);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((1, 1)).tap((0, 0));
      expect(play.back.held, 0);
      expect(play.back.back.pegs, [(1, 1), (5, 2), (2, 4)]);
    });

    test('the pointer names a peg and its place, and lands every winnable ask', () {
      expect(Play.of(Levels.at(0)).next, (0, (0, 0)));
      expect(Play.pointed((0, (0, 0))), 'Move peg A to (0, 0).');
      expect(Play.of(Levels.at(4)).next, isNull);
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 6) {
          final (i, to) = play.next!;
          play = play.tap(play.pegs[i]).tap(to);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, lessThanOrEqualTo(3), reason: level.name);
      }
    });

    test('the pointer keeps a peg in place when it already stands right', () {
      // C to (0, 1) first leaves A (1, 1), B (5, 2), C (0, 1): the aim
      // is then two moves off, and the pointer says so.
      var play = Play.of(Levels.at(0)).tap((2, 4)).tap((0, 1));
      expect(play.next, (0, (0, 0)));
      play = play.tap((1, 1)).tap((0, 0));
      expect(play.next, (1, (1, 0)));
      play = play.tap((5, 2)).tap((1, 0));
      expect(play.isDone, isTrue);
      expect(play.moves, 3);
    });

    test('the one point admits it at the nearest the field comes, or after twelve moves', () {
      var play = Play.of(Levels.at(4));
      play = play.tap((1, 1)).tap((0, 0));
      expect(play.gaveUp, isFalse);
      play = play.tap((5, 2)).tap((4, 1)).tap((2, 4)).tap((1, 4));
      expect(play.pegs, [(0, 0), (4, 1), (1, 4)]);
      expect(Rules.spread(play.a, play.b, play.c), Rules.nearest);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.tap(wander.a).tap(k.isEven ? (0, 0) : (1, 1));
      }
      expect(wander.moves, 12);
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Euler and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Euler showed in 1765'));
      expect(words, contains('17,600'));
      expect(words, contains('This is ask 5, The One Point.'));
      expect(words, contains('worked exactly'));
    });
  });
}
