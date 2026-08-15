import 'rules.dart';

/// What a cording asks.
enum Asked { rightCorner, sharpThree, squareWheel, givenTwo, offDiameter }

/// One cording on the sham: what is asked, the pegs given, how many
/// pegs to set, and what the sweep found.
class Cording {
  const Cording({
    required this.name,
    required this.asked,
    required this.given,
    required this.pegs,
    required this.ways,
    required this.sets,
    this.note,
  });

  final String name;
  final Asked asked;

  /// Pegs set before play.
  final List<Peg> given;

  /// How many pegs the cording takes in all.
  final int pegs;

  /// Sets of pegs that land it, by the sweep; nought for the hopeless.
  final int ways;

  /// Sets of pegs there are, the given ones honoured.
  final int sets;

  /// One thing worth knowing about this cording, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// Whether a full set of pegs meets the asking.
  bool meets(List<Peg> set) => switch (asked) {
        Asked.rightCorner => Rules.squareCorners(set).isNotEmpty,
        Asked.sharpThree => Rules.sharp(set),
        Asked.squareWheel => Rules.makesSquare(set),
        Asked.givenTwo => Rules.squareCorners(set).isNotEmpty,
        Asked.offDiameter => Rules.squareCorners(set).isNotEmpty &&
            Rules.squareCorners(set).any((i) => !Rules.isDiameter(set[(i + 1) % 3], set[(i + 2) % 3])),
      };

  /// The task, told in words for the ledger.
  String get task => switch (asked) {
        Asked.rightCorner => 'cord three pegs into a triangle with a square corner',
        Asked.sharpThree => 'cord three pegs into a triangle sharp at every corner',
        Asked.squareWheel => 'cord four pegs into a square',
        Asked.givenTwo => 'set a third peg to the two given for a square corner',
        Asked.offDiameter => 'cord a square corner whose far cord is not a diameter',
      };
}
