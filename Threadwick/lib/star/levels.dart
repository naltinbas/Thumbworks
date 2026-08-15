import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Pentagram',
      nails: 5,
      strokes: 1,
      ways: 2,
      aim: (5, 2),
      note: 'Five nails, skip two, and the thread comes home having touched '
          'all five: five shares no factor with two. Skip three draws the '
          'same five lines the other way round, so two settings of the 60 '
          'land it, and they are the one star.',
    ),
    Level(
      name: 'The Two Squares',
      nails: 8,
      strokes: 1 + 1,
      ways: 2,
      aim: (8, 2),
      note: 'Eight nails and a skip of two share the factor two, so the '
          'thread comes home after four nails and a second stroke takes the '
          'other four: two squares. Skip six is the same pair the other way. '
          'Skip four shares four and takes four strokes of two, bare lines '
          'across; skips three and five thread all eight at once.',
    ),
    Level(
      name: 'The Three Triangles',
      nails: 9,
      strokes: 3,
      ways: 2,
      aim: (9, 3),
      note: 'Nine nails and a skip of three share three, so each stroke '
          'touches nine over three, three nails, and three strokes cover the '
          'ring: three triangles. Skip six is the same. Skips two, four, five '
          'and seven share nothing with nine and thread it in one stroke, '
          'two stars between them.',
    ),
    Level(
      name: 'The Twelve',
      nails: 12,
      strokes: 1,
      ways: 2,
      aim: (12, 5),
      note: 'Twelve shares a factor with every skip from two to ten but five '
          'and seven, and those two draw the one star: two settings of the '
          '60. Skip six takes six strokes, bare lines through the middle; '
          'skips two and ten two hexagons, three and nine three squares, '
          'four and eight four triangles.',
    ),
    Level(
      name: 'The Star of David',
      nails: 6,
      strokes: 1,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. Six is two threes: skip two or '
          'four and the thread comes home after every other nail, three of '
          'them, and skip three and it bounces between two; skips one and '
          'five only run round the rim. The six-pointed star is two '
          'triangles, two strokes, and never one: none of the 60 settings '
          'lands it, and the walk of all five skips said so.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
