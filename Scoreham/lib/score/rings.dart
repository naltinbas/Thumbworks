import 'ring.dart';

/// The five rings that ship.
///
/// Every number here is checked twice before the bake: the walk
/// tries every start, the ledger counts without walking, and
/// tool/check_rings.dart refuses the lot if anything disagrees.
class Rings {
  static const all = [
    Ring(
      name: 'The Five Marks',
      marks: [-1, 1, -1, 1, 1],
      goods: 1,
      note: 'Three notches, two wipes, one ahead: one good start '
          'of the five, and it sits just past the tally\'s lowest '
          'ebb.',
    ),
    Ring(
      name: 'The Seven',
      marks: [1, -1, 1, -1, 1, 1, -1],
      goods: 1,
      note: 'Four notches, three wipes: still only one start of '
          'the seven keeps the tally off the ground the whole way '
          'round.',
    ),
    Ring(
      name: 'The Two Ahead',
      marks: [-1, 1, 1, 1, 1, -1],
      goods: 2,
      note: 'Four notches to two wipes runs two ahead, and the '
          'ring holds exactly two good starts: as many as the '
          'lead, never more, never fewer.',
    ),
    Ring(
      name: 'The Nine',
      marks: [-1, -1, -1, 1, -1, 1, 1, 1, 1],
      goods: 1,
      note: 'Three wipes straight off the start: the one good '
          'start hides deep, past the last and lowest ebb of the '
          'walk.',
    ),
    Ring(
      name: 'The Tied Vote',
      marks: [1, -1, 1, -1, 1, -1],
      goods: 0,
      note: 'Three notches, three wipes, nothing ahead: the whole '
          'walk always comes home to nought, so every start '
          'touches the ground somewhere on the way.',
    ),
  ];

  static int get count => all.length;

  static Ring at(int number) => all[number];
}
