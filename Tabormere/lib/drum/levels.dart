import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Tresillo',
      steps: 8,
      hits: 3,
      ways: 8,
      note: 'Three hits in eight steps go evenly as x..x..x. and its '
          'turnings, gaps of 3, 3 and 2: eight patterns of the 56, and every '
          'one a turning of Euclid\'s x.x..x.., laid down at the floors of 0, '
          '8/3 and 16/3. The Cuban tresillo is one of them.',
    ),
    Level(
      name: 'The Cinquillo',
      steps: 8,
      hits: 5,
      ways: 8,
      note: 'Five hits in eight go evenly as x.xx.xx. and its turnings, gaps '
          'of 2, 1, 2, 1 and 2: eight patterns of the 56, the rests falling '
          'where the tresillo\'s hits do. Euclid\'s is xx.xx.x.',
    ),
    Level(
      name: 'The Bossa',
      steps: 16,
      hits: 5,
      ways: 16,
      note: 'Five hits in sixteen go evenly as x..x..x...x..x.. and its '
          'turnings, gaps of 3, 3, 4, 3 and 3: sixteen patterns of the 4,368, '
          'and Euclid\'s is x..x..x..x..x..., the bossa nova clave turned.',
    ),
    Level(
      name: 'The Bembe',
      steps: 12,
      hits: 7,
      ways: 12,
      note: 'Seven hits in twelve go evenly as x.xx.x.xx.x. and its turnings, '
          'gaps of 2, 1, 2, 2, 1, 2 and 2: twelve patterns of the 792, and '
          'Euclid\'s is xx.x.xx.x.x., the bembe bell turned. Five in twelve '
          'go the other way about, x.x.x..x.x.. and its turnings.',
    ),
    Level(
      name: 'The Even Tresillo',
      steps: 8,
      hits: 3,
      equalGapsAsked: true,
      ways: 0,
      note: 'Hopeless, and the tile says so. Three equal gaps would add up to '
          'eight, and eight into three won\'t go: none of the 56 patterns has '
          'them, and the nearest, gaps of 3, 3 and 2, is the tresillo itself. '
          'Three in nine, x..x..x.., has equal gaps three ways.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
