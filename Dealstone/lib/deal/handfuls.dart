import 'handful.dart';

/// The five handfuls that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every hand, the standstill law, and tool/check_deals.dart
/// refuses the lot if anything disagrees.
class Handfuls {
  static const all = [
    Handful(
      name: 'The Stair of Six',
      stones: 6,
      asked: 0,
      opens: [6],
      ways: 1,
      note: 'One hand alone stands still at six: the stair '
          'itself, three, two, one, each deal paying it '
          'straight back.',
    ),
    Handful(
      name: 'The Long Six',
      stones: 6,
      asked: 6,
      opens: [6],
      ways: 1,
      note: 'The longest road of six is walked by '
          'two-two-one-one alone: six deals to the stair.',
    ),
    Handful(
      name: 'The Middle Road',
      stones: 10,
      asked: 3,
      opens: [10],
      ways: 5,
      note: 'Five hands of the forty-two stand three deals '
          'out, and the whole walk is drawn deal by deal '
          'beneath the piles.',
    ),
    Handful(
      name: 'The Twelve Deals',
      stones: 10,
      asked: 12,
      opens: [4, 3, 2, 1],
      ways: 3,
      note: 'The three longest hands of ten all keep their '
          'biggest pile at three: twelve deals each, the whole '
          'reach of the deal at ten.',
    ),
    Handful(
      name: 'The Eight Standstill',
      stones: 8,
      asked: 0,
      opens: [8],
      ways: 0,
      note: 'A standstill must pay itself back: the takings '
          'pile equals the count of piles, which forces the '
          'stair, and stairs hold one, three, six or ten '
          'stones, never eight.',
    ),
  ];

  static int get count => all.length;

  static Handful at(int number) => all[number];
}
