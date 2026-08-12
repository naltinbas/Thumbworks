import 'circle.dart';

/// The five circles that ship.
///
/// Every number here is checked before the bake: the sweep
/// against the daisy count, hearts times pairings, the pairing
/// lemma on every landing, and tool/check_daisies.dart refuses
/// the lot if anything disagrees.
class Circles {
  static const all = [
    Circle(
      name: 'The Three Friends',
      people: 3,
      ways: 1,
      note: 'The triangle is the one wiring of three that '
          'manages it, and it is the daisy of a single petal: '
          'every corner sits at its heart.',
    ),
    Circle(
      name: 'The Given Hub',
      people: 5,
      given: [(0, 1), (0, 2), (0, 3), (0, 4)],
      ways: 3,
      note: 'With the heart\'s friendships given, all that is '
          'left is pairing four people into two petals, and '
          'four people pair off three ways.',
    ),
    Circle(
      name: 'The Five',
      people: 5,
      ways: 15,
      note: 'Fifteen is five hearts times the three pairings '
          'of the rest: every landing is a daisy, and the '
          'count says so twice over.',
    ),
    Circle(
      name: 'The Seven',
      people: 7,
      ways: 105,
      note: 'A hundred and five is seven hearts times fifteen '
          'pairings of six, and the sweep of all 2,097,152 '
          'wirings finds not one landing more.',
    ),
    Circle(
      name: 'The Even Crowd',
      people: 4,
      ways: 0,
      note: 'Around any one person the friends pair off, each '
          'with the one friend they share through the middle, '
          'so every friend count comes even. Four people cap '
          'the count at three, so everyone has exactly two '
          'friends, a ring of four; and in a ring of four, '
          'neighbours share nobody at all.',
    ),
  ];

  static int get count => all.length;

  static Circle at(int number) => all[number];
}
