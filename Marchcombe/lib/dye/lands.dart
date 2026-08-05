import 'fewest.dart';
import 'land.dart';

/// One estate, ready to be painted.
class Estate {
  Estate({required this.land, required this.fewest});

  final Land land;

  /// The fewest dyes it takes. Written down here as well as worked out, so
  /// that a test can hold the two against each other.
  final int fewest;

  String get name => land.name;
}

/// The estates that ship.
///
/// Every one of them past the first two came out of `make find`, which
/// scatters fields across a grid and throws away everything that fails two
/// tests. The fewest dyes has to be the size of the biggest set of fields
/// that all share a hedge with each other, so the map carries a proof a player
/// can see by looking. And painting the fields in the order they come, each in
/// the first dye that will do, has to need more dyes than the answer, so the
/// obvious way is not the answer. About one map in a hundred passes both.
class Estates {
  const Estates._();

  static final List<Estate> all = [
    _quarters(),
    _theTwoLeys(),
    _hangings(),
    _coldharbour(),
    _starveall(),
    _brambleHay(),
    _theWholeCombe(),
  ];

  static int get count => all.length;

  static Estate at(int number) => all[number.clamp(0, all.length - 1)];

  /// Four fields in a square. Nothing here shares a hedge with the field
  /// across the corner from it, so two dyes do it.
  static Estate _quarters() => Estate(
        fewest: 2,
        land: Land(
          name: 'Quarters',
          rows: const [
            'AAABBB',
            'AAABBB',
            'AAABBB',
            'CCCDDD',
            'CCCDDD',
            'CCCDDD',
          ],
          called: const {
            'A': 'Long Acre',
            'B': 'Hopyard',
            'C': 'Cowlease',
            'D': 'Kiln Close',
          },
        ),
      );

  /// Two sets of three fields that all meet, sharing the long one in the
  /// middle. Three fields that all touch need three dyes between them.
  static Estate _theTwoLeys() => Estate(
        fewest: 3,
        land: Land(
          name: 'The Two Leys',
          rows: const [
            'AAABBB',
            'AAABBB',
            'CCCCCC',
            'CCCCCC',
            'DDDEEE',
            'DDDEEE',
          ],
          called: const {
            'A': 'Great Ley',
            'B': 'Rushmead',
            'C': 'The Slade',
            'D': 'Nine Acre',
            'E': 'Barrow Piece',
          },
        ),
      );

  static Estate _hangings() => Estate(
        fewest: 3,
        land: Land(
          name: 'Hangings',
          rows: const [
            'FFFEEEE',
            'FFFEEEB',
            'GGGEDDB',
            'GGHHCDB',
            'AHHCCDB',
            'AHHCCDB',
            'AAACCDB',
          ],
          called: const {
            'A': 'Pightle',
            'B': 'Sheepwalk',
            'C': 'Broomfield',
            'D': 'Well Close',
            'E': 'Windmill Hill',
            'F': 'The Butts',
            'G': 'Dogkennel',
            'H': 'Marlpit',
          },
        ),
      );

  static Estate _coldharbour() => Estate(
        fewest: 3,
        land: Land(
          name: 'Coldharbour',
          rows: const [
            'EAAACHH',
            'EAACCHH',
            'EGADDDH',
            'EGGDDDB',
            'EGGFFBB',
            'EGFFFBB',
            'EFFFBBB',
          ],
          called: const {
            'A': 'Ashen Croft',
            'B': 'Tenter Field',
            'C': 'Duckpuddle',
            'D': 'Gospel Piece',
            'E': 'Lark Rise',
            'F': 'Ox Pasture',
            'G': 'Horse Croft',
            'H': 'Cuckoo Pen',
          },
        ),
      );

  static Estate _starveall() => Estate(
        fewest: 3,
        land: Land(
          name: 'Starveall',
          rows: const [
            'CCCCHHH',
            'CCCBHHH',
            'AAGBEHH',
            'AFGBEEE',
            'AFFBEDD',
            'AFFBBDD',
            'AFFFDDD',
          ],
          called: const {
            'A': 'Chalk Piece',
            'B': 'Bell Rope',
            'C': 'The Warren',
            'D': 'Stony Land',
            'E': 'Goose Green',
            'F': 'Bean Close',
            'G': 'Withy Bed',
            'H': 'Hollow Meadow',
          },
        ),
      );

  static Estate _brambleHay() => Estate(
        fewest: 4,
        land: Land(
          name: 'Bramble Hay',
          rows: const [
            'CCCCIIAAA',
            'CCCCCIBBA',
            'DDDIIIBKA',
            'JDDIIIKKK',
            'JDDDEEEEE',
            'JJJJJEEGG',
            'HHFFEEGGG',
            'HHFFFFGGG',
            'HHFFFFGGG',
          ],
          called: const {
            'A': 'Rye Piece',
            'B': 'Picked Piece',
            'C': 'Home Ground',
            'D': 'Church Path',
            'E': 'Bramble Hay',
            'F': 'Fursey Close',
            'G': 'Tinker Acre',
            'H': 'The Pound',
            'I': 'Middle Field',
            'J': 'Hanger',
            'K': 'Little Mead',
          },
        ),
      );

  static Estate _theWholeCombe() => Estate(
        fewest: 4,
        land: Land(
          name: 'The Whole Combe',
          rows: const [
            'CCCJJJJFF',
            'CCCCKJJFF',
            'CAAAKKJFF',
            'BAAAKKKEG',
            'BBAAEEEEG',
            'BBBBEDDDG',
            'HHHIIIDDG',
            'HHHIIDDDG',
            'HHHIIIGGG',
          ],
          called: const {
            'A': 'Combe Head',
            'B': 'Sheep Down',
            'C': 'Upper Ley',
            'D': 'Mill Ground',
            'E': 'The Linch',
            'F': 'Furze Brake',
            'G': 'Long Coppice',
            'H': 'Water Meadow',
            'I': 'Hall Close',
            'J': 'Bulls Mead',
            'K': 'Hither Croft',
          },
        ),
      );

  /// Worked out once, when a map is opened.
  static Painting answerFor(int number) => Dyes.fewestFor(at(number).land);
}
