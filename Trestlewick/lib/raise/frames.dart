import 'fewest.dart';
import 'frame.dart';

/// The frames that ship.
///
/// Each one is a frame that could really stand up: sills first, then posts on
/// the sills, then whatever rests on the posts. What varies is how much of it
/// can go up at once, which is the whole of the puzzle.
///
/// Every one of them is a frame where one of the two floors is exactly the
/// answer, so the reason it cannot be done in fewer days is always something a
/// player can see rather than something to be taken on trust.
class Frames {
  const Frames._();

  static final List<Frame> all = [
    _theTrestle(),
    _theGableEnd(),
    _theCartShed(),
    _theQueenPost(),
    _theLongBarn(),
    _theTithe(),
  ];

  static int get count => all.length;

  static Frame at(int number) => all[number.clamp(0, all.length - 1)];

  /// One working out per frame, kept between screens so what it settles on
  /// the way through is not thrown away and settled again.
  static final _raisers = <int, Raiser>{};

  static Raiser raiserFor(int number) =>
      _raisers.putIfAbsent(number, () => Raiser(at(number)));

  /// Worked out once, when a frame is opened.
  static Raising raisingFor(int number) =>
      Raisings.withRaiser(raiserFor(number));

  /// Empties what the working out has kept. For the tests, so that one frame
  /// does not hand its working to another.
  static void forget() => _raisers.clear();

  /// A trestle, five timbers and two crews. The brace waits on the tie beam,
  /// the tie beam waits on both posts, and the posts wait on the sill, so it
  /// is four days however many crews are standing about.
  static Frame _theTrestle() => Frame(
        name: 'The Trestle',
        crews: 2,
        days: 4,
        timbers: const [
          Timber('Sill', 0.12, 0.86, 0.88, 0.86, stout: 1.3),
          Timber('Left post', 0.18, 0.86, 0.18, 0.50),
          Timber('Right post', 0.82, 0.86, 0.82, 0.50),
          Timber('Tie beam', 0.14, 0.50, 0.86, 0.50, stout: 1.2),
          Timber('Brace', 0.18, 0.64, 0.32, 0.50, stout: 0.8),
        ],
        rests: const [
          {},
          {0},
          {0},
          {1, 2},
          {1, 3},
        ],
      );

  /// The end of a barn: the trestle with a roof on it.
  static Frame _theGableEnd() => Frame(
        name: 'The Gable End',
        crews: 3,
        days: 5,
        timbers: const [
          Timber('Sill', 0.12, 0.86, 0.88, 0.86, stout: 1.3),
          Timber('Left post', 0.18, 0.86, 0.18, 0.50),
          Timber('Right post', 0.82, 0.86, 0.82, 0.50),
          Timber('Tie beam', 0.14, 0.50, 0.86, 0.50, stout: 1.2),
          Timber('Left brace', 0.18, 0.64, 0.32, 0.50, stout: 0.8),
          Timber('Right brace', 0.82, 0.64, 0.68, 0.50, stout: 0.8),
          Timber('Left rafter', 0.14, 0.50, 0.50, 0.14),
          Timber('Right rafter', 0.86, 0.50, 0.50, 0.14),
          Timber('Collar', 0.32, 0.32, 0.68, 0.32, stout: 0.8),
          Timber('King post', 0.50, 0.50, 0.50, 0.14, stout: 0.8),
        ],
        rests: const [
          {},
          {0},
          {0},
          {1, 2},
          {1, 3},
          {2, 3},
          {3},
          {3},
          {6, 7},
          {3, 6, 7},
        ],
      );

  /// An open shed: a long sill, four posts, a plate and the braces. Nothing
  /// waits very long on anything, so it is the crews that decide it.
  static Frame _theCartShed() => Frame(
        name: 'The Cart Shed',
        crews: 2,
        days: 6,
        timbers: const [
          Timber('Sill', 0.06, 0.86, 0.94, 0.86, stout: 1.3),
          Timber('First post', 0.12, 0.86, 0.12, 0.44),
          Timber('Second post', 0.38, 0.86, 0.38, 0.44),
          Timber('Third post', 0.62, 0.86, 0.62, 0.44),
          Timber('Fourth post', 0.88, 0.86, 0.88, 0.44),
          Timber('Left plate', 0.08, 0.44, 0.50, 0.44, stout: 1.2),
          Timber('Right plate', 0.50, 0.44, 0.92, 0.44, stout: 1.2),
          Timber('First brace', 0.12, 0.56, 0.24, 0.44, stout: 0.8),
          Timber('Second brace', 0.38, 0.56, 0.26, 0.44, stout: 0.8),
          Timber('Third brace', 0.62, 0.56, 0.74, 0.44, stout: 0.8),
          Timber('Fourth brace', 0.88, 0.56, 0.76, 0.44, stout: 0.8),
        ],
        rests: const [
          {},
          {0},
          {0},
          {0},
          {0},
          {1, 2},
          {3, 4},
          {1, 5},
          {2, 5},
          {3, 6},
          {4, 6},
        ],
      );

