import 'share.dart';

/// The five shares that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every set of cuts, the window held to it, every string of each
/// size swept, and tool/check_strings.dart refuses the lot if
/// anything disagrees.
class Shares {
  static const all = [
    Share(
      name: 'The One Cut',
      sweets: 'RRBBBBRR',
      cuts: 1,
      ways: 1,
      note: 'One cut in the middle shares it, and no other of the '
          'seven: 36 of the 70 strings of four reds and four blues '
          'share with one cut, and 34 need two.',
    ),
    Share(
      name: 'The Two Cuts',
      sweets: 'RRRRBBBB',
      cuts: 2,
      ways: 1,
      note: 'The reds-then-blues string is one of the 34 that need '
          'two cuts, and exactly one pair of cuts shares it: the '
          'window of four sweets holding two reds, which is the '
          'middle four.',
    ),
    Share(
      name: 'The Three Kinds',
      sweets: 'RRGGBB',
      cuts: 3,
      ways: 1,
      note: 'Three kinds may need three cuts, and this string does: '
          'any three sweets in a row of it hold two of a kind, so no '
          'two cuts share it, and one set of three does. Of the 90 '
          'strings of two reds, two greens and two blues, 36 share '
          'with one cut, 42 need two and 12 need three.',
    ),
    Share(
      name: 'The Long String',
      sweets: 'RRRBBBRRRBBB',
      cuts: 2,
      ways: 6,
      note: 'Six sets of two cuts or fewer share the long string, '
          'the middle cut alone among them; of the 924 strings of '
          'six reds and six blues, 400 share with one cut and 524 '
          'need two, and every one shares with two.',
    ),
    Share(
      name: 'The Single Cut',
      sweets: 'RRRRBBBB',
      cuts: 1,
      ways: 0,
      note: 'The seven cuts leave first pieces R, RR, RRR, RRRR, '
          'RRRRB, RRRRBB and RRRRBBB, and none holds two reds and '
          'two blues; the sweep read all seven.',
    ),
  ];

  static int get count => all.length;

  static Share at(int number) => all[number];
}
