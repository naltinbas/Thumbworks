import 'rules.dart';

/// One ask: which tree to pick.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'far': a tree in sight in the tenth row; 'twice': a tree hidden
  /// behind exactly two others; 'shadow': a tree in sight hiding four;
  /// 'deep': a tree in sight in the far corner, file and row 7 or more;
  /// 'edge': a hidden tree in the first row or the first file, which
  /// there never is.
  final String kind;

  /// How many trees land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the tree [t] lands the ask.
  bool meets((int, int) t) {
    if (!Rules.inOrchard(t)) return false;
    final seen = Rules.seenByFactor(t);
    switch (kind) {
      case 'far':
        return seen && t.$2 == Rules.side;
      case 'twice':
        return !seen && Rules.between(t).length == 2;
      case 'shadow':
        return seen && Rules.hides(t).length == 4;
      case 'deep':
        return seen && t.$1 >= 7 && t.$2 >= 7;
      default:
        return !seen && (t.$1 == 1 || t.$2 == 1);
    }
  }

  /// The tree the pointer works towards, the sweep's first that lands
  /// the ask, row by row from the gate, or null.
  (int, int)? get aim {
    for (final t in Rules.trees) {
      if (meets(t)) return t;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'far':
        return 'pick a tree in sight in the tenth row';
      case 'twice':
        return 'pick a tree hidden behind exactly two others';
      case 'shadow':
        return 'pick a tree in sight that hides four others';
      case 'deep':
        return 'pick a tree in sight in the far corner, file and row seven or more';
      default:
        return 'pick a hidden tree in the first row or the first file';
    }
  }
}
