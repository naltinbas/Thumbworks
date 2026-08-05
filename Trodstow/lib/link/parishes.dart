import 'cheapest.dart';
import 'parish.dart';

/// One parish, ready to be joined up.
class Round {
  Round({required this.parish, required this.yards});

  final Parish parish;

  /// What the cheapest network comes to. Written down here as well as worked
  /// out, so a test can hold the two against each other.
  final int yards;

  String get name => parish.name;
}

/// The parishes that ship.
///
/// No two paths in any of them cost the same, which means there is exactly one
/// cheapest network and every reason the game gives is exactly true rather
/// than nearly. Every one of them also came out of `make find`, which throws
/// away any parish where cutting the paths that get everybody to one place by
/// the shortest way happens to be the cheapest network as well.
class Rounds {
  const Rounds._();

  static final List<Round> all = [
    _lowTrodstow(),
    _netherWick(),
    _theThreeFords(),
    _coldAsh(),
    _theWideParish(),
    _theWholeHundred(),
  ];

  static int get count => all.length;

  static Round at(int number) => all[number.clamp(0, all.length - 1)];

  /// Worked out once, when a parish is opened.
  static Network answerFor(int number) => Cheapests.of(at(number).parish);

  static Round _lowTrodstow() => Round(
        yards: 850,
        parish: Parish(
          name: 'Low Trodstow',
          places: const [
            Place('Coldpiece', 0.42, 0.38),
            Place('Barrow End', 0.82, 0.23),
            Place('Stonepit', 0.56, 0.26),
            Place('Rushall', 0.35, 0.74),
            Place('Fold Head', 0.50, 0.54),
          ],
          trods: const [
            Trod(0, 1, 428),
            Trod(0, 2, 198),
            Trod(0, 3, 330),
            Trod(0, 4, 192),
            Trod(1, 2, 241),
            Trod(1, 4, 413),
            Trod(2, 4, 267),
            Trod(3, 4, 219),
          ],
        ),
      );

  static Round _netherWick() => Round(
        yards: 1385,
        parish: Parish(
          name: 'Nether Wick',
          places: const [
            Place('Mill End', 0.53, 0.41),
            Place('Kiln Row', 0.57, 0.28),
            Place('Cold Ash', 0.21, 0.26),
            Place('The Grange', 0.79, 0.54),
            Place('Sheepwash', 0.20, 0.84),
            Place('Woodhouse', 0.18, 0.61),
          ],
          trods: const [
            Trod(0, 1, 154),
            Trod(0, 2, 376),
            Trod(0, 3, 308),
            Trod(0, 5, 386),
            Trod(1, 2, 343),
            Trod(1, 3, 326),
            Trod(2, 5, 356),
            Trod(4, 5, 224),
          ],
        ),
      );

  static Round _theThreeFords() => Round(
        yards: 1284,
        parish: Parish(
          name: 'The Three Fords',
          places: const [
            Place('Long Marsh', 0.65, 0.62),
            Place('Hazelrigg', 0.48, 0.20),
            Place('Church Town', 0.43, 0.70),
            Place('Nethergate', 0.49, 0.32),
            Place('Sheepwash', 0.28, 0.84),
            Place('Fold Head', 0.37, 0.46),
            Place('Stonepit', 0.72, 0.33),
          ],
          trods: const [
            Trod(0, 2, 250),
            Trod(0, 3, 363),
            Trod(0, 4, 386),
            Trod(0, 5, 310),
            Trod(0, 6, 270),
            Trod(1, 3, 128),
            Trod(1, 5, 304),
            Trod(1, 6, 271),
            Trod(2, 3, 351),
            Trod(2, 4, 233),
            Trod(3, 5, 183),
            Trod(3, 6, 220),
            Trod(4, 5, 377),
            Trod(5, 6, 346),
          ],
        ),
      );

  static Round _coldAsh() => Round(
        yards: 1756,
        parish: Parish(
          name: 'Cold Ash',
          places: const [
            Place('Coldpiece', 0.46, 0.32),
            Place('Barrow End', 0.58, 0.78),
            Place('Kiln Row', 0.35, 0.15),
            Place('Woodhouse', 0.16, 0.55),
            Place('Rushall', 0.33, 0.80),
            Place('The Grange', 0.81, 0.83),
            Place('Long Marsh', 0.89, 0.55),
            Place('Mill End', 0.40, 0.53),
          ],
          trods: const [
            Trod(0, 2, 196),
            Trod(0, 3, 381),
            Trod(0, 7, 255),
            Trod(1, 4, 261),
            Trod(1, 5, 224),
            Trod(1, 6, 403),
            Trod(1, 7, 327),
            Trod(3, 4, 290),
            Trod(3, 7, 250),
            Trod(4, 7, 286),
            Trod(5, 6, 284),
          ],
        ),
      );

  static Round _theWideParish() => Round(
        yards: 1942,
        parish: Parish(
          name: 'The Wide Parish',
          places: const [
            Place('Stonepit', 0.73, 0.26),
            Place('Woodhouse', 0.10, 0.53),
            Place('Fold Head', 0.48, 0.60),
            Place('Nethergate', 0.33, 0.33),
            Place('Long Marsh', 0.69, 0.41),
            Place('Sheepwash', 0.20, 0.75),
            Place('Hazelrigg', 0.49, 0.17),
            Place('Church Town', 0.60, 0.72),
            Place('The Grange', 0.81, 0.82),
          ],
          trods: const [
            Trod(0, 4, 153),
            Trod(0, 6, 285),
            Trod(1, 2, 374),
            Trod(1, 3, 298),
            Trod(1, 5, 226),
            Trod(2, 3, 313),
            Trod(2, 4, 310),
            Trod(2, 5, 326),
            Trod(2, 7, 157),
            Trod(2, 8, 382),
            Trod(3, 4, 354),
            Trod(3, 6, 257),
            Trod(4, 6, 317),
            Trod(4, 7, 297),
            Trod(5, 7, 366),
            Trod(7, 8, 269),
          ],
        ),
      );

  static Round _theWholeHundred() => Round(
        yards: 1910,
        parish: Parish(
          name: 'The Whole Hundred',
          places: const [
            Place('Rushall', 0.30, 0.70),
            Place('Long Marsh', 0.73, 0.49),
            Place('Church Town', 0.45, 0.86),
            Place('Cold Ash', 0.18, 0.36),
            Place('Fold Head', 0.63, 0.80),
            Place('Kiln Row', 0.81, 0.13),
            Place('The Grange', 0.88, 0.75),
            Place('Stonepit', 0.78, 0.38),
            Place('Mill End', 0.78, 0.61),
            Place('Coldpiece', 0.16, 0.13),
          ],
          trods: const [
            Trod(0, 2, 220),
            Trod(0, 3, 349),
            Trod(0, 4, 350),
            Trod(1, 4, 310),
            Trod(1, 5, 394),
            Trod(1, 6, 309),
            Trod(1, 7, 131),
            Trod(1, 8, 117),
            Trod(2, 4, 214),
            Trod(3, 9, 230),
            Trod(4, 6, 268),
            Trod(4, 8, 237),
            Trod(5, 7, 247),
            Trod(6, 8, 165),
            Trod(7, 8, 236),
          ],
        ),
      );
}
