import 'rules.dart';

/// One ask: sacks to load into so many carts.
class Level {
  const Level({
    required this.name,
    required this.sacks,
    required this.carts,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The sacks' weights in stone.
  final List<int> sacks;

  /// The carts to load them into.
  final int carts;

  /// How many loadings do it, carts unnamed, from the search.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  int get weight => sacks.fold(0, (a, b) => a + b);

  bool get winnable => ways > 0;

  /// Whether [cartOf] loads every sack, none past ten, and uses every
  /// cart.
  bool meets(List<int?> cartOf) {
    if (!Rules.sound(sacks, cartOf, carts)) return false;
    return true;
  }

  /// The task, told in words for the ledger.
  String get task {
    final list = sacks.map((s) => '$s').toList();
    final told = '${list.sublist(0, list.length - 1).join(', ')} and ${list.last}';
    final count = switch (carts) { 2 => 'two', 3 => 'three', 4 => 'four', _ => '$carts' };
    return 'load the sacks of $told stone into $count carts of ten';
  }
}
