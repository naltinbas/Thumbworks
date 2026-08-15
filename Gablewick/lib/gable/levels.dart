import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Right Angle',
      kind: 'right',
      ways: 4,
      aim: (3, 4, 5),
      note: 'Four right-angled triangles to fifteen have a whole area: 3-4-5 '
          'with 6, 6-8-10 with 24, 5-12-13 with 30 and 9-12-15 with 54, four '
          'of the 372 triangles with whole sides to fifteen. Every one is a '
          'half of a whole rectangle, which is why the area comes whole.',
    ),
    Level(
      name: 'The Twelve',
      kind: 'area',
      areaAsked: 12,
      ways: 2,
      aim: (5, 5, 6),
      note: 'Two triangles to fifteen have an area of exactly 12, and they '
          'are the two halves of the same cut: 5-5-6 and 5-5-8, each two '
          '3-4-5 triangles set back to back, one along the 3 and one along '
          'the 4.',
    ),
    Level(
      name: 'The Two Alike',
      kind: 'isosceles',
      ways: 4,
      aim: (5, 5, 6),
      note: 'Four triangles to fifteen with two sides alike and no right angle '
          'have a whole area: 5-5-6 and 5-5-8 with 12, 10-10-12 with 48 and '
          '10-13-13 with 60, each two right-angled halves back to back, '
          '3-4-5 or 6-8-10 or 5-12-13.',
    ),
    Level(
      name: 'The Uneven',
      kind: 'scalene',
      ways: 2,
      aim: (13, 14, 15),
      note: 'Two triangles to fifteen with no two sides alike and no right '
          'angle have a whole area: 13-14-15 with 84, the biggest whole area '
          'to fifteen and two right-angled halves of 5-12-13 and 9-12-15 '
          'along the 14, and 4-13-15 with 24, a 9-12-15 with a 5-12-13 cut '
          'away, the two standing on one line with the 12 shared.',
    ),
    Level(
      name: 'The Three Odds',
      kind: 'allOdd',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. Sixteen times the area squared '
          'is the perimeter times the perimeter less twice each side, and '
          'with three odd sides all four of those are odd, so the product is '
          'odd and never sixteen times anything: none of the 372, and every '
          'one of the ten whole-area triangles to fifteen has an even side '
          'and an area a multiple of six.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
