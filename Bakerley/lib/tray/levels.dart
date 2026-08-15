import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Pinwheel',
      width: 4,
      height: 4,
      counts: [0, 0, 4, 0, 0],
      ways: 2,
      note: 'Four tees fill the four-by-four two ways, the pinwheel and its '
          'mirror, each tee\'s stem into the next; six tees never fill the '
          'six-by-four, though the colouring allows it, and eight fill the '
          'eight-by-four six ways.',
    ),
    Level(
      name: 'The Four Elbows',
      width: 4,
      height: 4,
      counts: [0, 0, 0, 0, 4],
      ways: 10,
      note: 'Four elbows fill the four-by-four ten ways; four skews fill it not '
          'at all, though the colouring allows them too.',
    ),
    Level(
      name: 'The Mixed Tray',
      width: 5,
      height: 4,
      counts: [0, 0, 2, 2, 1],
      ways: 12,
      note: 'Two tees, two skews and an elbow fill the five-by-four twelve ways, '
          'the two tees covering three dark and one light and one dark and three '
          'light between them, so the colouring comes out even.',
    ),
    Level(
      name: 'The Long Tray',
      width: 6,
      height: 4,
      counts: [2, 2, 0, 0, 2],
      ways: 92,
      note: 'Two bars, two squares and two elbows fill the six-by-four '
          'ninety-two ways, and every one of those fours covers two dark and two '
          'light cells whichever way it lies.',
    ),
    Level(
      name: 'The Five',
      width: 5,
      height: 4,
      counts: [1, 1, 1, 1, 1],
      ways: 0,
      note: 'Chequer the tray: ten dark cells and ten light. The bar, the square, '
          'the skew and the elbow each cover two dark and two light whichever way '
          'they lie, and the tee covers three of one and one of the other, so the '
          'five together cover eleven of one shade and nine of the other, never '
          'ten and ten; the search finds no filling either, none of the fillings '
          'of the five-by-four by one of each.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
