import 'charm.dart';

/// The charms that ship.
///
/// Every number here is checked twice over: tool/check_charms.dart
/// sweeps every filling of the bed and refuses the bake if a written
/// figure is wrong, and the suite proves the counting besides.
class Charms {
  static const all = [
    Charm(
      name: 'The Nine Coins',
      pins: {},
      ways: 8,
      note: 'Eight charms hold, and they are one square eight ways '
          'round: turn or mirror any and the sweep finds it among '
          'the rest.',
    ),
    Charm(
      name: 'The Anchored Five',
      pins: {4: 5},
      ways: 8,
      note: 'The pin costs nothing: the four lines through the heart '
          'count sixty together and the whole bed forty five, so the '
          'heart carries the odd fifteen alone. Five it was always '
          'going to be.',
    ),
    Charm(
      name: 'The Cornered Two',
      pins: {0: 2},
      ways: 2,
      note: 'A two in the corner leaves two charms standing, each the '
          'other mirrored across that corner: the sweep counts them '
          'both.',
    ),
    Charm(
      name: 'The Written Row',
      pins: {0: 4, 1: 9, 2: 2},
      ways: 1,
      note: 'A whole row written leaves exactly one charm: the sweep '
          'says so, and every other coin is forced from there.',
    ),
    Charm(
      name: 'The Heart of One',
      pins: {4: 1},
      ways: 0,
      note: 'The four lines through the heart count sixty together; '
          'the bed holds forty five, and the heart is counted three '
          'times over. Sixty less forty five is fifteen, three '
          'hearts\' worth, so the heart is five, and one it can '
          'never be. The sweep of every filling agrees: none holds.',
    ),
    Charm(
      name: 'The Heavy Row',
      pins: {0: 9, 1: 8},
      ways: 0,
      note: 'Nine and eight side by side already count seventeen, and '
          'their row must count fifteen: the third coin would be '
          'worth less than nothing, and no coin is. The sweep '
          'agrees: none holds.',
    ),
  ];

  static int get count => all.length;

  static Charm at(int number) => all[number];
}
