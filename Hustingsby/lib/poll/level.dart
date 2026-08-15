import 'rules.dart';

/// One ask: a poll to count in an order of a given kind.
class Level {
  Level({
    required this.name,
    required this.ash,
    required this.birch,
    required this.kind,
    this.count,
    required this.ways,
    required this.note,
  });

  final String name;
  final int ash;
  final int birch;

  /// 'ahead': Ash ahead after every ballot; 'levels': the count stands
  /// level exactly [count] times; 'changes': the lead changes hands
  /// exactly [count] times; 'neverBehind': Ash never behind, level
  /// allowed.
  final String kind;
  final int? count;

  /// How many of the orders land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  int get ballots => ash + birch;

  /// Every order of the poll, kept once.
  late final List<List<bool>> orders = Rules.orders(ash, birch);

  /// Whether a complete order lands the ask.
  bool meets(List<bool> order) {
    if (order.length != ballots || order.where((a) => a).length != ash) return false;
    switch (kind) {
      case 'ahead':
        return Rules.aheadThroughout(order);
      case 'levels':
        return Rules.levels(order) == count;
      case 'changes':
        return Rules.changesOfHands(order) == count;
      default:
        return Rules.neverBehind(order);
    }
  }

  /// The order the pointer works towards, or null when none lands it.
  late final List<bool>? aim = orders.where(meets).firstOrNull;

  /// The task, told in words for the ledger.
  String get task {
    final poll = 'count ${_word(ash)} Ash and ${_word(birch)} Birch';
    switch (kind) {
      case 'ahead':
        return '$poll in an order that keeps Ash ahead after every ballot';
      case 'levels':
        return '$poll in an order that stands level exactly ${count == 1 ? 'once' : count == 2 ? 'twice' : '${_word(count!)} times'}';
      case 'changes':
        return '$poll in an order where the lead changes hands exactly ${count == 1 ? 'once' : count == 2 ? 'twice' : '${_word(count!)} times'}';
      default:
        return '$poll in an order that never puts Ash behind, level allowed';
    }
  }

  static String _word(int n) => const ['nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight'][n];
}
