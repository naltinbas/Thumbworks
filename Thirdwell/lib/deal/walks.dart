import 'walk.dart';

/// The five walks that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every run of placings, Gergonne's arithmetic held to it for
/// every counter and every place, and tool/check_deals.dart
/// refuses the lot if anything disagrees.
class Walks {
  static const all = [
    Walk(
      name: 'The Top',
      chosen: 16,
      place: 0,
      deals: 3,
      ways: 1,
      note: 'Top, top, top: the run of placings that reads nought in '
          'threes, and the only one of the 27 that lands the counter on '
          'top.',
    ),
    Walk(
      name: 'The Middle',
      chosen: 16,
      place: 13,
      deals: 3,
      ways: 1,
      note: 'Middle, middle, middle: one and three and nine make '
          'thirteen, the middle place of twenty-seven, and no other run '
          'lands it there.',
    ),
    Walk(
      name: 'The Bottom',
      chosen: 16,
      place: 26,
      deals: 3,
      ways: 1,
      note: 'Bottom, bottom, bottom: two and six and eighteen make '
          'twenty-six, the last place, one run only.',
    ),
    Walk(
      name: 'The Twentieth',
      chosen: 16,
      place: 19,
      deals: 3,
      ways: 1,
      note: 'Nineteen is one and nought threes and two nines: middle, '
          'then top, then bottom, and the counter lands twentieth from '
          'the top; every one of the 27 places is reached by exactly one '
          'run, from any of the 27 starts.',
    ),
    Walk(
      name: 'The Top in Two',
      chosen: 16,
      place: 0,
      deals: 2,
      ways: 0,
      note: 'Two deals reach only nine places, the second, fifth, eighth '
          'and so on to the twenty-sixth: counter 17 starts one nine and '
          'seven down, so after two deals its place is always one more '
          'than a multiple of three, and the top is not.',
    ),
  ];

  static int get count => all.length;

  static Walk at(int number) => all[number];
}
