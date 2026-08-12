import 'show.dart';

/// The five benches that ship.
///
/// Every number here is checked twice before the bake: the walk of
/// every sitting plays each bench out, and tool/check_shows.dart
/// refuses the lot if any count, skip, or label disagrees with it.
class Shows {
  static const all = [
    Show(
      name: 'The Four Marrows',
      marrows: 4,
      skip: 1,
      wins: 11,
      of: 24,
      swept: 64,
      note: 'Taking the first marrow blind wins only the 6 sittings '
          'of 24 that open with the best; the rule\'s eleven nearly '
          'doubles that.',
    ),
    Show(
      name: 'The Five',
      marrows: 5,
      skip: 2,
      wins: 52,
      of: 120,
      swept: 1024,
      note: 'At five the rule waves two by; waving only one wins 50 '
          'of the 120, two sittings short.',
    ),
    Show(
      name: 'The Six',
      marrows: 6,
      skip: 2,
      wins: 308,
      of: 720,
      note: 'Six marrows and still only two waved by: a third '
          'skipped drops the count to 282.',
    ),
    Show(
      name: 'The Seven',
      marrows: 7,
      skip: 2,
      wins: 2088,
      of: 5040,
      note: 'Seven marrows, two waved by, 29 sittings of every 70 '
          'won; skipping three instead gives up 36 of them.',
    ),
    Show(
      name: 'The Sure Pick',
      marrows: 4,
      skip: 1,
      wins: 11,
      of: 24,
      swept: 64,
      sure: true,
      note: 'The best rule there is still misses 13 sittings of the '
          '24; certainty was never on the bench.',
    ),
  ];

  static int get count => all.length;

  static Show at(int number) => all[number];
}
