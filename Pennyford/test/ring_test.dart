import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pennyford/ring/levels.dart';
import 'package:pennyford/ring/play.dart';
import 'package:pennyford/ring/rules.dart';

/// The angle, the measure, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the ring', () {
    test('equal coins take sixty degrees, six fit and never seven', () {
      for (var n = 1; n <= 6; n++) {
        expect(Rules.span(n, n) * 180 / pi, closeTo(60, 1e-9));
        expect(Rules.mostRound(n, n), 6);
        expect(Rules.fits(n, n, 6), isTrue);
        expect(Rules.fits(n, n, 7), isFalse);
        expect(Rules.spare(n, n), 0);
      }
    });

    test('the count by the angle and by the measure agree on every setting', () {
      for (var middle = 1; middle <= 6; middle++) {
        for (var ring = 1; ring <= 6; ring++) {
          expect(Rules.mostRound(middle, ring), Rules.mostMeasured(middle, ring), reason: '$middle, $ring');
        }
      }
      expect(Rules.mostRound(3, 1), 12);
      expect(Rules.mostRound(4, 3), 7);
      expect(Rules.mostRound(1, 2), 4);
      expect(Rules.mostRound(6, 1), 21);
      expect(Rules.mostRound(2, 1), 9);
      expect(Rules.settings, 36);
    });

    test('the spare and the angle each takes', () {
      expect(Rules.spare(3, 1), closeTo(12.5, 0.05));
      expect(Rules.spare(4, 3), closeTo(4.7, 0.05));
      expect(Rules.spare(1, 2), closeTo(25.5, 0.05));
      expect(Rules.span(3, 1) * 180 / pi, closeTo(28.96, 0.01));
      expect(Rules.span(1, 2) * 180 / pi, closeTo(83.62, 0.01));
    });

    test('the centres sit at equal angles at the two radii added', () {
      final (x, y) = Rules.centre(3, 1, 12, 0);
      expect(x, closeTo(0, 1e-12));
      expect(y, closeTo(4, 1e-12));
      final (x3, y3) = Rules.centre(3, 1, 12, 3);
      expect(x3, closeTo(4, 1e-12));
      expect(y3, closeTo(0, 1e-12));
    });

    test('the sweep', () {
      expect(Rules.sweep((m, r) => Rules.mostRound(m, r) == 12), (2, 36, (3, 1)));
      expect(Rules.sweep((m, r) => r >= m && Rules.fits(m, r, 7)), (0, 36, null));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Seven Pennies']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 36), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(1).task, 'set the sizes so exactly six coins fit round the middle coin, and no more');
      expect(Levels.at(4).task, 'set the sizes so seven coins fit round a middle coin no bigger than themselves');
    });

    test('an ask is met by the count exactly', () {
      expect(Levels.at(1).meets(3, 3), isTrue);
      expect(Levels.at(1).meets(5, 4), isTrue);
      expect(Levels.at(1).meets(3, 2), isFalse);
      expect(Levels.at(2).meets(3, 2), isTrue);
      expect(Levels.at(2).meets(5, 3), isFalse);
      expect(Levels.at(3).meets(6, 2), isTrue);
      expect(Levels.at(4).meets(4, 3), isFalse);
      expect(Levels.at(4).meets(3, 3), isFalse);
    });
  });

  group('the play', () {
    test('opens on a middle of two and rings of one, nine round, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.middle, play.ring, play.moves), (2, 1, 0));
        expect(play.fit, 9);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a dial a step, and a dial at its end stays', () {
      var play = Play.of(Levels.at(0)).set(0, 1);
      expect((play.middle, play.ring, play.moves), (3, 1, 1));
      expect(play.fit, 12);
      play = play.set(1, -1);
      expect(play, same(play.set(1, -1)));
      final atEnd = Play.standing(Levels.at(0), 6, 6);
      expect(atEnd.set(0, 1), same(atEnd));
      expect(atEnd.set(1, 1), same(atEnd));
      expect(atEnd.set(0, -1).middle, 5);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, 1);
      expect(play.back.middle, 2);
      expect(play.back.back.moves, 0);
    });

    test('the four lands, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).set(0, -1).set(1, 1);
      expect((play.middle, play.ring), (1, 2));
      expect(play.fit, 4);
      expect(play.isDone, isTrue);
      expect(play.set(1, 1), same(play));
    });

    test('the pointer names the coin and the way', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (0, 1));
      play = play.set(0, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, 1)), 'Widen the middle coin.');
      expect(Play.pointed((1, -1)), 'Narrow the ring coins.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer rings every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final (which, by) = play.next!;
          play = play.set(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the seven pennies admit it at equal coins, or after thirty taps', () {
      var play = Play.of(Levels.at(4)).set(0, 1);
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1).set(1, 1);
      expect((play.middle, play.ring), (3, 3));
      expect(play.gaveUp, isTrue);
      expect(play.fit, 6);
      expect(play.moves, 3);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells the sixty degrees and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('seven sixties are more than a turn'));
      expect(words, contains('This is ask 5, The Seven Pennies.'));
      expect(words, contains('36 settings, tried in full'));
    });
  });
}
