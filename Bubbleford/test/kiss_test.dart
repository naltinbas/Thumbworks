import 'package:flutter_test/flutter_test.dart';
import 'package:bubbleford/kiss/levels.dart';
import 'package:bubbleford/kiss/play.dart';
import 'package:bubbleford/kiss/rules.dart';

/// The bends, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the bends', () {
    test('the fourths by the formula, by trial, and the relation', () {
      expect(Rules.count, 8000);
      expect(Rules.triples, hasLength(8000));
      expect(Rules.sum([2, 2, 3]), 7);
      expect(Rules.pairs([2, 2, 3]), 16);
      expect(Rules.squares([2, 2, 3]), 17);
      expect(Rules.root(16), 4);
      expect(Rules.root(15), isNull);
      expect(Rules.whole([2, 2, 3]), isTrue);
      expect(Rules.fourths([2, 2, 3]), (15, -1));
      expect(Rules.fourths([2, 3, 6]), (23, -1));
      expect(Rules.fourths([1, 1, 4]), (12, 0));
      expect(Rules.fourths([1, 1, 12]), (24, 4));
      expect(Rules.fourths([1, 1, 1]), isNull);
      expect(Rules.fourthsByTrial([2, 2, 3]), [-1, 15]);
      expect(Rules.fourthsByTrial([1, 1, 1]), isEmpty);
      expect(Rules.descartes(-1, 2, 2, 3), isTrue);
      expect(Rules.descartes(1, 2, 3, 4), isFalse);
      expect(Rules.outerSign([2, 2, 3]), -1);
      expect(Rules.outerSign([1, 1, 4]), 0);
      expect(Rules.outerSign([1, 1, 12]), 1);
      expect(Rules.tell([2, 2, 3]), '2, 2 and 3');
      expect(Rules.tellFourth([2, 2, 3], inner: true), '15');
      expect(Rules.tellFourth([2, 2, 3], inner: false), '-1');
      expect(Rules.tellFourth([1, 1, 1], inner: true), '3 + 2 root 3');
      expect(Rules.tellFourth([4, 4, 4], inner: false), '12 - 8 root 3');
      expect(Rules.tellFourth([1, 2, 3], inner: true), '6 + 2 root 11');
      expect(Rules.valid([0, 1, 1]), isFalse);
      expect(Rules.valid([20, 20, 20]), isTrue);
    });

    test('the sweep: the formula and the trial agree on every setting, and no fourths are twins', () {
      var whole = 0, wraps = 0, flat = 0, unit = 0;
      for (final k in Rules.triples) {
        final f = Rules.fourths(k);
        final trial = Rules.fourthsByTrial(k);
        if (f == null) {
          expect(trial, isEmpty, reason: '$k');
        } else {
          expect(trial, unorderedEquals([f.$1, f.$2]), reason: '$k');
          expect(f.$1 == f.$2, isFalse, reason: '$k');
          expect(Rules.descartes(k[0], k[1], k[2], f.$1) && Rules.descartes(k[0], k[1], k[2], f.$2), isTrue, reason: '$k');
          whole++;
          if (f.$2 == -1) unit++;
        }
        expect(Rules.sum(k) * Rules.sum(k), Rules.squares(k) + 2 * Rules.pairs(k), reason: '$k');
        final sg = Rules.outerSign(k);
        if (sg < 0) wraps++;
        if (sg == 0) flat++;
      }
      expect((whole, wraps, flat, unit), (207, 7001, 33, 27));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Twin Fourths']);
      for (final level in Levels.all) {
        expect(Rules.triples.where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [2, 2, 3]);
      expect(Levels.at(1).aim, [1, 1, 4]);
      expect(Levels.at(2).aim, [2, 2, 3]);
      expect(Levels.at(3).aim, [1, 1, 12]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the three bends so that the outer bubble has a bend of -1, a unit bubble round the three');
      expect(Levels.at(1).task, 'set the three bends so that the outer bubble flattens to a straight line');
      expect(Levels.at(2).task, 'set the three bends so that both fourth bends are whole and the outer bubble wraps round');
      expect(Levels.at(3).task, 'set the three bends so that both fourth bends are whole and the outer bubble sits in the far gap');
      expect(Levels.at(4).task, 'set the three bends so that the two fourth bubbles are of one bend');
    });

    test('an ask is met by the bends', () {
      expect(Levels.at(0).meets([2, 2, 3]), isTrue);
      expect(Levels.at(0).meets([2, 3, 6]), isTrue);
      expect(Levels.at(0).meets([1, 1, 4]), isFalse);
      expect(Levels.at(1).meets([1, 1, 4]), isTrue);
      expect(Levels.at(1).meets([3, 3, 12]), isTrue);
      expect(Levels.at(1).meets([2, 2, 3]), isFalse);
      expect(Levels.at(2).meets([2, 2, 3]), isTrue);
      expect(Levels.at(2).meets([1, 1, 12]), isFalse);
      expect(Levels.at(3).meets([1, 1, 12]), isTrue);
      expect(Levels.at(3).meets([1, 4, 12]), isTrue);
      expect(Levels.at(3).meets([1, 1, 4]), isFalse);
      expect(Levels.at(4).meets([2, 2, 3]), isFalse);
      expect(Levels.at(0).meets([0, 2, 3]), isFalse);
    });
  });

  group('the play', () {
    test('opens at 1, 1 and 1', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.bends, [1, 1, 1]);
        expect((play.moves, play.whole), (0, false));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a step moves one dial within one and twenty', () {
      final play = Play.of(Levels.at(4));
      expect(play.step(2, 1).bends, [1, 1, 2]);
      expect(play.step(0, -1), same(play));
      expect(play.step(3, 1), same(play));
      expect(Play.standing(Levels.at(4), [20, 1, 1]).step(0, 1).bends, [20, 1, 1]);
      expect(play.step(2, 1).moves, 1);
      final whole = play.step(2, 1).step(2, 1).step(2, 1);
      expect(whole.bends, [1, 1, 4]);
      expect(whole.whole, isTrue);
      expect(whole.seen, {'1,1,4'});
      expect(whole.fourthsByTrial, [0, 12]);
    });

    test('back undoes one step', () {
      final play = Play.of(Levels.at(0)).step(0, 1).step(1, 1);
      expect(play.back.bends, [2, 1, 1]);
      expect(play.back.back.bends, [1, 1, 1]);
    });

    test('the pointer steps the first dial off the aim towards it', () {
      expect(Play.of(Levels.at(0)).next, (0, 1));
      expect(Play.pointed((0, 1)), 'Step bend 1 up.');
      expect(Play.of(Levels.at(1)).next, (2, 1));
      expect(Play.standing(Levels.at(0), [2, 2, 5]).next, (2, -1));
      expect(Play.pointed((2, -1)), 'Step bend 3 down.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 60) {
          final (place, by) = play.next!;
          play = play.step(place, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var gap = Play.of(Levels.at(3));
      while (!gap.isDone) {
        final (place, by) = gap.next!;
        gap = gap.step(place, by);
      }
      expect(gap.bends, [1, 1, 12]);
      expect(gap.moves, 11);
    });

    test('the twin fourths admits it after three whole settings, or twelve taps', () {
      var play = Play.of(Levels.at(4)).step(2, 1).step(2, 1).step(2, 1);
      expect(play.seen, hasLength(1));
      play = play.step(2, 1).step(2, 1).step(2, 1).step(2, 1).step(2, 1);
      expect(play.bends, [1, 1, 9]);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.step(0, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 12);
      var wholes = Play.of(Levels.at(4));
      for (final b in [[1, 1, 4], [1, 4, 4], [1, 4, 9], [1, 4, 12]]) {
        for (var i = 0; i < 3; i++) {
          while (wholes.bends[i] != b[i] && !wholes.isOver) {
            wholes = wholes.step(i, b[i] > wholes.bends[i] ? 1 : -1);
          }
        }
      }
      expect(wholes.gaveUp, isTrue);
    });

    test('the why tells Descartes and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Descartes found in 1643'));
      expect(words, contains('8,000'));
      expect(words, contains('This is ask 5, The Twin Fourths.'));
      expect(words, contains('worked in full'));
    });
  });
}
