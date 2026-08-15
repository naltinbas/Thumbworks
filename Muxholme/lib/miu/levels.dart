import 'level.dart';

/// The five strings that ship.
///
/// Every number here is checked before the bake: every derivation of
/// so many steps swept, every string on the sheet walked from MI, the
/// count of I held to its law, and tool/check_derivings.dart refuses
/// the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'MIU',
      target: 'MIU',
      steps: 1,
      ways: 1,
      derivations: 2,
      note: 'MI ends in I, so rule one puts a U on the end: MIU in one step, '
          'the only other step being rule two, MII.',
    ),
    Level(
      name: 'MIIU',
      target: 'MIIU',
      steps: 2,
      ways: 1,
      derivations: 3,
      note: 'Rule two doubles the I, MII, and rule one ends it with U: MIIU '
          'in two steps, one derivation of the three of two steps.',
    ),
    Level(
      name: 'MUI',
      target: 'MUI',
      steps: 3,
      ways: 1,
      derivations: 6,
      note: 'Double twice, MII then MIIII, and turn the first three I into U: '
          'MUI, one derivation of the six of three steps. The count of I went '
          'one, two, four, one.',
    ),
    Level(
      name: 'MUIIU',
      target: 'MUIIU',
      steps: 5,
      ways: 2,
      derivations: 57,
      note: 'Double three times, MIIIIIIII, eight I; turn the first three to U, '
          'MUIIIII, and three more to U, MUIIU: five steps, two derivations of '
          'the fifty-seven, the two last steps either way round.',
    ),
    Level(
      name: 'MU',
      target: 'MU',
      steps: 6,
      ways: 0,
      derivations: 299,
      note: 'MU has no I at all, and the count of I is never a multiple of '
          'three: it starts at one, rule two doubles it and rule three takes '
          'three away, and neither makes a multiple of three out of what is not '
          'one. Every derivation of six steps was swept, 299 of them, and every '
          'string on the sheet walked, 106,389 strings, and MU is not among '
          'them.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
