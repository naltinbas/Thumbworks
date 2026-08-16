import 'rules.dart';

/// One ask: a number to sunder into parts of a given kind.
class Level {
  const Level({
    required this.name,
    required this.number,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;
  final int number;

  /// 'differentThree': all parts different, three or more; 'oddFour':
  /// all parts odd, four exactly; 'different': all parts different;
  /// 'threeByThree': three parts, the largest three; 'differentEven':
  /// all parts different and even.
  final String kind;

  /// How many partitions land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The partitions of the number, kept once.
  List<List<int>> get all => Rules.partitions(number);

  /// Whether the parts, whatever their order, land the ask: they add
  /// to the number and are of the kind.
  bool meets(List<int> parts) {
    if (parts.isEmpty || parts.fold<int>(0, (a, b) => a + b) != number) return false;
    final sorted = List.of(parts)..sort((a, b) => b - a);
    switch (kind) {
      case 'differentThree':
        return Rules.allDifferent(sorted) && sorted.length >= 3;
      case 'oddFour':
        return Rules.allOdd(sorted) && sorted.length == 4;
      case 'different':
        return Rules.allDifferent(sorted);
      case 'threeByThree':
        return sorted.length == 3 && sorted.first == 3;
      default:
        return Rules.allDifferent(sorted) && Rules.allEven(sorted);
    }
  }

  /// The partition the pointer works towards, the sweep's first, or null.
  List<int>? get aim => all.where(meets).firstOrNull;

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'differentThree':
        return 'sunder $number into parts all different, three parts or more';
      case 'oddFour':
        return 'sunder $number into odd parts, four of them exactly';
      case 'different':
        return 'sunder $number into parts all different';
      case 'threeByThree':
        return 'sunder $number into three parts exactly, the largest of them 3';
      default:
        return 'sunder $number into even parts all different';
    }
  }
}
