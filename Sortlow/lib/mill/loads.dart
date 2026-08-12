import 'load.dart';

/// The five loads that ship.
///
/// Every number here is checked before the bake: the walk and
/// the backwards table over all 9,990 loads, and
/// tool/check_roads.dart refuses the lot if anything disagrees.
class Loads {
  static const all = [
    Load(
      name: 'The One Turn',
      asked: 1,
      opens: 2026,
      ways: 383,
      note: 'The smallest one-turn load is a surprise: '
          'twenty-six, worn as 0026, whose one grind is 6200 '
          'less 26.',
    ),
    Load(
      name: 'The Three Turns',
      asked: 3,
      opens: 1467,
      ways: 2400,
      note: 'Three turns is the commonest road home: '
          'twenty-four hundred loads stand there, more than at '
          'any other distance.',
    ),
    Load(
      name: 'The Seven Turns',
      asked: 7,
      opens: 1467,
      ways: 2184,
      note: 'No road is longer: seven turns is the mill\'s '
          'whole reach, and 2,184 loads walk it full.',
    ),
    Load(
      name: 'The Standstill',
      asked: 0,
      opens: 1000,
      ways: 1,
      note: 'One number alone stands still: 7641 less 1467 '
          'gives 6174 back. No other four digits do it.',
    ),
    Load(
      name: 'The Eighth Turn',
      asked: 8,
      opens: 1000,
      ways: 0,
      note: 'The repdigits never enter, collapsing to nought '
          'at one grind and barred at the door; everything '
          'else arrives by the seventh.',
    ),
  ];

  static int get count => all.length;

  static Load at(int number) => all[number];
}
