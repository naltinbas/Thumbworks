import 'watch.dart';

/// The watches that ship.
///
/// Every number here is checked twice over: tool/check_watches.dart
/// sweeps every ring of each and runs the shift-walk besides, and
/// refuses the bake on any disagreement.
class Watches {
  static const all = [
    Watch(
      name: 'The Four Lanterns',
      span: 2,
      length: 4,
      ways: 4,
      note: 'Lit-lit, lit-dark, dark-lit, dark-dark: a full ring is '
          'two lit shoulder to shoulder and two dark the same, '
          'wherever it starts.',
    ),
    Watch(
      name: 'The Eight Watch',
      span: 3,
      length: 8,
      ways: 16,
      note: 'Each lantern begins exactly one word, and half the '
          'words begin lit: a full ring always lights exactly four '
          'of the eight.',
    ),
    Watch(
      name: 'The Locked Watch',
      span: 3,
      length: 8,
      lockedPlaces: 105,
      lockedBits: 1,
      ways: 1,
      note: 'Four lanterns held fast leave the sixteen full rings '
          'just one way through: the free four have one right '
          'answer, and three of them want lighting.',
    ),
    Watch(
      name: 'The Sixteen',
      span: 4,
      length: 16,
      ways: 256,
      note: 'Each lantern begins one of the sixteen words, so a '
          'full ring lights exactly eight, and there is still room '
          'to wander getting there.',
    ),
    Watch(
      name: 'The Short Ring',
      span: 3,
      length: 7,
      ways: 0,
      note: 'One lantern more would mend it: eight places give the '
          'eight words room, and sixteen rings set that watch.',
    ),
  ];

  static int get count => all.length;

  static Watch at(int number) => all[number];
}
