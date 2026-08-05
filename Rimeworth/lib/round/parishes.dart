import 'parish.dart';

/// One parish, ready to be gritted.
class Gritting {
  Gritting({required this.name, required this.parish, required this.runs});

  final String name;
  final Parish parish;

  /// The fewest runs it takes. Written down here as well as worked out, so
  /// that a test can hold the two against each other.
  final int runs;
}

/// The parishes that ship.
///
/// They get longer, and the odd junctions get more numerous, which is the
/// same thing as the number of runs going up. Every one of them has a lane
/// that will strand the lorry if it is salted too early.
class Grittings {
  const Grittings._();

  static final List<Gritting> all = [
    _lowFold(),
    _gableRow(),
    _twoHamlets(),
    _theLongChain(),
    _turnpikeHead(),
    _wheelGreen(),
    _saltersCross(),
  ];

  static int get count => all.length;

  static Gritting at(int number) => all[number.clamp(0, all.length - 1)];

  /// Two triangles meeting at a crossroads. Every junction has an even number
  /// of lanes, so one run does it and comes back to where it set off.
  static Gritting _lowFold() => Gritting(
        name: 'Low Fold',
        runs: 1,
        parish: Parish(
          junctions: const [
            Junction('Fold End', 0.20, 0.28),
            Junction('Bell Corner', 0.20, 0.72),
            Junction('The Cross', 0.50, 0.50),
            Junction('Kiln Bank', 0.80, 0.28),
            Junction('Marlpit', 0.80, 0.72),
          ],
          lanes: const [
            Lane(0, 1),
            Lane(0, 2),
            Lane(1, 2),
            Lane(2, 3),
            Lane(2, 4),
            Lane(3, 4),
          ],
        ),
      );

  /// A square with both ways across it and a roof on top. Two junctions have
  /// three lanes, so one run still does it, but only if it sets off at one of
  /// them and finishes at the other.
  static Gritting _gableRow() => Gritting(
        name: 'Gable Row',
        runs: 1,
        parish: Parish(
          junctions: const [
            Junction('Yard Gate', 0.22, 0.82),
            Junction('Smithy', 0.78, 0.82),
            Junction('Chapel', 0.22, 0.46),
            Junction('Rookery', 0.78, 0.46),
            Junction('Gable', 0.50, 0.18),
          ],
          lanes: const [
            Lane(0, 1),
            Lane(0, 2),
            Lane(1, 3),
            Lane(2, 3),
            Lane(0, 3),
            Lane(1, 2),
            Lane(2, 4),
            Lane(3, 4),
          ],
        ),
      );

  /// Two hamlets with a good deal of lane between them. Four junctions have
  /// an odd number, so no single run reaches everything.
  static Gritting _twoHamlets() => Gritting(
        name: 'The Two Hamlets',
        runs: 2,
        parish: Parish(
          junctions: const [
            Junction('Stone Bridge', 0.18, 0.24),
            Junction('Cold Harbour', 0.50, 0.20),
            Junction('Nine Elms', 0.82, 0.24),
            Junction('Wold Top', 0.18, 0.76),
            Junction('Hen Cote', 0.50, 0.80),
            Junction('Tan Yard', 0.82, 0.76),
          ],
          lanes: const [
            Lane(0, 1),
            Lane(1, 2),
            Lane(3, 4),
            Lane(4, 5),
            Lane(1, 4),
            Lane(0, 3),
            Lane(2, 5),
            Lane(0, 4),
            Lane(2, 4),
          ],
        ),
      );

  /// A green with six lanes off it and a ring right round. Every junction on
  /// the ring has three lanes, and six odd junctions is three runs.
  static Gritting _wheelGreen() => Gritting(
        name: 'Wheel Green',
        runs: 3,
        parish: Parish(
          junctions: const [
            Junction('Church Stile', 0.50, 0.14),
            Junction('Long Reach', 0.81, 0.32),
            Junction('Barrow Head', 0.81, 0.68),
            Junction('Mill Race', 0.50, 0.86),
            Junction('Ash Row', 0.19, 0.68),
            Junction('Dovecote', 0.19, 0.32),
            Junction('The Green', 0.50, 0.50),
          ],
          lanes: const [
            Lane(0, 1),
            Lane(1, 2),
            Lane(2, 3),
            Lane(3, 4),
            Lane(4, 5),
            Lane(5, 0),
            Lane(6, 0),
            Lane(6, 1),
            Lane(6, 2),
            Lane(6, 3),
            Lane(6, 4),
            Lane(6, 5),
          ],
        ),
      );

