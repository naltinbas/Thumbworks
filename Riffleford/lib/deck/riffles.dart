import 'riffle.dart';

/// The five riffles that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every full riffle, the counts by arithmetic, the tops-differ
/// walk, and tool/check_riffles.dart refuses the lot if anything
/// disagrees.
class Riffles {
  static const all = [
    Riffle(
      name: 'The Odd Cut',
      deck: 'RBRBRBRB',
      cut: 3,
      turned: true,
      kinds: 2,
      wantMixed: true,
      ways: 56,
      riffles: 56,
      note: 'Every one of the 56 riffles deals four mixed pairs; the '
          'piles read the pattern in opposite directions from the cut, '
          'and their tops differ at the start of every pair, whichever '
          'card dropped last.',
    ),
    Riffle(
      name: 'The Even Cut',
      deck: 'RBRBRBRB',
      cut: 4,
      turned: true,
      kinds: 2,
      wantMixed: true,
      ways: 70,
      riffles: 70,
      note: 'Every one of the 70 riffles deals four mixed pairs, the '
          'packet turned; the same cut with the packet not turned lands '
          'only 6 of the 70.',
    ),
    Riffle(
      name: 'The Unturned Packet',
      deck: 'RBRBRBRB',
      cut: 4,
      turned: false,
      kinds: 2,
      wantMixed: true,
      ways: 6,
      riffles: 70,
      note: 'With the packet not turned the two piles read the pattern '
          'the same way and both start red, so only 6 riffles of the 70 '
          'keep every pair mixed, and all six deal the deck back in its '
          'own order.',
    ),
    Riffle(
      name: 'The Three Kinds',
      deck: 'RBGRBGRBG',
      cut: 4,
      turned: true,
      kinds: 3,
      wantMixed: true,
      ways: 126,
      riffles: 126,
      note: 'Three kinds round and round, and every one of the 126 '
          'riffles deals three triples with one of each: the principle '
          'holds for any length of pattern.',
    ),
    Riffle(
      name: 'The Two Reds',
      deck: 'RBRBRBRB',
      cut: 3,
      turned: true,
      kinds: 2,
      wantMixed: false,
      ways: 0,
      riffles: 56,
      note: 'The two piles begin red and black, and after any pair '
          'the piles\' tops are one of each again, so no pair ever holds '
          'two reds nor two blacks; the sweep dealt all 56 and found '
          'none.',
    ),
  ];

  static int get count => all.length;

  static Riffle at(int number) => all[number];
}
