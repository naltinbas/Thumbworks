import 'package:flutter_test/flutter_test.dart';
import 'package:mousewold/chase/grounds.dart';
import 'package:mousewold/chase/play.dart';
import 'package:mousewold/chase/rules.dart';

void main() {
  group('the ground', () {
    test('knows its paths both ways, and the stay', () {
      final rules = Rules(3, const [(0, 1), (1, 2)]);
      expect(rules.movesFrom(0), containsAll([0, 1]));
      expect(rules.movesFrom(1), containsAll([0, 1, 2]));
    });
  });

  group('the two ways of knowing', () {
    test('the folding rule and the search never part on any small '
        'ground', () {
      // The anchor: every connected ground of five posts or fewer
      // here (the checker sweeps six), the search knowing nothing of
      // corners, the folding nothing of chases.
      var swept = 0;
      for (var posts = 2; posts <= 5; posts++) {
        final pairs = <(int, int)>[
          for (var a = 0; a < posts; a++)
            for (var b = a + 1; b < posts; b++) (a, b),
        ];
        for (var mask = 0; mask < (1 << pairs.length); mask++) {
          final paths = <(int, int)>[
            for (var at = 0; at < pairs.length; at++)
              if (mask & (1 << at) != 0) pairs[at],
          ];
          final beside = List.generate(posts, (_) => <int>[]);
          for (final (a, b) in paths) {
            beside[a].add(b);
            beside[b].add(a);
          }
          final seen = <int>{0};
          var edge = [0];
          while (edge.isNotEmpty) {
            final next = <int>[];
            for (final post in edge) {
              for (final other in beside[post]) {
                if (seen.add(other)) next.add(other);
              }
            }
            edge = next;
          }
          if (seen.length != posts) continue;
          swept++;
          final rules = Rules(posts, paths);
          expect(rules.folding() != null, rules.catWins,
              reason: 'posts $posts paths $paths');
        }
      }
      expect(swept, greaterThan(700));
    });

    test('the ring fence has no corner and no catch', () {
      final ground = Grounds.at(4);
      final rules = Rules(ground.posts, ground.paths);
      expect(rules.folding(), isNull);
      expect(rules.catWins, isFalse);
    });

    test('the hedgerow folds end over end', () {
      final ground = Grounds.at(0);
      final rules = Rules(ground.posts, ground.paths);
      expect(rules.folding(), isNotNull);
      expect(rules.folding(), hasLength(5));
    });
  });

  group('every ground that ships', () {
    for (var number = 0; number < Grounds.count; number++) {
      final ground = Grounds.at(number);

      test('${ground.name} is what it says it is', () {
        final rules = Rules(ground.posts, ground.paths);
        if (ground.winnable) {
          expect(rules.catWinsFrom(ground.catStart), isTrue);
          var worst = 0;
          for (var mouse = 0; mouse < ground.posts; mouse++) {
            if (mouse == ground.catStart) continue;
            final rounds = rules.catchIn[ground.catStart][mouse];
            if (rounds > worst) worst = rounds;
          }
          expect(worst, ground.rounds);
        } else {
          expect(rules.catWins, isFalse);
        }
      });
    }
  });

  group('a chase in play', () {
    test('opens with the mouse at its best stand', () {
      final play = Play.of(Grounds.at(0));
      expect(play.cat, 2);
      expect(play.mouse, isNot(2));
      expect(play.toCatch, isNotNull);
      expect(play.rounds, 0);
    });

    test('a step moves the cat and the mouse flees', () {
      final play = Play.of(Grounds.at(0));
      final stepped = play.step(play.next!);
      expect(stepped.rounds, 1);
      expect(stepped.caught, isFalse);
      expect(stepped.mouse, isNot(stepped.cat));
    });

    test('a far post is refused', () {
      final play = Play.of(Grounds.at(0));
      expect(play.mayStep(5), isFalse);
      expect(identical(play.step(5), play), isTrue);
    });

    test('take back returns the chase as it stood', () {
      final start = Play.of(Grounds.at(0));
      final stepped = start.step(start.next!);
      expect(stepped.back.rounds, 0);
      expect(identical(start.back, start), isTrue);
    });

    test('following the search catches on every winnable ground '
        'within its rounds', () {
      for (var number = 0; number < Grounds.count; number++) {
        final ground = Grounds.at(number);
        if (!ground.winnable) continue;
        var play = Play.of(ground);
        var guard = 0;
        while (!play.caught) {
          if (guard++ > 10) fail('${ground.name} never caught');
          play = play.step(play.next!);
        }
        expect(play.rounds, lessThanOrEqualTo(ground.rounds!),
            reason: ground.name);
      }
    });

    test('the ring fence never catches, and gives up at the line', () {
      var play = Play.of(Grounds.at(4));
      expect(play.toCatch, isNull);
      expect(play.next, isNull);
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 12) fail('the futility line never came');
        // Chase straight at the mouse.
        final toward = play.rules
            .movesFrom(play.cat)
            .where((post) => post != play.cat)
            .first;
        play = play.step(toward);
        expect(play.caught, isFalse);
      }
      expect(play.gaveUp, isTrue);
    });
  });
}
