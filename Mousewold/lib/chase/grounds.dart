import 'ground.dart';

/// The grounds that ship.
///
/// Every number here is checked twice over: tool/check_grounds.dart
/// searches every chase and folds every ground, sweeps the folding
/// rule against the search on every small ground there is, and
/// refuses the bake on any disagreement.
class Grounds {
  static const all = [
    Ground(
      name: 'The Hedgerow',
      posts: 6,
      paths: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)],
      spots: [
        (0.08, 0.5), (0.25, 0.38), (0.42, 0.52), (0.59, 0.38),
        (0.76, 0.52), (0.92, 0.4),
      ],
      catStart: 2,
      rounds: 3,
      note: 'A hedge has two ends and nowhere to hide: every post '
          'folds behind its neighbour, and the search says three '
          'rounds catch the mouse from the middle.',
    ),
    Ground(
      name: 'The Old Oak',
      posts: 7,
      paths: [(0, 1), (1, 2), (1, 3), (0, 4), (4, 5), (4, 6)],
      spots: [
        (0.5, 0.52), (0.3, 0.3), (0.12, 0.14), (0.46, 0.1),
        (0.7, 0.72), (0.55, 0.9), (0.88, 0.88),
      ],
      catStart: 0,
      rounds: 2,
      note: 'A tree folds leaf by leaf, twig by twig, down to its '
          'trunk: two rounds from the fork, says the search of every '
          'chase.',
    ),
    Ground(
      name: 'The Barnyard',
      posts: 6,
      paths: [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3), (3, 4), (4, 5)],
      spots: [
        (0.08, 0.5), (0.28, 0.26), (0.28, 0.74), (0.48, 0.5),
        (0.7, 0.5), (0.92, 0.5),
      ],
      catStart: 3,
      rounds: 2,
      note: 'Triangles fold sweetly: each corner of the yard hides '
          'behind another post whole, and the tail is a hedge. Two '
          'rounds from the gate.',
    ),
    Ground(
      name: 'The Cartwheel',
      posts: 7,
      paths: [
        (0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6),
        (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 1),
      ],
      spots: [
        (0.5, 0.5), (0.5, 0.08), (0.86, 0.29), (0.86, 0.71),
        (0.5, 0.92), (0.14, 0.71), (0.14, 0.29),
      ],
      catStart: 0,
      rounds: 1,
      note: 'The hub touches every post, so the whole rim folds into '
          'it: one round, wherever the mouse stands.',
    ),
    Ground(
      name: 'The Ring Fence',
      posts: 6,
      paths: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0)],
      spots: [
        (0.5, 0.08), (0.86, 0.29), (0.86, 0.71), (0.5, 0.92),
        (0.14, 0.71), (0.14, 0.29),
      ],
      catStart: 0,
      rounds: null,
      note: 'A ring hides no corners: every post keeps two ways out, '
          'and neither lies inside a neighbour\'s reach. The mouse '
          'keeps the ring between you forever, and the search of '
          'every chase agrees: no standing ever catches.',
    ),
  ];

  static int get count => all.length;

  static Ground at(int number) => all[number];
}
