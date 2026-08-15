import 'rules.dart';

/// One ask: a village and a test to set, for how far a flag can be trusted.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.num = 0,
    this.den = 1,
    this.prevalence,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'exact': the flagged are ill num/den of the time exactly; 'under':
  /// fewer than num/den; 'atLeast': num/den or more; 'sureWithAlarm':
  /// every time, while the test still flags some of the well.
  final String kind;
  final int num;
  final int den;

  /// A prevalence the ask fixes, one in this, or null for any.
  final int? prevalence;

  /// How many of the sham's settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  int get settings => Rules.sweep((p, c, a) => true).$2;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int p, (int, int) catchRate, (int, int) alarm) {
    if (prevalence != null && p != prevalence) return false;
    final share = Rules.byChances(p, catchRate, alarm);
    switch (kind) {
      case 'exact':
        return share == (num, den);
      case 'under':
        return Rules.compare(share, (num, den)) < 0;
      case 'atLeast':
        return Rules.compare(share, (num, den)) >= 0;
      default:
        return alarm != (0, 1) && share == (1, 1);
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    final fever = prevalence == null ? '' : 'set the fever at one in ${prevalence == 1000 ? 'a thousand' : '$prevalence'} and ';
    final head = prevalence == null ? 'set the fever and the test' : '${fever}the test';
    switch (kind) {
      case 'exact':
        return '$head so a flagged villager is ill exactly ${_share()}';
      case 'under':
        return '$head so a flagged villager is ill fewer than ${_share()}';
      case 'atLeast':
        return '$head so a flagged villager is ill at least ${_share()}';
      default:
        return '$head so a flagged villager is ill every time while the test still flags some of the well';
    }
  }

  String _share() => num == 1 && den == 2
      ? 'one time in two'
      : num == 1 && den == 10
          ? 'one time in ten'
          : num == 9 && den == 10
              ? 'nine times in ten'
              : '$num in $den';
}
