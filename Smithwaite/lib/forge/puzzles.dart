import 'puzzle.dart';

/// The puzzles that ship.
///
/// The first three are the toy as the smith hands it over, every ring on,
/// at three, four and five rings. The Tangle is five rings with only the
/// top one on, which looks nearly done and is the farthest state five
/// rings have: thirty one moves, ten more than the whole puzzle from the
/// start. The Masterpiece is the piece a prentice made to become a master,
/// seven rings and eighty five moves, every one of them forced.
class Puzzles {
  const Puzzles._();

  static final List<Puzzle> all = [
    Puzzle(name: 'The Prentice Piece', rings: 3, fewest: 5),
    Puzzle(name: 'The Four in Hand', rings: 4, fewest: 10),
    Puzzle(name: 'The Fair Day Five', rings: 5, fewest: 21),
    Puzzle(
      name: 'The Tangle',
      rings: 5,
      laid: 1 << 4,
      fewest: 31,
      note: 'One ring on looks nearly done. It is the farthest state five '
          'rings have: every ring must go on again before the top one can '
          'come off.',
    ),
    Puzzle(name: 'The Masterpiece', rings: 7, fewest: 85),
  ];

  static int get count => all.length;

  static Puzzle at(int number) => all[number.clamp(0, all.length - 1)];
}
