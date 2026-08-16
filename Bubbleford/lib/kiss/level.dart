import 'rules.dart';

/// One ask: what the three bends are to make of the fourth.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'unit': the outer bubble's bend -1, a unit bubble round the three;
  /// 'flat': the outer bend nought, a straight line; 'wrap': both
  /// fourths whole and the outer wrapping round; 'gap': both fourths
  /// whole and the outer in the far gap; 'twin': the two fourths of one
  /// bend, which they never are.
  final String kind;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the bends [k] land the ask.
  bool meets(List<int> k) {
    if (!Rules.valid(k)) return false;
    final f = Rules.fourths(k);
    switch (kind) {
      case 'unit':
        return f != null && f.$2 == -1;
      case 'flat':
        return Rules.outerSign(k) == 0;
      case 'wrap':
        return f != null && Rules.outerSign(k) < 0;
      case 'gap':
        return f != null && Rules.outerSign(k) > 0;
      default:
        return f != null && f.$1 == f.$2;
    }
  }

  /// The setting the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  List<int>? get aim {
    for (final k in Rules.triples) {
      if (meets(k)) return k;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'unit':
        return 'set the three bends so that the outer bubble has a bend of -1, a unit bubble round the three';
      case 'flat':
        return 'set the three bends so that the outer bubble flattens to a straight line';
      case 'wrap':
        return 'set the three bends so that both fourth bends are whole and the outer bubble wraps round';
      case 'gap':
        return 'set the three bends so that both fourth bends are whole and the outer bubble sits in the far gap';
      default:
        return 'set the three bends so that the two fourth bubbles are of one bend';
    }
  }
}
