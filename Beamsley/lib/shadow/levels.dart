import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Whole Meets',
      kind: 'whole',
      ways: 1248,
      note: 'The meetings are fractions as a rule, so all three landing on '
          'peg places is rare: 1,248 settings of the 511,488, the first '
          'with the pegs (-2, -2), (0, -2) and (-2, 1) cast -1, 3 and 2.',
    ),
    Level(
      name: 'The Level Axis',
      kind: 'level',
      ways: 43872,
      note: 'The axis lies level on 43,872 settings, and upright on as '
          'many, since turning the whole field a quarter turn turns the '
          'axis with it.',
    ),
    Level(
      name: 'The Far Line',
      kind: 'infinity',
      ways: 31968,
      note: 'When the three casts are equal the shadow triangle is the '
          'triangle blown up about the lantern, every side parallel to its '
          'own, so all three meetings run off to infinity and the axis is '
          'the line at infinity: 31,968 settings, four casts for every one '
          'of the 7,992 triangles. Exactly two casts equal leaves one '
          'meeting far off, 287,712 settings, no two equal leaves none, '
          '191,808, and two far with one at hand never happens.',
    ),
    Level(
      name: 'The Axis Through the Lantern',
      kind: 'lantern',
      ways: 7200,
      note: 'The axis runs through the lantern itself on 7,200 settings, the '
          'point the two triangles are drawn from; the meetings still lie '
          'on one line, and that line now passes through the middle of the '
          'picture.',
    ),
    Level(
      name: 'The Crooked Axis',
      kind: 'crooked',
      ways: 0,
      note: 'Hopeless, and the tile says so. Desargues proved in 1639 that '
          'two triangles drawn from one point meet side to side in three '
          'places on one line, and the theorem is the plainest statement of '
          'what a projection cannot break: it holds whatever the pegs, '
          'whatever the casts, and it holds when a meeting runs off to '
          'infinity, which is why the proof wants the projective plane '
          'rather than the flat one. The sweep of all 511,488 settings '
          'finds the three meetings on one line every time, and the three '
          'never fall together.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
