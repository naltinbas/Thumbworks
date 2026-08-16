import 'package:flutter_test/flutter_test.dart';
import 'package:footbury/foot/frac.dart';
import 'package:footbury/foot/levels.dart';
import 'package:footbury/foot/play.dart';
import 'package:footbury/foot/rules.dart';

/// The feet, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the feet', () {
    test('the rim, the field, the feet, the line and the two measures on a named setting', () {
      expect(Rules.rim, hasLength(12));
      expect(Rules.rim.every(Rules.onRim), isTrue);
      expect(Rules.field, hasLength(121));
      expect(Rules.triangles, hasLength(220));
      expect(Rules.onRim((3, 4)), isTrue);
      expect(Rules.onRim((3, 3)), isFalse);
      expect(Rules.inField((5, -5)), isTrue);
      expect(Rules.inField((6, 0)), isFalse);
      final t = [(5, 0), (-4, 3), (-3, -4)];
      expect(Rules.feet(t, (0, 5)).map(Rules.tellPoint).toList(), ['(-21/5, 22/5)', '(3, -1)', '(-1, 2)']);
      expect(Rules.simsonLine(t, (0, 5)), isNotNull);
      expect(Rules.ratioByFeet(t, (0, 5)), Frac.zero);
      expect(Rules.ratioByEuler((0, 5)), Frac.zero);
      expect(Rules.feet(t, (0, 0)).map(Rules.tellPoint).toList(), ['(-7/2, -1/2)', '(1, -2)', '(1/2, 3/2)']);
      expect(Rules.ratioByFeet(t, (0, 0)), Frac.of(1, 4));
      expect(Rules.ratioByEuler((0, 0)), Frac.of(1, 4));
      expect(Rules.simsonLine(t, (0, 0)), isNull);
      expect(Rules.ratioByFeet(t, (1, 2)), Frac.of(1, 5));
      expect(Rules.ratioByEuler((5, 5)), Frac.of(-1, 4));
      expect(Rules.twiceAreaOf(t), Frac.of(60));
      final line = Rules.simsonLine([(5, 0), (4, 3), (-5, 0)], (0, -5))!;
      expect(Rules.through(line, (Frac.zero, Frac.zero)), isTrue);
      expect(Rules.level(Rules.simsonLine([(5, 0), (4, 3), (3, 4)], (0, 5))!), isTrue);
      expect(Rules.alongSide(Rules.simsonLine([(5, 0), (4, 3), (3, 4)], (-3, -4))!, [(5, 0), (4, 3), (3, 4)]), isTrue);
      expect(Rules.tellPeg((-3, 4)), '(-3, 4)');
    });

    test('the sweep: the two measures agree on every setting, and the feet line up on the rim alone', () {
      var settings = 0, onRim = 0, lines = 0;
      for (final t in Rules.triangles) {
        for (final p in Rules.field) {
          if (t.contains(p)) continue;
          settings++;
          final r = Rules.ratioByFeet(t, p);
          expect(Rules.ratioByEuler(p), r, reason: '$t $p');
          final line = Rules.simsonLine(t, p);
          if (Rules.onRim(p)) {
            onRim++;
            expect(line, isNotNull, reason: '$t $p');
          } else {
            expect(line, isNull, reason: '$t $p');
          }
          if (line != null) lines++;
        }
      }
      expect((settings, onRim, lines), (25960, 1980, 1980));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Line Off the Rim']);
      for (final level in Levels.all) {
        var ways = 0;
        for (final t in Rules.triangles) {
          for (final p in Rules.field) {
            if (level.meets(t, p)) ways++;
          }
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim!.$1, [(5, 0), (4, 3), (3, 4)]);
      expect(Levels.at(0).aim!.$2, (0, 0));
      expect(Levels.at(2).aim!.$1, [(5, 0), (4, 3), (-5, 0)]);
      expect(Levels.at(2).aim!.$2, (0, -5));
      expect(Levels.at(3).aim!.$2, (0, 5));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set a triangle on the rim and a point whose feet make a quarter of it');
      expect(Levels.at(1).task, 'set a triangle on the rim and a point whose feet make a fifth of it');
      expect(Levels.at(2).task, 'set a triangle on the rim and a rim point whose feet lie in a line through the middle');
      expect(Levels.at(3).task, 'set a triangle on the rim and a rim point whose feet lie in a level line');
      expect(Levels.at(4).task, 'set a triangle on the rim and a point off the rim whose feet lie in a line');
    });

    test('an ask is met by the setting', () {
      final t = [(5, 0), (-4, 3), (-3, -4)];
      expect(Levels.at(0).meets(t, (0, 0)), isTrue);
      expect(Levels.at(0).meets(t, (1, 2)), isFalse);
      expect(Levels.at(1).meets(t, (1, 2)), isTrue);
      expect(Levels.at(1).meets(t, (-2, -1)), isTrue);
      expect(Levels.at(1).meets(t, (0, 0)), isFalse);
      expect(Levels.at(2).meets([(5, 0), (4, 3), (-5, 0)], (0, -5)), isTrue);
      expect(Levels.at(2).meets(t, (0, 5)), isFalse);
      expect(Levels.at(3).meets([(5, 0), (4, 3), (3, 4)], (0, 5)), isTrue);
      expect(Levels.at(3).meets(t, (0, 5)), isFalse);
      expect(Levels.at(4).meets(t, (0, 5)), isFalse);
      expect(Levels.at(4).meets(t, (0, 0)), isFalse);
      expect(Levels.at(0).meets([(5, 0), (4, 3), (3, 3)], (0, 0)), isFalse);
      expect(Levels.at(0).meets(t, (5, 0)), isFalse);
    });
  });

  group('the play', () {
    test('opens with nothing set', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.pegs, isEmpty);
        expect((play.moves, play.full, play.tried), (0, false, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps set three rim corners then a point anywhere, and the last one lifts', () {
      var play = Play.of(Levels.at(4)).tap((5, 0));
      expect(play.pegs, [(5, 0)]);
      expect(play.tap((1, 1)), same(play));
      expect(play.tap((5, 0)).pegs, isEmpty);
      play = play.tap((-4, 3)).tap((-3, -4));
      expect(play.corners, [(5, 0), (-4, 3), (-3, -4)]);
      expect(play.tap((5, 0)), same(play));
      play = play.tap((0, 0));
      expect(play.full, isTrue);
      expect(play.point, (0, 0));
      expect(play.tried, 1);
      expect(play.ratio, Frac.of(1, 4));
      expect(play.ratioByEuler, Frac.of(1, 4));
      expect(play.line, isNull);
      expect(play.tap((2, 2)), same(play));
      final rim = play.tap((0, 0)).tap((0, 5));
      expect(rim.pointOnRim, isTrue);
      expect(rim.line, isNotNull);
      expect(rim.tried, 1);
      expect(play.tap((6, 0)), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((5, 0)).tap((0, 5));
      expect(play.back.pegs, [(5, 0)]);
      expect(play.back.back.pegs, isEmpty);
    });

    test('the pointer sets the aim in order, and lifts a stray last peg', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, ((5, 0), false));
      expect(Play.pointed(((5, 0), false), set: 0), 'Set corner A at (5, 0).');
      play = play.tap((0, 5));
      expect(play.next, ((0, 5), true));
      expect(Play.pointed(play.next!, set: 1), 'Lift the peg at (0, 5).');
      play = play.tap((0, 5)).tap((5, 0)).tap((4, 3)).tap((3, 4));
      expect(play.next, ((0, 5), false));
      expect(Play.pointed(play.next!, set: 3), 'Set the point at (0, 5).');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in four taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final (peg, _) = play.next!;
          play = play.tap(peg);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 4, reason: level.name);
      }
    });

    test('the line off the rim admits it after three points off the rim, or sixteen taps', () {
      var play = Play.of(Levels.at(4)).tap((5, 0)).tap((-4, 3)).tap((-3, -4)).tap((0, 0));
      expect(play.tried, 1);
      expect(play.gaveUp, isFalse);
      play = play.tap((0, 0)).tap((1, 2));
      expect(play.tried, 2);
      play = play.tap((1, 2)).tap((2, 2));
      expect(play.tried, 3);
      expect(play.gaveUp, isTrue);
      expect(play.moves, 8);
      expect(play.ratio, Frac.of(17, 100));
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 16; k++) {
        wander = wander.tap((5, 0));
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 16);
    });

    test('the why tells Wallace, Simson, Euler and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Wallace found in 1799'));
      expect(words, contains('Euler had the measure of it in 1763'));
      expect(words, contains('25,960'));
      expect(words, contains('This is ask 5, The Line Off the Rim.'));
      expect(words, contains('footed in full'));
    });
  });
}
