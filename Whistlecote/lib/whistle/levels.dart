import 'level.dart';

/// The five sets of calls that ship.
///
/// Every number here is checked before the bake: every marking swept,
/// the shepherd's way and the product held to the sweep on every set of
/// up to six calls of up to four notes, and tool/check_whistles.dart
/// refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Three Calls',
      calls: [('Come-bye', 1), ('Away', 2), ('Lie down', 2)],
      ways: 2,
      markings: 12,
      note: 'One note for Come-bye takes half of every tune, all the whistles '
          'that begin with that note; the two two-note calls must both start '
          'with the other note, and there are just two such whistles. Two '
          'markings of the twelve, one for each note Come-bye takes, and the '
          'shares come to the whole exactly, four and two and two of eight.',
    ),
    Level(
      name: 'The Four Calls',
      calls: [('Come-bye', 1), ('Away', 2), ('Walk up', 3), ('Lie down', 3)],
      ways: 4,
      markings: 224,
      note: 'Shares of four, two, one and one: eight of eight, so nothing is '
          'left over and every whistle of three notes is either a call or begins '
          'with one. Two notes for Come-bye, then two whistles of two notes left '
          'for Away, then the two three-note whistles that neither begins are '
          'the last two calls: four markings of the 224.',
    ),
    Level(
      name: 'The Long Calls',
      calls: [('Come-bye', 2), ('Away', 2), ('Walk up', 3), ('Lie down', 3)],
      ways: 36,
      markings: 168,
      note: 'Two calls of two notes take four of the eight three-note whistles '
          'between them, whichever two they are; the two three-note calls choose '
          'among the four left, six ways, and the two-note calls chose six ways '
          'themselves: 36 markings of the 168, and the shares come to six of '
          'eight, so a quarter of the tunes is never used.',
    ),
    Level(
      name: 'The Five Calls',
      calls: [('Lie down', 2), ('Come-bye', 3), ('Away', 3), ('Walk up', 3), ('That\'ll do', 3)],
      ways: 60,
      markings: 280,
      note: 'One two-note call, four ways, takes two of the eight three-note '
          'whistles; the four three-note calls choose among the six left, '
          'fifteen ways: sixty markings of the 280. Shares of two, one, one, one '
          'and one, six of eight.',
    ),
    Level(
      name: 'The Crowded Calls',
      calls: [('Lie down', 1), ('Come-bye', 2), ('Away', 3), ('Walk up', 3), ('That\'ll do', 3)],
      ways: 0,
      markings: 448,
      note: 'One note takes half of every tune, two notes a quarter more, and '
          'that leaves a quarter: two three-note whistles that neither begins, '
          'and three are asked. Shares of four, two, one, one and one come to '
          'nine of eight, more than the whole, so of the 448 markings none '
          'lands, and Kraft\'s inequality says the same of any calls whose '
          'shares are more than the whole.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
