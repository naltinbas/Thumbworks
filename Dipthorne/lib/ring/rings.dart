import 'ring.dart';

/// The rings that ship.
///
/// The two-beat rings carry the famous trick, and Ip Dip is the boundary
/// case that teaches it: eight is a power of two, so the front figure of
/// 1000 moves to the back and leaves 0001, the dip stone seat itself. The
/// longer rhymes have no trick, only the reckoning, and the count run out
/// loud agrees with it on every ring here and every ring the suite sweeps.
class Rings {
  const Rings._();

  static final List<Ring> all = [
    Ring(
      name: 'Ip Dip',
      children: 8,
      rhyme: const ['Ip,', 'dip'],
      safe: 1,
      note: 'Eight is a power of two, and for those the turn changes '
          'nothing: 1000 turns to 0001. The dip stone seat itself is safe, '
          'and it is the only kind of ring where it is.',
    ),
    Ring(
      name: 'The Thirteen',
      children: 13,
      rhyme: const ['Ip,', 'dip'],
      safe: 11,
    ),
    Ring(
      name: 'The Score',
      children: 20,
      rhyme: const ['Ip,', 'dip'],
      safe: 9,
    ),
    Ring(
      name: 'Sky Blue',
      children: 10,
      rhyme: const ['One,', 'two,', 'sky,', 'blue,', 'all', 'out', 'YOU'],
      safe: 9,
      note: 'Seven beats have no binary turn. The reckoning alone carries '
          'the longer rhymes, and the count run out loud agrees with it.',
    ),
    Ring(
      name: 'The Whole Yard',
      children: 21,
      rhyme: const ['Ash,', 'oak,', 'thorn,', 'iron,', 'OUT'],
      safe: 12,
    ),
  ];

  static int get count => all.length;

  static Ring at(int number) => all[number.clamp(0, all.length - 1)];
}
