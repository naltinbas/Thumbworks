import 'dart:io';

import 'package:mousewold/chase/grounds.dart';
import 'package:mousewold/chase/rules.dart';

/// Searches every chase, folds every ground, sweeps the folding rule
/// against the search on every connected ground of six posts or
/// fewer, and refuses the bake on any disagreement.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  // The theorem, swept.
  var swept = 0;
  for (var posts = 2; posts <= 6; posts++) {
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
      claim((rules.folding() != null) == rules.catWins,
          'the folding rule and the search part on a ground of '
          '$posts posts');
    }
  }
  stdout.writeln('every connected ground of six posts or fewer, '
      '$swept of them: the ground folds to a point exactly when the '
      'cat can win');
  stdout.writeln('');

  for (var number = 0; number < Grounds.count; number++) {
    final ground = Grounds.at(number);
    final rules = Rules(ground.posts, ground.paths);
    if (ground.winnable) {
      claim(rules.catWinsFrom(ground.catStart),
          '${ground.name}: the cat cannot win from its start');
      var worst = 0;
      for (var mouse = 0; mouse < ground.posts; mouse++) {
        if (mouse == ground.catStart) continue;
        final rounds = rules.catchIn[ground.catStart][mouse];
        if (rounds > worst) worst = rounds;
      }
      claim(worst == ground.rounds,
          '${ground.name}: worst rounds $worst, written '
          '${ground.rounds}');
      claim(rules.folding() != null,
          '${ground.name}: cat-win but the ground jams');
    } else {
      claim(!rules.catWins,
          '${ground.name}: the cat wins from somewhere after all');
      claim(rules.folding() == null,
          '${ground.name}: dead but the ground folds');
    }

    final verdict = ground.winnable
        ? 'the catch in ${ground.rounds} round'
            '${ground.rounds == 1 ? '' : 's'} from post '
            '${ground.catStart}'
        : 'the mouse escapes forever, and the ground never folds';
    stdout.writeln(' ${number + 1} ${ground.name.padRight(14)} '
        '${ground.posts} posts  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
