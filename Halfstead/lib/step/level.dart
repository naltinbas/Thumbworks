import 'frac.dart';
import 'rules.dart';

/// One ask: a share and a count of steps to set, for where they leave
/// the runner.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.share,
    this.bound,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'within': the share fixed and no more than [bound] left; 'exactly':
  /// exactly [bound] left; 'wall': nothing left.
  final String kind;

  /// The share the ask fixes, as (over, under), or null.
  final (int, int)? share;

  /// The bound on what is left, as (over, under), or null.
  final (int, int)? bound;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  Frac? get shareFrac => share == null ? null : Frac.of(share!.$1, share!.$2);
  Frac? get boundFrac => bound == null ? null : Frac.of(bound!.$1, bound!.$2);

  /// Whether [n] steps of [s] land the ask.
  bool meets(Frac s, int n) {
    if (n < 1 || n > Rules.most || !Rules.shares.contains(s)) return false;
    final left = Rules.left(s, n);
    switch (kind) {
      case 'within':
        return s == shareFrac && left.compareTo(boundFrac!) <= 0;
      case 'exactly':
        return left == boundFrac;
      default:
        return left == Frac.zero;
    }
  }

  /// The setting the pointer works towards, the sweep's first, shares in
  /// their order and steps from one, or null.
  (Frac, int)? get aim {
    for (final s in Rules.shares) {
      for (var n = 1; n <= Rules.most; n++) {
        if (meets(s, n)) return (s, n);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'within':
        return 'get within ${_bound()} of the wall, covering ${Rules.tellShare(shareFrac!)} of what is left at every step';
      case 'exactly':
        return 'stop with exactly ${_bound()} of the way left';
      default:
        return 'reach the wall';
    }
  }

  String _bound() {
    final b = bound!;
    if (b == (1, 4)) return 'a quarter';
    if (b == (1, 100)) return 'a hundredth';
    if (b == (1, 1000)) return 'a thousandth';
    if (b == (1, 64)) return 'one part in sixty-four';
    return '${b.$1}/${b.$2}';
  }
}
