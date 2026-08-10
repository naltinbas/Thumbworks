import 'chase.dart';
import 'fewest.dart';

/// One forme on the bench: a chase, the arrangement it was handed over in, and
/// the fewest slides that put it right.
class Forme {
  Forme({
    required this.chase,
    required this.start,
    required this.fewest,
    this.dropped = false,
  });

  final Chase chase;

  /// How the type stands when the forme is picked up.
  final List<int> start;

  /// The fewest slides from there to reading right. Written down here as well
  /// as worked out, so a test can hold the two against each other. On the
  /// dropped forme it is the fewest after the two sorts are swapped back.
  final int fewest;

  /// Whether this is the forme the apprentice dropped: two sorts swapped, so
  /// no amount of sliding can ever make it read right.
  final bool dropped;

  String get name => chase.name;
}

/// The formes that ship.
///
/// The words are the words of the trade: a quoin is the wedge that locks the
/// type in, a flong is the mould a page is cast from, matrices are the moulds
/// the letters themselves are cast in. Every word has no letter twice, which
/// the reasoning about pairs out of order quietly relies on.
///
/// One forme is impossible on purpose and says so on the label, the way the
/// map nobody can win in Warrenshaw does. The apprentice has put two sorts
/// back the wrong way round, and no sliding will ever mend it. It is there to
/// be seen: the game shows why, and lets you swap the pair back and then
/// solve what is left.
class Formes {
  const Formes._();

  static final List<Forme> all = [
    Forme(
      chase: Chase(name: 'Ink', wide: 2, tall: 2, reading: 'INK'),
      start: const [-1, 2, 1, 0],
      fewest: 6,
    ),
    Forme(
      chase: Chase(name: 'The Quoin', wide: 3, tall: 2, reading: 'QUOIN'),
      start: const [2, 4, 3, -1, 1, 0],
      fewest: 14,
    ),
    Forme(
      chase: Chase(name: 'The Flong', wide: 2, tall: 3, reading: 'FLONG'),
      start: const [4, -1, 0, 3, 1, 2],
      fewest: 16,
    ),
    Forme(
      chase: Chase(name: 'The Dropped Forme', wide: 2, tall: 2, reading: 'INK'),
      // Two sorts back the wrong way round, so it can never be slid right,
      // and a test proves that by walking everything. Swap the pair and five
      // slides finish it.
      start: const [2, 1, -1, 0],
      fewest: 5,
      dropped: true,
    ),
    Forme(
      chase: Chase(name: 'Justify', wide: 4, tall: 2, reading: 'JUSTIFY'),
      start: const [3, 6, -1, 5, 2, 1, 0, 4],
      fewest: 22,
    ),
    Forme(
      chase: Chase(name: 'The Foundry', wide: 4, tall: 2, reading: 'FOUNDRY'),
      start: const [3, 5, 1, 4, 2, -1, 6, 0],
      fewest: 30,
    ),
    Forme(
      chase: Chase(name: 'Matrices', wide: 3, tall: 3, reading: 'MATRICES'),
      // The worst arrangement there is: nothing on the whole frame is
      // further from reading right, and a test says so.
      start: const [5, 3, 6, 7, 4, -1, 2, 1, 0],
      fewest: 31,
    ),
  ];

  static int get count => all.length;

  static Forme at(int number) => all[number.clamp(0, all.length - 1)];

  /// One walk per forme, kept between screens so the table of distances is
  /// not thrown away and walked again.
  static final _slides = <int, Slides>{};

  static Slides slidesFor(int number) =>
      _slides.putIfAbsent(number, () => Slides(at(number).chase));

  /// Empties what the walks have kept. For the tests, so that one forme does
  /// not hand its table to another.
  static void forget() => _slides.clear();
}