  /// Four loops of lane strung along a valley. Every junction is even, so it
  /// is one run, and every join between two loops is a lane that will strand
  /// the lorry the moment it is salted at the wrong time.
  static Gritting _theLongChain() => Gritting(
        name: 'The Long Chain',
        runs: 1,
        parish: Parish(
          junctions: const [
            Junction('Pound Green', 0.12, 0.30),
            Junction('Salt Way', 0.12, 0.70),
            Junction('Ferry Steps', 0.34, 0.50),
            Junction('Beck Foot', 0.53, 0.24),
            Junction('Hollow Turn', 0.53, 0.76),
            Junction('Gorse Bank', 0.72, 0.50),
            Junction('Withy Bed', 0.89, 0.26),
            Junction('Hall Gate', 0.89, 0.74),
          ],
          lanes: const [
            Lane(0, 1),
            Lane(0, 2),
            Lane(1, 2),
            Lane(2, 3),
            Lane(2, 4),
            Lane(3, 5),
            Lane(4, 5),
            Lane(5, 6),
            Lane(5, 7),
            Lane(6, 7),
          ],
        ),
      );

  /// The whole of it, with the salt house on the crossroads in the middle.
  /// Six junctions have an odd number of lanes, so it is three times out with
  /// the lorry and the order matters every time.
  static Gritting _saltersCross() => Gritting(
        name: "Salter's Cross",
        runs: 3,
        parish: Parish(
          junctions: const [
            Junction('Salt House', 0.50, 0.50),
            Junction('Low Moor', 0.20, 0.20),
            Junction('Cinder Path', 0.50, 0.14),
            Junction('Rick Yard', 0.80, 0.20),
            Junction('Sheepwash', 0.86, 0.50),
            Junction('Turnpike', 0.80, 0.82),
            Junction('Corn Hill', 0.50, 0.88),
            Junction('Weir End', 0.20, 0.82),
            Junction('Bark Mill', 0.14, 0.50),
          ],
          lanes: const [
            Lane(0, 2),
            Lane(0, 4),
            Lane(0, 6),
            Lane(0, 8),
            Lane(1, 2),
            Lane(1, 8),
            Lane(2, 3),
            Lane(3, 4),
            Lane(4, 5),
            Lane(5, 6),
            Lane(6, 7),
            Lane(7, 8),
            Lane(0, 1),
            Lane(0, 5),
          ],
        ),
      );

  /// A ring at the top, a ring at the bottom and the crossroads between them.
  /// Four odd junctions, so two runs, and picking the wrong pair of junctions
  /// to set off from wastes the second one.
  static Gritting _turnpikeHead() => Gritting(
        name: 'Turnpike Head',
        runs: 2,
        parish: Parish(
          junctions: const [
            Junction('Turnpike', 0.50, 0.10),
            Junction('Hollow Turn', 0.20, 0.26),
            Junction('Ferry Steps', 0.80, 0.26),
            Junction('The Cross', 0.50, 0.42),
            Junction('Marlpit', 0.16, 0.58),
            Junction('Beck Foot', 0.84, 0.58),
            Junction('Withy Bed', 0.34, 0.78),
            Junction('Hall Gate', 0.66, 0.78),
            Junction('Sheepwash', 0.50, 0.93),
          ],
          lanes: const [
            Lane(0, 1),
            Lane(0, 2),
            Lane(0, 3),
            Lane(1, 3),
            Lane(2, 3),
            Lane(1, 4),
            Lane(2, 5),
            Lane(3, 6),
            Lane(3, 7),
            Lane(4, 6),
            Lane(5, 7),
            Lane(6, 8),
            Lane(7, 8),
            Lane(6, 7),
          ],
        ),
      );
}
