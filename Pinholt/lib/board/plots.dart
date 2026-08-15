import 'plot.dart';

/// The five plots that ship.
///
/// Every number here is checked before the bake: the sweep at
/// every count of pins, the fence held to the frame census, and
/// tool/check_frames.dart refuses the lot if anything disagrees.
class Plots {
  static const all = [
    Plot(
      name: 'The Framed Four',
      pins: 4,
      asked: 1,
      ways: 7398,
      placings: 9498,
      note: 'Four pins frame when the fence runs through all four, '
          '7,398 placings of the 9,498, and never otherwise.',
    ),
    Plot(
      name: 'The Tucked Four',
      pins: 4,
      asked: 0,
      ways: 2100,
      placings: 9498,
      note: 'Four pins go frameless when one is tucked inside the '
          'other three, a fence of three, 2,100 placings of the '
          '9,498.',
    ),
    Plot(
      name: 'The Lone Frame',
      pins: 5,
      asked: 1,
      ways: 624,
      placings: 25052,
      note: 'Five pins hold one frame only when the fence runs '
          'through three of them and two stand inside, 624 '
          'placings of the 25,052; the frame is the two inside '
          'with the two fence pins on one side of their line, and '
          'it is built that way for every one of the 624.',
    ),
    Plot(
      name: 'The Three Frames',
      pins: 6,
      asked: 3,
      ways: 12,
      placings: 36698,
      note: 'Three frames is the fewest six pins ever hold, and '
          'only 12 placings of the 36,698 manage it; a fence of '
          'three holds 3, 5 or 6 frames, of four 7 to 9, of five '
          '10 to 12, and six on the fence hold all 15.',
    ),
    Plot(
      name: 'The Frameless Five',
      pins: 5,
      asked: 0,
      ways: 0,
      placings: 25052,
      note: 'Five pins hold 1, 3 or 5 frames and never nought nor '
          'any other count: one for a fence of three, three for a '
          'fence of four, five for a fence of five, over all 25,052 '
          'placings.',
    ),
  ];

  static int get count => all.length;

  static Plot at(int number) => all[number];
}
