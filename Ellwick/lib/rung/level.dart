import 'rules.dart';

/// One ask: a side and diagonal to find.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'over': the miss is one over; 'under': one under; 'thousandth': the
  /// diagonal over the side within a thousandth of the true diagonal;
  /// 'record': nearer than every smaller side; 'true': the miss is
  /// nought.
  final String kind;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The rung the pointer climbs to, (side, diagonal), or null when none
  /// lands it.
  final (int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int side, int diagonal) {
    switch (kind) {
      case 'over':
        return Rules.miss(side, diagonal) == 1;
      case 'under':
        return Rules.miss(side, diagonal) == -1;
      case 'thousandth':
        return Rules.off(side, diagonal) < 0.001;
      case 'record':
        return Rules.isRecord(side, diagonal);
      default:
        return Rules.miss(side, diagonal) == 0;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'over':
        return 'set the side and the diagonal so the diagonal squared is one over twice the side squared';
      case 'under':
        return 'set the side and the diagonal so the diagonal squared is one under twice the side squared';
      case 'thousandth':
        return 'set the side and the diagonal so the diagonal over the side is within a thousandth of the true diagonal';
      case 'record':
        return 'set the side and the diagonal so the pair comes nearer the true diagonal than every smaller side does, the diagonal the nearest for its side';
      default:
        return 'set the side and the diagonal so the diagonal squared is exactly twice the side squared';
    }
  }
}
