import 'block.dart';

/// The blocks that ship.
///
/// The Thin Truckle teaches the strip: two rows, and the whole game is
/// keeping the bottom one crumb longer than the top. The Square teaches
/// the mirror: nibble the corner next to the mould, then answer every
/// bite across the diagonal. The Long Block and the Great Block have no
/// such shape: the first mouse still wins them, the stealing argument
/// says so, but only the search can say how, and that difference is the
/// point of the game.
///
/// The Second Mouse hands the first bite to the grey mouse on a block
/// where perfect play then wins it the cheese. It ships labelled, in the
/// house tradition of maps nobody can win: the stealing argument cuts
/// both ways, and being second against a mouse that knows is the way to
/// feel it.
class Blocks {
  const Blocks._();

  static final List<Block> all = [
    Block(
      name: 'The Thin Truckle',
      width: 5,
      height: 2,
      fewest: 5,
      note: 'Two rows have a shape you can hold: hand back a block whose '
          'bottom row is exactly one crumb longer than its top, every '
          'time, and the mould is never yours.',
    ),
    Block(
      name: 'The Square',
      width: 4,
      height: 4,
      fewest: 4,
      note: 'Squares have a shape too: nibble the crumb next to the '
          'mould, then answer every bite with its mirror across the '
          'diagonal. The arms stay even, and the last crumb of the arms '
          'is never the mould.',
    ),
    Block(
      name: 'The Long Block',
      width: 5,
      height: 3,
      fewest: 6,
      note: 'No mirror, no strip, no shape anyone has ever named. The '
          'stealing argument proves the first mouse wins every block, and '
          'names no bite at all: the opening here came out of the search, '
          'not out of the proof.',
    ),
    Block(name: 'The Great Block', width: 6, height: 4, fewest: 6),
    Block(
      name: 'The Second Mouse',
      width: 4,
      height: 3,
      fewest: null,
      mouseFirst: true,
      note: 'The grey mouse bites first here, and first wins every block '
          'bigger than the mould alone. That is the stealing argument '
          'felt from the wrong side.',
    ),
  ];

  static int get count => all.length;

  static Block at(int number) => all[number.clamp(0, all.length - 1)];
}
