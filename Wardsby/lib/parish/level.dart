import 'rules.dart';

/// One ask: a parish to draw into wards so a side wins so many.
class Level {
  const Level({
    required this.name,
    required this.map,
    required this.kind,
    required this.wins,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The households, B or R, twenty-five in reading order.
  final String map;

  /// 'blue': the Blues win [wins] wards or more; 'red': the Reds win
  /// [wins] wards or more, which is the Blues winning five less that or
  /// fewer.
  final String kind;
  final int wins;

  /// How many of the 4,006 drawings land it.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  List<bool> get blue => map.split('').map((c) => c == 'B').toList();

  int get blues => blue.where((b) => b).length;

  int get settings => Rules.drawings.length;

  bool get winnable => ways > 0;

  /// Whether a sound drawing [d] lands the ask.
  bool meets(List<int?> d) {
    if (!Rules.sound(d)) return false;
    final w = Rules.blueWins(d.cast<int>(), blue);
    return kind == 'blue' ? w >= wins : Rules.wards - w >= wins;
  }

  /// The task, told in words for the ledger.
  String get task {
    final who = kind == 'blue' ? 'Blues' : 'Reds';
    final count = switch (wins) { 2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five', _ => '$wins' };
    return 'draw the five wards so the $who win ${wins == 5 ? 'all five' : '$count of the five'}, the parish being $blues Blue and ${25 - blues} Red';
  }
}
