import 'fewest.dart';
import 'pyx.dart';

/// The boxes that ship.
///
/// Four coins is here because counting alone gets it wrong. Eight things to
/// tell apart and two weighings tell nine apart, so counting says two might
/// do, and it cannot be done in two. Counting says what is impossible and it
/// is right about that. It does not say what is possible.
///
/// Nine Clipped and Nine are the same nine coins, once knowing the wrong one
/// is light and once not. Nine things to tell apart takes two weighings and
/// eighteen takes three, which is the whole of what not knowing costs.
class Boxes {
  const Boxes._();

  static const all = <Pyx>[
    Pyx(name: 'Three', coins: 3, fewest: 2),
    Pyx(name: 'Four', coins: 4, fewest: 3),
    Pyx(name: 'Nine Clipped', coins: 9, fewest: 2, knownLight: true),
    Pyx(name: 'Six', coins: 6, fewest: 3),
    Pyx(name: 'Nine', coins: 9, fewest: 3),
    Pyx(name: 'Eleven', coins: 11, fewest: 3),
    Pyx(name: 'The Dozen', coins: 12, fewest: 3),
  ];

  static int get count => all.length;

  static Pyx at(int number) => all[number.clamp(0, all.length - 1)];

  /// One searching per box, kept between screens so that what it works out on
  /// the way through is not thrown away and worked out again.
  static final _assays = <int, Assay>{};

  static Assay assayFor(int number) =>
      _assays.putIfAbsent(number, () => Assay.of(at(number).coins));

  /// Empties what the searching has kept. For the tests, so that one box does
  /// not hand its working to another.
  static void forget() => _assays.clear();
}
