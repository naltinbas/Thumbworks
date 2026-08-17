import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts. The numbers inside the
/// notes are the same sweep's, written out by hand.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Small Estate',
      estate: 12,
      ways: 1,
      kind: 'level',
      note: 'Twelve coins against bonds of 12, 24 and 36, which is the '
          'Talmud\'s hundred zuz against a hundred, two hundred and three '
          'hundred. One division of the 91 levels all three scales, and it '
          'is four coins each. With so little on the table no bond is small '
          'enough for anyone to concede anything, so every pair splits dead '
          'even, and even between every pair means the three purses match.',
    ),
    Level(
      name: 'The Middling Estate',
      estate: 24,
      ways: 1,
      kind: 'level',
      note: 'Twenty-four coins, the Talmud\'s two hundred zuz. One division '
          'of the 325 levels all three scales: 6, 9 and 9, which is 50, 75 '
          'and 75 zuz. The short bond is now small enough that the other '
          'two concede nothing to it and it takes a quarter, while the two '
          'long bonds still split their own coins evenly.',
    ),
    Level(
      name: 'The Large Estate',
      estate: 36,
      ways: 1,
      kind: 'level',
      note: 'Thirty-six coins, the Talmud\'s three hundred zuz. One division '
          'of the 703 levels all three scales: 6, 12 and 18, which is 50, '
          '100 and 150 zuz, and here alone the shares run in proportion to '
          'the bonds. The three rows of the table look like three different '
          'rules and are one.',
    ),
    Level(
      name: 'The Fuller Estate',
      estate: 48,
      ways: 1,
      kind: 'level',
      note: 'Forty-eight coins, past the halfway mark of the 72 the bonds '
          'come to, and the rule turns over: below half the claims the '
          'shares are levelled from the bottom, above it the losses are. '
          'One division of the 1,225 levels every scale, 6, 15 and 27, so '
          'the short bond gets no more than it did at thirty-six while the '
          'other two take the rest.',
    ),
    Level(
      name: 'Reward the Long Bond',
      estate: 12,
      ways: 0,
      kind: 'long',
      note: 'Hopeless, and the card at the end of the ask says so. Twelve '
          'coins is under every bond, so no heir can concede a coin to '
          'another: whatever two of them hold between them, both still '
          'claim all of it, and the garment rule halves it. Even between '
          'every pair leaves the three purses equal, and equal purses put '
          'nobody ahead. None of the 91 divisions does it.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
