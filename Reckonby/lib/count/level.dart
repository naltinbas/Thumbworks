import 'rules.dart';

/// One ask: what the house is to read.
class Level {
  const Level({
    required this.name,
    required this.number,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The reading the ask wants.
  final int number;

  /// How many settings of the wheels read it: one, or none at all.
  final int ways;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// The wheels that read it, or null when none do.
  List<int>? get aim => Rules.wheelsFor(number);

  bool meets(List<int> at) => Rules.reading(at) == number;

  /// The turns it takes from the opening, which is the wheels of the
  /// number added up.
  int? get fewest =>
      aim == null ? null : Rules.turns(Rules.opening, aim!);

  /// The task, told in words.
  String get task => 'turn the wheels until the house reads $number';
}
