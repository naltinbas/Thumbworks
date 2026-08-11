import 'tilth.dart';

/// The tilths that ship.
///
/// Each winning board is the only winnable board of its size, grown by
/// unsowing from the barn, and the game still has choices because wrong
/// sowings leave boards of the same size that are not that one. The
/// Dead Furrows is a lost board whose death is visible: its first
/// furrow holds two, can never be sown holding other than one, and only
/// ever gains.
class Tilths {
  const Tilths._();

  static final List<Tilth> all = [
    Tilth(
      name: 'The First Handful',
      board: const [1, 1, 3],
      winnable: true,
      note: 'Five seeds. Sow the third furrow first and the first '
          'furrow swells to two: overfull, dead, and the board tells '
          'you so. Nearest first is the way home.',
    ),
    Tilth(
      name: 'The Eight Seeds',
      board: const [0, 2, 2, 4],
      winnable: true,
    ),
    Tilth(
      name: 'The Dead Furrows',
      board: const [2, 2],
      winnable: false,
      note: 'The first furrow holds two. It can be sown only holding '
          'exactly one, and every other sowing adds to it: those two '
          'seeds can never leave, and the board was dead before a hand '
          'touched it. The only winnable board of four seeds is nought, '
          'one, three.',
    ),
    Tilth(
      name: 'The Twelve',
      board: const [0, 0, 0, 2, 4, 6],
      winnable: true,
      note: 'Twelve seeds and three empty furrows by the barn: the '
          'unsowing leaves gaps where it must, and the play threads '
          'them.',
    ),
    Tilth(
      name: 'The Score of Seeds',
      board: const [0, 2, 2, 1, 3, 5, 7],
      winnable: true,
    ),
  ];

  static int get count => all.length;

  static Tilth at(int number) => all[number.clamp(0, all.length - 1)];
}
