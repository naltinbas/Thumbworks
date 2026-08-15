import 'yard.dart';

/// The five yards that ship.
///
/// Every number here is checked before the bake: the sweep at
/// every count, the formula and the box held to it, and
/// tool/check_yards.dart refuses the lot if anything disagrees.
class Yards {
  static const all = [
    Yard(
      name: 'The Square Yard',
      slabs: 4,
      asked: 8,
      ways: 16,
      placings: 228,
      note: 'Four slabs wear a kerb of eight only as the square, 16 '
          'placings of the 228, and every other four wears ten.',
    ),
    Yard(
      name: 'The Six',
      slabs: 6,
      asked: 10,
      ways: 24,
      placings: 1436,
      note: 'Six slabs in a kerb of ten are the two by three and the '
          'three by two, 24 placings of the 1,436, and nothing else '
          'gets under twelve.',
    ),
    Yard(
      name: 'The Eight',
      slabs: 8,
      asked: 12,
      ways: 52,
      placings: 8409,
      note: 'Eight slabs in a kerb of twelve are the two by four, or '
          'the three by three less a corner, 52 placings of the 8,409; '
          'nine slabs in twelve are the three by three alone, 9 '
          'placings.',
    ),
    Yard(
      name: 'The Ten',
      slabs: 10,
      asked: 14,
      ways: 176,
      placings: 39622,
      note: 'Ten slabs wear fourteen at the shortest, 176 placings of '
          'the 39,622: 8 of them fill a two by five, and the other 168 '
          'sit in a three by four with two cells left bare.',
    ),
    Yard(
      name: 'The Five in Eight',
      slabs: 5,
      asked: 8,
      ways: 0,
      placings: 571,
      note: 'Five slabs wear ten at the shortest, 96 placings of the '
          '571, and every one of the 571 sits in a box of at least two '
          'by three, whose kerb is ten already.',
    ),
  ];

  static int get count => all.length;

  static Yard at(int number) => all[number];
}
