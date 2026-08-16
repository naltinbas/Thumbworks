import 'rules.dart';

/// One ask: three gates to set so the lanes meet, with a condition.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'middles': the lanes meet with every gate at a middle; 'oneMiddle':
  /// they meet with one gate a middle and no more; 'quarter': they meet
  /// with D a quarter of the way from B; 'twoSet': they meet with D at 1:2
  /// and E at 2:1; 'thirds': every gate a third of the way from its
  /// corner, the same way round, and the lanes meeting.
  final String kind;

  /// How many of the 1,331 settings land it, from the sweep.
  final int ways;

  /// The gates the pointer walks to, (d, e, f), or null.
  final (int, int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the gates land the ask, the lanes crossed for real.
  bool meets(int d, int e, int f) {
    if (!Rules.meetByCrossing(d, e, f)) return false;
    final middles = [d, e, f].where((g) => g == Rules.paces ~/ 2).length;
    switch (kind) {
      case 'middles':
        return middles == 3;
      case 'oneMiddle':
        return middles == 1;
      case 'quarter':
        return d == Rules.paces ~/ 4;
      case 'twoSet':
        return d == Rules.paces ~/ 3 && e == 2 * Rules.paces ~/ 3;
      default:
        return d == Rules.paces ~/ 3 && e == Rules.paces ~/ 3 && f == Rules.paces ~/ 3;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'middles':
        return 'set the three gates so the lanes meet, every gate at the middle of its side';
      case 'oneMiddle':
        return 'set the three gates so the lanes meet, one gate at a middle and no more';
      case 'quarter':
        return 'set the three gates so the lanes meet, the gate on BC a quarter of the way from B';
      case 'twoSet':
        return 'set the three gates so the lanes meet, the gate on BC a third of the way from B and the gate on CA two thirds from C';
      default:
        return 'set every gate a third of the way from its corner, the same way round, so the lanes meet';
    }
  }
}
