import 'combe.dart';

/// The five combes that ship.
///
/// Every number here is checked before the bake: the sweep, the
/// Prufer code and the standing arithmetic, and
/// tool/check_combes.dart refuses the lot if anything disagrees.
class Combes {
  static const all = [
    Combe(
      name: 'The Three Cottages',
      cottages: 3,
      ends: null,
      ways: 3,
      note: 'Three cottages wire into a run three ways, one for '
          'each cottage left in the middle: Cayley\'s count says '
          'three to the one, and the sweep agrees.',
    ),
    Combe(
      name: 'The Sixteen',
      cottages: 4,
      ends: null,
      ways: 16,
      note: 'Cayley\'s count: four cottages wire four-squared '
          'ways, and every one of the sixteen codes to its own '
          'two-letter Prufer word and back.',
    ),
    Combe(
      name: 'The Long Lane',
      cottages: 5,
      ends: 2,
      ways: 60,
      note: 'Two lane\'s ends make the run one long lane, and 60 '
          'of the 125 runs walk so: five cottages in a row, '
          'counted with both directions worn away.',
    ),
    Combe(
      name: 'The Star',
      cottages: 5,
      ends: 4,
      ways: 5,
      note: 'Four lane\'s ends leave one cottage holding every '
          'line: five runs, one for each choice of the hub.',
    ),
    Combe(
      name: 'The Ring Round',
      cottages: 5,
      ends: 0,
      ways: 0,
      note: 'No lane\'s end means every cottage on two lines at '
          'least, wanting ten line-ends in all, and a run of '
          'four lines has eight to give: two short, before a '
          'single wiring is tried. The sweep tried them all '
          'anyway and found nothing.',
    ),
  ];

  static int get count => all.length;

  static Combe at(int number) => all[number];
}
