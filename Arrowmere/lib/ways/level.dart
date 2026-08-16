import 'rules.dart';

/// One ask: a village, and the same thing wanted of it every time, that
/// every place can still be reached from every other once all its
/// streets are one-way.
class Level {
  const Level({
    required this.name,
    required this.village,
    required this.ways,
    required this.note,
  });

  final String name;

  final Village village;

  /// How many orientations land it, from the sweep.
  final int ways;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether [arrows] land the ask.
  bool meets(List<bool> arrows) =>
      Rules.valid(village, arrows) && Rules.strong(village, arrows);

  /// The orientation the pointer works towards, the sweep's first that
  /// lands the ask, or null.
  List<bool>? get aim => Rules.aim(village);

  /// The fewest turns the ask takes from the village's opening, or null
  /// when nothing lands it.
  int? get fewest => Rules.nearest(village, village.opening)?.$2;

  /// The most ordered pairs any orientation of the village gets
  /// between, of the [pairsWanted] there are.
  int get bestPairs => Rules.best(village);

  int get pairsWanted => village.placeCount * (village.placeCount - 1);

  /// The task, told in words for the ledger.
  String get task => 'point every street of ${village.name}, leaving every '
      'place reachable from every other';
}
