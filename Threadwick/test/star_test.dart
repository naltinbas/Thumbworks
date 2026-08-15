import 'package:flutter_test/flutter_test.dart';
import 'package:threadwick/star/levels.dart';
import 'package:threadwick/star/play.dart';
import 'package:threadwick/star/rules.dart';

/// The walk, the asks and the play, checked at the domain: nothing here
/// touches a widget.
void main() {
  group('the walk', () {
    test('strokes walked, and the divisor', () {
      expect(Rules.strokes(5, 2), [
        [0, 2, 4, 1, 3]
      ]);
      expect(Rules.strokes(6, 2), [
        [0, 2, 4],
        [1, 3, 5]
      ]);
      expect(Rules.strokes(6, 3), [
        [0, 3],
        [1, 4],
        [2, 5]
      ]);
      expect(Rules.strokes(8, 2).length, 2);
      expect(Rules.strokes(9, 3).length, 3);
      expect(Rules.strokes(12, 5).length, 1);
      expect(Rules.strokes(7, 1), [
        [0, 1, 2, 3, 4, 5, 6]
      ]);
      for (var nails = 3; nails <= 12; nails++) {
        for (var skip = 1; skip < nails; skip++) {
          expect(Rules.strokes(nails, skip).length, Rules.strokesByDivisor(nails, skip), reason: '$nails by $skip');
          expect(Rules.strokes(nails, skip)[0].length, Rules.nailsAStrokeByDivisor(nails, skip), reason: '$nails by $skip');
        }
      }
      expect(Rules.settings, 60);
    });

    test('a star is not the rim', () {
      expect(Rules.isStar(7, 1), isFalse);
      expect(Rules.isStar(7, 6), isFalse);
      expect(Rules.isStar(7, 2), isTrue);
      expect(Rules.isStar(7, 5), isTrue);
    });

    test('the same lines both ways round', () {
      expect(Rules.lines(5, 2), [(0, 2), (0, 3), (1, 3), (1, 4), (2, 4)]);
      expect(Rules.lines(5, 3), Rules.lines(5, 2));
      expect(Rules.lines(6, 3), [(0, 3), (1, 4), (2, 5)]);
    });

    test('the one-stroke stars and Euler\'s count', () {
      expect(Rules.oneStrokeStars(5), [2, 3]);
      expect(Rules.oneStrokeStars(6), isEmpty);
      expect(Rules.oneStrokeStars(7), [2, 3, 4, 5]);
      expect(Rules.oneStrokeStars(12), [5, 7]);
      expect(Rules.coprimes(12), 4);
      expect(Rules.coprimes(7), 6);
      for (var nails = 5; nails <= 12; nails++) {
        expect(Rules.oneStrokeStars(nails).length, Rules.coprimes(nails) - 2, reason: '$nails');
      }
    });

    test('the sweep', () {
      expect(Rules.sweep((n, k) => n == 6 && Rules.isStar(n, k) && Rules.strokes(n, k).length == 1), (0, 60, null));
      expect(Rules.sweep((n, k) => n == 5 && Rules.isStar(n, k)), (2, 60, (5, 2)));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Star of David']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 60), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the nails and the skip so a star of five nails is threaded in one stroke');
      expect(Levels.at(1).task, 'set the nails and the skip so a star of eight nails is threaded in two strokes exactly');
      expect(Levels.at(4).task, 'set the nails and the skip so a star of six nails is threaded in one stroke');
    });

    test('an ask is met by the nails, a star, and the strokes exactly', () {
      expect(Levels.at(0).meets(5, 2), isTrue);
      expect(Levels.at(0).meets(5, 3), isTrue);
      expect(Levels.at(0).meets(5, 1), isFalse);
      expect(Levels.at(0).meets(7, 2), isFalse);
      expect(Levels.at(1).meets(8, 2), isTrue);
      expect(Levels.at(1).meets(8, 4), isFalse);
      expect(Levels.at(1).meets(8, 3), isFalse);
      expect(Levels.at(4).meets(6, 2), isFalse);
      expect(Levels.at(4).meets(6, 1), isFalse);
    });
  });

  group('the play', () {
    test('opens on seven nails and the rim, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.nails, play.skip, play.moves), (7, 1, 0));
        expect(play.isStar, isFalse);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a dial a step, a dial at its end stays, and fewer nails pull the skip down', () {
      var play = Play.of(Levels.at(0)).set(1, 1);
      expect((play.nails, play.skip, play.moves), (7, 2, 1));
      play = play.set(0, -1);
      expect((play.nails, play.skip, play.moves), (6, 2, 2));
      final wide = Play.standing(Levels.at(1), 7, 6);
      expect(wide.set(1, 1), same(wide));
      expect(wide.set(0, -1).skip, 5);
      final atEnd = Play.standing(Levels.at(1), 12, 1);
      expect(atEnd.set(0, 1), same(atEnd));
      expect(atEnd.set(1, -1), same(atEnd));
      final atStart = Play.standing(Levels.at(1), 5, 1);
      expect(atStart.set(0, -1), same(atStart));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, 1);
      expect(play.back.nails, 7);
      expect(play.back.back.moves, 0);
    });

    test('the pentagram lands, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).set(0, -1).set(0, -1).set(1, 1);
      expect((play.nails, play.skip), (5, 2));
      expect(play.strokes, hasLength(1));
      expect(play.isDone, isTrue);
      expect(play.set(1, 1), same(play));
    });

    test('the pointer names the dial and the way', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (0, 1));
      play = play.set(0, 1);
      expect(play.next, (1, 1));
      play = play.set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, -1)), 'Take away a nail.');
      expect(Play.pointed((0, 1)), 'Add a nail.');
      expect(Play.pointed((1, 1)), 'Widen the skip.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer threads every winnable ask', () {
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

    test('the star of David admits it once skips two, three and four are tried at six, or after thirty taps', () {
      var play = Play.of(Levels.at(4)).set(0, -1).set(1, 1);
      expect((play.nails, play.skip), (6, 2));
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      expect((play.nails, play.skip), (6, 4));
      expect(play.gaveUp, isTrue);
      expect(play.skipsTriedAtSix, {1, 2, 3, 4});
      expect(play.moves, 4);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells the factor and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Six is two threes'));
      expect(words, contains('This is ask 5, The Star of David.'));
      expect(words, contains('60 settings, walked in full'));
    });
  });
}
