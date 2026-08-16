import 'frac.dart';
import 'rules.dart';

/// One ask: where the three marks are to stand, and what the sliver is
/// to come to.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'seventh': the sliver a seventh of the field; 'vanish': the sliver
  /// nothing at all; 'seventieth': a seventieth; 'widest': as big as the
  /// sliver gets; 'sly': the sliver nothing while the three cuts miss
  /// one another, which never happens.
  final String kind;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The biggest share any setting leaves: 100/133, from the marks one
  /// twelfth along or eleven.
  static Frac get widest => Frac.of(100, 133);

  /// Whether the marks [m] land the ask.
  bool meets(List<int> m) {
    if (!Rules.valid(m)) return false;
    final share = Rules.shareByRouth(m);
    switch (kind) {
      case 'seventh':
        return share == Frac.of(1, 7);
      case 'vanish':
        return share == Frac.zero;
      case 'seventieth':
        return share == Frac.of(1, 70);
      case 'widest':
        return share == widest;
      default:
        return share == Frac.zero && !Rules.cutsMeet(m);
    }
  }

  /// The setting the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  List<int>? get aim {
    for (var d = Rules.least; d <= Rules.most; d++) {
      for (var e = Rules.least; e <= Rules.most; e++) {
        for (var f = Rules.least; f <= Rules.most; f++) {
          if (meets([d, e, f])) return [d, e, f];
        }
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'seventh':
        return 'set the marks so that the sliver is a seventh of the field';
      case 'vanish':
        return 'set the marks so that the sliver comes to nothing';
      case 'seventieth':
        return 'set the marks so that the sliver is a seventieth of the field';
      case 'widest':
        return 'set the marks so that the sliver is as big as it gets';
      default:
        return 'set the marks so that the sliver comes to nothing while the three cuts miss one another';
    }
  }
}
