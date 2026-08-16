import 'rules.dart';

/// One ask: a number to make from so many triangular numbers.
class Level {
  const Level({
    required this.name,
    required this.number,
    required this.slots,
    required this.ways,
    required this.note,
  });

  final String name;
  final int number;

  /// How many triangular numbers to add, nought allowed.
  final int slots;

  /// How many heaps land it, from the sweep, order set aside.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The triangular numbers on the shelf: those up to the number.
  List<int> get shelf => Rules.triangles.where((t) => t <= number).toList();

  /// Whether the slots as filled land the ask.
  bool meets(List<int?> filled) => filled.length == slots && filled.every((s) => s != null) && filled.fold<int>(0, (a, b) => a + b!) == number;

  /// The heap the pointer works towards, the sweep's first, or null.
  List<int>? get aim => Rules.heaps(number, slots).firstOrNull;

  /// The task, told in words for the ledger.
  String get task => 'make $number by adding ${slots == 2 ? 'two' : 'three'} triangular numbers, nought allowed';
}
