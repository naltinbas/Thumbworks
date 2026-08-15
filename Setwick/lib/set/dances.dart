import 'dance.dart';

/// The five sets that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every pairing, Bezout's partners held to it, Wilson's product
/// taken whole, and tool/check_sets.dart refuses the lot if
/// anything disagrees.
class Dances {
  static const all = [
    Dance(
      name: 'The Set of Seven',
      caller: 7,
      pairings: 3,
      ways: 1,
      note: 'Two pairs, 2 with 4 and 3 with 5, and the whole set '
          'multiplied comes to 6 over 7: 720 is 102 sevens and 6.',
    ),
    Dance(
      name: 'The Set of Eleven',
      caller: 11,
      pairings: 105,
      ways: 1,
      note: 'One pairing of the 105 lands, 2 with 6, 3 with 4, 5 '
          'with 9 and 7 with 8, and 3,628,800 is 329,890 elevens '
          'and 10.',
    ),
    Dance(
      name: 'The Set of Thirteen',
      caller: 13,
      pairings: 945,
      ways: 1,
      note: 'One pairing of the 945 lands, five pairs, and 12! is '
          '36,846,276 thirteens and 12.',
    ),
    Dance(
      name: 'The Set of Seventeen',
      caller: 17,
      pairings: 135135,
      ways: 1,
      note: 'One pairing of the 135,135 lands, seven pairs, and 16! '
          'is 1,230,752,346,352 seventeens and 16.',
    ),
    Dance(
      name: 'The Set of Nine',
      caller: 9,
      pairings: 15,
      ways: 0,
      note: 'Dancer 3 comes to 3, 6, 0, 3, 6, 0, 3, 6 with the '
          'eight in turn and never to one, dancer 6 the same the '
          'other way about, and 8! is 4,480 nines exactly, nothing '
          'over.',
    ),
  ];

  static int get count => all.length;

  static Dance at(int number) => all[number];
}
