import 'package:flutter_test/flutter_test.dart';
import 'package:beamsley/shadow/frac.dart';
import 'package:beamsley/shadow/levels.dart';
import 'package:beamsley/shadow/play.dart';
import 'package:beamsley/shadow/rules.dart';

/// The lantern, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the casting', () {
    test('the field, the shadows, the meetings and the axis on a named setting', () {
      expect(Rules.pegs, hasLength(24));
      expect(Rules.pegs.contains((0, 0)), isFalse);
      expect(Rules.casts, [-2, -1, 2, 3]);
      expect(Rules.shadow((1, 0), 3), (3, 0));
      expect(Rules.shadow((-1, 2), -2), (2, -4));
      final t = [(1, 0), (0, 1), (-1, -1)];
      expect(Rules.valid(t), isTrue);
      expect(Rules.flat([(1, 0), (2, 0), (-1, 0)]), isTrue);
      expect(Rules.sharesRay([(-2, -2), (-1, -2), (-1, -1)]), isTrue);
      expect(Rules.valid([(-2, -2), (-1, -2), (-1, -1)]), isFalse);
      final m = Rules.meetings(t, [2, 3, -1]);
      expect(m.map(Rules.tellPoint).toList(), ['(4, -3)', '(1/2, 2)', '(5/3, 1/3)']);
      expect(Rules.inLine(m), isTrue);
      expect(Rules.tellLine(Rules.axis(m)!), 'the line -10 x - 7 y = -19');
      final far = Rules.meetings(t, [2, 2, 2]);
      expect(far.every(Rules.atInfinity), isTrue);
      expect(Rules.tellLine(Rules.axis(far)!), 'the line at infinity');
      expect(Rules.meetingByHand(t, [2, 3, -1], 0), (Frac.of(4), Frac.of(-3)));
      expect(Rules.meetingByHand(t, [2, 2, 2], 0), isNull);
      expect(Rules.tidy((2, 4, 6)), (1, 2, 3));
      expect(Rules.tidy((-2, -4, -6)), (1, 2, 3));
      expect(Rules.tellPeg((-2, 1)), '(-2, 1)');
    });

    test('the sweep: the two voices agree on every setting, and the three meetings always lie on one line', () {
      var triangles = 0, settings = 0, allFar = 0, whole = 0, lantern = 0;
      for (final a in Rules.pegs) {
        for (final b in Rules.pegs) {
          if (b == a) continue;
          for (final c in Rules.pegs) {
            if (c == a || c == b) continue;
            final t = [a, b, c];
            if (!Rules.valid(t)) continue;
            triangles++;
            for (final ta in Rules.casts) {
              for (final tb in Rules.casts) {
                for (final tc in Rules.casts) {
                  settings++;
                  final casts = [ta, tb, tc];
                  final m = Rules.meetings(t, casts);
                  expect(Rules.inLine(m), isTrue, reason: '$t $casts');
                  expect(m.any(Rules.isNowhere), isFalse, reason: '$t $casts');
                  for (var s = 0; s < 3; s++) {
                    final byHand = Rules.meetingByHand(t, casts, s);
                    if (byHand == null) {
                      expect(Rules.atInfinity(m[s]), isTrue, reason: '$t $casts $s');
                    } else {
                      expect(Frac.of(m[s].$1, m[s].$3), byHand.$1, reason: '$t $casts $s');
                      expect(Frac.of(m[s].$2, m[s].$3), byHand.$2, reason: '$t $casts $s');
                    }
                  }
                  final far = m.where(Rules.atInfinity).length;
                  expect(far == 3, ta == tb && tb == tc, reason: '$t $casts');
                  expect(far, isNot(2), reason: '$t $casts');
                  if (far == 3) allFar++;
                  final axis = Rules.axis(m);
                  expect(axis, isNotNull, reason: '$t $casts');
                  if (m.every((h) => h.$3 != 0 && h.$1 % h.$3 == 0 && h.$2 % h.$3 == 0)) whole++;
                  if (axis!.$3 == 0 && !(axis.$1 == 0 && axis.$2 == 0)) lantern++;
                }
              }
            }
          }
        }
      }
      expect((triangles, settings), (7992, 511488));
      expect((allFar, whole, lantern), (31968, 1248, 7200));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Crooked Axis']);
      for (final level in Levels.all) {
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim!.$1, [(-2, -2), (0, -2), (-2, 1)]);
      expect(Levels.at(0).aim!.$2, [-1, 3, 2]);
      expect(Levels.at(2).aim!.$2, [-2, -2, -2]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the pegs and the casts so that the three meetings all fall on peg places');
      expect(Levels.at(1).task, 'set the pegs and the casts so that the axis lies level');
      expect(Levels.at(2).task, 'set the pegs and the casts so that all three meetings are far off and the axis is the line at infinity');
      expect(Levels.at(3).task, 'set the pegs and the casts so that the axis runs through the lantern');
      expect(Levels.at(4).task, 'set the pegs and the casts so that the three meetings do not lie on one line');
    });

    test('an ask is met by the setting', () {
      final t = [(1, 0), (0, 1), (-1, -1)];
      expect(Levels.at(2).meets(t, [2, 2, 2]), isTrue);
      expect(Levels.at(2).meets(t, [2, 2, 3]), isFalse);
      expect(Levels.at(0).meets([(-2, -2), (0, -2), (-2, 1)], [-1, 3, 2]), isTrue);
      expect(Levels.at(0).meets(t, [2, 3, -1]), isFalse);
      expect(Levels.at(1).meets([(-2, -2), (-1, -2), (-2, -1)], [-2, -2, -1]), isTrue);
      expect(Levels.at(3).meets([(-2, -2), (-1, -2), (-2, -1)], [-1, -2, -2]), isTrue);
      expect(Levels.at(4).meets(t, [2, 3, -1]), isFalse);
      expect(Levels.at(0).meets([(-2, -2), (-1, -2), (-1, -1)], [2, 2, 2]), isFalse);
      expect(Levels.at(2).meets(t, [2, 2]), isFalse);
    });
  });

  group('the play', () {
    test('opens with no pegs and every cast at two', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.pegs, isEmpty);
        expect(play.casts, [2, 2, 2]);
        expect((play.moves, play.full, play.tried), (0, false, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps set three pegs, the last one lifts, and a peg on a used ray is refused', () {
      var play = Play.of(Levels.at(4)).tap((1, 0));
      expect(play.pegs, [(1, 0)]);
      expect(play.tap((2, 0)), same(play));
      expect(play.tap((-1, 0)), same(play));
      expect(play.tap((1, 0)).pegs, isEmpty);
      play = play.tap((0, 1)).tap((-1, -1));
      expect(play.full, isTrue);
      expect(play.sound, isTrue);
      expect(play.tried, 1);
      expect(play.shadows, [(2, 0), (0, 2), (-2, -2)]);
      expect(play.farOff, 3);
      expect(play.tap((2, 1)), same(play));
      expect(play.tap((5, 5)), same(play));
    });

    test('a cast steps along the row and stops at its ends', () {
      final play = Play.of(Levels.at(4)).tap((1, 0)).tap((0, 1)).tap((-1, -1));
      final atTheEnd = play.step(0, 1);
      expect(atTheEnd.casts, [3, 2, 2]);
      expect(atTheEnd.step(0, 1), same(atTheEnd));
      expect(play.step(1, -1).casts, [2, -1, 2]);
      expect(play.step(3, 1), same(play));
      expect(play.step(0, 0), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((1, 0)).tap((0, 1));
      expect(play.back.pegs, [(1, 0)]);
      expect(play.back.back.pegs, isEmpty);
    });

    test('the pointer sets the pegs, then steps the casts', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, ('peg', 0));
      expect(play.wanted, (-2, -2));
      expect(play.pointed(('peg', 0)), 'Set peg A at (-2, -2).');
      play = play.tap((1, 1));
      expect(play.next, ('lift', 0));
      expect(play.pointed(('lift', 0)), 'Lift peg A.');
      play = play.tap((1, 1)).tap((-2, -2)).tap((0, -2)).tap((-2, 1));
      expect(play.next, ('cast', 0));
      expect(play.pointed(('cast', 0)), 'Step A\'s cast in.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final n = play.next!;
          play = n.$1 == 'peg' ? play.tap(play.wanted!) : n.$1 == 'lift' ? play.tap(play.pegs.last) : play.step(n.$2, play.castWay(n.$2));
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var whole = Play.of(Levels.at(0));
      while (!whole.isDone) {
        final n = whole.next!;
        whole = n.$1 == 'peg' ? whole.tap(whole.wanted!) : n.$1 == 'lift' ? whole.tap(whole.pegs.last) : whole.step(n.$2, whole.castWay(n.$2));
      }
      expect(whole.moves, 5);
    });

    test('the crooked axis admits it after three settings, or twenty-four taps', () {
      var play = Play.of(Levels.at(4)).tap((1, 0)).tap((0, 1)).tap((-1, -1));
      expect(play.tried, 1);
      expect(play.gaveUp, isFalse);
      play = play.step(0, 1);
      expect(play.tried, 2);
      expect(play.gaveUp, isFalse);
      play = play.step(1, 1);
      expect(play.tried, 3);
      expect(play.gaveUp, isTrue);
      expect(play.moves, 5);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        wander = k.isEven ? wander.tap((1, 0)) : wander.tap((1, 0));
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 24);
    });

    test('the why tells Desargues and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Desargues proved it in 1639'));
      expect(words, contains('511,488'));
      expect(words, contains('This is ask 5, The Crooked Axis.'));
      expect(words, contains('crossed in full'));
    });
  });
}
