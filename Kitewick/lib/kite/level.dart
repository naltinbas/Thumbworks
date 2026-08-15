import 'rules.dart';

/// One ask: a kite to slate, perhaps with a set count of slates across.
class Level {
  Level({
    required this.name,
    required this.order,
    this.acrossAsked,
    required this.ways,
    required this.note,
  }) : kite = Kite(order);

  final String name;
  final int order;

  /// The count of slates lying across the ask wants, or null for any.
  final int? acrossAsked;

  /// How many slatings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  final Kite kite;

  bool get winnable => ways > 0;

  /// The slatings there are, all of them, kept once.
  late final List<List<(int, int)>> slatings = kite.slatings();

  /// Whether a slating meets the ask.
  bool meets(List<(int, int)> slates) => kite.covers(slates) && (acrossAsked == null || kite.acrossCount(slates) == acrossAsked);

  /// The slating the pointer works towards, or null when none lands it.
  late final List<(int, int)>? aim = slatings.where(meets).firstOrNull;

  /// The task, told in words for the ledger.
  String get task {
    final kiteTold = 'slate the kite of order ${_word(order)}, ${kite.count} cells';
    if (acrossAsked == null) return kiteTold;
    return '$kiteTold, with exactly ${_word(acrossAsked!)} slate${acrossAsked == 1 ? '' : 's'} lying across';
  }

  static String _word(int n) => const ['nought', 'one', 'two', 'three', 'four', 'five', 'six'][n];
}
