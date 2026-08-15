import 'rules.dart';

/// What a cording asks of the midpoint figure.
enum Asked { rectangle, rhombus, square, fourthPeg, skew }

/// One cording on the sham: what is asked, the pegs given, and what
/// the sweep found.
class Cording {
  const Cording({
    required this.name,
    required this.asked,
    required this.given,
    required this.ways,
    required this.fours,
    this.note,
  });

  final String name;
  final Asked asked;

  /// Pegs set before play, in order.
  final List<Peg> given;

  /// Ordered fours on the board that land it, by the sweep; nought
  /// for the hopeless.
  final int ways;

  /// Ordered fours there are, the given pegs honoured.
  final int fours;

  /// One thing worth knowing about this cording, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// Whether four pegs meet the asking.
  bool meets(List<Peg> four) => switch (asked) {
        Asked.rectangle => Rules.rectangleByDiagonals(four),
        Asked.rhombus => Rules.rhombusByDiagonals(four),
        Asked.square => Rules.squareByDiagonals(four),
        Asked.fourthPeg => Rules.rectangleByDiagonals(four),
        Asked.skew => !Rules.parallelogramByMidpoints(four),
      };

  /// The task, told in words for the ledger.
  String get task => switch (asked) {
        Asked.rectangle => 'set four pegs whose midpoint figure is a rectangle',
        Asked.rhombus => 'set four pegs whose midpoint figure is a rhombus',
        Asked.square => 'set four pegs whose midpoint figure is a square',
        Asked.fourthPeg => 'set the fourth peg after three given, for a rectangle',
        Asked.skew => 'set four pegs whose midpoint figure is not a parallelogram',
      };
}
