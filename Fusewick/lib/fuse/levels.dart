import 'level.dart';

/// The five times that ship.
///
/// Every number here is checked before the bake: every plan of lighting
/// swept, and tool/check_burns.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Thirty',
      fuses: 1,
      asked: 120,
      ways: 1,
      plans: 3,
      note: 'A fuse burns an hour end to end, however unevenly, so lit at both '
          'ends it is gone in half an hour: the two flames meet wherever they '
          'meet, but the whole hour of fuse has burnt in that time twice over. '
          'One plan of the three strikes thirty.',
    ),
    Level(
      name: 'The Forty-Five',
      fuses: 2,
      asked: 180,
      ways: 2,
      plans: 19,
      note: 'Light one fuse at both ends and the other at one end. When the '
          'first is gone, half an hour has passed and the other has half an '
          'hour of fuse left; light its other end and that half hour burns '
          'in a quarter. Two plans of the nineteen strike forty-five.',
    ),
    Level(
      name: 'The Seventy-Five',
      fuses: 3,
      asked: 300,
      ways: 18,
      plans: 231,
      note: 'Thirty by one fuse at both ends, then forty-five more by the other '
          'two the same way, lit at the first burnout: eighteen plans of the '
          '231 strike seventy-five one way or another.',
    ),
    Level(
      name: 'The Fifty-Two and a Half',
      fuses: 3,
      asked: 210,
      ways: 6,
      plans: 231,
      note: 'Three fuses can halve a half: one at both ends and two at one end '
          'each; at thirty, light the second\'s other end, and it is gone at '
          'forty-five with the third holding fifteen minutes; light the '
          'third\'s other end and it is gone seven and a half minutes later. '
          'Six plans of the 231.',
    ),
    Level(
      name: 'The Twenty',
      fuses: 2,
      asked: 80,
      ways: 0,
      plans: 19,
      note: 'The first burnout comes at thirty or at sixty, since a fresh fuse '
          'takes an hour at one end and half at both, and every later burnout '
          'is a whole or a half of what a fuse had left at the one before: '
          'with two fuses the burnouts fall only at 30, 45, 60, 90 and 120, '
          'nineteen plans swept, and twenty is none of them.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
