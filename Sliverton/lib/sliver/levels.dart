import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Seventh',
      kind: 'seventh',
      ways: 2,
      note: 'Cut from each corner to the mark two thirds of the way along '
          'the far side and the sliver is a seventh of the field, the '
          'one-seventh triangle: the marks 8, 8 and 8 twelfths do it, and so '
          'do 4, 4 and 4, since the share is the same whether the ratios are '
          'two or a half. Those two settings alone of the 1,331 leave a '
          'seventh.',
    ),
    Level(
      name: 'The Vanishing',
      kind: 'vanish',
      ways: 31,
      note: 'The sliver comes to nothing on 31 settings of the 1,331, and '
          'those are exactly the ones where the three cuts meet at a point: '
          'the ratios multiply to one, which is Ceva\'s word of 1678. The '
          'middle marks, 6, 6 and 6, are the plainest of them, the three '
          'cuts meeting at the middle of the field.',
    ),
    Level(
      name: 'The Seventieth',
      kind: 'seventieth',
      ways: 12,
      note: 'A sliver of a seventieth comes on 12 settings, the marks 1, 8 '
          'and 8 the first; a two-hundred-and-tenth comes on 12 as well, and '
          '282 settings leave a sliver thinner than a hundredth, the '
          'thinnest of all a 74,338th, from the marks 4, 7 and 7.',
    ),
    Level(
      name: 'The Widest Sliver',
      kind: 'widest',
      ways: 2,
      note: 'The sliver is widest at 100 parts in 133, better than three '
          'quarters of the field, when every mark sits one twelfth along, or '
          'every mark eleven twelfths; 40 settings leave a sliver of half '
          'the field or more, and 219 different shares come up in all.',
    ),
    Level(
      name: 'The Sly Vanishing',
      kind: 'sly',
      ways: 0,
      note: 'Hopeless, and the tile says so. If the sliver has no area its '
          'three corners are one point, and that point sits on all three '
          'cuts, so the cuts meet; and the other way about, cuts that meet '
          'leave the three corners together and no sliver at all. Routh\'s '
          'rule of 1891 says the same in arithmetic: the share is the square '
          'of xyz less one over a product that never vanishes, so the sliver '
          'goes only when xyz is one, which is Ceva\'s condition for the '
          'cuts to meet. The sweep of all 1,331 settings finds the sliver '
          'gone on 31 and the cuts meeting on the same 31.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
