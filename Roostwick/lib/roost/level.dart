import 'rules.dart';

/// One ask: a wood of birds, to be settled a hollow apiece.
class Level {
  const Level({
    required this.name,
    required this.board,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The birds, written as the letters of the hollows each is tethered
  /// between: 'ABAC' is one bird between A and B and one between A and
  /// C.
  final String board;

  /// How many of the 2^n seatings settle the wood. The sweep's number,
  /// counted twice, and the checker refuses the bake if it drifts.
  final int ways;

  /// The taps from the opening to the nearest seating that settles;
  /// null when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  List<(int, int)> get birds => Rules.read(board);

  int get flock => board.length ~/ 2;

  /// How many seatings the wood has at all.
  int get seatings => 1 << flock;

  bool get winnable => ways > 0;

  /// Whether this seating settles the wood.
  bool meets(int pick) => Rules.settled(birds, pick);

  /// The task, told in words.
  String get task =>
      'settle the ${flock == 4 ? 'four' : 'six'} birds of ${name.toLowerCase()}'
      ', each in a hollow of its own';
}
