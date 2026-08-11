import 'deal.dart';

/// The deals that ship.
///
/// Every one but the third came out of `make find`, which keeps a morning
/// only when the hoarder's way of playing it, each bale on the heaviest top
/// that can take it to keep the snug tops free, ends at least one pile over
/// the fewest. The tempting mistake has somewhere to fall on every deal.
///
/// The Nine Tods is there for a different reason. Three falling loads of
/// three rising bales make the longest rising run and the longest falling
/// run both exactly three, and nine is the most bales that can hold both
/// runs under four: the boundary case of the theorem tested at every size in
/// the suite. Ten bales always break one way or the other.
class Deals {
  const Deals._();

  static final List<Deal> all = [
    Deal(
      name: 'The Morning Cart',
      fewest: 2,
      tods: const [39, 22, 38, 3, 34],
    ),
    Deal(
      name: 'The Hoarded Fit',
      fewest: 3,
      tods: const [7, 37, 26, 4, 23, 14, 16],
    ),
    Deal(
      name: 'The Nine Tods',
      fewest: 3,
      tods: const [20, 24, 28, 12, 15, 18, 5, 8, 10],
      note: 'This morning also has a falling run of three, and nine bales '
          'is the most a carter can load with neither run reaching four. '
          'Ten always break, one way or the other.',
    ),
    Deal(
      name: 'The Long Wain',
      fewest: 4,
      tods: const [9, 38, 37, 3, 8, 33, 36, 29, 34, 26, 24, 6],
    ),
    Deal(
      name: 'The Whole Clip',
      fewest: 5,
      tods: const [38, 16, 40, 21, 31, 33, 26, 37, 30, 34, 8, 24, 2, 12, 4, 11],
    ),
  ];

  static int get count => all.length;

  static Deal at(int number) => all[number.clamp(0, all.length - 1)];
}
