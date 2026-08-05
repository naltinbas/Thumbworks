import 'dairy.dart';
import 'fewest.dart';

/// One morning in the dairy, ready to be measured out.
class Morning {
  Morning({required this.dairy, required this.fewest});

  final Dairy dairy;

  /// The fewest goes it takes. Written down here as well as worked out, so
  /// that a test can hold the two against each other.
  final int fewest;

  String get name => dairy.name;
}

/// The mornings that ship.
///
/// They get longer, and two of them have churns that share a factor, so that
/// there are amounts nobody can measure at all and the game has something
/// worth saying about why.
class Mornings {
  const Mornings._();

  static final List<Morning> all = [
    Morning(
      fewest: 6,
      dairy: Dairy(name: 'Four Gallons', churns: const [3, 5], want: 4),
    ),
    Morning(
      fewest: 6,
      dairy: Dairy(name: 'Nothing Odd', churns: const [6, 10], want: 8),
    ),
    Morning(
      fewest: 10,
      dairy: Dairy(name: 'The Long Way Round', churns: const [3, 8], want: 4),
    ),
    Morning(
      fewest: 8,
      dairy: Dairy(name: 'Ten out of Fourteen', churns: const [6, 14], want: 10),
    ),
    Morning(
      fewest: 12,
      dairy: Dairy(name: 'Seven', churns: const [3, 11], want: 7),
    ),
    Morning(
      fewest: 14,
      dairy: Dairy(name: 'Five out of Thirteen', churns: const [3, 13], want: 5),
    ),
    Morning(
      fewest: 9,
      dairy: Dairy(name: 'The Whole Dairy', churns: const [5, 6, 11], want: 8),
    ),
  ];

  static int get count => all.length;

  static Morning at(int number) => all[number.clamp(0, all.length - 1)];

  /// Worked out once, when a morning is opened.
  static Measure answerFor(int number) => Pouring.fewestFor(at(number).dairy)!;
}
