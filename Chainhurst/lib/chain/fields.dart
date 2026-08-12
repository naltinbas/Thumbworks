import 'field.dart';

/// The five fields that ship.
///
/// Every number here is checked twice before the bake: strung
/// lines against thirds-on-the-pair over the whole sweep, and
/// tool/check_chains.dart refuses the lot if anything disagrees.
class Fields {
  static const all = [
    Field(
      name: 'The One Chain',
      stones: 3,
      asked: 0,
      offRow: false,
      ways: 152,
      note: 'The only way to no bare chain is one laden chain: '
          'all three stones in a single row. The sweep finds 152 '
          'rows of three on the field, straight, slant and steep.',
    ),
    Field(
      name: 'The Six',
      stones: 4,
      asked: 6,
      offRow: false,
      ways: 9498,
      note: 'Four stones with no three sharing a row string six '
          'chains, every pair its own: 9,498 of the 12,650 '
          'placings sit so.',
    ),
    Field(
      name: 'The Three',
      stones: 4,
      asked: 3,
      offRow: false,
      ways: 3088,
      note: 'Four stones only ever show nought, three, or six '
          'bare chains, nothing between: the sweep of all 12,650 '
          'placings found no other count. Three means a laden '
          'chain of three with the fourth stone off it.',
    ),
    Field(
      name: 'The Fewest of Five',
      stones: 5,
      asked: 4,
      offRow: true,
      ways: 4358,
      note: 'Four bare chains is the floor for five stones not '
          'all in one row on this field: the sweep looked for '
          'three or fewer and found none. Four stones in a row '
          'with one stood off is one way of touching it.',
    ),
    Field(
      name: 'The Bare-less Field',
      stones: 5,
      asked: 0,
      offRow: true,
      ways: 0,
      note: 'Sylvester and Gallai\'s law: stones not all in one '
          'row always show a bare chain. The sweep laid all '
          '53,130 placings of five; the only twelve with no bare '
          'chain are the five-in-a-row placings the asking bars.',
    ),
  ];

  static int get count => all.length;

  static Field at(int number) => all[number];
}
