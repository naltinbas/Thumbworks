import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Ten',
      hands: 10,
      want: 36,
      beats: false,
      ways: 9,
      note: 'Ten hands cut to 36 at best, which is three, three and four, '
          'or two, two, three and three, since a four and a pair of twos '
          'come to the same. Nine of the 512 cuttings reach it, three of '
          'them laying the four in a different place and six laying the '
          'twos.',
    ),
    Level(
      name: 'The Eleven',
      hands: 11,
      want: 54,
      beats: false,
      ways: 4,
      note: 'Eleven leaves two over when it is divided by three, and the '
          'two is left as a part of its own: three, three, three and two, '
          'which multiplies to 54. Four of the 1,024 cuttings reach it, one '
          'for each place the two can go.',
    ),
    Level(
      name: 'The Twelve',
      hands: 12,
      want: 81,
      beats: false,
      ways: 1,
      note: 'Twelve divides by three exactly, so the best cutting is all '
          'threes and there is only one of it: 81 from four parts, and one '
          'cutting of the 2,048.',
    ),
    Level(
      name: 'The Sixteen',
      hands: 16,
      want: 324,
      beats: false,
      ways: 20,
      note: 'Sixteen leaves one over, and a lone one would be wasted, so it '
          'goes in with a three to make a four: four threes and a four, or '
          'four threes and two twos, 324 either way. Twenty of the 32,768 '
          'cuttings reach it, five with the four and fifteen with the twos.',
    ),
    Level(
      name: 'Beat the Threes',
      hands: 16,
      want: 324,
      beats: true,
      ways: 0,
      note: 'Hopeless, and the card at the end of the ask says so. Any part '
          'of five or more can be cut into a three and the rest, and the '
          'product goes up, since three times what is left beats the part '
          'itself once the part is five or more. Three twos should be two '
          'threes, since nine beats eight. So the best cutting has nothing '
          'but threes with a four or a two over, and for sixteen that is '
          'four threes and a four: 324, which 20 of the 32,768 cuttings '
          'reach and none of them passes.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
