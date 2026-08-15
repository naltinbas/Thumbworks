import 'rules.dart';

/// One ask: a show to judge so the majority does something in particular.
class Level {
  const Level({
    required this.name,
    required this.pies,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// How many pies are entered, three or four.
  final int pies;

  /// 'ring': the majority runs in a ring through all the pies; 'points':
  /// a pie beats every other yet another has more points; 'modest': a
  /// pie beats every other and is first on no ballot.
  final String kind;

  /// How many of the profiles land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  /// The profiles there are: three ballots over the pies' rankings.
  int get settings {
    final r = Rules.rankings(pies).length;
    return r * r * r;
  }

  bool get winnable => ways > 0;

  /// Whether the three ballots land the ask.
  bool meets(List<List<int>> profile) {
    switch (kind) {
      case 'ring':
        return Rules.ring(profile, pies);
      case 'points':
        final w = Rules.condorcetWinner(profile, pies);
        if (w == null) return false;
        final pts = Rules.points(profile, pies);
        return pts.any((x) => x > pts[w]);
      default:
        final w = Rules.condorcetWinner(profile, pies);
        return w != null && !Rules.firsts(profile).contains(w);
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    final count = pies == 3 ? 'three' : 'four';
    switch (kind) {
      case 'ring':
        return 'rank the $count pies so the majority runs in a ring, each beating the next and the last the first';
      case 'points':
        return 'rank the $count pies so one beats every other head to head and another has more points';
      default:
        return 'rank the $count pies so one beats every other head to head and is first on no ballot';
    }
  }
}