  /// A queen post truss. The longest run through it is six timbers deep, and
  /// four crews cannot help with that.
  static Frame _theQueenPost() => Frame(
        name: 'The Queen Post',
        crews: 4,
        days: 6,
        timbers: const [
          Timber('Sill', 0.10, 0.88, 0.90, 0.88, stout: 1.3),
          Timber('Left post', 0.16, 0.88, 0.16, 0.54),
          Timber('Right post', 0.84, 0.88, 0.84, 0.54),
          Timber('Tie beam', 0.12, 0.54, 0.88, 0.54, stout: 1.2),
          Timber('Left brace', 0.16, 0.66, 0.28, 0.54, stout: 0.8),
          Timber('Right brace', 0.84, 0.66, 0.72, 0.54, stout: 0.8),
          Timber('Left rafter', 0.12, 0.54, 0.50, 0.16),
          Timber('Right rafter', 0.88, 0.54, 0.50, 0.16),
          Timber('Left queen', 0.31, 0.54, 0.31, 0.35, stout: 0.8),
          Timber('Right queen', 0.69, 0.54, 0.69, 0.35, stout: 0.8),
          Timber('Collar', 0.31, 0.35, 0.69, 0.35, stout: 0.9),
          Timber('Left strut', 0.31, 0.54, 0.22, 0.44, stout: 0.7),
          Timber('Right strut', 0.69, 0.54, 0.78, 0.44, stout: 0.7),
          Timber('Ridge', 0.44, 0.16, 0.56, 0.16, stout: 1.1),
        ],
        rests: const [
          {},
          {0},
          {0},
          {1, 2},
          {1, 3},
          {2, 3},
          {3},
          {3},
          {3, 6},
          {3, 7},
          {8, 9},
          {6, 8},
          {7, 9},
          {6, 7},
        ],
      );

  /// Two bays of a long barn, and three crews for sixteen timbers, so it is
  /// the work rather than the waiting that decides it.
  static Frame _theLongBarn() => Frame(
        name: 'The Long Barn',
        crews: 3,
        days: 6,
        timbers: const [
          Timber('Left sill', 0.06, 0.88, 0.50, 0.88, stout: 1.3),
          Timber('Right sill', 0.50, 0.88, 0.94, 0.88, stout: 1.3),
          Timber('First post', 0.12, 0.88, 0.12, 0.50),
          Timber('Second post', 0.37, 0.88, 0.37, 0.50),
          Timber('Third post', 0.63, 0.88, 0.63, 0.50),
          Timber('Fourth post', 0.88, 0.88, 0.88, 0.50),
          Timber('Left plate', 0.08, 0.50, 0.50, 0.50, stout: 1.2),
          Timber('Right plate', 0.50, 0.50, 0.92, 0.50, stout: 1.2),
          Timber('First brace', 0.12, 0.62, 0.24, 0.50, stout: 0.8),
          Timber('Second brace', 0.37, 0.62, 0.25, 0.50, stout: 0.8),
          Timber('Third brace', 0.63, 0.62, 0.75, 0.50, stout: 0.8),
          Timber('Fourth brace', 0.88, 0.62, 0.76, 0.50, stout: 0.8),
          Timber('Left rafter', 0.08, 0.50, 0.50, 0.16),
          Timber('Right rafter', 0.92, 0.50, 0.50, 0.16),
          Timber('Ridge', 0.42, 0.16, 0.58, 0.16, stout: 1.1),
          Timber('Collar', 0.30, 0.33, 0.70, 0.33, stout: 0.8),
        ],
        rests: const [
          {},
          {},
          {0},
          {0},
          {1},
          {1},
          {2, 3},
          {4, 5},
          {2, 6},
          {3, 6},
          {4, 7},
          {5, 7},
          {6},
          {7},
          {12, 13},
          {12, 13},
        ],
      );

  /// The whole tithe barn. Eighteen timbers and four crews would be five days
  /// of work, but the run from the sill up to the ridge is six timbers deep.
  static Frame _theTithe() => Frame(
        name: 'The Tithe Barn',
        crews: 4,
        days: 6,
        timbers: const [
          Timber('Left sill', 0.05, 0.90, 0.50, 0.90, stout: 1.3),
          Timber('Right sill', 0.50, 0.90, 0.95, 0.90, stout: 1.3),
          Timber('First post', 0.11, 0.90, 0.11, 0.54),
          Timber('Second post', 0.37, 0.90, 0.37, 0.54),
          Timber('Third post', 0.63, 0.90, 0.63, 0.54),
          Timber('Fourth post', 0.89, 0.90, 0.89, 0.54),
          Timber('Left plate', 0.07, 0.54, 0.50, 0.54, stout: 1.2),
          Timber('Right plate', 0.50, 0.54, 0.93, 0.54, stout: 1.2),
          Timber('First brace', 0.11, 0.66, 0.23, 0.54, stout: 0.8),
          Timber('Second brace', 0.37, 0.66, 0.25, 0.54, stout: 0.8),
          Timber('Third brace', 0.63, 0.66, 0.75, 0.54, stout: 0.8),
          Timber('Fourth brace', 0.89, 0.66, 0.77, 0.54, stout: 0.8),
          Timber('Tie beam', 0.07, 0.54, 0.93, 0.54, stout: 1.2),
          Timber('Left rafter', 0.07, 0.54, 0.50, 0.14),
          Timber('Right rafter', 0.93, 0.54, 0.50, 0.14),
          Timber('King post', 0.50, 0.54, 0.50, 0.14, stout: 0.8),
          Timber('Collar', 0.29, 0.34, 0.71, 0.34, stout: 0.8),
          Timber('Ridge', 0.42, 0.14, 0.58, 0.14, stout: 1.1),
        ],
        rests: const [
          {},
          {},
          {0},
          {0},
          {1},
          {1},
          {2, 3},
          {4, 5},
          {2, 6},
          {3, 6},
          {4, 7},
          {5, 7},
          {6, 7},
          {12},
          {12},
          {12, 13, 14},
          {13, 14},
          {13, 14},
        ],
      );
}
