import 'rules.dart';

/// One ask: a count of coins to fit round the middle coin.
class Level {
  const Level({
    required this.name,
    required this.count,
    this.noSmaller = false,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// The coins that must fit round the middle, exactly, and no more.
  final int count;

  /// Whether the ring coins must be no smaller than the middle.
  final bool noSmaller;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, (middle, ring), or null when none
  /// lands it.
  final (int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int middle, int ring) => (!noSmaller || ring >= middle) && Rules.mostRound(middle, ring) == count;

  /// The task, told in words for the ledger.
  String get task => noSmaller
      ? 'set the sizes so ${Rules.count(count)} coins fit round a middle coin no bigger than themselves'
      : 'set the sizes so exactly ${Rules.count(count)} coins fit round the middle coin, and no more';
}
