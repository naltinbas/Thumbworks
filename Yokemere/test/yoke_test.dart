import 'package:flutter_test/flutter_test.dart';
import 'package:yokemere/yoke/levels.dart';
import 'package:yokemere/yoke/play.dart';
import 'package:yokemere/yoke/rules.dart';

/// The yard itself, with no screen anywhere near it.
void main() {
  group('the team', () {
    test('pulls what its pairs multiply to, added up', () {
      expect(Rules.pull([0, 1, 2, 3, 4]), 55);
      expect(Rules.pull([4, 3, 2, 1, 0]), 35);
      expect(Rules.pull(Rules.opening), 35);
    });

    test('has 120 yokings, each written once', () {
      final all = Rules.yokings();
      expect(all.length, 120);
      expect(all.map((y) => y.join()).toSet().length, 120);
    });

    test('counts a swap as one, and a full turn round as four', () {
      expect(Rules.between([0, 1, 2, 3, 4], [0, 1, 2, 3, 4]), 0);
      expect(Rules.between([0, 1, 2, 3, 4], [1, 0, 2, 3, 4]), 1);
      expect(Rules.between([0, 1, 2, 3, 4], [4, 3, 2, 1, 0]), 2);
    });
  });

  group('the two voices', () {
    test('agree on the hardest and softest pulls', () {
      var hardest = 0, softest = 1 << 30;
      for (final y in Rules.yokings()) {
        final p = Rules.pull(y);
        if (p > hardest) hardest = p;
        if (p < softest) softest = p;
      }
      expect(hardest, Rules.hardest());
      expect(softest, Rules.softest());
      expect(hardest, 55);
      expect(softest, 35);
    });

    test('agree on every pair of rows of five beasts from nine', () {
      final choices = <List<int>>[];
      void pick(int from, List<int> so) {
        if (so.length == Rules.oxen) {
          choices.add([...so]);
          return;
        }
        for (var v = from; v <= 9; v++) {
          pick(v + 1, [...so, v]);
        }
      }

      pick(1, const []);
      expect(choices.length, 126);
      final all = Rules.yokings();
      var pairs = 0;
      for (final a in choices) {
        for (final b in choices) {
          pairs++;
          var best = 0, worst = 1 << 30;
          for (final y in all) {
            var total = 0;
            for (var i = 0; i < Rules.oxen; i++) {
              total += a[i] * b[y[i]];
            }
            if (total > best) best = total;
            if (total < worst) worst = total;
          }
          var together = 0, opposite = 0;
          for (var i = 0; i < Rules.oxen; i++) {
            together += a[i] * b[i];
            opposite += a[i] * b[Rules.oxen - 1 - i];
          }
          expect(best, together, reason: '$a against $b');
          expect(worst, opposite, reason: '$a against $b');
        }
      }
      expect(pairs, 15876);
    });
  });

  group('the swap that carries the proof', () {
    test('changes the pull by the near gap times the off gap', () {
      for (final y in Rules.yokings()) {
        for (var i = 0; i < Rules.oxen; i++) {
          for (var j = i + 1; j < Rules.oxen; j++) {
            expect(Rules.pull(Rules.swap(y, i, j)) - Rules.pull(y),
                Rules.swapGain(y, i, j),
                reason: '$y $i $j');
          }
        }
      }
    });

    test('never softens a crossed pair and never hardens an uncrossed one',
        () {
      for (final y in Rules.yokings()) {
        for (var i = 0; i < Rules.oxen; i++) {
          for (var j = i + 1; j < Rules.oxen; j++) {
            final gain = Rules.swapGain(y, i, j);
            if (Rules.crossed(y, i, j)) {
              expect(gain, greaterThanOrEqualTo(0));
            } else {
              expect(gain, lessThanOrEqualTo(0));
            }
          }
        }
      }
    });

    test('leaves exactly one team with nothing crossed, the hardest', () {
      final tidy = [
        for (final y in Rules.yokings())
          if (!Play.yoked(Levels.at(0), y).anyCrossed) y,
      ];
      expect(tidy.length, 1);
      expect(tidy.single, [0, 1, 2, 3, 4]);
      expect(Rules.pull(tidy.single), Rules.hardest());
    });

    test('walks every team up to that one and never back', () {
      for (final y in Rules.yokings()) {
        var here = [...y];
        for (var steps = 0; steps < 20; steps++) {
          var moved = false;
          for (var i = 0; i < Rules.oxen && !moved; i++) {
            for (var j = i + 1; j < Rules.oxen && !moved; j++) {
              if (!Rules.crossed(here, i, j)) continue;
              final was = Rules.pull(here);
              here = Rules.swap(here, i, j);
              expect(Rules.pull(here), greaterThanOrEqualTo(was));
              moved = true;
            }
          }
          if (!moved) break;
        }
        expect(Rules.pull(here), Rules.hardest(), reason: '$y');
      }
    });
  });

  group('every ask', () {
    test('lands as many yokings as it claims', () {
      for (final level in Levels.all) {
        final n = Rules.yokings().where(level.meets).length;
        expect(n, level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.ways).toList(), [10, 7, 3, 1, 0]);
    });

    test('opens turned back to front, which lands nothing', () {
      expect(Rules.pull(Rules.opening), Rules.softest());
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });

    test('is yoked by the pointer in the swaps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.swaps < 12) {
          final aim = play.next!;
          play = play.tap(aim.$1).tap(aim.$2);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.swaps, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('takes hold of a place and changes two over', () {
      final held = Play.of(Levels.at(0)).tap(0);
      expect(held.held, 0);
      expect(held.swaps, 0);
      final swapped = held.tap(1);
      expect(swapped.held, isNull);
      expect(swapped.swaps, 1);
      expect(swapped.order, [3, 4, 2, 1, 0]);
    });

    test('lets go when the same place is tapped again', () {
      final held = Play.of(Levels.at(0)).tap(2);
      expect(held.tap(2).held, isNull);
      expect(held.tap(2).swaps, 0);
    });

    test('takes a swap back', () {
      final one = Play.of(Levels.at(0)).tap(0).tap(1);
      expect(one.back.order, Rules.opening);
      expect(one.back.swaps, 0);
    });

    test('knows which places are crossed', () {
      final open = Play.of(Levels.at(0));
      expect(open.anyCrossed, isTrue);
      expect(open.crossedWith(0), isNotEmpty);
      final best = Play.yoked(Levels.at(0), const [0, 1, 2, 3, 4]);
      expect(best.anyCrossed, isFalse);
      expect(best.crossedWith(0), isEmpty);
    });

    test('points at two places to change over', () {
      final play = Play.of(Levels.at(0));
      final aim = play.next!;
      expect(play.pointed(aim), contains('Take hold of place'));
      expect(play.tap(aim.$1).pointed(aim), contains('Now take place'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('asks past the hardest pull there is', () {
      expect(dead.pull, greaterThan(Rules.hardest()));
      expect(Rules.yokings().where(dead.meets), isEmpty);
    });

    test('keeps no pointer at all', () {
      expect(Play.of(dead).next, isNull);
    });

    test('admits it after six teams', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final pair in const [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4),
        (0, 2)]) {
        play = play.tap(pair.$1).tap(pair.$2);
      }
      expect(play.gaveUp, isTrue);
    });
  });

  group('the why', () {
    test('names the swap, the sweep and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(3)));
      expect(words, contains('near gap multiplied'));
      expect(words, contains('15,876'));
      expect(words, contains('The Best Team'));
    });
  });
}
